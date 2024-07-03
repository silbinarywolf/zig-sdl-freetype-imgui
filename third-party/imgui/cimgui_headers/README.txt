cimgui expects imgui to exist in this specific structure
- ./imgui/imgui.h
- ./imgui/imgui_internal.h

So we can just pull down cimgui as an external dependency, fake that structure here
