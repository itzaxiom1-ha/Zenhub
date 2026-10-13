--[[
    Zen Hub — Modules/Visuals.lua
    by Zen Devs

    Visual / cosmetic effect functions for Blox Fruits.
    Each exported function is self-contained and returns without side effects
    unless the player explicitly calls it.

    Exports:
        Visuals.GiveDarkBlade(player)
        Visuals.GiveCelestialArt(player)
        Visuals.GiveDivineArt(player)
        Visuals.GiveTensei(player)
        Visuals.GiveAllKamuis(player)
        Visuals.GiveFruitRain(player)
        Visuals.GiveBlackBlast(player)
        Visuals.GiveBlackNuke(player)
        Visuals.GiveRougeFruit(player)
        Visuals.SummonIsland(player, islandName)
        Visuals.RemoveEffects()
--]]

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")

local Visuals = {}

-- ── Internal: load an rbxasset model ────────────────────────────────────
local function LoadAsset(id)
    local function tryLoad()
        local prev = getthreadidentity and getthreadidentity()
        if setthreadidentity then
            pcall(setthreadidentity, 8)
        end
        local ok, result = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(id))
        end)
        if prev and setthreadidentity then
            pcall(setthreadidentity, prev)
        end
        if ok and result and #result > 0 then
            return result
        end
        return nil
    end
    return tryLoad()
end

-- ── Internal: safe notification via game's own system ──────────────────
local function GameNotify(msg)
    pcall(function()
        local notif = require(ReplicatedStorage:FindFirstChild("Notification"))
        if notif and notif.new then
            notif.new(msg):Display()
        end
    end)
end

-- ── GiveDarkBlade ────────────────────────────────────────────────────────
--  Loads a cosmetic Triple Darkblade model into ReplicatedStorage and sets
--  up the full animation + combat loop for the local player.
function Visuals.GiveDarkBlade(player)
    player = player or Players.LocalPlayer

    GameNotify("<Color=Purple>Zen Hub: Gifted you Triple Darkblade<Color=/>")

    -- Guard: only create once
    if ReplicatedStorage:FindFirstChild("ZH_TEST_SWORD") then
        ReplicatedStorage:FindFirstChild("ZH_TEST_SWORD"):Destroy()
    end

    local asset = LoadAsset(18631972861)
    local model = asset and asset[1]
    if not model then
        warn("[Zen Hub Visuals] Failed to load Darkblade asset.")
        return
    end

    model.Name   = "ZH_TEST_SWORD"
    model.Parent = ReplicatedStorage

    -- Anim IDs used by the original darkblade sequence
    local COMBO_ANIMS = {9897433972, 9897434364, 9897435270, 9897435626}

    local state = {
        comboStep  = 1,
        lastAttack = 0,
        equipped   = false,
        canM1      = true,
        m1CD       = 0.5,
        holdZ      = false,
        holdX      = false,
        idleTrack  = nil,
        currentAnim= nil,
        holdZFlag  = Instance.new("BoolValue"),
        holdXFlag  = Instance.new("BoolValue"),
    }

    local humanoid, animator

    local function refreshChar()
        local char = player.Character
        if not char then return end
        humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            animator = humanoid:FindFirstChild("Animator")
                    or Instance.new("Animator", humanoid)
        end
    end
    refreshChar()
    player.CharacterAdded:Connect(refreshChar)

    local function playIdle()
        if not state.equipped or not humanoid or not animator then return end
        if state.idleTrack and state.idleTrack.IsPlaying then return end
        if state.currentAnim and state.currentAnim.IsPlaying then
            state.currentAnim:Stop()
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://10432912847"
        state.idleTrack = animator:LoadAnimation(anim)
        state.idleTrack.Looped = true
        state.idleTrack:Play()
    end

    local function doM1()
        if not state.equipped or not state.canM1 then return end
        if tick() - state.lastAttack < state.m1CD then return end
        state.canM1    = false
        state.lastAttack = tick()
        if state.idleTrack and state.idleTrack.IsPlaying then
            state.idleTrack:Stop()
            state.idleTrack = nil
        end
        local animId = COMBO_ANIMS[state.comboStep] or COMBO_ANIMS[1]
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. animId
        local track = animator:LoadAnimation(anim)
        state.currentAnim = track
        track:Play()
        state.comboStep = (state.comboStep % #COMBO_ANIMS) + 1
        task.delay(state.m1CD, function()
            state.canM1 = true
            if state.equipped then playIdle() end
        end)
    end

    -- Tool setup
    local tool = Instance.new("Tool")
    tool.Name           = "Triple DarkBlade (ZenHub)"
    tool.RequiresHandle = false
    tool.CanBeDropped   = false

    tool.Equipped:Connect(function()
        state.equipped = true
        refreshChar()
        playIdle()
    end)
    tool.Unequipped:Connect(function()
        state.equipped = false
        if state.idleTrack then state.idleTrack:Stop() state.idleTrack = nil end
    end)
    tool.Activated:Connect(doM1)

    -- Z / X hold binds
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Z then state.holdZ = true end
        if input.KeyCode == Enum.KeyCode.X then state.holdX = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Z then state.holdZ = false end
        if input.KeyCode == Enum.KeyCode.X then state.holdX = false end
    end)

    tool.Parent = player.Backpack
end

-- ── SummonIsland ──────────────────────────────────────────────────────────
-- SummonIsland requires server-side access
-- not available in this version.
-- notifies the player and logs the attempt.
function Visuals.SummonIsland(player, islandName)
    warn("[Zen Hub Visuals] SummonIsland: not available in this version.")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "Zen Hub",
            Text     = "SummonIsland is not available in the free feature set.",
            Duration = 5,
        })
    end)
end

-- ── GiveCelestialArt / GiveDivineArt / GiveTensei / GiveAllKamuis ────────
-- These cosmetics are not available in this version.



local MISSING_MSG = "[Zen Hub Visuals] %s: not available in this version."

function Visuals.GiveCelestialArt()
    warn(MISSING_MSG:format("GiveCelestialArt"))
end

function Visuals.GiveDivineArt()
    warn(MISSING_MSG:format("GiveDivineArt"))
end

function Visuals.GiveTensei()
    warn(MISSING_MSG:format("GiveTensei"))
end

function Visuals.GiveAllKamuis()
    warn(MISSING_MSG:format("GiveAllKamuis"))
end

function Visuals.GiveFruitRain()
    warn(MISSING_MSG:format("GiveFruitRain"))
end

function Visuals.GiveBlackBlast()
    warn(MISSING_MSG:format("GiveBlackBlast"))
end

function Visuals.GiveBlackNuke()
    warn(MISSING_MSG:format("GiveBlackNuke"))
end

function Visuals.GiveRougeFruit()
    warn(MISSING_MSG:format("GiveRougeFruit"))
end

-- ── RemoveEffects ─────────────────────────────────────────────────────────
-- Removes particle / visual spam from workspace to improve performance.
function Visuals.RemoveEffects()
    pcall(function()
        local ws = game:GetService("Workspace")
        for _, desc in ipairs(ws:GetDescendants()) do
            if desc:IsA("ParticleEmitter") or desc:IsA("Trail")
            or desc:IsA("Smoke") or desc:IsA("Fire") or desc:IsA("Sparkles") then
                pcall(function() desc.Enabled = false end)
            end
            if desc:IsA("Explosion") then
                pcall(function()
                    desc.BlastPressure = 0
                    desc.BlastRadius   = 0
                end)
            end
        end
    end)
end

-- ── FPS boost ─────────────────────────────────────────────────────────────
-- Reduces visual fidelity aggressively to maximise frame rate.
function Visuals.ForceFPSBoost()
    pcall(function()
        local ws      = game:GetService("Workspace")
        local lighting= game:GetService("Lighting")

        local terrain = ws:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize     = 0
            terrain.WaterWaveSpeed    = 0
            terrain.WaterReflectance  = 0
            terrain.WaterTransparency = 0
        end

        lighting.GlobalShadows = false
        lighting.FogEnd        = 9e9
        settings().Rendering.QualityLevel = 1

        for _, d in ipairs(lighting:GetDescendants()) do
            if d:IsA("BlurEffect")           or d:IsA("SunRaysEffect")
            or d:IsA("ColorCorrectionEffect") or d:IsA("BloomEffect")
            or d:IsA("DepthOfFieldEffect") then
                d.Enabled = false
            end
        end

        for _, d in ipairs(game:GetDescendants()) do
            if d:IsA("BasePart") or d:IsA("UnionOperation")
            or d:IsA("MeshPart") or d:IsA("CornerWedgePart")
            or d:IsA("TrussPart") then
                pcall(function()
                    d.Material    = Enum.Material.Plastic
                    d.Reflectance = 0
                end)
            elseif d:IsA("Decal") then
                pcall(function() d.Transparency = 1 end)
            elseif d:IsA("ParticleEmitter") or d:IsA("Trail") then
                pcall(function() d.Lifetime = NumberRange.new(0) end)
            end
        end
    end)
end

return Visuals
