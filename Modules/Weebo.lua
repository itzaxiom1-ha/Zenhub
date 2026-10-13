--[[
    Zen Hub — Modules/Weebo.lua
    by Zen Devs

    Handles:
      1. Discord webhook logger (session stats, test pings)
      2. Finder API poster — posts job IDs to api.zenhubdev.cv
         so discord members can join rare servers instantly.

    API base: https://api.zenhubdev.cv
    All finder posts go through the API (dedup + rate limit handled server-side).
    No hardcoded discord webhook URLs in the script.
--]]

local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")

local Weebo = {}

-- ── Config ────────────────────────────────────────────────────────────────
local API_BASE = "https://api.zenhubdev.cv"
local API_KEY  = "PASTE_YOUR_API_SECRET_HERE"  -- matches .env API_SECRET

-- ── HTTP helper ───────────────────────────────────────────────────────────
local function GetRequester()
    return (syn and syn.request)
        or http_request
        or (http and http.request)
        or request
        or httprequest
        or nil
end

local function Post(url, body)
    local req = GetRequester()
    if not req then
        warn("[Zen Hub Weebo] No HTTP request function available.")
        return nil
    end
    local payload = HttpService:JSONEncode(body)
    local ok, result = pcall(req, {
        Url     = url,
        Method  = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["X-ZenHub-Key"] = API_KEY,
        },
        Body = payload,
    })
    if not ok then
        warn("[Zen Hub Weebo] HTTP error: " .. tostring(result))
        return nil
    end
    return result
end

-- ── Player info ───────────────────────────────────────────────────────────
local function GetPlayerInfo()
    local lp = Players.LocalPlayer
    return {
        username = lp and lp.Name        or "Unknown",
        display  = lp and lp.DisplayName or "Unknown",
        userId   = lp and tostring(lp.UserId) or "0",
    }
end

local function GetSea()
    local attr = game:GetService("Workspace"):GetAttribute("MAP")
    if attr == "Sea1" then return "Sea 1"
    elseif attr == "Sea2" then return "Sea 2"
    elseif attr == "Sea3" then return "Sea 3"
    else return "Unknown" end
end

-- ── Finder poster ─────────────────────────────────────────────────────────
-- eventType: "mirage" | "kitsune" | "boss" | "fruit" | "moon" | "sword"
-- extra: optional string (boss name, fruit name, etc.)
function Weebo.PostFinder(eventType, extra)
    local player = GetPlayerInfo()
    local jobId  = game.JobId

    if not jobId or jobId == "" then
        warn("[Zen Hub Weebo] No JobId available.")
        return
    end

    task.spawn(function()
        local result = Post(API_BASE .. "/finder/" .. eventType, {
            jobId    = jobId,
            userId   = player.userId,
            username = player.username,
            sea      = GetSea(),
            extra    = extra or "",
        })

        if result then
            local ok, data = pcall(HttpService.JSONDecode, HttpService, result.Body or "")
            if ok and data then
                if data.duplicate then
                    -- already posted, silent skip
                elseif data.posted then
                    print(("[Zen Hub] %s posted! Job: %s"):format(eventType, jobId))
                end
            end
        end
    end)
end

-- ── Heartbeat (keeps scanner count live on stats page) ────────────────────
local heartbeatThread
function Weebo.StartHeartbeat()
    if heartbeatThread then task.cancel(heartbeatThread) end
    local player = GetPlayerInfo()
    heartbeatThread = task.spawn(function()
        while task.wait(60) do
            pcall(function()
                Post(API_BASE .. "/finder/heartbeat", {
                    userId   = player.userId,
                    username = player.username,
                    sea      = GetSea(),
                })
            end)
        end
    end)
end

function Weebo.StopHeartbeat()
    if heartbeatThread then
        task.cancel(heartbeatThread)
        heartbeatThread = nil
    end
end

-- ── Personal webhook logger ───────────────────────────────────────────────
local COLOURS = {
    Info    = 5814783,
    Success = 3066993,
    Warning = 16776960,
    Error   = 15158332,
    Farm    = 10181046,
}

local function SafeEncode(t)
    local ok, r = pcall(HttpService.JSONEncode, HttpService, t)
    return ok and r or nil
end

function Weebo.BuildPayload(eventName, data)
    data = data or {}
    local player = GetPlayerInfo()
    local colour = COLOURS[data.colour or "Info"] or COLOURS.Info

    local description = string.format(
        "**Player:** %s (%s)\n**User ID:** %s",
        player.display, player.username, player.userId
    )
    if data.Extra and data.Extra ~= "" then
        description = description .. "\n" .. tostring(data.Extra)
    end

    local fields = {}
    if data.Stats then
        table.insert(fields, { name="Session Stats", value=tostring(data.Stats), inline=false })
    end
    if data.Field2 and data.Field2.name then
        table.insert(fields, {
            name   = tostring(data.Field2.name),
            value  = tostring(data.Field2.value or ""),
            inline = true,
        })
    end

    return SafeEncode({
        username = "Zen Hub",
        embeds   = {{
            title       = "Zen Hub — " .. tostring(eventName),
            description = description,
            color       = colour,
            fields      = fields,
            footer      = { text = "Zen Hub by Zen Devs — zenhubdev.cv" },
            timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }},
    })
end

function Weebo.PostPersonal(webhookUrl, payload)
    if not webhookUrl or webhookUrl == "" or not payload then return false end
    local req = GetRequester()
    if not req then return false end
    local ok, result = pcall(req, {
        Url     = webhookUrl,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = payload,
    })
    if not ok then return false end
    local code = result and result.StatusCode or 0
    return code >= 200 and code < 300
end

function Weebo.Log(ctx, eventName, data)
    local url = ctx and ctx.Settings and ctx.Settings.Webhook
    if not url or url == "" then return end
    local payload = Weebo.BuildPayload(eventName, data)
    if payload then
        task.spawn(function()
            Weebo.PostPersonal(url, payload)
        end)
    end
end

function Weebo.StartAutoLog(ctx, intervalSeconds)
    intervalSeconds = math.max(intervalSeconds or 300, 30)
    task.spawn(function()
        while task.wait(intervalSeconds) do
            if ctx and ctx.Settings and ctx.Settings.AutoWebhookLog then
                local rt    = ctx.Module and ctx.Module.Runtime
                local stats = rt and string.format(
                    "Mobs: %d | Bosses: %d | Levels: +%d | Beli: +%d | Frags: +%d",
                    rt.MobsKilled or 0, rt.BossesKilled or 0,
                    rt.LevelGained or 0, rt.BeliGained or 0, rt.FragmentsGained or 0
                ) or ""
                Weebo.Log(ctx, "Auto Data Log", {
                    colour = "Farm",
                    Extra  = stats ~= "" and ("**Session Stats:**\n" .. stats) or nil,
                })
            end
        end
    end)
end

return Weebo
