#!/usr/bin/env python3
"""Build itch.io upload archives from the tracked Eity source and assets."""
import argparse
from hashlib import sha256
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
from tempfile import TemporaryDirectory
from urllib.request import urlopen
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parent
CACHE = ROOT / ".build"
DIST = ROOT / "dist"
LOVE_VERSION = "11.5"
RUNTIMES = {
    "windows": (f"love-{LOVE_VERSION}-win64.zip", "ba6e56be2685e53c817749c4a5007f51137136fe5a3ab64920508babc2e74369"),
    "linux": (f"love-{LOVE_VERSION}-x86_64.AppImage", "65a673406431eff7167a15a032bf7a2e4ba50108e091eb7b176465831f9b5e00"),
}


def runtime(platform):
    name, expected_hash = RUNTIMES[platform]
    path = CACHE / name
    if not path.exists():
        url = f"https://github.com/love2d/love/releases/download/{LOVE_VERSION}/{name}"
        with urlopen(url, timeout=60) as response:
            data = response.read()
        if sha256(data).hexdigest() != expected_hash:
            raise ValueError(f"Download failed integrity check: {name}")
        path.write_bytes(data)
    if sha256(path.read_bytes()).hexdigest() != expected_hash:
        raise ValueError(f"Invalid runtime {path}. Delete it and rerun the build.")
    return path


def archive_game(destination):
    paths = subprocess.check_output(
        ["git", "ls-files", "-z", "--", "Eity"], cwd=ROOT
    ).decode("utf-8").split("\0")
    with ZipFile(destination, "w", ZIP_DEFLATED) as archive:
        for name in filter(None, paths):
            path = ROOT / name
            if path.is_file() and path.suffix != ".dll":
                archive.write(path, path.relative_to(ROOT / "Eity").as_posix())


def zip_tree(folder, destination, executables=()):
    with ZipFile(destination, "w", ZIP_DEFLATED) as archive:
        for path in sorted(folder.rglob("*")):
            if not path.is_file():
                continue
            name = path.relative_to(folder).as_posix()
            entry = ZipInfo.from_file(path, name)
            entry.create_system = 3
            mode = 0o755 if name in executables else 0o644
            entry.external_attr = (stat.S_IFREG | mode) << 16
            entry.compress_type = ZIP_DEFLATED
            archive.writestr(entry, path.read_bytes())


def build_windows(game, folder):
    with ZipFile(runtime("windows")) as engine:
        for item in engine.namelist():
            name = Path(item).name
            if name in ("love.exe", "lovec.exe", "game.ico", "changes.txt") or not name or item.endswith("/"):
                continue
            (folder / name).write_bytes(engine.read(item))
        engine_exe = next(item for item in engine.namelist() if Path(item).name == "love.exe")
        with (folder / "Eity.exe").open("wb") as output, engine.open(engine_exe) as executable, game.open("rb") as data:
            shutil.copyfileobj(executable, output)
            shutil.copyfileobj(data, output)
    shutil.copyfile(ROOT / "Eity/discord-rpc.dll", folder / "discord-rpc.dll")


def build_linux(game, folder):
    shutil.copyfile(runtime("linux"), folder / "love.AppImage")
    shutil.copyfile(game, folder / "Eity.love")
    (folder / "Eity").write_bytes(
        b'#!/bin/sh\n'
        b'set -eu\n'
        b'cd "$(dirname "$0")"\n'
        b'exec ./love.AppImage --appimage-extract-and-run Eity.love "$@"\n'
    )
    (folder / ".itch.toml").write_bytes(
        b'[[actions]]\nname = "play"\npath = "Eity"\n'
    )


def build_web(game, folder):
    npm = shutil.which("npm.cmd" if os.name == "nt" else "npm")
    node = shutil.which("node")
    if not npm or not node:
        raise ValueError("The Web build requires Node.js and npm on PATH.")
    tool = CACHE / "web-tool"
    entry = tool / "node_modules/love.js/index.js"
    if not entry.exists():
        subprocess.run(
            [npm, "install", "--prefix", str(tool), "--no-save", "--no-audit",
             "--no-fund", "--ignore-scripts", "love.js@11.4.1"],
            cwd=ROOT, check=True,
        )
    subprocess.run(
        [node, str(entry), str(game), str(folder), "-t", "Eity", "-m", "268435456", "-c"],
        cwd=ROOT, check=True,
    )
    shutil.rmtree(folder / "theme")
    shutil.copyfile(ROOT / "tools/web.html", folder / "index.html")
    shutil.copyfile(entry.parent / "LICENSE", folder / "love.js-LICENSE.txt")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("platforms", nargs="+", choices=["all", "windows", "linux", "web"])
    args = parser.parse_args()
    targets = ["windows", "linux", "web"] if "all" in args.platforms else dict.fromkeys(args.platforms)
    DIST.mkdir(exist_ok=True)
    CACHE.mkdir(exist_ok=True)
    builders = {"windows": build_windows, "linux": build_linux, "web": build_web}
    with TemporaryDirectory(dir=CACHE) as temp:
        staging = Path(temp)
        game = staging / "Eity.love"
        archive_game(game)
        for target in targets:
            folder = staging / target
            folder.mkdir()
            builders[target](game, folder)
            shutil.copyfile(ROOT / "LICENSE", folder / "Eity-LICENSE.txt")
            executables = ("Eity", "love.AppImage") if target == "linux" else ()
            name = f"Eity-{target}.zip"
            zip_tree(folder, staging / name, executables)
            (staging / name).replace(DIST / name)
            print(f"Built dist/{name}", flush=True)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
