# Generating Eity maps

Install Python 3.10+ and `librosa==0.11.0` with `python -m pip install librosa==0.11.0`. Put the audio and a background at `maps/<title>/song.mp3` and `maps/<title>/bg.jpg`, then generate the chart. Use the same folder name in the map registry.

```sh
python tools/generate_map.py "maps/Abstract World/song.mp3" "maps/Abstract World/map.lua" --title "Abstract World" --artist "Meteor Sightseeing" --difficulty Insane --style 0 --bpm 186
```

The generator separates percussion, measures attacks across frequency bands, and uses dynamic beat tracking to find the song's pulse. It fits a stable grid when enough beats agree, then moves individual hits toward nearby audible attacks. If the automatic result is in half or double time, pass `--bpm` with the checked tempo. Hit times account for Eity's different travel distances on horizontal and vertical lanes. Repeated directional phrases give each chart a consistent pattern, and holds leave room before the next hit.

Easy emphasizes the main beat. Normal adds selected offbeats. Hard increases the approach speed and fits more frequent turns. Insane charts denser subdivisions when the audio supports them. Use `--style` to choose a starting directional pattern.

## Meteor Sightseeing set

Song Select groups all charts by difficulty from Easy to Insane and sorts titles alphabetically within each group. The shipped charts use the zero-based alphabetical position of the song folder as their style. Quiet passages thin out, optional offbeats require a nearby attack, and holds require sustained energy and a gap before the next turn.

| In-game title | Vocal | Difficulty | Tempo | Generator options |
| --- | --- | --- | --- | --- |
| Tears of Control | Asahina Kon | Easy | 99 BPM | `--style 10 --bpm 99` |
| Supreme Sign | Haramori Yoshina | Normal | 154 BPM | `--style 9` |
| Blank Paper | SATORI | Hard | 180 BPM | `--style 1 --bpm 180` |
| Abstract World | Haramori Yoshina | Insane | 186 BPM | `--style 0 --bpm 186` |

Music by Meteor Sightseeing. [Tears of Control](https://rsnsightseeing.booth.pm/items/7189010), [Supreme Sign](https://rsnsightseeing.booth.pm/en/items/6500777), [Blank Paper](https://booth.pm/en/items/5261064), [Abstract World](https://rsnsightseeing.booth.pm/items/4987667)
