const std = @import("std");
const builtin = @import("builtin");
const sdl = @import("sdl");
const imgui = @import("imgui");

const log = std.log.default;
const assert = std.debug.assert;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    _ = allocator;

    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        log.err("unable to initialize SDL: {s}", .{sdl.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer sdl.SDL_Quit();

    // TODO: auto-detect screen working on and popup there
    const window_x = sdl.SDL_WINDOWPOS_CENTERED_DISPLAY(0);
    const window_y = sdl.SDL_WINDOWPOS_CENTERED_DISPLAY(0);

    const window = sdl.SDL_CreateWindow(
        "Zig SDL + Freetype + ImGui",
        window_x,
        window_y,
        640,
        480,
        sdl.SDL_WINDOW_ALWAYS_ON_TOP | sdl.SDL_WINDOW_RESIZABLE, // sdl.SDL_WINDOW_HIDDEN,
    ) orelse {
        log.err("unable to create window: {s}", .{sdl.SDL_GetError()});
        return error.SDLWindowInitializationFailed;
    };
    defer sdl.SDL_DestroyWindow(window);

    const renderer: *sdl.SDL_Renderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_SOFTWARE) orelse {
        log.err("unable to create renderer: {s}", .{sdl.SDL_GetError()});
        return error.SDLRendererInitializationFailed;
    };
    defer sdl.SDL_DestroyRenderer(renderer);

    const font_data = @embedFile("fonts/Lato-Regular.ttf");
    const font_atlas: *imgui.ImFontAtlas = imgui.ImFontAtlas_ImFontAtlas();
    _ = imgui.ImFontAtlas_AddFontFromMemoryTTF(
        font_atlas,
        @constCast(@ptrCast(font_data[0..].ptr)),
        font_data.len,
        32,
        null,
        null,
    );
    // defer imgui.ImFontAtlas_destroy(font_atlas); // Segmentation Fault: IM_FREE(font_cfg.FontData), due to font not being owned by IMGUI allocators

    // Setup ImGui
    const ctx = imgui.igCreateContext(font_atlas);
    defer imgui.igDestroyContext(ctx);

    _ = imgui.ImGui_ImplSDL2_InitForSDLRenderer(@ptrCast(window), @ptrCast(renderer));
    defer imgui.ImGui_ImplSDL2_Shutdown();

    _ = imgui.ImGui_ImplSDLRenderer2_Init(@ptrCast(renderer));
    defer imgui.ImGui_ImplSDLRenderer2_Shutdown();

    var has_quit = false;
    while (!has_quit) {
        imgui.ImGui_ImplSDLRenderer2_NewFrame();
        imgui.ImGui_ImplSDL2_NewFrame();
        imgui.igNewFrame();

        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event) != 0) {
            _ = imgui.ImGui_ImplSDL2_ProcessEvent(@ptrCast(&event));
            switch (event.type) {
                sdl.SDL_QUIT => {
                    has_quit = true;
                },
                else => {},
            }
        }

        _ = sdl.SDL_SetRenderDrawColor(renderer, 0, 0, 255, 0);
        _ = sdl.SDL_RenderClear(renderer);

        // ImGui
        {
            // Setup IMGUI.begin window to cover full window / screen
            const viewport = imgui.igGetMainViewport()[0];
            var viewport_pos = viewport.Pos;
            viewport_pos.x -= 3;
            imgui.igSetNextWindowPos(viewport_pos, 0, .{});
            var viewport_size = viewport.Size;
            viewport_size.x += 4;
            imgui.igSetNextWindowSize(viewport_size, 0);
            _ = imgui.igBegin("mainwindow", null, imgui.ImGuiWindowFlags_MenuBar | imgui.ImGuiWindowFlags_NoTitleBar |
                imgui.ImGuiWindowFlags_NoDecoration | imgui.ImGuiWindowFlags_NoResize | imgui.ImGuiWindowFlags_NoBackground);
            defer imgui.igEnd();

            // Show full demo
            imgui.igShowDemoWindow(null);

            {
                if (imgui.igBeginMenuBar()) {
                    defer imgui.igEndMenuBar();
                    if (imgui.igBeginMenu("File", true)) {
                        defer imgui.igEndMenu();
                        if (imgui.igMenuItem_Bool("Open..", "Ctrl+O", false, true)) {}
                        if (imgui.igMenuItem_Bool("Save", "Ctrl+S", false, true)) {}
                        if (imgui.igMenuItem_Bool("Close", "Ctrl+W", false, true)) {}
                    }
                }

                imgui.igText("Hello World!");
                // imgui.igSliderFloat("float", &f, 0.0f, 1.0f, "%.3f", 0);
                // imgui.igText("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / io->Framerate, io->Framerate);
            }
        }

        imgui.igRender();
        imgui.ImGui_ImplSDLRenderer2_RenderDrawData(@ptrCast(imgui.igGetDrawData()), @ptrCast(renderer));
        sdl.SDL_RenderPresent(@ptrCast(renderer));
    }
}
