--[[
    Zen Hub — UI/Elements.lua
    by Zen Devs

    Constants, icon IDs, section helpers, and any reusable building blocks
    that don't belong to a specific tab.

    These are passed in Context.UIElements so tabs can pull them in without
    importing a separate module.
--]]

local Elements = {}

-- ── Icon asset IDs ────────────────────────────────────────────────────────
-- Replace with your own rbxassetid values if you host your own icons.
Elements.Icons = {
    Home      = "rbxassetid://10734896206",
    Farm      = "rbxassetid://10734950854",
    Sea       = "rbxassetid://10734961000",
    Player    = "rbxassetid://10734958420",
    Dragon    = "rbxassetid://10734953288",
    Dungeon   = "rbxassetid://10734955116",
    Trials    = "rbxassetid://10734959840",
    Travel    = "rbxassetid://10734963388",
    Shop      = "rbxassetid://10734961932",
    Misc      = "rbxassetid://10734957060",
    Webhook   = "rbxassetid://10734964640",
}

-- ── Window metadata ───────────────────────────────────────────────────────
Elements.WindowTitle    = "Zen Hub"
Elements.WindowSubtitle = "Blox Fruits"
Elements.Version        = "v1.0"
Elements.Credits        = "Zen Devs"

-- ── SaveFolder name ───────────────────────────────────────────────────────
Elements.SaveFolder     = "ZenHub"
Elements.SaveFile       = "BloxFruits"

-- ── Notification helper ───────────────────────────────────────────────────
-- Passed to Module.SendNotify in places that need a self-contained ref.
function Elements.Notify(title, body, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = title    or "Zen Hub",
            Text     = body     or "",
            Duration = duration or 5,
        })
    end)
end

return Elements
