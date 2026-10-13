--[[
    Zen Hub — Modules/Funcs.lua
    by Zen Devs

    Thin wrappers around Linoria element creation.
    Each wrapper:
      • Writes the default value into Settings immediately.
      • Registers a display name in Module.FunctionDisplayNames.
      • Calls Module.Functions[Key].Start / .Stop on toggle changes.
      • Calls Module.Loops[Key].Start  / .Stop on toggle changes.
      • Stores Toggle references in Module.Toggles for external .Update() calls.
      • Respects save = false opt-out.

    None of these functions depend on a specific UI backend — they delegate
    to the Section's add* methods supplied by Linoria at runtime.
--]]

local FuncsModule = {}

---Init: bind the wrapper set to a shared Context and return it.
---@param Context table  { Settings, Module, Tween? }
---@return table  Funcs
function FuncsModule.Init(Context)
    Context  = Context or {}
    local Settings = Context.Settings or (getgenv and getgenv().Settings) or _G.Settings or {}
    local Module   = Context.Module   or (getgenv and getgenv().Module)   or _G.Module   or {}
    local Tween    = Context.Tween    or (Module and Module.TweenManager)

    -- Ensure sub-tables exist so callers never have to guard.
    Module.Functions           = Module.Functions           or {}
    Module.Loops               = Module.Loops               or {}
    Module.Toggles             = Module.Toggles             or {}
    Module.FunctionDisplayNames= Module.FunctionDisplayNames or {}

    local Funcs = {}

    -- ── Toggle ─────────────────────────────────────────────────────────────
    --  Section     : Linoria section object
    --  Label       : display text
    --  Key         : Settings key AND Function key
    --  Default     : initial boolean
    --  Options     : { global, save, callback, locked, description, stop }
    function Funcs:CreateToggle(Section, Label, Key, Default, Options)
        Options = Options or {}
        Settings[Key] = Default

        Module.FunctionDisplayNames[Key] = Label

        local SaveKey = (Options.save ~= false) and Key or nil

        local toggle = Section:AddToggle(Key, {
            Text    = Label,
            Default = Default,
            Tooltip = Options.description,
        })

        toggle:OnChanged(function(Value)
            Settings[Key] = Value

            if Value then
                if Module.Functions[Key] and Module.Functions[Key].Start then
                    Module.Functions[Key].Start()
                end
                if Module.Loops[Key] and Module.Loops[Key].Start then
                    Module.Loops[Key].Start()
                end
            else
                if Module.Functions[Key] and Module.Functions[Key].Stop then
                    Module.Functions[Key].Stop()
                elseif Module.Functions[Key] then
                    Module.Functions[Key].Running = false
                end

                if Module.Loops[Key] and Module.Loops[Key].Stop then
                    Module.Loops[Key].Stop()
                elseif Module.Loops[Key] then
                    Module.Loops[Key].Running = false
                end

                if Module.ActiveFunction == Key then
                    Module.ActiveFunction = nil
                end

                if Options.stop ~= false and Tween then
                    if Tween.StopTween then Tween:StopTween() end
                    if not (Settings.AutoSharkAnchor or Settings.AutoFindLeviatan
                            or Settings.AutoSailbacktoTiki or Settings.AutoSail) then
                        if Tween.StopBoatTween then Tween:StopBoatTween() end
                    end
                end
            end

            if type(Options.callback) == "function" then
                Options.callback(Value)
            end
        end)

        if Key then
            Module.Toggles[Key] = toggle
        end

        return toggle
    end

    -- ── Dropdown ───────────────────────────────────────────────────────────
    --  Section     : Linoria section
    --  Name        : display text
    --  Key         : Settings key
    --  Default     : initial selection (string or table for multi)
    --  Items       : list of choices
    --  Config      : { global, save, callback, locked, multi }
    function Funcs:CreateDropdown(Section, Name, Key, Default, Items, Config)
        Config = Config or {}
        Settings[Key] = Default

        local SaveKey = (Config.save ~= false) and Key or nil

        local dropdown = Section:AddDropdown(Key, {
            Text    = Name,
            Values  = Items,
            Default = Default,
            Multi   = Config.multi or false,
        })

        dropdown:OnChanged(function(Value)
            Settings[Key] = Value
            if type(Config.callback) == "function" then
                Config.callback(Value)
            end
        end)

        return dropdown
    end

    -- ── Slider ─────────────────────────────────────────────────────────────
    --  Section    : Linoria section
    --  Label      : display text
    --  Key        : Settings key
    --  Min, Max   : range
    --  Default    : initial number
    --  Options    : { global, save, callback, locked, step }
    function Funcs:CreateSlider(Section, Label, Key, Min, Max, Default, Options)
        Options = Options or {}
        Settings[Key] = Default

        local SaveKey = (Options.save ~= false) and Key or nil

        local slider = Section:AddSlider(Key, {
            Text    = Label,
            Default = Default,
            Min     = Min,
            Max     = Max,
            Rounding= Options.step or 1,
        })

        slider:OnChanged(function(Value)
            Settings[Key] = Value
            if type(Options.callback) == "function" then
                Options.callback(Value)
            end
        end)

        return slider
    end

    -- ── Textbox ────────────────────────────────────────────────────────────
    --  Section   : Linoria section
    --  Label     : display text
    --  Key       : Settings key
    --  Options   : { global, save, callback, default, confirmText }
    function Funcs:CreateTextbox(Section, Label, Key, Options)
        Options = Options or {}
        Settings[Key] = Options.default or ""

        local SaveKey = (Options.save ~= false) and Key or nil

        local textbox = Section:AddInput(Key, {
            Text        = Label,
            Default     = Options.default or "",
            Placeholder = Options.placeholder or "",
            Numeric     = Options.numeric or false,
            Finished    = Options.confirmText ~= nil,
        })

        textbox:OnChanged(function(Value)
            Settings[Key] = Value
            if type(Options.callback) == "function" then
                Options.callback(Value)
            end
        end)

        return textbox
    end

    -- ── Button ────────────────────────────────────────────────────────────
    --  Section  : Linoria section
    --  Label    : button text
    --  Callback : function()
    function Funcs:CreateButton(Section, Label, Callback)
        return Section:AddButton({
            Text    = Label,
            Func    = Callback or function() end,
        })
    end

    -- ── Label ─────────────────────────────────────────────────────────────
    --  Section : Linoria section
    --  Text    : label text
    function Funcs:CreateLabel(Section, Text)
        return Section:AddLabel(Text)
    end

    return Funcs
end

-- Allow require()-style use: both FuncsModule.Init(ctx) and FuncsModule(ctx)
setmetatable(FuncsModule, {
    __call = function(self, ctx)
        return self.Init(ctx)
    end,
})

return FuncsModule
