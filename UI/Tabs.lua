--[[
    Zen Hub — UI/Tabs.lua
    by Zen Devs

    Registers every feature into Linoria using the EXACT original
    Settings keys from the original Blox Fruits implementation.

    How it works:
      Linoria toggles write to Settings[KEY].
      Feature loops run in BloxFruits.lua and check
      Settings[KEY] every 0.25s — no manual Start()/Stop() needed.
--]]

local Tabs = {}

function Tabs.Init(Context, BF)
    local Settings  = Context.Settings      -- this IS the original tbl
    local Library   = Context.Library
    local TabMap    = Context.Tabs
    local ActiveD   = BF and BF.ActiveData or {}
    local Visuals   = Context.Visuals or {}
    local Weebo     = Context.Weebo   or {}
    local FireInvoke= BF and BF.FireInvoke or function() end

    -- ── Helpers ───────────────────────────────────────────────────────────
    local function L(tab, label, fn)
        local ok, err = pcall(function()
            local box = tab:AddLeftGroupbox(label)
            fn(box)
        end)
        if not ok then warn(("[ZH Tabs] L '%s': %s"):format(label,tostring(err))) end
    end
    local function R(tab, label, fn)
        local ok, err = pcall(function()
            local box = tab:AddRightGroupbox(label)
            fn(box)
        end)
        if not ok then warn(("[ZH Tabs] R '%s': %s"):format(label,tostring(err))) end
    end

    -- Core element creators — just write to Settings[key], fn28 does the rest
    local function Tog(box, label, key, default, desc)
        Settings[key] = Settings[key] ~= nil and Settings[key] or (default or false)
        local t = box:AddToggle(key, { Text=label, Default=Settings[key], Tooltip=desc })
        t:OnChanged(function(v) Settings[key]=v end)
        return t
    end
    local function Drp(box, label, key, default, list, multi)
        Settings[key] = Settings[key] ~= nil and Settings[key] or default
        local d = box:AddDropdown(key, { Text=label, Values=list or {}, Default=Settings[key], Multi=multi or false })
        d:OnChanged(function(v) Settings[key]=v end)
        return d
    end
    local function Sld(box, label, key, min, max, default, step)
        Settings[key] = Settings[key] ~= nil and Settings[key] or default
        local s = box:AddSlider(key, { Text=label, Min=min, Max=max, Default=Settings[key], Rounding=step or 1 })
        s:OnChanged(function(v) Settings[key]=v end)
        return s
    end
    local function Txt(box, label, key, placeholder, cb)
        Settings[key] = Settings[key] or ""
        local t = box:AddInput(key, { Text=label, Default=Settings[key], Placeholder=placeholder or "" })
        t:OnChanged(function(v) Settings[key]=v; if cb then cb(v) end end)
        return t
    end
    local function Btn(box, label, fn)
        return box:AddButton({ Text=label, Func=fn or function() end })
    end
    local function Lbl(box, text)
        return box:AddLabel(text)
    end

    -- ══════════════════════════════════════════════════════════════════════
    -- HOME (Farm)
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Home, "Main Farm", function(box)
        Drp(box,"Weapon","SelectWeapon","Melee",{"Melee","Sword","Blox Fruit","Gun"})
        Drp(box,"Farm Method","FarmMode","Quest",{"Quest","No Quest","Nearest"})
        Drp(box,"Quest Farm Mode","QuestFarmMode","Double Quest",{"Single Quest","Double Quest","Triple Quest"})
        Sld(box,"Nearest Distance","checknearestdist",1000,5000,1500)
        Tog(box,"Auto Farm","AutoFarm",false,"Farms mobs matching your current level quest.")
        Tog(box,"Take Quest","AcceptQuests",false,"Accept quest for mob farming")
        Tog(box,"Auto Bones","AutoFarmBones",false)
        Tog(box,"Enable Mastery","MasteryFarm",false)
        Sld(box,"Health Mob %","HealthMob",15,100,25)
        Tog(box,"Auto Random Surprise","Auto_Random_Surprise",false)
        Tog(box,"Auto Pray","AutoPray",false)
        Tog(box,"Auto Try Luck","AutoTryLuck",false)
    end)
    R(TabMap.Home, "Boss / Special", function(box)
        Tog(box,"Auto Katakuri (Cake Prince)","AutoFarmPrince",false)
        Tog(box,"Ignore Katakuri","IgnoreCakePrince",false)
        Tog(box,"Auto Dough King","AutoDoughKing",false)
        Tog(box,"Ignore Dough King Item","IgnoreDoughChaliceFarm",false)
        Drp(box,"Select Material","SelectMaterial",
            ActiveD.Materials and ActiveD.Materials[1] or "Leather + Scrap Metal",
            ActiveD.Materials or {})
        Tog(box,"Auto Farm Material","AutoMaterial",false)
        Tog(box,"Auto Farm Boss","AutoFarmBoss",false)
        Drp(box,"Select Boss","SelectBoss",nil,ActiveD.BossNames or {})
        Tog(box,"Auto Kill All Bosses","AutoKillAllBosses",false)
        Tog(box,"Get Boss Quest","GetBossQuest",false,"Takes the boss quest before attacking")
    end)
    L(TabMap.Home, "Farm Settings", function(box)
        Sld(box,"Tweening Speed","TweenSpeed",10,250,250)
        Sld(box,"Farm Distance","PosY",0,30,18)
        Sld(box,"Bring Radius","BringMonsterRadius",150,400,350)
        Drp(box,"Pos Method","PosMethod","Above",{"Above","Orbit"})
        Tog(box,"Start Bring","BringMonster",true)
        Drp(box,"Attack Method","FastSettings","Fast Attack",{"Fast Attack","Legit Attack"})
        Sld(box,"Fast Attack Delay","FastAttackDelay",0,1,0)
        Tog(box,"Fast Attack","AutoAttack",true)
        Tog(box,"Zen Attack","ZenHubAttack",false)
        Tog(box,"Auto Attack Gun","AutoAttackGun",true)
        Sld(box,"Gun Shoot Amount","ShootAmount",1,10,1)
        Tog(box,"Remove Fast Attack Animation","RemoveAnimationFast",true)
        Tog(box,"Attack Mobs","attackmobs",true)
        Tog(box,"Attack Players","attackplayers",true)
        Tog(box,"Auto Observation Haki","AutoActivateObservationHaki",false)
        Tog(box,"Auto Set Spawn Point","AutoSetSpawnPoint",false)
        Tog(box,"Bypass Get Quest","BypassGetQuest",false)
        Drp(box,"Select Team","TeamSelectLoad","Pirates",{"Pirates","Marines"})
        Tog(box,"Auto Load Script on Load","AutoLoadScriptonLoad",false,"Works on higher unc executors")
        Tog(box,"Walk in Water","Water",true)
        Tog(box,"Auto Hop when 30mins","AutoHopwhen30mins",false)
        Tog(box,"Hop When Admin","HopWhenAdmin",true)
        Tog(box,"Anti AFK","AntiAFK",true)
        Btn(box,"Remove Effects",function() if Visuals.RemoveEffects then Visuals.RemoveEffects() end end)
    end)
    R(TabMap.Home, "Skills", function(box)
        Drp(box,"Select Skills","SelectSkills","Blox Fruit",{"Blox Fruit","Melee","Sword","Gun"},true)
        Drp(box,"Blox Fruit Keys","BloxFruitKeys","Z",{"Z","X","C","V","F"},true)
        Drp(box,"Melee Keys","MeleeKeys","Z",{"Z","X","C"},true)
        Drp(box,"Sword Keys","SwordKeys","Z",{"Z","X"},true)
        Drp(box,"Gun Keys","GunKeys","Z",{"Z","X"},true)
        Tog(box,"Auto Use Skills","AutoSkills",false)
        Sld(box,"Z Hold Time","HoldTime_Z",0,5,0)
        Sld(box,"X Hold Time","HoldTime_X",0,5,0)
        Sld(box,"C Hold Time","HoldTime_C",0,5,0)
        Sld(box,"V Hold Time","HoldTime_V",0,5,0)
        Sld(box,"F Hold Time","HoldTime_F",0,5,0)
        Sld(box,"Blox Fruit Skill Delay","BloxFruitDelay",0,5,0)
        Sld(box,"Melee Skill Delay","MeleeDelay",0,5,0)
        Sld(box,"Sword Skill Delay","SwordDelay",0,5,0)
        Sld(box,"Gun Skill Delay","GunDelay",0,5,0)
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- FARM (Sub Farm)
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Farm, "World Farm", function(box)
        Tog(box,"Auto Second Sea Quest","AutoSecondSea",false)
        Tog(box,"Auto Third Sea Quest","AutoThirdSea",false)
    end)
    R(TabMap.Farm, "Quest Farm", function(box)
        Tog(box,"Complete Saber Quest","AutoUnlockSaber",false)
        Tog(box,"Complete Bartilo Quest","AutoBartiloQuest",false)
        Tog(box,"Complete Citizen Quest","CompleteCitizenQuest",false)
        Tog(box,"Complete Rainbow Haki Quest","GetRainbowHaki",false)
    end)
    L(TabMap.Farm, "Items Farm", function(box)
        Tog(box,"Auto Get Yama (Fully)","AutoYama",false)
        Tog(box,"Auto Get Tushita (Fully)","AutoTushita",false)
        Tog(box,"Auto Get CDK (Fully)","AutoCDKQuest",false,"Don't turn on remove fog while using this")
        Tog(box,"Auto Get Rengoku (Fully)","AutoRengoku",false)
        Tog(box,"Auto Get TTK (Fully)","AutoTTK",false)
        Tog(box,"Auto Evolve DarkBlade V2","AutoGetDBV2",false)
        Tog(box,"Auto Shark Anchor (Fully)","AutoSharkAnchor",false)
        Tog(box,"Auto Get Skull Guitar (Fully)","AutoGetSkullGuitar",false)
        Tog(box,"Ignore Material Farm for Skull Guitar","IgnoreMaterialFarmGuitar",false)
    end)
    R(TabMap.Farm, "Sword Mastery", function(box)
        Sld(box,"Select Sword Mastery","SelectSwordMastery",100,600,600)
        Tog(box,"Auto Mastery Swords (Fully)","AutoMasterySwords",false)
    end)
    L(TabMap.Farm, "Fight Style", function(box)
        Tog(box,"Auto Death Step","AutoDeathStep",false)
        Tog(box,"Auto Sharkman Karate","AutoSharkmanKarate",false)
        Tog(box,"Auto Electric Claw","AutoElectricClaw",false)
        Tog(box,"Auto Dragon Talon","AutoDragonTalon",false)
    end)
    R(TabMap.Farm, "Timely Farm", function(box)
        Tog(box,"Auto Elite Hunter","AutoTaskEliteHunter",false)
        Tog(box,"Auto Factory Raid","AutoFactoryRaid",false)
        Tog(box,"Auto Pirate Raid","AutoFarmPirateRaid",false)
        Tog(box,"Auto Soul Reaper","AutoSoulReaper",false)
        Tog(box,"Auto Darkbeard","AutoDarkbeard",false)
        Tog(box,"Auto Greybeard","AutoGreybeard",false)
        Tog(box,"Auto Cursed Captain","AutoCursedCaptain",false)
        Tog(box,"Auto Open Colors Plate","AutoOpenColorsTask",false)
        Tog(box,"Auto True Form Rip Indra","AutoRipIndra",false)
    end)
    L(TabMap.Farm, "Other Farm", function(box)
        Tog(box,"Farm Observation","AutoFarmObservation",false)
        Tog(box,"Auto Get Observation V2","AutoKenV2",false)
        Tog(box,"Farm Observation Hopping","StartObsHop",false)
        Tog(box,"Auto Dummy Training","DummyTraining",false)
        Tog(box,"Chest Farm","AutoChest",false)
        Tog(box,"Stop If Items","StopChest",false)
        Tog(box,"Auto Hop on Chests","AutoHopChest",false)
        Sld(box,"Chest Hop Count","ChestHopCount",1,50,10)
        Tog(box,"Stop Hop If Chalice","StopHopChestIfChalice",true)
        Tog(box,"Tyrant of the Skies","AutoTyrantOfTheSkies",false)
        Tog(box,"Use Skull Guitar for Tyrant","ShootGunTyrant",true)
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- SEA EVENTS
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Sea, "Mirage Event", function(box)
        Tog(box,"Auto Find Mirage Island","AutoFindMirageIsland",false)
        Tog(box,"Teleport to Mirage","AutoTeleportMirage",false)
    end)
    R(TabMap.Sea, "Kitsune Event", function(box)
        Tog(box,"Auto Find Kitsune Island","AutoFindKitsuneIsland",false)
        Tog(box,"Teleport to Shrine","AutoTeleportKitsune",false)
        Tog(box,"Auto Collect Azure Embers","CollectAzure",false)
        Tog(box,"Auto Kitsune Farm","AutoBlueMoonFarm",false)
        Sld(box,"Set Azure Ember","SetAzureEmber",1,25,1)
        Tog(box,"Auto Trade Azure Ember","TradeAzureEmber",false)
    end)
    L(TabMap.Sea, "Leviathan Hunt", function(box)
        Btn(box,"Bribe Leviathan",function() pcall(function() FireInvoke(nil,"InfoLeviathan","2") end) end)
        Tog(box,"Auto Find Leviathan","AutoFindLeviatan",false)
        Tog(box,"Ignore Sea Events While Finding","AutoIgnoreSeaEventsLeviathan",false)
        Tog(box,"Auto Kill Leviathan","AutoKillLeviathan",false)
        Tog(box,"Auto Sail back to Tiki","AutoSailbacktoTiki",false)
    end)
    R(TabMap.Sea, "Sea Farm / Boat", function(box)
        Drp(box,"Select Boat","BoatSelected","PirateBrigade",ActiveD.BoatsList or {})
        Drp(box,"Select Zone","SeaLevelSelected","Level 6",ActiveD.ZoneList or {})
        Sld(box,"Boat Height","BoatPosY",0,150,31)
        Sld(box,"Boat Speed","SpeedBoat",10,250,230)
        Drp(box,"Sea Event Targets","SeaEventTargets",nil,ActiveD.SeaEventTargets or {},true)
        Tog(box,"Auto Drive","AutoSail",false)
        Tog(box,"Auto Farm Sea Events","AutoFarmSeaEvents",false)
        Tog(box,"Protect Boat","ProtectBoat",true)
        Tog(box,"Auto Buy Boat When Dies","AutoBuyNewBoatWhendies",false)
        Tog(box,"Reset Player if Boat Destroyed","ResetPlayerdestroyboat",false)
        Tog(box,"Auto Dodge Terror Shark","DodgeTerror",true)
        Tog(box,"Auto Dodge Sea Beast","DodgefSeabeast",true)
        Sld(box,"Manual Boat Speed","ManualBoatSpeed",20,250,150)
        Tog(box,"Manual Increase Boat Speed","ManualIncreaseBoatSpeed",false)
        Btn(box,"Buy New Boat",function() pcall(function() FireInvoke(nil,"BuyBoat",Settings.BoatSelected or "PirateBrigade") end) end)
    end)
    L(TabMap.Sea, "Fishing", function(box)
        Drp(box,"Select Rod","RodSelected","Fishing Rod",ActiveD.RodsList or {})
        Drp(box,"Select Bait","BaitSelected","Basic Bait",ActiveD.BaitsList or {})
        Tog(box,"Auto Fishing","Auto_Fishing",false)
        Tog(box,"Auto Angler Quest","AutoGetAnglerQuest",false)
        Tog(box,"Auto Use Rod Skill","AutoUseRodSkill",false)
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- PLAYER
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Player, "Stats", function(box)
        Tog(box,"Auto Stats","AutoStats",false)
        Sld(box,"Points per tick","PointsSlider",1,100,1)
        Tog(box,"Melee","Melee",false)
        Tog(box,"Defense","Defense",false)
        Tog(box,"Sword","Sword",false)
        Tog(box,"Gun","Gun",false)
        Tog(box,"Demon Fruit","DemonFruit",false)
        Btn(box,"Add Points (manual)",function()
            local stat = Settings.StatType or "Melee"
            local pts  = Settings.PointsSlider or 1
            pcall(function() FireInvoke(nil,"AddPoint",stat,pts) end)
        end)
    end)
    R(TabMap.Player, "ESP / Visual", function(box)
        Tog(box,"Cam Lock","CamLock",false)
        Tog(box,"Enable Aimbot","EnableAimbot",false)
        Tog(box,"Auto Observation Haki","AutoActivateObservationHaki",false)
        Tog(box,"Auto Haki","AutoHaki",false)
        Tog(box,"X-Ray","XRay",false,function(v)
            Settings.XRay=v
            local fn = BF and BF.Functions and BF.Functions["XRay"]
            if fn then (v and fn.Start or fn.Stop)() end
        end)
        Tog(box,"White Screen","White_Screen",false,function(v)
            pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(not v) end)
        end)
        Tog(box,"Walk in Water","Water",true)
        Tog(box,"Infinite Zoom","InfiniteZoom",false,function(v)
            if v then game.Players.LocalPlayer.CameraMaxZoomDistance=math.huge
            else game.Players.LocalPlayer.CameraMaxZoomDistance=400 end
        end)
    end)
    L(TabMap.Player, "Target Player", function(box)
        local pList = {"Nearest"}
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game.Players.LocalPlayer then table.insert(pList,p.Name) end
        end
        Drp(box,"Select Player","SelectPlayer","Nearest",pList)
        Tog(box,"Teleport to Player","TeleporttoPlayer",false)
        Tog(box,"Spectate Player","SpectatePlayer",false)
    end)
    R(TabMap.Player, "Movement", function(box)
        Sld(box,"Walk Speed","WalkSpeed",1,500,16,function(v)
            local c=game.Players.LocalPlayer.Character
            local h=c and c:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed=v end
        end)
        Sld(box,"Jump Power","JumpPower",1,500,50,function(v)
            local c=game.Players.LocalPlayer.Character
            local h=c and c:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower=v end
        end)
        Tog(box,"Anti AFK","AntiAFK",true)
        Tog(box,"Disable Damage Counter","DisableDamageCounter",false)
        Tog(box,"Disable Notifications","DisableNotifications",false)
        Tog(box,"Auto Hop When 30 Mins","AutoHopwhen30mins",false)
        Tog(box,"Hop When Admin","HopWhenAdmin",true)
        Btn(box,"FPS Boost",function()
            local fn = BF and BF.Functions and BF.Functions["FPSBoost"]
            if fn then fn.Start() end
        end)
        Btn(box,"Redeem All Codes",function()
            local fn = BF and BF.Functions and BF.Functions["RedeemAllCodes"]
            if fn then fn.Start() end
        end)
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- DRAGON / PREHISTORIC
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Dragon, "Dragon Update", function(box)
        Tog(box,"Auto Upgrade Dragon Talon","AutoUpgradeDragonTalon",false)
        Btn(box,"TP to Dojo Trainer",function()
            local tm=BF and BF.TweenManager
            if tm then tm:topos(CFrame.new(5867,1208,870)) end
        end)
        Btn(box,"TP to Dragon Hunter",function()
            local tm=BF and BF.TweenManager
            if tm then tm:topos(CFrame.new(5864,1209,808)) end
        end)
        Btn(box,"TP to Dragon Wizard",function()
            local tm=BF and BF.TweenManager
            if tm then tm:topos(CFrame.new(5775,1209,806)) end
        end)
    end)
    R(TabMap.Dragon, "Belt Obtainment", function(box)
        Btn(box,"TP to Dojo Trainer",function()
            local tm=BF and BF.TweenManager
            if tm then tm:topos(CFrame.new(5867,1208,870)) end
        end)
        Tog(box,"Auto White Belt","AutoWhiteBelt",false)
        Tog(box,"Auto Purple Belt","AutoPurpleBelt",false)
    end)
    L(TabMap.Dragon, "Prehistoric Event", function(box)
        Tog(box,"Auto Find Prehistoric Island","AutoFindPrehistoricIsland",false)
        Tog(box,"Teleport to Prehistoric Island","AutoTeleportPrehistoric",false)
        Tog(box,"Auto Complete Volcanic Event","AutoVolcanicEvent",false)
        Tog(box,"Use Skull Guitar for Volcano","ShootGunVolcano",true)
        Tog(box,"Auto Collect Bones","AutoCollectBones",false)
        Tog(box,"Auto Collect Dragon Eggs","AutoCollectEgg",false)
        Tog(box,"Auto Farm Blaze Ember","AutoQuestBlaze",false)
        Drp(box,"Select Gun","SelectGunBlaze","Skull Guitar",{"Skull Guitar","Bazooka"})
        Btn(box,"Craft Volcanic Magnet",function()
            local fn=BF and BF.Functions and BF.Functions["CraftVolcanicMagnet"]
            if fn then fn.Start() end
        end)
        Btn(box,"Craft Dragonheart",function()
            local fn=BF and BF.Functions and BF.Functions["CraftDragonheart"]
            if fn then fn.Start() end
        end)
        Btn(box,"Craft Dragonstorm",function()
            local fn=BF and BF.Functions and BF.Functions["CraftDragonstorm"]
            if fn then fn.Start() end
        end)
        Btn(box,"Craft Dino Hood",function()
            local fn=BF and BF.Functions and BF.Functions["CraftDinoHood"]
            if fn then fn.Start() end
        end)
        Btn(box,"Craft T-Rex Skull",function()
            local fn=BF and BF.Functions and BF.Functions["CraftTRexSkull"]
            if fn then fn.Start() end
        end)
    end)
    R(TabMap.Dragon, "Draco Race", function(box)
        Tog(box,"Teleport to Draco Trial","AutoTrialDracoTP",false)
        Btn(box,"Change to Draco Race",function()
            local fn=BF and BF.Functions and BF.Functions["ChangeDracoRace"]
            if fn then fn.Start() end
        end)
        Tog(box,"Auto Draco Race V2","AutoCollectFireFlowers",false)
        Tog(box,"Auto Complete Draco Trial","AutoCompleteDracoTrial",false)
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- DUNGEON / RAIDS
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Dungeon, "Raid Menu", function(box)
        Drp(box,"Raid Chip","SelectRaid",nil,ActiveD.Raids_Chip or {})
        Tog(box,"Auto Buy Chip","AutoBuyChip",false)
        Tog(box,"Auto Complete Raid","AutoRaidFull",false)
        Tog(box,"Instant Kill Islands 4-5","InstantKillLateIslands",false)
        Tog(box,"Auto Unstore Below 1m Fruit","AutoUnstoreBelowFruit",false)
        Tog(box,"Auto Awaken","AutoAwaken",false)
        Sld(box,"Frags Cap","FragsCap",1000,1000000,1000)
        Tog(box,"Auto Stop Raid at Frags Cap","Autostopraid",false)
    end)
    R(TabMap.Dungeon, "Dungeon Menu", function(box)
        Tog(box,"Auto Unlock Difficulties","AutoUnlockDifficulties",false)
        Tog(box,"Auto Complete Dungeon","AutoDungeonFull",false)
        Tog(box,"Auto Destroy Shrines/Vents","AutoDungeonShrine",false)
        Drp(box,"Select Cards","CardsSelection",nil,ActiveD.DungeonCards or {},true)
        Tog(box,"Auto Select Cards","AutoCardsDungeon",false)
        Btn(box,"Unlock Next Difficulty",function()
            local fn=BF and BF.Functions and BF.Functions["UnlockDungeonDifficulty"]
            if fn then fn.Start() end
        end)
        Btn(box,"TP to Dungeon Map",function()
            local fn=BF and BF.Functions and BF.Functions["TPDungeonHub"]
            if fn then fn.Start() end
        end)
        Btn(box,"Return to Previous Sea",function()
            local fn=BF and BF.Functions and BF.Functions["TPDungeonBack"]
            if fn then fn.Start() end
        end)
        Tog(box,"Auto Law Raid","AutoLawRaid",false)
    end)
    L(TabMap.Dungeon, "Fruit Menu", function(box)
        Btn(box,"Open Normal Fruit Shop",function()
            local fn=BF and BF.Functions and BF.Functions["OpenNormalFruitShop"]
            if fn then fn.Start() end
        end)
        Btn(box,"Open Advanced Fruit Shop",function()
            local fn=BF and BF.Functions and BF.Functions["OpenAdvFruitShop"]
            if fn then fn.Start() end
        end)
        Tog(box,"Auto Roll Fruit","Random_Auto",false)
        Tog(box,"Auto Store Fruit","AutoStoreFruit",false)
        Tog(box,"Teleport to Fruit","Tweenfruit",false)
        Tog(box,"Hop If No Fruit","HopIfNoFruit",false)
        Tog(box,"Fruit Notification","FruitCheck",false)
        Btn(box,"TP to Advanced Fruit Dealer",function()
            local fn=BF and BF.Functions and BF.Functions["TPAdvFruitDealer"]
            if fn then fn.Start() end
        end)
    end)
    R(TabMap.Dungeon, "Trinkets & Refiner", function(box)
        Btn(box,"Buy Trinket",function()
            local fn=BF and BF.Functions and BF.Functions["BuyTrinket"]
            if fn then fn.Start() end
        end)
        Tog(box,"Auto Buy Trinkets","AutoBuyTrinkets",false)
        Btn(box,"Fuse / Merge 3 Trinkets",function()
            local fn=BF and BF.Functions and BF.Functions["FuseTrinkets"]
            if fn then fn.Start() end
        end)
        Tog(box,"Auto Fuse Trinkets","AutoFuseTrinkets",false)
        Btn(box,"Reforge / Refine Trinket",function()
            local fn=BF and BF.Functions and BF.Functions["RefineTrinket"]
            if fn then fn.Start() end
        end)
        Tog(box,"Auto Refine Trinket","AutoRefineTrinkets",false)
        Btn(box,"Open Trinket Merge GUI",function()
            local fn=BF and BF.Functions and BF.Functions["OpenTrinketMergeGUI"]
            if fn then fn.Start() end
        end)
        Btn(box,"Open Trinket Refiner GUI",function()
            local fn=BF and BF.Functions and BF.Functions["OpenTrinketRefineGUI"]
            if fn then fn.Start() end
        end)
        Btn(box,"Open Trinket Scrap GUI",function()
            local fn=BF and BF.Functions and BF.Functions["OpenTrinketScrapGUI"]
            if fn then fn.Start() end
        end)
        Tog(box,"Auto Scrap Junk Trinkets","AutoScrapTrinkets",false)
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- TRIALS
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Trials, "Trials", function(box)
        Btn(box,"Go to Race Door",function()
            local fn=BF and BF.Functions and BF.Functions["TPRaceDoor"]
            if fn then fn.Start() end
        end)
        Tog(box,"Auto (Activate) Race","AutoActiveRacenear",false,"Activates race when 2+ accounts are ready")
        Tog(box,"Auto Complete Trials","AutoFinishTrial",false)
        Tog(box,"Kill Players after Trial","AutoKillPlayerinTrial",false)
        Btn(box,"Reset Character",function()
            local fn=BF and BF.Functions and BF.Functions["ResetCharHead"]
            if fn then fn.Start() end
        end)
        Tog(box,"Auto Choose Gear","AutoChooseGear",false)
        Drp(box,"Train Method","TrainMethod","Bones",ActiveD.TrainMethods or {"Bones","Cakes"})
        Tog(box,"Auto Train Gear","AutoTrainGear",false)
        Tog(box,"Auto Pull Lever (Fully)","AutoFullyPullLever",false)
        Tog(box,"Teleport to Blue Gear","TweenMGear",false)
    end)
    R(TabMap.Trials, "Area TPs", function(box)
        local TRIAL_CFS = {
            GreatTree     = CFrame.new(2948,2282,-7214),
            TempleOfTime  = CFrame.new(28286,14895,103),
            AncientOne    = CFrame.new(28982,14888,-120),
            LeverPull     = CFrame.new(28575,14937,72),
            SafeZone      = CFrame.new(28273,14897,157),
            PvpZone       = CFrame.new(28767,14967,-164),
            Clock         = CFrame.new(29552,15069,-86),
        }
        for k, cf in pairs(TRIAL_CFS) do
            local label = k:gsub("(%u)", " %1"):gsub("^%s","")
            local cf2 = cf
            Btn(box,"TP to "..label,function()
                local tm=BF and BF.TweenManager
                if tm then tm:topos(cf2) end
            end)
        end
    end)
    L(TabMap.Trials, "Misc Trial", function(box)
        Tog(box,"Auto Upgrade Gear","BuyGear",false)
        Tog(box,"Auto Activate V3","AutoAgility",false)
        Tog(box,"Auto Activate V4","AutoActiveRaceV4",false)
        Tog(box,"Auto Look Moon","AutoLookMoon",false)
        Btn(box,"Init Temple of Time",function()
            local fn=BF and BF.Functions and BF.Functions["InitTempleOfTime"]
            if fn then fn.Start() end
        end)
    end)
    R(TabMap.Trials, "Race Upgrades / Obtainment", function(box)
        Tog(box,"Auto Race Evolve V2","AutoStartRaceV2",false)
        Tog(box,"Auto Race Evolve V3","AutoStartRaceV3",false)
        Tog(box,"Auto Get Ghoul Race","AutoGetGhoulRace",false)
        Tog(box,"Auto Get Cyborg Race","AutoGetCyborgRace",false)
        Tog(box,"Auto Race V4","AutoRaceV4",false)
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- TRAVEL
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Travel, "World Travel", function(box)
        Btn(box,"Teleport to World 1",function() pcall(function() FireInvoke(nil,"TravelMain") end) end)
        Btn(box,"Teleport to World 2",function() pcall(function() FireInvoke(nil,"TravelDressrosa") end) end)
        Btn(box,"Teleport to World 3",function() pcall(function() FireInvoke(nil,"TravelZou") end) end)
    end)
    R(TabMap.Travel, "Island Travel", function(box)
        Drp(box,"Select Island","TeleportIslandSelect",nil,ActiveD.IslandsList or {})
        Tog(box,"Start Traveling","TeleportToIsland",false)
    end)
    L(TabMap.Travel, "NPC Travel", function(box)
        Drp(box,"Select NPC","NpcTween",nil,ActiveD.NPCList or {})
        Tog(box,"Start Traveling","TPtoNPC",false)
    end)
    R(TabMap.Travel, "Player Travel", function(box)
        local pList = {"Nearest"}
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p ~= game.Players.LocalPlayer then table.insert(pList,p.Name) end
        end
        Drp(box,"Select Player","SelectPlayer","Nearest",pList)
        Tog(box,"Teleport to Player","TeleporttoPlayer",false)
        Tog(box,"Spectate","SpectatePlayer",false)
    end)
    L(TabMap.Travel, "Server Travel", function(box)
        Txt(box,"Job ID","JobID","paste job ID here",function(v)
            if v and v~="" then
                pcall(function()
                    game:GetService("ReplicatedStorage").__ServerBrowser
                        :InvokeServer("teleport",v:gsub("%s+",""))
                end)
            end
        end)
        Btn(box,"Copy Job ID",function()
            pcall(function() setclipboard(tostring(game.JobId)) end)
        end)
        Btn(box,"Server Hop",function()
            local sch = BF and BF.Scheduler
            if sch and sch.ServerHop then sch.ServerHop(0) end
        end)
        Btn(box,"Rejoin",function()
            local sch = BF and BF.Scheduler
            if sch and sch.Rejoin then sch.Rejoin() end
        end)
    end)
    R(TabMap.Travel, "Join by Server ID", function(box)
        Lbl(box,"Paste a ZenHub- Server ID from discord.")
        Txt(box,"Server ID","JoinByIDInput","ZenHub-...")
        Btn(box,"Join Server",function()
            local fn=BF and BF.Functions and BF.Functions["JoinByID"]
            if fn then fn.Start() end
        end)
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- SHOP
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Shop, "Melee / Fighting Style", function(box)
        Drp(box,"Select Melee","SelectMelee",nil,ActiveD.MeleeNames or {})
        Tog(box,"Auto Buy Melee","AutoBuyMelee",false)
        Btn(box,"Buy Melee Now",function()
            local fn=BF and BF.Functions and BF.Functions["BuyMelee"]
            if fn then fn.Start() end
        end)
    end)
    R(TabMap.Shop, "Fruit Dealer", function(box)
        Drp(box,"Fruit to Buy","SelectFruitDealerFruit","Buddha-Buddha",ActiveD.DealerFruitList or {})
        Tog(box,"Auto Buy Fruit (Normal)","AutoBuyFruitDealer",false)
        Tog(box,"Auto Buy Fruit (Mirage)","AutoBuyMirageFruitDealer",false)
        Btn(box,"Buy Selected Fruit Now",function()
            local fn=BF and BF.Functions and BF.Functions["BuySelectedFruit"]
            if fn then fn.Start() end
        end)
        Btn(box,"Open Normal Shop",function()
            local fn=BF and BF.Functions and BF.Functions["OpenNormalFruitShop"]
            if fn then fn.Start() end
        end)
        Btn(box,"Open Advanced Shop",function()
            local fn=BF and BF.Functions and BF.Functions["OpenAdvFruitShop"]
            if fn then fn.Start() end
        end)
    end)
    L(TabMap.Shop, "Abilities & Accessories", function(box)
        Drp(box,"Ability","BuyAbility","Geppo",ActiveD.AbilityNames or {"Geppo","Buso Haki","Soru","Observation Haki"})
        Btn(box,"Buy Ability",function()
            local ability = Settings.BuyAbility
            local map = {
                ["Geppo"]={"BuyHaki","Geppo"},["Buso Haki"]={"BuyHaki","Buso"},
                ["Soru"]={"BuyHaki","Soru"},["Observation Haki"]={"KenTalk","Buy"},
            }
            local r = map[ability]
            if r then pcall(function() FireInvoke(nil,table.unpack(r)) end) end
        end)
        Tog(box,"Auto Buy Haki Color","AutoBuyEnchancementColor",false)
        Drp(box,"Accessory","BuyAccessories","Tomoe Ring",ActiveD.AccessoryNames or {"Tomoe Ring","Black Cape","Swordsman Hat"})
        Btn(box,"Buy Accessory",function()
            local acc=Settings.BuyAccessories
            if acc then pcall(function() FireInvoke(nil,acc) end) end
        end)
    end)
    R(TabMap.Shop, "Swords & Race Shop", function(box)
        Drp(box,"Legendary Sword","SelectLegendarySword","Shizu",ActiveD.LegendarySwordNames or {"Shizu","Oroshi","Saishi"})
        Tog(box,"Buy Legendary Sword","BuyLegendSword",false)
        Tog(box,"Auto Get TTK","AutoTTK",false)
        Btn(box,"Buy Ghoul Race",function()
            local fn=BF and BF.Functions and BF.Functions["BuyGhoulRace"]
            if fn then fn.Start() end
        end)
        Btn(box,"Buy Cyborg Race",function()
            local fn=BF and BF.Functions and BF.Functions["BuyCyborgRace"]
            if fn then fn.Start() end
        end)
        Btn(box,"Race Reroll",function() pcall(function() FireInvoke(nil,"BlackbeardReward","Reroll","2") end) end)
        Btn(box,"Reset Stats",function() pcall(function() FireInvoke(nil,"BlackbeardReward","Refund","2") end) end)
    end)
    L(TabMap.Shop, "Scrolls", function(box)
        Drp(box,"Scroll Type","SelectScrollType","Common Scroll",
            {"Common Scroll","Rare Scroll","Legendary Scroll","Mythical Scroll"})
        Sld(box,"Amount","ScrollCraftAmount",1,99,1)
        Btn(box,"Craft Scroll",function()
            local fn=BF and BF.Functions and BF.Functions["CraftScroll"]
            if fn then fn.Start() end
        end)
    end)
    R(TabMap.Shop, "UI Shortcuts", function(box)
        Btn(box,"Open Awakenings",function()
            pcall(function() game.Players.LocalPlayer.PlayerGui.Main.AwakeningToggler.Visible=true end)
        end)
        Btn(box,"Open Haki Colors",function()
            pcall(function() game.Players.LocalPlayer.PlayerGui.Main.Colors.Visible=true end)
        end)
        Btn(box,"Open Title Menu",function()
            pcall(function() game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TitlesMenu").Open:Fire() end)
        end)
        Btn(box,"Give Triple DarkBlade",function()
            if Visuals and Visuals.GiveDarkBlade then Visuals.GiveDarkBlade(game.Players.LocalPlayer) end
        end)
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- MISC
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Misc, "Settings", function(box)
        Tog(box,"Bypass TP","BypassTP",false)
        Tog(box,"Disable Damage Counter","DisableDamageCounter",false)
        Tog(box,"Disable Notifications","DisableNotifications",false)
        Tog(box,"Auto Load Script on Load","AutoLoadScriptonLoad",false)
        Drp(box,"Default Team","TeamSelectLoad","Pirates",{"Pirates","Marines"})
    end)
    R(TabMap.Misc, "Player Info", function(box)
        Btn(box,"Show Stats",function()
            local lp2 = game.Players.LocalPlayer
            local d   = lp2:FindFirstChild("Data")
            local lvl = d and d:FindFirstChild("Level")
            local bli = d and d:FindFirstChild("Beli")
            local frg = d and d:FindFirstChild("Fragments")
            local pts = d and d:FindFirstChild("Points")
            local msg = ("Level: %d | Beli: %d | Frags: %d | Points: %d"):format(
                lvl and lvl.Value or 0,
                bli and bli.Value or 0,
                frg and frg.Value or 0,
                pts and pts.Value or 0
            )
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification",{Title="Stats",Text=msg,Duration=8})
            end)
        end)
        Btn(box,"Copy Job ID",function() pcall(function() setclipboard(tostring(game.JobId)) end) end)
        Btn(box,"Redeem All Codes",function()
            local fn=BF and BF.Functions and BF.Functions["RedeemAllCodes"]
            if fn then fn.Start() end
        end)
        Btn(box,"FPS Boost",function()
            local fn=BF and BF.Functions and BF.Functions["FPSBoost"]
            if fn then fn.Start() end
        end)
        Btn(box,"Remove Effects",function()
            if Visuals and Visuals.RemoveEffects then Visuals.RemoveEffects() end
        end)
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- WEBHOOK
    -- ══════════════════════════════════════════════════════════════════════
    L(TabMap.Webhook, "Personal Webhook", function(box)
        Txt(box,"Webhook URL","Webhook","https://discord.com/api/webhooks/...")
        Btn(box,"Send Test Webhook",function()
            local fn=BF and BF.Functions and BF.Functions["SendTestWebhook"]
            if fn then fn.Start() end
        end)
        Tog(box,"Auto Data Log (5min)","AutoWebhookLog",false)
    end)
    R(TabMap.Webhook, "Finder System", function(box)
        Lbl(box,"Posts Job IDs to Zen Hub Official discord.")
        Tog(box,"Mirage Island Finder","MirageFinder",false)
        Tog(box,"Kitsune Island Finder","KitsuneFinder",false)
        Tog(box,"Boss Finder","BossFinder",false)
        Tog(box,"Fruit Notifier","FruitNotifier",false)
        Tog(box,"Legendary Sword Notifier","SwordNotifier",false)
        Tog(box,"Moon Finder","MoonFinder",false)
        Btn(box,"Copy Stats URL",function()
            pcall(function() setclipboard("https://zenhubdev.cv/stats") end)
        end)
    end)

    print("[Zen Hub] UI fully registered. by Zen Devs")
end

return Tabs
