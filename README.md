# Eity

Eity is a directional rhythm game. Turn to catch notes as they converge from four directions.

[Download prior releases](https://github.com/TheJeme/Eity/releases) · [itch.io artwork and page copy](promo/itch-page.md)

![Eity gameplay](promo/gameplay.png)

## Build

Install Python 3.9+ and Git. The Web target also uses Node.js and npm. From the repository root, choose one platform, several platforms, or all three.

```sh
python build.py web
python build.py windows linux
python build.py all
```

Use `python3` if that is how Python is installed. First builds download the pinned runtimes and cache them under `.build/`. The builds read the current working copies of tracked game files. Add new game files to Git before building.

| Target | Upload file | Local launch |
| --- | --- | --- |
| Windows x64 | `dist/Eity-windows.zip` | Extract the archive and run `Eity.exe`. |
| Linux x86-64 | `dist/Eity-linux.zip` | Extract the archive and run `./Eity`. The launcher extracts the bundled AppImage at runtime and works without FUSE. |
| Browser | `dist/Eity-web.zip` | Extract the archive, serve that directory with `python -m http.server 8000`, and open [localhost:8000](http://localhost:8000). |

For local development, run `love Eity` with [LÖVE 11.5](https://github.com/love2d/love/releases/tag/11.5).

## Upload to itch.io

Create an HTML project. Upload the Web ZIP intact and mark it as playable in the browser. A 16:9 embed such as 960 × 540 matches the game viewport. Enable mobile browser play for touch access. Upload the Windows and Linux ZIPs as downloads and select their platform flags. The browser build uses the non-threaded [love.js compatibility runtime](https://github.com/Davidobot/love.js#notes) for standard itch.io embeds. [itch.io HTML5 upload guide](https://itch.io/docs/creators/html5)

## Controls

| Input | During a song | Song selection |
| --- | --- | --- |
| Keyboard | Arrow keys or WASD to face a direction. Esc pauses and R restarts. | Arrow keys move through songs. Enter plays and Esc goes back. |
| Gamepad | D-pad, either stick, or the face buttons to face a direction. Start pauses. | From the title screen, press the top face button to open the song list. Move with the D-pad or a stick. Bottom face button plays, left face button picks a random song, and right face button goes back. |
| Touch | Tap relative to the center to face that direction. Tap the center diamond to pause. | Swipe the list to scroll. Tap a song to select it and tap Play to start. |

Mapped gamepads use SDL's standard layout. Controllers without a mapping use the first two axes, the hat, and the common raw button positions. Actual raw button positions depend on the controller.

## Charts

[Generate beat maps and see the Meteor Sightseeing track credits](tools/charting.md).

## License

[MIT](LICENSE)
