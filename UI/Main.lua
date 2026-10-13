--[[
    Zen Hub — UI/Main.lua
    by Zen Devs

    Creates the Linoria window and tab skeleton.
    Returns: Window, Tabs

    Nothing in this file registers feature toggles — that is all in UI/Tabs.lua.
    This file is intentionally thin; its only job is to build the chrome.
--]]

local Main = {}

function Main.Init(Context)
    local Library      = Context.Library
    local ThemeManager = Context.ThemeManager
    local SaveManager  = Context.SaveManager
    local Elements     = Context.UIElements or {}

    if not Library then
        error("[Zen Hub UI/Main] Library is nil — cannot build window.")
    end

    -- ── Create window ─────────────────────────────────────────────────────
    local Window = Library:CreateWindow({
        Title            = "Zen Hub",
        Center           = true,
        AutoShow         = true,
        TabPadding       = 8,
        MenuFadeTime     = 0.2,
    })

    -- ── Tabs ──────────────────────────────────────────────────────────────
    local Tabs = {
        Home    = Window:AddTab("Home"),
        Farm    = Window:AddTab("Farm"),
        Sea     = Window:AddTab("Sea Events"),
        Player  = Window:AddTab("Player"),
        Dragon  = Window:AddTab("Dragon"),
        Dungeon = Window:AddTab("Dungeon"),
        Trials  = Window:AddTab("Trials"),
        Travel  = Window:AddTab("Travel"),
        Shop    = Window:AddTab("Shop"),
        Misc    = Window:AddTab("Misc"),
        Webhook = Window:AddTab("Webhook"),
    }

    -- Store on Context so Tabs.lua and SaveManager can access them
    Context.Window = Window
    Context.Tabs   = Tabs

    -- ── Keybind to toggle visibility ──────────────────────────────────────
    -- Linoria default: RightShift toggles the window.
    -- You can change this after the library loads:
    --   Library.ToggleKeybind = Enum.KeyCode.RightControl

    return Window, Tabs
end

return Main
