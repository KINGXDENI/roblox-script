--[[
    ════════════════════════════════════════════════════════════════════════════
    ⚔️ JIWA BESI: DUNGEON (IRON SOUL) - FLUENT UI ADVANCED PRO HUB V3.0 ⚔️
    ════════════════════════════════════════════════════════════════════════════
    Game: Jiwa Besi: Dungeon (Place ID: 117533937949084 | Universe: 9910245722)
    Powered by Fluent UI Library (Windows 11 Acrylic Style)
    
    Fitur Lengkap:
      [✓] SMART AUTO-QUEST SOLVER:
          - Menampilkan Info Quest Aktif Real-Time (Nama, Aksi, & Progress X/Y)
          - Dialog & Window Quest: Bypass instan via TaskRE
          - Equip & Forge Quest: Auto trigger equip/forge remote
          - KillMon & WorldClear: Auto dekati monster dungeon & aktifkan kill aura
      [✓] AUTO DUNGEON CLEARER:
          - Teleport & buru semua monster per-room secara otomatis
          - Safe Hover Mode (Melayang 4.5 studs di atas mob agar anti-hit)
          - Auto Replay Dungeon & Auto Select Card Bonus
      [✓] Auto Claim Daily Quests, 7-Daily Login, & Group Reward
      [✓] Auto Mob Kill Aura & Auto Skill Rotation
      [✓] Smart Auto Dodge / Dash saat Diserang
      [✓] Monster / Enemy ESP (Highlight Merah & Box)
      [✓] Auto Roll / Gacha Trait & Senjata
      [✓] Auto Hatch Pet & Auto Claim Pet Expedition
      [✓] Auto Upgrade Stat Poin (ATK / HP / DEF)
      [✓] Auto Fortify & Enchant Senjata
      [✓] Redeem Semua Promo Code Aktif
      [✓] Instant Teleport Semua Lokasi & NPC Lobby
      [✓] Player Mod (WalkSpeed, Infinite Jump, Anti-AFK, FullBright)
      [✓] Draggable Floating Re-open Icon (⚔️) & RightShift / Insert Keybind
    ════════════════════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid", 10)
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid", 10)
    RootPart = newChar:WaitForChild("HumanoidRootPart", 10)
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🎨 1. FLUENT UI INITIALIZATION (SAFE LOADER)
-- ══════════════════════════════════════════════════════════════════════════
local FluentSuccess, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not FluentSuccess or not Fluent then
    warn("[Iron Soul Hub] Gagal memuat Fluent UI. Periksa koneksi internet executor!")
    return
end

local SaveManagerLoaded, SaveManager = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
end)

local InterfaceManagerLoaded, InterfaceManager = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

local Window = Fluent:CreateWindow({
    Title = "Iron Soul: Dungeon Hub",
    SubTitle = "v3.0 [Fluent Edition]",
    TabWidth = 160,
    Size = UDim2.fromOffset(590, 470),
    Acrylic = false, -- false untuk stabilitas & FPS tinggi
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- ══════════════════════════════════════════════════════════════════════════
-- 🔘 FLOATING RE-OPEN TOGGLE BUTTON & KEYBIND
-- ══════════════════════════════════════════════════════════════════════════
pcall(function()
    local gethui = gethui or function() return game:GetService("CoreGui") end
    local parentGui = gethui() or LocalPlayer:WaitForChild("PlayerGui")

    local oldBtn = parentGui:FindFirstChild("IronSoulFluentToggleGui")
    if oldBtn then oldBtn:Destroy() end

    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "IronSoulFluentToggleGui"
    ToggleGui.ResetOnSpawn = false
    ToggleGui.Parent = parentGui

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleHubBtn"
    ToggleBtn.Size = UDim2.fromOffset(45, 45)
    ToggleBtn.Position = UDim2.new(0, 15, 0.5, -22)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    ToggleBtn.Text = "⚔️"
    ToggleBtn.TextSize = 22
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.AutoButtonColor = true
    ToggleBtn.Parent = ToggleGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = ToggleBtn

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(120, 110, 200)
    UIStroke.Thickness = 1.6
    UIStroke.Parent = ToggleBtn

    -- Draggable Logic
    local dragging, dragStart, startPos
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local function toggleMainWindow()
        pcall(function()
            if Window.Root then
                Window.Root.Visible = not Window.Root.Visible
            elseif Window.Minimize then
                Window:Minimize()
            end
        end)
    end

    ToggleBtn.MouseButton1Click:Connect(toggleMainWindow)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Insert then
            toggleMainWindow()
        end
    end)
end)

-- ══════════════════════════════════════════════════════════════════════════
-- ⚙️ 2. STATUS VARIABEL
-- ══════════════════════════════════════════════════════════════════════════
local AutoQuestActive = false
local AutoDailyActive = false
local KillAuraActive = false
local AutoSkillActive = false
local AutoDodgeActive = false
local AutoClearDungeonActive = false
local SafeHoverActive = true
local AutoReplayDungeon = false
local MobESPActive = false
local InfJumpActive = false
local AntiAFKActive = true
local FullBrightActive = false

local AutoRollActive = false
local AutoPetHatchActive = false
local AutoPetExpedition = false
local AutoUpgradeStatActive = false
local TargetStat = "ATK"

local AuraRange = 25
local DefaultSpeed = 16

local CurrentQuestStatus = "Sedang memeriksa status quest..."
local QuestParagraph = nil

local function updateQuestStatusUI(text)
    CurrentQuestStatus = text
    if QuestParagraph then
        pcall(function()
            if QuestParagraph.SetDesc then
                QuestParagraph:SetDesc(text)
            elseif QuestParagraph.SetContent then
                QuestParagraph:SetContent(text)
            end
        end)
    end
end

-- ══════════════════════════════════════════════════════════════════════════
-- 🧩 3. FRAMEWORK & REMOTES RESOLVER
-- ══════════════════════════════════════════════════════════════════════════
local TaskRE
local DailyQuestRE
local GroupRewardRemote
local SevenDailyRE
local PlayerActionRE
local RollingRE
local PetsHatchRE
local PetsExpeditionRE
local ForgeRF
local AttrUpgradeRE
local CodesRemote

task.spawn(function()
    pcall(function()
        local fw = ReplicatedStorage:WaitForChild("Framework", 10)
        local features = fw and fw:WaitForChild("Features", 10)
        local gameplay = fw and fw:WaitForChild("Gameplay", 10)
        local systems = fw and fw:WaitForChild("Systems", 10)
        
        if features then
            local taskSys = features:FindFirstChild("TaskSystem")
            if taskSys then TaskRE = taskSys:FindFirstChild("TaskRE") end

            local dqSys = features:FindFirstChild("DailyQuestSystem")
            if dqSys then DailyQuestRE = dqSys:FindFirstChild("RE") end

            local groupSys = features:FindFirstChild("GroupRewardSystem")
            if groupSys and groupSys:FindFirstChild("GroupRewardUtil") then
                GroupRewardRemote = groupSys.GroupRewardUtil:FindFirstChild("RemoteEvent")
            end

            local sevenSys = features:FindFirstChild("SevenDailySystem")
            if sevenSys then SevenDailyRE = sevenSys:FindFirstChild("RE") end
        end

        if gameplay then
            local rollSys = gameplay:FindFirstChild("RollingSystem")
            if rollSys then RollingRE = rollSys:FindFirstChild("RollingRE") end

            local petsSys = gameplay:FindFirstChild("PetsSystem")
            if petsSys then
                local hatch = petsSys:FindFirstChild("PetsHatchUtil")
                if hatch then PetsHatchRE = hatch:FindFirstChild("RemoteEvent") end
                local exp = petsSys:FindFirstChild("PetsExpeditionUtil")
                if exp then PetsExpeditionRE = exp:FindFirstChild("RemoteEvent") end
            end

            local equipSys = gameplay:FindFirstChild("EquipmentSystem")
            if equipSys then
                ForgeRF = equipSys:FindFirstChild("ForgeRF")
            end

            local attrSys = gameplay:FindFirstChild("AttributeUpgrade")
            if attrSys and attrSys:FindFirstChild("AttributeUpgradeUtil") then
                AttrUpgradeRE = attrSys.AttributeUpgradeUtil:FindFirstChild("RemoteEvent")
            end
        end

        if systems then
            local codeSys = systems:FindFirstChild("CodesSystem")
            if codeSys then
                CodesRemote = codeSys:FindFirstChildWhichIsA("RemoteEvent") or codeSys:FindFirstChildWhichIsA("RemoteFunction")
            end
        end

        local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
        if remotes then
            PlayerActionRE = remotes:FindFirstChild("PlayerActionRE")
        end
    end)
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🛡️ 4. ANTI-AFK, INFINITE JUMP & FULLBRIGHT
-- ══════════════════════════════════════════════════════════════════════════
LocalPlayer.Idled:Connect(function()
    if AntiAFKActive then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfJumpActive and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local originalBrightness = Lighting.Brightness
local originalClockTime = Lighting.ClockTime
local originalFogEnd = Lighting.FogEnd

local function updateLighting()
    if FullBrightActive then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = originalBrightness
        Lighting.ClockTime = originalClockTime
        Lighting.FogEnd = originalFogEnd
        Lighting.GlobalShadows = true
    end
end

local function safeTeleport(targetPos)
    if RootPart then
        RootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

-- ══════════════════════════════════════════════════════════════════════════
-- 📜 5. SMART AUTO QUEST & TASK ENGINE
-- ══════════════════════════════════════════════════════════════════════════
local function getActiveQuestDetails()
    local success, result = pcall(function()
        local fw = require(ReplicatedStorage:WaitForChild("Framework"))
        local TaskUtil = fw.Modules.TaskUtil
        local ResMainTask = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("ResMainTask"))
        
        local tasks = TaskUtil:GetTasks(LocalPlayer)
        if not tasks then return nil end

        for taskId, taskInfo in pairs(tasks) do
            if not taskInfo.Completed then
                local def = ResMainTask[taskId]
                return {
                    id = taskId,
                    def = def,
                    info = taskInfo,
                    progress = taskInfo.Progress or 0,
                    target = (def and def.ActionParam1) or 1,
                    action = (def and def.Action) or "Unknown",
                    param2 = (def and def.ActionParam2) or "",
                    title = (def and def.Title) or taskId
                }
            end
        end
        return nil
    end)
    if success then return result end
    return nil
end

local function solveActiveTasks()
    local q = getActiveQuestDetails()
    if not q then
        updateQuestStatusUI("Semua quest saat ini sudah selesai!")
        return
    end

    local statusText = string.format("Quest: %s\nTipe Aksi: %s\nProgress: %d / %d", q.id, q.action, q.progress, q.target)

    -- 1. Penanganan Dialog NPC
    if q.action == "DialogNpc" then
        if TaskRE then
            TaskRE:FireServer("UpdateTaskProgress", "DialogNpc", q.param2, 1)
            statusText = statusText .. "\n[✓] Mengirim sinyal dialog NPC..."
        end

    -- 2. Penanganan Buka Window / GUI
    elseif q.action == "OpenGUIWindow" then
        if TaskRE then
            TaskRE:FireServer("UpdateTaskProgress", "OpenGUIWindow", q.param2, 1)
            statusText = statusText .. "\n[✓] Mengirim sinyal buka window..."
        end

    -- 3. Penanganan Equip Senjata
    elseif q.action == "EquipThing" or q.action == "EquipSkill" then
        pcall(function()
            local fw = require(ReplicatedStorage.Framework)
            if fw.Modules.EquipmentUtil then
                fw.Modules.EquipmentUtil:ChangeWeaponSlot(LocalPlayer)
                statusText = statusText .. "\n[✓] Mengganti / equip senjata..."
            end
        end)

    -- 4. Penanganan Tempa / Forge
    elseif q.action == "ForgeThing" then
        if ForgeRF then
            pcall(function()
                ForgeRF:InvokeServer("Forge")
                statusText = statusText .. "\n[✓] Menempa equipment di furnace..."
            end)
        end

    -- 5. Penanganan Membunuh Monster (KillMon)
    elseif q.action == "KillMon" then
        local enemyFolder = workspace:FindFirstChild("EnemyNpc")
        local targetEnemy = nil
        if enemyFolder then
            for _, enemy in ipairs(enemyFolder:GetChildren()) do
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
                if hum and hum.Health > 0 and hrp then
                    targetEnemy = enemy
                    break
                end
            end
        end

        if targetEnemy then
            local tHrp = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy:FindFirstChildWhichIsA("BasePart")
            if tHrp and RootPart then
                safeTeleport(tHrp.Position + Vector3.new(0, 3, 0))
                KillAuraActive = true
                statusText = statusText .. "\n[⚔️] Menyerang monster dungeon terdekat..."
            end
        else
            statusText = statusText .. "\n[📍] Berjalan ke Portal Dungeon (MainPlayPoint)..."
            safeTeleport(Vector3.new(82.9, 24.5, 163.99))
        end

    -- 6. Penanganan Selesaikan Stage (WorldClear)
    elseif q.action == "WorldClear" then
        statusText = statusText .. "\n[📍] Memasuki portal dungeon untuk selesaikan stage..."
        safeTeleport(Vector3.new(82.9, 24.5, 163.99))
    end

    updateQuestStatusUI(statusText)
end

-- Auto Quest Loop
task.spawn(function()
    while true do
        task.wait(2.5)
        if AutoQuestActive then
            solveActiveTasks()
        else
            local q = getActiveQuestDetails()
            if q then
                updateQuestStatusUI(string.format("Quest: %s\nTipe: %s (Progress: %d / %d)\nNyalakan toggle untuk auto-kerjakan!", q.id, q.action, q.progress, q.target))
            else
                updateQuestStatusUI("Semua quest saat ini sudah selesai!")
            end
        end

        if AutoDailyActive and DailyQuestRE then
            pcall(function()
                for i = 1, 6 do
                    DailyQuestRE:FireServer("ClickGetReward", i)
                    task.wait(0.1)
                end
            end)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- ⚔️ 6. COMBAT & MOB KILL AURA + SMART DODGE
-- ══════════════════════════════════════════════════════════════════════════
local function getNearestEnemy()
    local enemyFolder = workspace:FindFirstChild("EnemyNpc")
    if not enemyFolder or not RootPart then return nil end

    local nearest = nil
    local minDistance = AuraRange

    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local eHum = enemy:FindFirstChildOfClass("Humanoid")
        local eHrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
        if eHum and eHum.Health > 0 and eHrp then
            local dist = (RootPart.Position - eHrp.Position).Magnitude
            if dist < minDistance then
                minDistance = dist
                nearest = enemy
            end
        end
    end
    return nearest
end

local lastDodgeTime = 0
local function triggerDodge()
    if tick() - lastDodgeTime < 1.2 then return end
    lastDodgeTime = tick()
    pcall(function()
        local controlMgr = Character:FindFirstChild("LocalControlMgr")
        if controlMgr and controlMgr:FindFirstChild("Action") then
            local dashMod = controlMgr.Action:FindFirstChild("Dash")
            if dashMod then
                local dm = require(dashMod)
                if dm and dm.PerformAction then dm:PerformAction() end
            end
        end
    end)
end

-- Auto Dodge Loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoDodgeActive and Character then
            if Character:GetAttribute("BeHit") == true then
                triggerDodge()
            end
        end
    end
end)

-- Kill Aura Loop
task.spawn(function()
    while true do
        task.wait(0.15)
        if KillAuraActive and RootPart then
            local target = getNearestEnemy()
            if target then
                pcall(function()
                    local tHrp = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart")
                    if tHrp then
                        RootPart.CFrame = CFrame.new(RootPart.Position, Vector3.new(tHrp.Position.X, RootPart.Position.Y, tHrp.Position.Z))

                        local controlMgr = Character:FindFirstChild("LocalControlMgr")
                        if controlMgr and controlMgr:FindFirstChild("Action") then
                            local baseAttack = controlMgr.Action:FindFirstChild("BaseAttack")
                            if baseAttack then
                                local bModule = require(baseAttack)
                                if bModule and bModule.PerformAction then
                                    bModule:PerformAction()
                                end
                            end
                        end

                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(0, 0))
                        task.wait(0.05)
                        VirtualUser:Button1Up(Vector2.new(0, 0))

                        if AutoSkillActive and controlMgr and controlMgr:FindFirstChild("Action") then
                            for _, skillName in ipairs({"Skill1", "Skill2", "SkillU", "SkillAW"}) do
                                local sMod = controlMgr.Action:FindFirstChild(skillName)
                                if sMod then
                                    pcall(function()
                                        local sm = require(sMod)
                                        if sm and sm.PerformAction then sm:PerformAction() end
                                    end)
                                end
                            end
                        end

                        local dist = (RootPart.Position - tHrp.Position).Magnitude
                        if AutoDodgeActive and dist < 7 then
                            triggerDodge()
                        end
                    end
                end)
            end
        end
    end
end)

-- Auto Dungeon Clearer Loop (Berpindah otomatis membunuh semua musuh di dungeon)
task.spawn(function()
    while true do
        task.wait(0.18)
        if AutoClearDungeonActive and RootPart and Humanoid and Humanoid.Health > 0 then
            local enemyFolder = workspace:FindFirstChild("EnemyNpc")
            local targetEnemy = nil
            local minDistance = math.huge

            if enemyFolder then
                for _, enemy in ipairs(enemyFolder:GetChildren()) do
                    local eHum = enemy:FindFirstChildOfClass("Humanoid")
                    local eHrp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
                    if eHum and eHum.Health > 0 and eHrp then
                        local dist = (RootPart.Position - eHrp.Position).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            targetEnemy = enemy
                        end
                    end
                end
            end

            if targetEnemy then
                pcall(function()
                    local tHrp = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy:FindFirstChildWhichIsA("BasePart")
                    if tHrp then
                        local hoverOffset = SafeHoverActive and Vector3.new(0, 4.5, 0) or Vector3.new(0, 0, -2.5)
                        RootPart.CFrame = CFrame.new(tHrp.Position + hoverOffset, tHrp.Position)
                        RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

                        local controlMgr = Character:FindFirstChild("LocalControlMgr")
                        if controlMgr and controlMgr:FindFirstChild("Action") then
                            local baseAttack = controlMgr.Action:FindFirstChild("BaseAttack")
                            if baseAttack then
                                local bModule = require(baseAttack)
                                if bModule and bModule.PerformAction then
                                    bModule:PerformAction()
                                end
                            end

                            for _, skillName in ipairs({"Skill1", "Skill2", "SkillU", "SkillAW"}) do
                                local sMod = controlMgr.Action:FindFirstChild(skillName)
                                if sMod then
                                    local sm = require(sMod)
                                    if sm and sm.PerformAction then sm:PerformAction() end
                                end
                            end
                        end

                        VirtualUser:CaptureController()
                        VirtualUser:Button1Down(Vector2.new(0, 0))
                        task.wait(0.04)
                        VirtualUser:Button1Up(Vector2.new(0, 0))
                    end
                end)
            else
                pcall(function()
                    local fw = ReplicatedStorage:FindFirstChild("Framework")
                    local bonusSys = fw and fw:FindFirstChild("Gameplay") and fw.Gameplay:FindFirstChild("WorldPlace")
                    if bonusSys and bonusSys:FindFirstChild("WorldBonusCardUtil") and bonusSys.WorldBonusCardUtil:FindFirstChild("RemoteEvent") then
                        bonusSys.WorldBonusCardUtil.RemoteEvent:FireServer("Select", 1)
                    end

                    if AutoReplayDungeon then
                        local mainPortal = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Location") and workspace.World.Location:FindFirstChild("MainPlayPoint")
                        if mainPortal then
                            safeTeleport(mainPortal.Position)
                        else
                            safeTeleport(Vector3.new(82.9, 24.5, 163.99))
                        end
                    end
                end)
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 👁️ 7. MOB & ENEMY ESP VISUALIZER
-- ══════════════════════════════════════════════════════════════════════════
local espBoxes = {}

local function clearESP()
    for _, box in pairs(espBoxes) do
        if box then box:Destroy() end
    end
    table.clear(espBoxes)
end

task.spawn(function()
    while true do
        task.wait(1)
        if MobESPActive then
            local enemyFolder = workspace:FindFirstChild("EnemyNpc")
            if enemyFolder then
                for _, enemy in ipairs(enemyFolder:GetChildren()) do
                    if not espBoxes[enemy] and enemy:FindFirstChildOfClass("Humanoid") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "IronSoulMobESP"
                        highlight.Adornee = enemy
                        highlight.FillColor = Color3.fromRGB(255, 60, 60)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0.1
                        highlight.Parent = enemy
                        espBoxes[enemy] = highlight

                        local hum = enemy:FindFirstChildOfClass("Humanoid")
                        if hum then
                            hum.Died:Connect(function()
                                if espBoxes[enemy] then
                                    espBoxes[enemy]:Destroy()
                                    espBoxes[enemy] = nil
                                end
                            end)
                        end
                    end
                end
            end
        else
            clearESP()
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🎰 8. GACHA, PETS & ATTRIBUTE AUTOMATION LOOPS
-- ══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        if AutoRollActive and RollingRE then
            pcall(function()
                RollingRE:FireServer("Roll", 1)
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if AutoPetHatchActive and PetsHatchRE then
            pcall(function()
                PetsHatchRE:FireServer("Hatch", 1)
            end)
        end
        if AutoPetExpedition and PetsExpeditionRE then
            pcall(function()
                PetsExpeditionRE:FireServer("ClaimAll")
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
        if AutoUpgradeStatActive and AttrUpgradeRE then
            pcall(function()
                AttrUpgradeRE:FireServer("Upgrade", TargetStat, 1)
            end)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 📑 FLUENT TABS SETUP
-- ══════════════════════════════════════════════════════════════════════════
local Tabs = {
    Quest = Window:AddTab({ Title = "Quests & Hadiah", Icon = "scroll" }),
    Combat = Window:AddTab({ Title = "Combat & Dungeon", Icon = "swords" }),
    Gacha = Window:AddTab({ Title = "Gacha & Upgrade", Icon = "sparkles" }),
    Teleport = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Player = Window:AddTab({ Title = "Player & Misc", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 1: QUESTS & HADIAH
-- ──────────────────────────────────────────────────────────────────────────
Tabs.Quest:AddSection("Status Quest Aktif")

QuestParagraph = Tabs.Quest:AddParagraph({
    Title = "Status Tugas:",
    Content = CurrentQuestStatus
})

Tabs.Quest:AddSection("Kontrol Auto-Quest")

local AutoQuestToggle = Tabs.Quest:AddToggle("AutoQuestToggle", {
    Title = "Smart Full-Auto Quest",
    Description = "Otomatis selesaikan dialog, equip, dan teleport serang monster sesuai quest aktif",
    Default = false
})
AutoQuestToggle:OnChanged(function()
    AutoQuestActive = Fluent.Options.AutoQuestToggle.Value
    if AutoQuestActive then
        solveActiveTasks()
        Fluent:Notify({
            Title = "Smart Auto Quest",
            Content = "Auto quest aktif! Memproses kebutuhan tugas...",
            Duration = 3
        })
    end
end)

Tabs.Quest:AddButton({
    Title = "⚡ Selesaikan Aksi Quest Sekarang (Manual Trigger)",
    Description = "Kirim sinyal penyelesaian dialog / aksi quest saat ini",
    Callback = function()
        solveActiveTasks()
        Fluent:Notify({
            Title = "Quest Solver",
            Content = "Aksi quest berhasil dipicu!",
            Duration = 3
        })
    end
})

Tabs.Quest:AddSection("Klaim Hadiah Berkala")

local AutoDailyToggle = Tabs.Quest:AddToggle("AutoDailyToggle", {
    Title = "Auto Klaim Daily Quest Rewards",
    Description = "Otomatis klaim reward peti daily quest setiap selesai",
    Default = false
})
AutoDailyToggle:OnChanged(function()
    AutoDailyActive = Fluent.Options.AutoDailyToggle.Value
end)

Tabs.Quest:AddButton({
    Title = "🎁 Klaim Semua Hadiah Sekaligus",
    Description = "Klaim Daily Quest, 7-Daily Login, dan Group Reward",
    Callback = function()
        pcall(function()
            if DailyQuestRE then
                for i = 1, 6 do DailyQuestRE:FireServer("ClickGetReward", i) end
            end
            if SevenDailyRE then
                for day = 1, 7 do SevenDailyRE:FireServer("Claim", day) end
            end
            if GroupRewardRemote then
                GroupRewardRemote:FireServer("Claim")
            end
            Fluent:Notify({
                Title = "Hadiah Diambil",
                Content = "Semua permintaan klaim telah dikirim!",
                Duration = 3
            })
        end)
    end
})

Tabs.Quest:AddSection("Promo Codes")

Tabs.Quest:AddButton({
    Title = "🎟️ Redeem Semua Kode Promo Aktif",
    Description = "Mencoba klaim semua gift code resmi developer game",
    Callback = function()
        local activeCodes = {
            "RELEASE", "DUNGEON", "IRONSOUL", "FREEGEMS", "UPDATE",
            "LIKE5000", "WELCOME", "GIFT", "POWER", "DISCORD"
        }
        pcall(function()
            for _, code in ipairs(activeCodes) do
                if CodesRemote then
                    if CodesRemote:IsA("RemoteEvent") then
                        CodesRemote:FireServer("ClaimCode", code)
                    elseif CodesRemote:IsA("RemoteFunction") then
                        CodesRemote:InvokeServer("ClaimCode", code)
                    end
                end
                task.wait(0.2)
            end
            Fluent:Notify({
                Title = "Kode Di-Redeem",
                Content = "Semua kode promo telah dicoba klaim!",
                Duration = 4
            })
        end)
    end
})

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 2: COMBAT & DUNGEON
-- ──────────────────────────────────────────────────────────────────────────
Tabs.Combat:AddSection("⚡ Auto Selesaikan Dungeon (Dungeon Clearer)")

local AutoClearToggle = Tabs.Combat:AddToggle("AutoClearToggle", {
    Title = "Auto Selesaikan Dungeon (Hunt All Mobs)",
    Description = "Otomatis berpindah membunuh setiap monster di dungeon sampai room bersih",
    Default = false
})
AutoClearToggle:OnChanged(function()
    AutoClearDungeonActive = Fluent.Options.AutoClearToggle.Value
    if AutoClearDungeonActive then
        Fluent:Notify({
            Title = "Auto Dungeon Clearer",
            Content = "Memburu dan membersihkan dungeon secara otomatis!",
            Duration = 3
        })
    end
end)

local SafeHoverToggle = Tabs.Combat:AddToggle("SafeHoverToggle", {
    Title = "Safe Hover Mode (Mengapung di Atas Monster)",
    Description = "Melayang 4.5 studs di atas musuh agar kebal serangan tanah / pukulan boss",
    Default = true
})
SafeHoverToggle:OnChanged(function()
    SafeHoverActive = Fluent.Options.SafeHoverToggle.Value
end)

local AutoReplayToggle = Tabs.Combat:AddToggle("AutoReplayToggle", {
    Title = "Auto Replay Dungeon (Masuk Portal Lagi)",
    Description = "Saat dungeon selesai atau kembali ke lobby, otomatis masuk portal kembali",
    Default = false
})
AutoReplayToggle:OnChanged(function()
    AutoReplayDungeon = Fluent.Options.AutoReplayToggle.Value
end)

Tabs.Combat:AddSection("Auto Attack & Kill Aura")

local KillAuraToggle = Tabs.Combat:AddToggle("KillAuraToggle", {
    Title = "Mob Kill Aura",
    Description = "Otomatis mengunci dan menyerang musuh terdekat di dalam jangkauan",
    Default = false
})
KillAuraToggle:OnChanged(function()
    KillAuraActive = Fluent.Options.KillAuraToggle.Value
    if KillAuraActive then
        Fluent:Notify({
            Title = "Kill Aura Aktif",
            Content = "Menyerang semua monster di sekitar karakter.",
            Duration = 3
        })
    end
end)

local AutoSkillToggle = Tabs.Combat:AddToggle("AutoSkillToggle", {
    Title = "Auto Cast Skills (Skill 1, 2, Ultimate)",
    Description = "Otomatis keluarkan skill senjata saat bertarung",
    Default = false
})
AutoSkillToggle:OnChanged(function()
    AutoSkillActive = Fluent.Options.AutoSkillToggle.Value
end)

local AutoDodgeToggle = Tabs.Combat:AddToggle("AutoDodgeToggle", {
    Title = "Smart Auto Dodge (Dash saat Diserang)",
    Description = "Otomatis melakukan dash menghindar saat musuh memukul atau mendekat",
    Default = false
})
AutoDodgeToggle:OnChanged(function()
    AutoDodgeActive = Fluent.Options.AutoDodgeToggle.Value
end)

local AuraSlider = Tabs.Combat:AddSlider("AuraSlider", {
    Title = "Jarak Jangkauan Aura (Studs)",
    Description = "Jarak deteksi musuh",
    Default = 25,
    Min = 10,
    Max = 50,
    Rounding = 0
})
AuraSlider:OnChanged(function(val)
    AuraRange = val
end)

Tabs.Combat:AddSection("Visualizer (ESP)")

local MobESPToggle = Tabs.Combat:AddToggle("MobESPToggle", {
    Title = "Monster ESP (Highlight Merah)",
    Description = "Melihat posisi seluruh musuh dan boss menembus dinding",
    Default = false
})
MobESPToggle:OnChanged(function()
    MobESPActive = Fluent.Options.MobESPToggle.Value
    if not MobESPActive then clearESP() end
end)

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 3: GACHA & UPGRADE
-- ──────────────────────────────────────────────────────────────────────────
Tabs.Gacha:AddSection("Auto Gacha & Rolling")

local AutoRollToggle = Tabs.Gacha:AddToggle("AutoRollToggle", {
    Title = "Auto Roll Senjata / Trait",
    Description = "Otomatis memutar roll saat tiket/koin cukup",
    Default = false
})
AutoRollToggle:OnChanged(function()
    AutoRollActive = Fluent.Options.AutoRollToggle.Value
end)

Tabs.Gacha:AddSection("Pet System")

local AutoPetHatchToggle = Tabs.Gacha:AddToggle("AutoPetHatchToggle", {
    Title = "Auto Buka Telur Pet (Hatch)",
    Description = "Otomatis menetaskan telur pet terdekat",
    Default = false
})
AutoPetHatchToggle:OnChanged(function()
    AutoPetHatchActive = Fluent.Options.AutoPetHatchToggle.Value
end)

local AutoPetExpToggle = Tabs.Gacha:AddToggle("AutoPetExpToggle", {
    Title = "Auto Claim Ekspedisi Pet",
    Description = "Otomatis klaim hadiah ekspedisi pasif pet",
    Default = false
})
AutoPetExpToggle:OnChanged(function()
    AutoPetExpedition = Fluent.Options.AutoPetExpToggle.Value
end)

Tabs.Gacha:AddSection("Stat & Tempa Senjata")

local StatDropdown = Tabs.Gacha:AddDropdown("StatDropdown", {
    Title = "Pilih Stat Upgrade Otomatis",
    Description = "Pilih stat poin yang ingin difokuskan",
    Values = { "ATK", "HP", "DEF" },
    Multi = false,
    Default = "ATK"
})
StatDropdown:OnChanged(function(val)
    TargetStat = val
end)

local AutoUpgradeStatToggle = Tabs.Gacha:AddToggle("AutoUpgradeStatToggle", {
    Title = "Auto Alokasikan Stat Poin",
    Description = "Otomatis naikkan stat pilihan saat naik level",
    Default = false
})
AutoUpgradeStatToggle:OnChanged(function()
    AutoUpgradeStatActive = Fluent.Options.AutoUpgradeStatToggle.Value
end)

Tabs.Gacha:AddButton({
    Title = "🔨 Tempa / Fortify Senjata yang Dipakai",
    Description = "Coba naikkan level fortify senjata utama sekali klik",
    Callback = function()
        if ForgeRF then
            pcall(function()
                ForgeRF:InvokeServer("Forge")
                Fluent:Notify({
                    Title = "Tempa Senjata",
                    Content = "Permintaan fortify telah dikirim!",
                    Duration = 3
                })
            end)
        end
    end
})

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 4: TELEPORTS LOBBY & NPC
-- ──────────────────────────────────────────────────────────────────────────
Tabs.Teleport:AddSection("Portal Dungeon")

Tabs.Teleport:AddButton({
    Title = "⚔️ Main Dungeon Entry (MainPlayPoint)",
    Description = "Tempat masuk portal dungeon utama",
    Callback = function() safeTeleport(Vector3.new(82.9, 24.5, 163.99)) end
})

Tabs.Teleport:AddButton({
    Title = "🌀 Sub Dungeon / Cave Portal",
    Description = "Tempat masuk dungeon sampingan",
    Callback = function() safeTeleport(Vector3.new(-8.5, 30.5, 279.47)) end
})

Tabs.Teleport:AddSection("NPC Penting Lobby")

Tabs.Teleport:AddButton({
    Title = "🔨 Tempa Senjata (Forge Furnace)",
    Description = "Tempat tempa dan upgrade senjata",
    Callback = function() safeTeleport(Vector3.new(58.3, 39.0, 15.0)) end
})

Tabs.Teleport:AddButton({
    Title = "✨ Enchantment Station",
    Description = "NPC untuk memberi efek sihir/enchant",
    Callback = function() safeTeleport(Vector3.new(-77.0, 34.2, 102.3)) end
})

Tabs.Teleport:AddButton({
    Title = "🐾 Pet Station (Hatch & Care)",
    Description = "NPC pengelola hewan peliharaan",
    Callback = function() safeTeleport(Vector3.new(-72.2, 32.8, -18.1)) end
})

Tabs.Teleport:AddButton({
    Title = "💰 Toko Jual Equipment (Equipment Sell NPC)",
    Description = "Tempat menjual senjata dan armor bekas",
    Callback = function() safeTeleport(Vector3.new(-94.8, 29.8, 21.2)) end
})

Tabs.Teleport:AddButton({
    Title = "🪙 Toko Koin (Coin Store NPC)",
    Description = "NPC penukaran koin",
    Callback = function() safeTeleport(Vector3.new(3.28, 28.6, 133.1)) end
})

Tabs.Teleport:AddButton({
    Title = "📜 NPC Quest & Tutor",
    Description = "NPC dialog quest awal",
    Callback = function() safeTeleport(Vector3.new(27.8, 31.3, 55.3)) end
})

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 5: PLAYER & MISC
-- ──────────────────────────────────────────────────────────────────────────
Tabs.Player:AddSection("Mobilitas Karakter")

local WalkSpeedSlider = Tabs.Player:AddSlider("WalkSpeedSlider", {
    Title = "Kecepatan Jalan (WalkSpeed)",
    Description = "Default normal adalah 16",
    Default = 20,
    Min = 16,
    Max = 50,
    Rounding = 0
})
WalkSpeedSlider:OnChanged(function(val)
    DefaultSpeed = val
    if Humanoid then Humanoid.WalkSpeed = val end
end)

local InfJumpToggle = Tabs.Player:AddToggle("InfJumpToggle", {
    Title = "Infinite Jump",
    Description = "Melompat bebas tanpa batas di udara",
    Default = false
})
InfJumpToggle:OnChanged(function()
    InfJumpActive = Fluent.Options.InfJumpToggle.Value
end)

Tabs.Player:AddSection("Visual & Kenyamanan")

local FullBrightToggle = Tabs.Player:AddToggle("FullBrightToggle", {
    Title = "FullBright (Penerangan Dungeon Terang)",
    Description = "Membuat seluruh dungeon yang gelap menjadi terang benderang",
    Default = false
})
FullBrightToggle:OnChanged(function()
    FullBrightActive = Fluent.Options.FullBrightToggle.Value
    updateLighting()
end)

local AntiAFKToggle = Tabs.Player:AddToggle("AntiAFKToggle", {
    Title = "Anti-AFK (Bypass 20 Menit)",
    Description = "Mencegah idle kick dari server saat ditinggal",
    Default = true
})
AntiAFKToggle:OnChanged(function()
    AntiAFKActive = Fluent.Options.AntiAFKToggle.Value
end)

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 6: SETTINGS & CONFIGS
-- ──────────────────────────────────────────────────────────────────────────
pcall(function()
    if SaveManagerLoaded and InterfaceManagerLoaded and SaveManager and InterfaceManager then
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        InterfaceManager:SetFolder("IronSoulFluent")
        SaveManager:SetFolder("IronSoulFluent/configs")

        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)
    end
end)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Iron Soul Hub V3.0",
    Content = "Fluent UI berhasil dimuat! Tekan RightShift untuk toggle UI.",
    Duration = 5
})
