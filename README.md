# Zig SDL+Freetype+ImGui

*Zig Version:* **0.13.0**

This is an example Zig project for compiling SDL + Freetype + ImGui as-is on:
- Windows
- Mac
- Linux

This project utilizes Zig's built-in Dependency management to pull down SDL, Freetype, ImGui and cimgui from their respective Github repositories and just uses their C bindings.

## How to run

```sh
zig build run
```

## Dependencies

- [SDL](https://github.com/libsdl-org/SDL) - Zlib License
- [Freetype](https://github.com/freetype/freetype) - FreeType License or GPLv2
- [ImGui](https://github.com/ocornut/imgui) - MIT License
- [cimgui](https://github.com/cimgui/cimgui) - C Bindings for ImGui - MIT License
- [Lato-Regular.ttf](https://www.fontsquirrel.com/license/lato) - SIL Open Font License

## Credits

- [Mitchell H](https://github.com/mitchellh/zig-build-freetype) for their `zig-build-freetype` repository
