--[[
    Zen Hub — UI/Theme.lua
    by Zen Devs

    Default Linoria theme token overrides for Zen Hub.
    Pass this table to Library:SetColorLibrary() or ThemeManager.

    All colour values are Color3 instances.
--]]

return {
    -- ── Primary accent ────────────────────────────────────────────────────
    Name     = "Zen Dark",
    Accent   = Color3.fromRGB(100, 200, 160),   -- teal-green

    -- ── Background layers ─────────────────────────────────────────────────
    Background      = Color3.fromRGB(18, 18, 22),
    Sidebar         = Color3.fromRGB(24, 24, 30),
    TabBackground   = Color3.fromRGB(28, 28, 36),
    SectionBg       = Color3.fromRGB(32, 32, 40),
    ElementBg       = Color3.fromRGB(38, 38, 48),

    -- ── Text colours ─────────────────────────────────────────────────────
    TextPrimary     = Color3.fromRGB(230, 230, 230),
    TextSecondary   = Color3.fromRGB(155, 155, 165),
    TextDisabled    = Color3.fromRGB(90,  90,  100),

    -- ── Interactive states ────────────────────────────────────────────────
    ToggleOn        = Color3.fromRGB(100, 200, 160),
    ToggleOff       = Color3.fromRGB(55,  55,  68),
    SliderFill      = Color3.fromRGB(100, 200, 160),
    SliderBg        = Color3.fromRGB(40,  40,  52),
    DropdownBg      = Color3.fromRGB(34,  34,  44),
    DropdownHover   = Color3.fromRGB(45,  45,  58),
    ButtonBg        = Color3.fromRGB(40,  40,  52),
    ButtonHover     = Color3.fromRGB(55,  55,  70),

    -- ── Borders / dividers ────────────────────────────────────────────────
    Border          = Color3.fromRGB(50,  50,  65),
    DividerColor    = Color3.fromRGB(42,  42,  55),

    -- ── Notification accent ───────────────────────────────────────────────
    NotifyBg        = Color3.fromRGB(22,  28,  28),
    NotifyAccent    = Color3.fromRGB(80, 180, 140),
}
