#!/usr/bin/env python3
"""Analyze a song and write an Eity chart. See tools/charting.md."""
import argparse
from dataclasses import dataclass
import json
from pathlib import Path

import librosa
import numpy as np
from scipy.signal import find_peaks


RATE = 22050
HOP = 220
CLOCKWISE = (448, 320, 64, 192)


@dataclass(frozen=True)
class Difficulty:
    speed: int
    spacing: float
    subdivision: float
    hold_bars: int


DIFFICULTIES = {
    "Easy": Difficulty(480, 0.45, 2.0, 3),
    "Normal": Difficulty(560, 0.26, 0.83, 2),
    "Hard": Difficulty(620, 0.17, 0.76, 2),
    "Insane": Difficulty(640, 0.145, 0.58, 2),
}


def normalize(values):
    return np.clip(values / max(float(np.quantile(values, 0.95)), 1e-7), 0, 2)


def analyze(path, bpm=None):
    signal, _ = librosa.load(path, sr=RATE, mono=True)
    duration = len(signal) / RATE
    magnitude = np.abs(librosa.stft(signal, n_fft=1024, hop_length=HOP))
    _, drums = librosa.decompose.hpss(magnitude, margin=(1, 2))
    mel = librosa.filters.mel(sr=RATE, n_fft=1024, n_mels=64, fmin=35, fmax=10500)
    drum_mel = librosa.amplitude_to_db(mel @ drums, ref=np.max, top_db=64)
    full_mel = librosa.amplitude_to_db(mel @ magnitude, ref=np.max, top_db=64)
    bands = (slice(0, 12), slice(12, 36), slice(36, 64))
    drum_flux = [normalize(np.maximum(np.diff(drum_mel[band], prepend=drum_mel[band, :1]), 0).mean(axis=0))
                 for band in bands]
    mix_flux = normalize(np.maximum(np.diff(full_mel, prepend=full_mel[:, :1]), 0).mean(axis=0))
    flux = 0.44 * drum_flux[0] + 0.26 * drum_flux[1] + 0.12 * drum_flux[2] + 0.18 * mix_flux
    loudness = librosa.feature.rms(y=signal, frame_length=1024, hop_length=HOP)[0]
    loudness /= max(float(np.quantile(loudness, 0.9)), 1e-7)
    estimated_bpm, frames = librosa.beat.beat_track(
        onset_envelope=flux, sr=RATE, hop_length=HOP, bpm=bpm, trim=False, tightness=100,
    )
    if len(frames) < 8:
        raise ValueError("Too few beats to generate a chart.")
    seconds_per_frame = HOP / RATE
    beats = frames * seconds_per_frame
    tempo = float(np.atleast_1d(estimated_bpm)[0])
    beats, tempo, grid = fit_grid(beats, tempo, bpm, flux, duration)
    peaks, _ = find_peaks(flux, distance=5, prominence=0.12)
    return duration, tempo, grid, beats, flux, loudness, peaks


def fit_grid(beats, tempo, bpm, flux, duration):
    # Fold occasional missing beats into the index, then estimate the period using the whole track.
    period = 60 / tempo
    indices = np.round((beats - beats[0]) / period).astype(int)
    keep = np.ones(len(beats), dtype=bool)
    for _ in range(3):
        if bpm is None:
            period, phase = np.polyfit(indices[keep], beats[keep], 1)
        else:
            phase = np.median(beats[keep] - indices[keep] * period)
        residual = beats - (phase + indices * period)
        keep = np.abs(residual) < min(0.095, period * 0.20)
        if np.count_nonzero(keep) < len(beats) * 0.55:
            return beats, tempo, "tracked"
        indices = np.round((beats - phase) / period).astype(int)
    # A small phase search prioritizes the master transients over frame-quantized tracker output.
    steps = np.arange(-0.045, 0.046, 0.005)
    best_phase = max(
        (phase + step for step in steps),
        key=lambda candidate: np.interp((candidate + indices[keep] * period) * RATE / HOP,
                                        np.arange(len(flux)), flux).sum(),
    )
    start = np.ceil(-best_phase / period)
    stop = np.floor((duration - best_phase) / period)
    return best_phase + np.arange(start, stop + 1) * period, 60 / period, "fixed"


def events_for_chart(beats, flux, loudness, peaks, duration, difficulty):
    frame_times = np.arange(len(flux)) * (HOP / RATE)
    local_activity = np.interp(beats, frame_times, loudness)
    accents = np.interp(beats, frame_times, flux)
    bar_offset = int(np.argmax([np.mean(accents[i::4]) for i in range(4)]))
    peak_times = frame_times[peaks]
    minimum_time = 396 / difficulty.speed + 0.05
    candidates = []

    def add(when, index, fraction, period, mandatory):
        if when < minimum_time or when > duration - 0.16:
            return
        center = int(round(when * RATE / HOP))
        if max(loudness[max(0, center - 9):center + 12], default=0) < 0.075:
            return
        tolerance = min(0.055, period * 0.13) if fraction == 0 else min(0.040, period * 0.12)
        nearby = np.flatnonzero(np.abs(peak_times - when) <= tolerance)
        if len(nearby):
            closest = max(nearby, key=lambda i: flux[peaks[i]] - 5 * abs(peak_times[i] - when))
            frame = peaks[closest]
            strength = flux[frame]
            # Refine the peak to its steep leading edge, keeping the time close to the grid.
            while frame > max(0, peaks[closest] - 3) and flux[frame - 1] > strength * 0.48:
                frame -= 1
            when = frame_times[frame]
        else:
            strength = flux[min(center, len(flux) - 1)]
        if minimum_time <= when <= duration - 0.16 and (mandatory or strength >= difficulty.subdivision):
            candidates.append((when, index, fraction, period, strength))

    for index, beat in enumerate(beats[:-1]):
        period = beats[index + 1] - beat
        pulse = index - bar_offset
        quiet = local_activity[index] < 0.40
        if difficulty.subdivision > 1 and (quiet or period < 0.44):
            if pulse % 2:
                continue
        if difficulty.subdivision <= 1 and quiet and pulse % 2 and accents[index] < 0.34:
            continue
        add(beat, pulse, 0, period, True)
        if difficulty.subdivision <= 1 and not quiet:
            if pulse > 3 and (difficulty.subdivision < 0.7 or pulse % 4 in (1, 3)):
                add(beat + period / 2, pulse, 0.5, period, False)

    # Prefer the beat when a snapped subdivision crowds it. There must be time to turn.
    selected = []
    for event in candidates:
        if selected and event[0] - selected[-1][0] < difficulty.spacing:
            fits_after_skip = len(selected) == 1 or event[0] - selected[-2][0] >= difficulty.spacing
            if event[2] == 0 and selected[-1][2] != 0 and fits_after_skip:
                selected.pop()
            else:
                continue
        if not selected or event[0] - selected[-1][0] >= difficulty.spacing:
            selected.append(event)
    return selected


def notes_for_chart(events, difficulty, style):
    # The patterns are expressed as positions around the four gameplay directions.
    motifs = (
        (0, 1, 1, 2, 2, 3, 3, 0),
        (0, 0, 3, 2, 2, 1, 0, 3),
        (0, 1, 2, 1, 0, 3, 2, 3),
        (0, 3, 3, 0, 1, 2, 1, 0),
    )
    notes = []
    previous_lane, previous_time = None, -np.inf
    last_hold_bar = -8
    for index, (when, beat, fraction, period, strength) in enumerate(events):
        bar, step = divmod(beat, 4)
        phrase = bar // 2
        pattern = motifs[(style + phrase // 2) % len(motifs)]
        position = step + 4 * (bar % 2)
        lane = (pattern[position] + style + phrase // 4) % 4
        if fraction:
            lane = (lane + (1 if phrase % 2 == 0 else -1)) % 4
        if previous_lane is not None and (lane - previous_lane) % 4 == 2 and when - previous_time < 0.34:
            lane = (previous_lane + (1 if phrase % 2 == 0 else -1)) % 4

        # Vertical notes travel 415.8 px; horizontal notes travel 396 px.
        # Equal approach times preserve spawn order and correct timing at each speed mod.
        speed = difficulty.speed * (105 if lane % 2 == 0 else 100) // 100
        following = events[index + 1][0] if index + 1 < len(events) else when
        hold = min(period * 0.72, following - when - 0.20)
        length = 0
        if fraction == 0 and step in (0, 2) and strength > 0.51 and hold >= 0.22 and bar - last_hold_bar >= difficulty.hold_bars:
            length = round(hold * speed)
            last_hold_bar = bar
        stamp = round(1000 * (when + 0.4 - 396 / difficulty.speed))
        notes.append((1, CLOCKWISE[lane], speed, length, stamp))
        previous_lane, previous_time = lane, when
    return notes


def write_map(output, title, artist, difficulty, duration, tempo, grid, notes):
    folder = output.parent.name
    entries = (
        ("Title", title), ("Porter", artist), ("Difficult", difficulty),
        ("Length", int(duration)), ("Song", f"maps/{folder}/song.mp3"),
        ("Background", f"maps/{folder}/bg.jpg"),
    )
    with output.open("w", encoding="utf-8", newline="\n") as file:
        file.write(f"-- Generated by tools/generate_map.py ({tempo:.2f} BPM, {grid} beat grid).\nlocal map = {{}}\n\n")
        for key, value in entries:
            file.write(f"function map.get{key}() return {json.dumps(value, ensure_ascii=False)} end\n")
        file.write("\nlocal notes = {\n")
        for note in notes:
            file.write("  {" + ", ".join(map(str, note)) + "},\n")
        file.write("}\n\nfunction map.getNotes() return notes end\n\nreturn map\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("audio", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--title", required=True)
    parser.add_argument("--artist", required=True)
    parser.add_argument("--difficulty", choices=DIFFICULTIES, required=True)
    parser.add_argument("--style", type=int, default=0, help="starting lane-pattern index")
    parser.add_argument("--bpm", type=float, help="known tempo or correction for half/double-time tracking")
    args = parser.parse_args()
    difficulty = DIFFICULTIES[args.difficulty]
    duration, tempo, grid, beats, flux, loudness, peaks = analyze(args.audio, args.bpm)
    events = events_for_chart(beats, flux, loudness, peaks, duration, difficulty)
    notes = notes_for_chart(events, difficulty, args.style)
    if not notes:
        parser.error("analysis produced an empty chart")
    write_map(args.output, args.title, args.artist, args.difficulty, duration, tempo, grid, notes)
    print(f"{args.title}: {tempo:.2f} BPM ({grid}), {len(notes)} notes, "
          f"{sum(bool(note[3]) for note in notes)} holds, {len(notes) * 60 / duration:.0f} notes/min")


if __name__ == "__main__":
    main()
