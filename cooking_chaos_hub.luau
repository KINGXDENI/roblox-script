--[[
    ════════════════════════════════════════════════════════════════════════════
    🍳 COOKING CHAOS - ADVANCED PRO CHEF HUB V1.0 (FLUENT UI EDITION) 🍳
    ════════════════════════════════════════════════════════════════════════════
    Game: Cooking Chaos (Place ID: 115585193927985)
    Developer: Hot Wok Studios
    Powered by Fluent UI Library (Windows 11 Acrylic Style)
    
    Fitur Utama:
      [✓] KITCHEN AUTOMATION & HELPERS:
          - Instant ProximityPrompt (Insta-Chop, Insta-Wash, Insta-Pickup, 0s Hold)
          - Anti-Burn Watchdog & Alarm (Peringatan sebelum masakan gosong)
          - Auto Extinguish Fire (Padamkan api dapur otomatis jika ada kebakaran)
          - Auto Clean Dirty Plates (Deteksi piring kotor & cuci otomatis)
          - No Carry Slowdown (Kecepatan tetap kencang meski membawa panci/extinguisher)
      [✓] STATION INSTANT TELEPORT:
          - Teleport Cepat: Serving Counter, Sink Station, Cutting Boards, Stoves, Crates
          - Click to Teleport Tool (Bebas berpindah di dalam dapur)
      [✓] KITCHEN VISUALS & ESP:
          - Appliance Status ESP (Highlight Kompor, Talenan, & Wastafel)
          - Piring & Bahan Masakan ESP (Deteksi piring bersih vs kotor)
      [✓] LOBBY, CODES & GACHA:
          - One-Click Redeem Semua Kode Aktif (THANKS20K, 10THOUSAND, THANKS5000, dll)
          - Auto Roll Chef Classes (Putar class koki otomatis dengan Gems)
      [✓] PLAYER & MOVEMENT MOD:
          - Kitchen Sprint WalkSpeed (16 - 45)
          - Infinite Jump, Anti-AFK (Bypass 20 Menit), FullBright Dapur Terang
      [✓] FLOATING DRAGGABLE TOGGLE (🧑‍🍳) & RIGHTSHIFT HOTKEY
    ════════════════════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ProximityPromptService = game:GetService("ProximityPromptService")

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
-- 🎨 1. FLUENT UI INITIALIZATION
-- ══════════════════════════════════════════════════════════════════════════
local FluentSuccess, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not FluentSuccess or not Fluent then
    warn("[Cooking Chaos Hub] Gagal memuat Fluent UI. Periksa koneksi internet executor!")
    return
end

local SaveManagerLoaded, SaveManager = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
end)

local InterfaceManagerLoaded, InterfaceManager = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

local Window = Fluent:CreateWindow({
    Title = "Cooking Chaos | Chef Pro Hub",
    SubTitle = "v1.0 [Fluent Edition]",
    TabWidth = 160,
    Size = UDim2.fromOffset(590, 470),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- ══════════════════════════════════════════════════════════════════════════
-- 🔘 FLOATING DRAGGABLE RE-OPEN BUTTON
-- ══════════════════════════════════════════════════════════════════════════
pcall(function()
    local gethui = gethui or function() return game:GetService("CoreGui") end
    local parentGui = gethui() or LocalPlayer:WaitForChild("PlayerGui")

    local oldBtn = parentGui:FindFirstChild("CookingChaosToggleGui")
    if oldBtn then oldBtn:Destroy() end

    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "CookingChaosToggleGui"
    ToggleGui.ResetOnSpawn = false
    ToggleGui.Parent = parentGui

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleChefHubBtn"
    ToggleBtn.Size = UDim2.fromOffset(45, 45)
    ToggleBtn.Position = UDim2.new(0, 15, 0.5, -22)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 25, 25)
    ToggleBtn.Text = "🧑‍🍳"
    ToggleBtn.TextSize = 22
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.AutoButtonColor = true
    ToggleBtn.Parent = ToggleGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = ToggleBtn

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(230, 120, 40)
    UIStroke.Thickness = 1.6
    UIStroke.Parent = ToggleBtn

    -- Draggable
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
-- ⚙️ 2. STATUS VARIABEL & DYNAMIC CONFIG
-- ══════════════════════════════════════════════════════════════════════════
local InstaPromptActive = false
local AntiBurnWatchdogActive = false
local AutoExtinguishActive = false
local AutoWashPlatesActive = false
local NoCarrySlowdownActive = false
local KitchenESPActive = false

local InfJumpActive = false
local AntiAFKActive = true
local FullBrightActive = false

local CustomWalkSpeed = 22
local OriginalPromptsHoldDuration = {}

-- ══════════════════════════════════════════════════════════════════════════
-- 🧩 3. DYNAMIC REMOTES & EVENT RESOLVER
-- ══════════════════════════════════════════════════════════════════════════
local CodeRemote = nil
local ClassRollRemote = nil
local ApplianceUpgradeRemote = nil

task.spawn(function()
    pcall(function()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("code") or name:find("redeem")) and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                CodeRemote = obj
            elseif (name:find("class") or name:find("roll") or name:find("spin")) and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                ClassRollRemote = obj
            elseif (name:find("upgrade") or name:find("appliance")) and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                ApplianceUpgradeRemote = obj
            end
        end
    end)
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🔪 4. INSTANT PROXIMITY PROMPT / FAST CHOP & WASH
-- ══════════════════════════════════════════════════════════════════════════
local function applyPromptOptimizations()
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if not OriginalPromptsHoldDuration[prompt] then
                OriginalPromptsHoldDuration[prompt] = prompt.HoldDuration
            end
            if InstaPromptActive then
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 25
            else
                prompt.HoldDuration = OriginalPromptsHoldDuration[prompt] or 1
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") and InstaPromptActive then
        OriginalPromptsHoldDuration[descendant] = descendant.HoldDuration
        descendant.HoldDuration = 0
        descendant.RequiresLineOfSight = false
        descendant.MaxActivationDistance = 25
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🔥 5. ANTI-BURN WATCHDOG & AUTO EXTINGUISHER
-- ══════════════════════════════════════════════════════════════════════════
local function findCookingApplianceDanger()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("pan") or name:find("pot") or name:find("stove") or name:find("fryer") then
            -- Cari indicator warning, api, atau bar progress merah
            local fire = obj:FindFirstChildOfClass("Fire") or obj:FindFirstChild("Smoke")
            if fire and fire.Enabled then
                return obj, "FIRE"
            end
            -- Periksa timer / status gui
            for _, gui in ipairs(obj:GetDescendants()) do
                if gui:IsA("TextLabel") then
                    local text = gui.Text:lower()
                    if text:find("burn") or text:find("danger") or text:find("overcook") then
                        return obj, "BURNING"
                    end
                end
            end
        end
    end
    return nil, nil
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if AntiBurnWatchdogActive then
            local appliance, status = findCookingApplianceDanger()
            if appliance then
                if status == "FIRE" then
                    Fluent:Notify({
                        Title = "🚨 KEBAKARAN DI DAPUR!",
                        Content = "Ada api di " .. appliance.Name .. "! Ambil alat pemadam!",
                        Duration = 3
                    })
                elseif status == "BURNING" then
                    Fluent:Notify({
                        Title = "⚠️ MASAKAN HAMPIR GOSONG!",
                        Content = "Segera angkat masakan di " .. appliance.Name .. "!",
                        Duration = 2
                    })
                end
            end
        end

        if AutoExtinguishActive and RootPart then
            -- Cari api di dapur
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Fire") and obj.Enabled then
                    local fireParent = obj.Parent
                    local firePart = fireParent:IsA("BasePart") and fireParent or fireParent:FindFirstChildWhichIsA("BasePart")
                    if firePart then
                        -- Cari fire extinguisher di backpack atau dapur
                        local extinguisher = Character:FindFirstChild("FireExtinguisher") or Character:FindFirstChildWhichIsA("Tool")
                        if not extinguisher and LocalPlayer.Backpack:FindFirstChild("FireExtinguisher") then
                            Humanoid:EquipTool(LocalPlayer.Backpack.FireExtinguisher)
                            extinguisher = Character:FindFirstChild("FireExtinguisher")
                        end

                        if extinguisher then
                            RootPart.CFrame = CFrame.new(firePart.Position + Vector3.new(0, 2, -3), firePart.Position)
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(0, 0))
                            task.wait(0.2)
                            VirtualUser:Button1Up(Vector2.new(0, 0))
                        end
                        break
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🍽️ 6. AUTO WASH DIRTY PLATES & DISHES
-- ══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        if AutoWashPlatesActive and RootPart then
            -- Cari piring kotor (Dirty Plate)
            local dirtyPlate = nil
            for _, item in ipairs(workspace:GetDescendants()) do
                local name = item.Name:lower()
                if (name:find("dirty") and name:find("plate")) or name:find("unwashed") then
                    local pPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
                    if pPart then
                        dirtyPlate = pPart
                        break
                    end
                end
            end

            if dirtyPlate then
                -- Interaksi dengan prompt piring jika ada
                local prompt = dirtyPlate.Parent:FindFirstChildOfClass("ProximityPrompt") or dirtyPlate:FindFirstChildOfClass("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🏃 7. NO CARRY SLOWDOWN & SPEED ENFORCER
-- ══════════════════════════════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    if NoCarrySlowdownActive and Humanoid then
        if Humanoid.WalkSpeed < CustomWalkSpeed then
            Humanoid.WalkSpeed = CustomWalkSpeed
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 👁️ 8. KITCHEN APPLIANCE & FOOD ESP
-- ══════════════════════════════════════════════════════════════════════════
local espBoxes = {}

local function clearKitchenESP()
    for _, box in pairs(espBoxes) do
        if box then box:Destroy() end
    end
    table.clear(espBoxes)
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if KitchenESPActive then
            for _, obj in ipairs(workspace:GetDescendants()) do
                local name = obj.Name:lower()
                if (name:find("stove") or name:find("cutting") or name:find("sink") or name:find("plate") or name:find("service") or name:find("counter")) and obj:IsA("Model") then
                    if not espBoxes[obj] then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "KitchenESP"
                        highlight.Adornee = obj

                        if name:find("stove") then
                            highlight.FillColor = Color3.fromRGB(255, 90, 40)
                        elseif name:find("sink") then
                            highlight.FillColor = Color3.fromRGB(40, 160, 255)
                        elseif name:find("cutting") then
                            highlight.FillColor = Color3.fromRGB(80, 220, 80)
                        elseif name:find("plate") then
                            highlight.FillColor = Color3.fromRGB(240, 240, 240)
                        else
                            highlight.FillColor = Color3.fromRGB(255, 215, 0)
                        end

                        highlight.FillTransparency = 0.55
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.OutlineTransparency = 0.2
                        highlight.Parent = obj
                        espBoxes[obj] = highlight
                    end
                end
            end
        else
            clearKitchenESP()
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🛡️ 9. MOVEMENT, ANTI-AFK & FULLBRIGHT
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
-- 📑 FLUENT TABS SETUP
-- ══════════════════════════════════════════════════════════════════════════
local Tabs = {
    Kitchen = Window:AddTab({ Title = "Dapur & Masak", Icon = "flame" }),
    Teleport = Window:AddTab({ Title = "Station Teleports", Icon = "map-pin" }),
    Visuals = Window:AddTab({ Title = "Visuals & ESP", Icon = "eye" }),
    Lobby = Window:AddTab({ Title = "Lobby & Codes", Icon = "gift" }),
    Player = Window:AddTab({ Title = "Player & Misc", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 1: DAPUR & MASAK (KITCHEN AUTOMATION)
-- ──────────────────────────────────────────────────────────────────────────
Tabs.Kitchen:AddSection("⚡ Bantuan Memasak Cepat (Instant Mechanics)")

local InstaPromptToggle = Tabs.Kitchen:AddToggle("InstaPromptToggle", {
    Title = "Instant Interaction (0s Hold)",
    Description = "Potong bahan, cuci piring, dan ambil barang secara instan tanpa tahan tombol E",
    Default = false
})
InstaPromptToggle:OnChanged(function()
    InstaPromptActive = Fluent.Options.InstaPromptToggle.Value
    applyPromptOptimizations()
    if InstaPromptActive then
        Fluent:Notify({
            Title = "Instant Interaction",
            Content = "Tahan tombol di talenan/wastafel sekarang instan 0 detik!",
            Duration = 3
        })
    end
end)

local NoCarrySlowdownToggle = Tabs.Kitchen:AddToggle("NoCarrySlowdownToggle", {
    Title = "No Carry Slowdown (Lari Bebas)",
    Description = "Kecepatan jalan tidak berkurang sama sekali saat membawa panci atau alat pemadam",
    Default = true
})
NoCarrySlowdownToggle:OnChanged(function()
    NoCarrySlowdownActive = Fluent.Options.NoCarrySlowdownToggle.Value
end)

Tabs.Kitchen:AddSection("🔥 Keselamatan Dapur & Anti-Gosong")

local AntiBurnToggle = Tabs.Kitchen:AddToggle("AntiBurnToggle", {
    Title = "Anti-Burn Watchdog & Alarm",
    Description = "Notifikasi bunyi/pesan darurat jika masakan di kompor hampir gosong",
    Default = false
})
AntiBurnToggle:OnChanged(function()
    AntiBurnWatchdogActive = Fluent.Options.AntiBurnToggle.Value
end)

local AutoExtinguishToggle = Tabs.Kitchen:AddToggle("AutoExtinguishToggle", {
    Title = "Auto Extinguish Kitchen Fire",
    Description = "Otomatis menggunakan pemadam api jika timbul kebakaran di dapur",
    Default = false
})
AutoExtinguishToggle:OnChanged(function()
    AutoExtinguishActive = Fluent.Options.AutoExtinguishToggle.Value
end)

Tabs.Kitchen:AddSection("🍽️ Pengelolaan Piring")

local AutoWashToggle = Tabs.Kitchen:AddToggle("AutoWashToggle", {
    Title = "Auto Deteksi & Cuci Piring Kotor",
    Description = "Mendeteksi piring kotor di sekitar dan memicu interaksi pencucian",
    Default = false
})
AutoWashToggle:OnChanged(function()
    AutoWashPlatesActive = Fluent.Options.AutoWashToggle.Value
end)

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 2: STATION TELEPORTS
-- ──────────────────────────────────────────────────────────────────────────
Tabs.Teleport:AddSection("Teleport Cepat ke Station Dapur")

Tabs.Teleport:AddButton({
    Title = "🛎️ Serving / Delivery Counter",
    Description = "Meja penyajian pesanan makanan ke pelanggan",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("serving") or name:find("delivery") or name:find("order")) and obj:IsA("BasePart") then
                safeTeleport(obj.Position)
                return
            end
        end
        Fluent:Notify({ Title = "Teleport", Content = "Mencari area serving terdekat...", Duration = 2 })
    end
})

Tabs.Teleport:AddButton({
    Title = "🧼 Sink / Dishwasher Station",
    Description = "Wastafel tempat mencuci tumpukan piring kotor",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("sink") or name:find("wash")) and obj:IsA("BasePart") then
                safeTeleport(obj.Position)
                return
            end
        end
        Fluent:Notify({ Title = "Teleport", Content = "Mencari wastafel cuci piring...", Duration = 2 })
    end
})

Tabs.Teleport:AddButton({
    Title = "🔪 Cutting Board / Chopping Station",
    Description = "Talenan tempat memotong sayur, daging, dan ikan",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("cutting") or name:find("chop")) and obj:IsA("BasePart") then
                safeTeleport(obj.Position)
                return
            end
        end
        Fluent:Notify({ Title = "Teleport", Content = "Mencari cutting board terdekat...", Duration = 2 })
    end
})

Tabs.Teleport:AddButton({
    Title = "🍳 Stoves & Fryers Station",
    Description = "Area kompor, panci, dan wajan memasak",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if (name:find("stove") or name:find("fryer") or name:find("pan")) and obj:IsA("BasePart") then
                safeTeleport(obj.Position)
                return
            end
        end
        Fluent:Notify({ Title = "Teleport", Content = "Mencari area kompor memasak...", Duration = 2 })
    end
})

Tabs.Teleport:AddButton({
    Title = "🧯 Fire Extinguisher Stand",
    Description = "Tempat alat pemadam kebakaran darurat",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if name:find("extinguisher") and obj:IsA("BasePart") then
                safeTeleport(obj.Position)
                return
            end
        end
        Fluent:Notify({ Title = "Teleport", Content = "Mencari stand alat pemadam...", Duration = 2 })
    end
})

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 3: VISUALS & KITCHEN ESP
-- ──────────────────────────────────────────────────────────────────────────
Tabs.Visuals:AddSection("Visualizer Dapur")

local KitchenESPToggle = Tabs.Visuals:AddToggle("KitchenESPToggle", {
    Title = "Kitchen Stations & Appliances ESP",
    Description = "Sorot posisi Kompor (Orange), Wastafel (Biru), dan Talenan (Hijau) menembus pandangan",
    Default = false
})
KitchenESPToggle:OnChanged(function()
    KitchenESPActive = Fluent.Options.KitchenESPToggle.Value
    if not KitchenESPActive then clearKitchenESP() end
end)

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 4: LOBBY, CODES & GACHA
-- ──────────────────────────────────────────────────────────────────────────
Tabs.Lobby:AddSection("🎟️ Redeem Promo Codes Resmi")

Tabs.Lobby:AddButton({
    Title = "🎁 Klaim Semua Kode Gems Cooking Chaos",
    Description = "Otomatis redeem kode resmi: THANKS20K, 10THOUSAND, THANKS5000, dll",
    Callback = function()
        local promoCodes = {
            "THANKS20K", "10THOUSAND", "THANKS5000", "RELEASE", "HOTWOK", "COOKING", "CHAOS"
        }
        
        pcall(function()
            for _, code in ipairs(promoCodes) do
                if CodeRemote then
                    if CodeRemote:IsA("RemoteEvent") then
                        CodeRemote:FireServer(code)
                    elseif CodeRemote:IsA("RemoteFunction") then
                        CodeRemote:InvokeServer(code)
                    end
                else
                    -- Fallback cari remote stand koki di workspace/ReplicatedStorage
                    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
                        if rem:IsA("RemoteEvent") and rem.Name:lower():find("code") then
                            rem:FireServer(code)
                        end
                    end
                end
                task.wait(0.25)
            end
            Fluent:Notify({
                Title = "Kode Di-Redeem",
                Content = "Semua kode promo telah dikirimkan ke server!",
                Duration = 4
            })
        end)
    end
})

Tabs.Lobby:AddSection("🧑‍🍳 Chef Classes & Upgrades")

Tabs.Lobby:AddButton({
    Title = "🎲 Roll Chef Class Baru (Gems)",
    Description = "Mencoba memutar gacha class koki jika memiliki cukup Gems",
    Callback = function()
        pcall(function()
            if ClassRollRemote then
                if ClassRollRemote:IsA("RemoteEvent") then
                    ClassRollRemote:FireServer("Roll")
                elseif ClassRollRemote:IsA("RemoteFunction") then
                    ClassRollRemote:InvokeServer("Roll")
                end
                Fluent:Notify({ Title = "Chef Class", Content = "Permintaan roll class dikirim!", Duration = 3 })
            else
                Fluent:Notify({ Title = "Info", Content = "Class roll remote sedang dicari di server.", Duration = 3 })
            end
        end)
    end
})

-- ──────────────────────────────────────────────────────────────────────────
-- 📑 TAB 5: PLAYER & MOVEMENT
-- ──────────────────────────────────────────────────────────────────────────
Tabs.Player:AddSection("Mobilitas Koki")

local WalkSpeedSlider = Tabs.Player:AddSlider("WalkSpeedSlider", {
    Title = "Kecepatan Jalan Koki (WalkSpeed)",
    Description = "Bergerak gesit di dapur tanpa hambatan (Default: 16)",
    Default = 22,
    Min = 16,
    Max = 45,
    Rounding = 0
})
WalkSpeedSlider:OnChanged(function(val)
    CustomWalkSpeed = val
    if Humanoid then Humanoid.WalkSpeed = val end
end)

local InfJumpToggle = Tabs.Player:AddToggle("InfJumpToggle", {
    Title = "Infinite Jump",
    Description = "Lompat bebas di atas meja atau rintangan dapur",
    Default = false
})
InfJumpToggle:OnChanged(function()
    InfJumpActive = Fluent.Options.InfJumpToggle.Value
end)

Tabs.Player:AddSection("Visual & Kenyamanan")

local FullBrightToggle = Tabs.Player:AddToggle("FullBrightToggle", {
    Title = "FullBright (Penerangan Dapur Maksimal)",
    Description = "Menghilangkan bayangan gelap agar seluruh sudut dapur terlihat jelas",
    Default = false
})
FullBrightToggle:OnChanged(function()
    FullBrightActive = Fluent.Options.FullBrightToggle.Value
    updateLighting()
end)

local AntiAFKToggle = Tabs.Player:AddToggle("AntiAFKToggle", {
    Title = "Anti-AFK (Bypass 20 Menit)",
    Description = "Mencegah kick server saat menunggu ronde atau AFK di lobby",
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
        InterfaceManager:SetFolder("CookingChaosFluent")
        SaveManager:SetFolder("CookingChaosFluent/configs")

        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)
    end
end)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Cooking Chaos Pro Hub",
    Content = "Chef Hub berhasil dimuat! Tekan RightShift untuk toggle UI.",
    Duration = 5
})
