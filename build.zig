const std = @import("std");
const builtin = @import("builtin");
const wii = @import("zig-wii-sdk");
// const rm2k_plugin = @import("plugins/rm2k/build.zig");

const app_name = "Zig-SDL-Freetype-ImGui";
const recommended_zig_version = "0.13.0";

pub fn build(b: *std.Build) !void {
    switch (comptime builtin.zig_version.order(std.SemanticVersion.parse(recommended_zig_version) catch unreachable)) {
        .eq => {},
        .lt => {
            @compileError("The minimum version of Zig required to compile " ++ app_name ++ " is " ++ recommended_zig_version ++ ", found " ++ @import("builtin").zig_version_string ++ ".");
        },
        .gt => {
            const colors = std.io.getStdErr().supportsAnsiEscapeCodes();
            std.debug.print(
                "{s}WARNING:\n" ++ app_name ++ " recommends Zig version '{s}', but found '{s}', build may fail...{s}\n\n\n",
                .{
                    if (colors) "\x1b[1;33m" else "",
                    recommended_zig_version,
                    builtin.zig_version_string,
                    if (colors) "\x1b[0m" else "",
                },
            );
        },
    }

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // const os_tag = target.result.os.tag;

    // Build
    var exe: *std.Build.Step.Compile = b.addExecutable(.{
        .name = "zig-sdl-freetype-imgui",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        // NOTE(jae): 2024-05-12
        // Testing with the Zig x86 compiler
        // .use_llvm = false,
        // .use_lld = true,
    });

    // add sdl
    const sdl_module = blk: {
        const sdl_dep = b.dependency("sdl", .{
            .optimize = .ReleaseFast,
            .target = target,
        });
        const sdl_lib = sdl_dep.artifact("sdl");
        exe.linkLibrary(sdl_lib);
        // NOTE(jae): 2024-07-02
        // Old logic that existed in: https://github.com/andrewrk/sdl-zig-demo
        // if (target.query.isNativeOs() and target.result.os.tag == .linux) {
        //     // The SDL package doesn't work for Linux yet, so we rely on system
        //     // packages for now.
        //     exe.linkSystemLibrary("SDL2");
        //     exe.linkLibC();
        // } else {
        //     exe.linkLibrary(sdl_lib);
        // }

        const sdl_module = sdl_dep.module("sdl");
        exe.root_module.addImport("sdl", sdl_module);
        break :blk sdl_module;
    };

    // add tray
    // {
    //     const tray_dep = b.dependency("tray", .{
    //         .optimize = .ReleaseFast,
    //         .target = target,
    //     });
    //     exe.root_module.addImport("tray", tray_dep.module("tray"));
    // }

    // add freetype
    const freetype_lib = blk: {
        var freetype_dep = b.dependency("freetype", .{
            .target = target,
            .optimize = .ReleaseFast,
        });
        const freetype_lib = freetype_dep.artifact("freetype");
        exe.root_module.linkLibrary(freetype_lib);
        exe.root_module.addImport("freetype", freetype_dep.module("freetype"));
        break :blk freetype_lib;
    };

    // add imgui
    {
        const imgui_enable_freetype = true;
        var imgui_dep = b.dependency("imgui", .{
            .target = target,
            .optimize = .ReleaseFast,
            .enable_freetype = imgui_enable_freetype,
        });
        const imgui_lib = imgui_dep.artifact("imgui");
        exe.root_module.linkLibrary(imgui_lib);
        exe.root_module.addImport("imgui", imgui_dep.module("imgui"));

        // Add <ft2build.h> to ImGui so it can compile with Freetype support
        if (imgui_enable_freetype) {
            for (freetype_lib.root_module.include_dirs.items) |freetype_include_dir| {
                switch (freetype_include_dir) {
                    .path => |p| imgui_lib.addIncludePath(p),
                    else => {}, // std.debug.panic("unhandled path from Freeytpe: {s}", .{@tagName(freetype_include_dir)}),
                }
            }
        }
        // Add <SDL.h> to ImGui so it can compile with Freetype support
        for (sdl_module.include_dirs.items) |sdl_include_dir| {
            switch (sdl_include_dir) {
                .path => |p| imgui_lib.addIncludePath(p),
                else => {}, // std.debug.panic("unhandled path from SDL: {s}", .{@tagName(sdl_include_dir)}),
            }
        }
    }

    b.installArtifact(exe);

    const run = b.step("run", "Run the application");
    const run_cmd = b.addRunArtifact(exe);
    run.dependOn(&run_cmd.step);
}
