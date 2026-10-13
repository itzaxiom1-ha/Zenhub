--[[
    Zen Hub
    by Zen Devs

    Main Loader — ZenHub.lua
    Supports: Blox Fruits (994732206)
--]]

-- ── Guard ─────────────────────────────────────────────────────────────────
if getgenv and getgenv().ZenHubActive then
    return warn("[Zen Hub] Already running.")
end
if getgenv then getgenv().ZenHubActive = true end

-- ── Services ──────────────────────────────────────────────────────────────
local Players   = game:GetService("Players")
local StarterGui= game:GetService("StarterGui")
local lp        = Players.LocalPlayer

-- ── Config ────────────────────────────────────────────────────────────────
local REPO = "https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_ZENHUB_REPO/main/ZenHub/"

local LINORIA_URL    = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"
local SAVEMGR_URL    = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua"
local THEMEMGR_URL   = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua"

local GAME_MAP = {
    [2753915549] = "BloxFruits",
    [994732206]  = "BloxFruits",
}

-- ── Notify ────────────────────────────────────────────────────────────────
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title=title or "Zen Hub", Text=text or "", Duration=dur or 5,
        })
    end)
end

-- ── Fetch & execute ───────────────────────────────────────────────────────
local function Fetch(url, retries)
    retries = retries or 2
    for i = 1, retries do
        local ok, result = pcall(function()
            local src = game:HttpGet(url, true)
            if not src or #src == 0
            or src:sub(1,20):find("404")
            or src:find("404: Not Found",1,true) then
                error("empty or 404")
            end
            local chunk, err = loadstring(src)
            if not chunk then error(err) end
            return chunk()
        end)
        if ok and result ~= nil then return result end
        if i < retries then task.wait(0.3) end
    end
    return nil
end

-- ── Wait for game ready ───────────────────────────────────────────────────
local function WaitReady()
    while not (game:IsLoaded() and lp:FindFirstChild("DataLoaded")) do
        task.wait()
    end
end

-- ── Boot ──────────────────────────────────────────────────────────────────
local function Boot()
    local gameName = GAME_MAP[game.PlaceId] or GAME_MAP[game.GameId]
    if not gameName then
        warn(("[Zen Hub] Unsupported game: %d"):format(game.PlaceId))
        Notify("Zen Hub", "Game not supported.", 5)
        return
    end

    WaitReady()

    -- 1. Load Linoria
    Notify("Zen Hub", "Loading UI...", 3)
    local Library = Fetch(LINORIA_URL)
    if not Library then
        Notify("Zen Hub", "UI library failed.", 5)
        return
    end
    local SaveManager  = Fetch(SAVEMGR_URL)  or {}
    local ThemeManager = Fetch(THEMEMGR_URL) or {}

    -- 2. Load feature module (BloxFruits.lua returns its tables)
    Notify("Zen Hub", "Loading features...", 3)
    local BF = Fetch(REPO .. "Modules/BloxFruits.lua")
    if not BF or not BF.Functions then
        warn("[Zen Hub] BloxFruits module failed or returned nil.")
        Notify("Zen Hub", "Feature module failed.", 5)
        return
    end

    -- 3. Load support modules
    local Visuals = Fetch(REPO .. "Modules/Visuals.lua") or {}
    local Weebo   = Fetch(REPO .. "Modules/Weebo.lua")   or {}

    -- 4. Build Context — single shared table everything talks through
    local Context = {
        -- From BloxFruits module return
        Settings     = BF.Settings,
        Module       = {
            Functions           = BF.Functions,
            Loops               = BF.Loops,
            Toggles             = BF.Toggles,
            TweenManager        = BF.TweenManager,
            SubFunction         = BF.SubFunction,
            Scheduler           = BF.Scheduler,
            JoinAPI             = BF.JoinAPI,
            IsMultiFunction     = BF.IsMultiFunction,
            ActiveData          = BF.ActiveData,
            SendNotify          = BF.SendNotify,
            FireInvoke          = BF.FireInvoke,
            IsReady             = BF.IsReady,
            Player              = BF.Player,
            Environment         = BF.Environment,
            Runtime             = BF.Runtime,
            Performance         = BF.Performance,
            State               = BF.State,
            Remotes             = BF.Remotes,
        },
        -- Support modules
        Library      = Library,
        SaveManager  = SaveManager,
        ThemeManager = ThemeManager,
        Visuals      = Visuals,
        Weebo        = Weebo,
        Notify       = Notify,
        RepoRoot     = REPO,
        GameName     = gameName,
    }

    -- Convenience alias so BF's own SendNotify calls reach the module table
    Context.Module.SendNotify = function(_, title, text, dur, actions, id)
        return BF.SendNotify(_, title, text, dur, actions, id)
    end

    -- 5. Load Funcs (Linoria wrappers)
    local FuncsModule = Fetch(REPO .. "Modules/Funcs.lua")
    if FuncsModule then
        Context.Funcs = FuncsModule.Init(Context)
    else
        warn("[Zen Hub] MISSING: Funcs.lua")
    end

    -- 6. Load UI modules
    local UITheme    = Fetch(REPO .. "UI/Theme.lua")    or {}
    local UIElements = Fetch(REPO .. "UI/Elements.lua") or {}
    local UIMain     = Fetch(REPO .. "UI/Main.lua")
    if not UIMain then
        warn("[Zen Hub] MISSING: UI/Main.lua")
        Notify("Zen Hub", "UI/Main failed.", 5)
        return
    end
    Context.UITheme    = UITheme
    Context.UIElements = UIElements

    -- 7. Create Linoria window + tabs
    Notify("Zen Hub", "Building UI...", 3)
    local Window, Tabs = UIMain.Init(Context)
    if not Window then
        warn("[Zen Hub] Window creation failed.")
        return
    end
    Context.Window = Window
    Context.Tabs   = Tabs

    -- 8. Register all feature toggles into tabs
    local UITabs = Fetch(REPO .. "UI/Tabs.lua")
    if UITabs then
        UITabs.Init(Context, BF)
    else
        warn("[Zen Hub] MISSING: UI/Tabs.lua")
    end

    -- 9. Apply theme
    if UITheme and UITheme.Accent and Library.SetColorLibrary then
        pcall(function() Library:SetColorLibrary(UITheme) end)
    end

    -- 10. SaveManager + ThemeManager
    if SaveManager and SaveManager.SetLibrary then
        pcall(function()
            SaveManager:SetLibrary(Library)
            SaveManager:SetFolder("ZenHub")
            SaveManager:BuildConfigSection(Tabs.Misc or Tabs.Home)
            SaveManager:LoadAutoloadConfig()
        end)
    end
    if ThemeManager and ThemeManager.SetLibrary then
        pcall(function()
            ThemeManager:SetLibrary(Library)
            ThemeManager:SetFolder("ZenHub")
            ThemeManager:ApplyToTab(Tabs.Misc or Tabs.Home)
        end)
    end

    -- 11. Start Weebo heartbeat
    if Weebo and Weebo.StartHeartbeat then
        Weebo.StartHeartbeat()
    end

    Notify("Zen Hub", "Ready! by Zen Devs", 5)
    print("[Zen Hub] Fully loaded. by Zen Devs")
end

task.spawn(Boot)
