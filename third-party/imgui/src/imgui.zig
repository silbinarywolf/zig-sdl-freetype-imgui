pub usingnamespace @cImport({
    @cDefine("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "1");
    @cInclude("cimgui.h");
});
// NOTE(jae): 2024-07-02
// Seperated imports as ZLS (0.14.0-dev.19+43995dd) can't find "imgui_impl_sdl2.h" for some reason and it breaks autocomplete.
// At least this way only barely used backend functions don't have autocomplete
pub usingnamespace @cImport({
    @cDefine("IMGUI_IMPL_API", ""); // fix "{this-folder}/../backends/*.h"
    @cDefine("bool", "int"); // unknown type name 'bool'
    @cInclude("imgui_impl_sdl2.h");
    @cInclude("imgui_impl_sdlrenderer2.h");
});
