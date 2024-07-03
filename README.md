# Zig SDL+Freetype+ImGui

![Continuous integration](https://github.com/silbinarywolf/zig-sdl-freetype-imgui/actions/workflows/ci.yml/badge.svg)

This is an example Zig project for compiling SDL + Freetype + ImGui as-is on:
- Windows
- Mac
- Linux

This project utilizes Zig's built-in Dependency management to pull down SDL, Freetype, ImGui and cimgui from their respective Github repositories and just uses their C bindings.

## Requirements

* [Zig 0.13.x](https://ziglang.org/download/#release-0.13.0)

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
