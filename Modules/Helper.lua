--[[
    Zen Hub — Modules/Helper.lua
    by Zen Devs

    Protects PlayerGui from game-side Destroy/Remove/ClearAllChildren calls
    that could close the hub overlay.  No remote calls, no external deps.
--]]

local Players  = game:GetService("Players")
local plr      = Players.LocalPlayer
local PlayerGui= plr:WaitForChild("PlayerGui")

local BLOCKED = { Destroy = true, Remove = true, ClearAllChildren = true }

-- hookmetamethod is only available in certain executors.
-- If it is not present, the guard simply does nothing (safe fallback).
if not (hookmetamethod and newcclosure and checkcaller and getnamecallmethod) then
    task.defer(function()
        warn("[Zen Hub] Helper: hookmetamethod not available — PlayerGui guard skipped.")
    end)
    return
end

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if checkcaller() then
        return OldNamecall(self, ...)
    end

    if typeof(self) == "Instance" and self == PlayerGui and BLOCKED[method] then
        task.defer(function()
            warn("[Zen Hub Guard] Blocked '" .. method .. "' on PlayerGui.")
        end)
        return nil
    end

    return OldNamecall(self, ...)
end))

task.defer(function()
    print("[Zen Hub] PlayerGui protection active.")
end)
