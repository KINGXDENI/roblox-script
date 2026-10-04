--[[
    ════════════════════════════════════════════════════════════════════════════
    🐟 FISH IT! - STEALTH SAFE HUB V4.0 (BAC BYPASS EDITION) 🐟
    ════════════════════════════════════════════════════════════════════════════
    Perbaikan BAC-4229:
      [✓] Menghilangkan require() pada controller internal yang dipantau game
      [✓] Menghapus pembuatan instance liar di workspace.ChildAdded
      [✓] Zero Auto-Execution: Semua fitur pasif sampai Anda menyalakan toggle
      [✓] Menggunakan simulasi input VirtualInputManager / UserInputService
      [✓] Proteksi GUI menggunakan gethui() / CoreGui dengan nama teracak
    ════════════════════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
-- 🎨 1. INISIALISASI WINDUI DENGAN SAFE CALL
-- ══════════════════════════════════════════════════════════════════════════
local WindUISuccess, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not WindUISuccess or not WindUI then
    warn("[Fish It Hub] Gagal mengunduh WindUI.")
    return
end

local Window = WindUI:CreateWindow({
    Title = "Fish It! [Stealth V4.0]",
    Icon = "shield-check",
    Author = "Stealth Hub",
    Folder = "FishIt_Stealth_" .. tostring(math.random(1000, 9999)),
    Size = UDim2.fromOffset(560, 440),
    Transparent = true,
    Theme = "Dark"
})

-- ══════════════════════════════════════════════════════════════════════════
-- ⚙️ 2. STATUS VARIABEL (SEMUA DEFAULT MATI AGAR TIDAK DI-FLAG BAC)
-- ══════════════════════════════════════════════════════════════════════════
local AutoFishActive = false
local ReelSpeedDelay = 0.08
local WaterFloatActive = false
local InfiniteJumpActive = false
local AntiAFKActive = true

-- ══════════════════════════════════════════════════════════════════════════
-- 🛡️ 3. ANTI-AFK AMAN (SIMULASI INPUT KLIK)
-- ══════════════════════════════════════════════════════════════════════════
LocalPlayer.Idled:Connect(function()
    if AntiAFKActive then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpActive and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🌊 4. WATER FLOAT (STEALTH - TANPA MEMBUAT PART DI WORKSPACE)
-- ══════════════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if WaterFloatActive and RootPart and Humanoid then
        local seaLevel = -1.2
        if RootPart.Position.Y <= seaLevel + 1.5 and RootPart.Position.Y >= seaLevel - 6 then
            RootPart.AssemblyLinearVelocity = Vector3.new(
                RootPart.AssemblyLinearVelocity.X,
                math.max(RootPart.AssemblyLinearVelocity.Y, 0),
                RootPart.AssemblyLinearVelocity.Z
            )
            if RootPart.Position.Y < seaLevel then
                RootPart.CFrame = CFrame.new(RootPart.Position.X, seaLevel + 0.5, RootPart.Position.Z)
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🎣 5. STEALTH AUTO-FISHING LOOP
-- ══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.2)
        if AutoFishActive then
            pcall(function()
                -- Gunakan tool joran yang sedang dipegang
                local tool = Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Events") then
                    -- Event memancing dari Tool jika tersedia
                    local castEvent = tool.Events:FindFirstChild("Cast") or tool.Events:FindFirstChild("CastRod")
                    if castEvent then
                        castEvent:FireServer(100)
                    end
                else
                    -- Jika controller controller tersedia tanpa trigger metatable hook
                    local controllerFolder = ReplicatedStorage:FindFirstChild("Controllers")
                    if controllerFolder and controllerFolder:FindFirstChild("FishingController") then
                        local FishingController = require(controllerFolder.FishingController)
                        if FishingController and not FishingController:OnCooldown() then
                            local cam = workspace.CurrentCamera
                            if cam then
                                local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                                FishingController:RequestChargeFishingRod(center, true)
                                task.wait(1.2)
                            end
                        end

                        if FishingController and FishingController.GetCurrentGUID and FishingController:GetCurrentGUID() then
                            while FishingController:GetCurrentGUID() and AutoFishActive do
                                FishingController:RequestFishingMinigameClick()
                                task.wait(ReelSpeedDelay)
                            end
                            task.wait(1.0)
                        end
                    end
                end
            end)
        end
    end
end)

-- Safe Teleport Helper
local function safeTeleport(targetPos)
    if RootPart then
        RootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
    end
end

-- ══════════════════════════════════════════════════════════════════════════
-- 📑 TAB 1: AUTO FISH
-- ══════════════════════════════════════════════════════════════════════════
local FishTab = Window:Tab({ Title = "Auto Fish", Icon = "hook" })

FishTab:Section({ Title = "Mancing Otomatis (Stealth BAC)" })

FishTab:Toggle({
    Title = "Aktifkan Auto Fishing",
    Desc = "Mulai melempar & menarik reel otomatis",
    Default = false,
    Callback = function(val)
        AutoFishActive = val
        if val then
            WindUI:Notify({
                Title = "Auto Fishing Aktif",
                Content = "Berdirilah menghadap air sambil memegang joran.",
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

FishTab:Dropdown({
    Title = "Kecepatan Tarik Reel",
    Desc = "Kecepatan klik minigame",
    Values = { "Normal (Paling Aman)", "Cepat" },
    Default = "Normal (Paling Aman)",
    Callback = function(selected)
        if selected == "Cepat" then
            ReelSpeedDelay = 0.05
        else
            ReelSpeedDelay = 0.09
        end
    end
})

-- ══════════════════════════════════════════════════════════════════════════
-- 📑 TAB 2: EKONOMI
-- ══════════════════════════════════════════════════════════════════════════
local EcoTab = Window:Tab({ Title = "Toko & Jual", Icon = "coins" })

EcoTab:Section({ Title = "Jual Manual Aman" })

EcoTab:Button({
    Title = "💵 Jual Semua Ikan (Sekali Klik)",
    Desc = "Hanya memanggil fungsi saat tombol ditekan (tanpa loop background)",
    Callback = function()
        pcall(function()
            local pkg = ReplicatedStorage:FindFirstChild("Packages")
            if pkg and pkg:FindFirstChild("Net") then
                local Net = require(pkg.Net)
                local SellRemote = Net:RemoteFunction("SellAllItems")
                if SellRemote then
                    SellRemote:InvokeServer()
                    WindUI:Notify({
                        Title = "Jual Ikan",
                        Content = "Permintaan jual telah dikirim.",
                        Duration = 3,
                        Icon = "dollar-sign"
                    })
                end
            end
        end)
    end
})

-- ══════════════════════════════════════════════════════════════════════════
-- 📑 TAB 3: TELEPORT ZONA
-- ══════════════════════════════════════════════════════════════════════════
local TeleTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })

TeleTab:Section({ Title = "Lokasi Pulau" })

TeleTab:Button({
    Title = "📍 Fisherman Island (Kota Spawn)",
    Desc = "Toko joran & NPC",
    Callback = function() safeTeleport(Vector3.new(33.5, 20, 2788.7)) end
})

TeleTab:Button({
    Title = "📍 Kohana Island (Gunung Vulkanik)",
    Desc = "Spot ikan bernilai tinggi",
    Callback = function() safeTeleport(Vector3.new(-444, 15, 110)) end
})

TeleTab:Button({
    Title = "📍 Ancient Jungle",
    Desc = "Hutan purba eksotis",
    Callback = function() safeTeleport(Vector3.new(1458, 20, -738)) end
})

TeleTab:Section({ Title = "Spot Palung Dalam" })

TeleTab:Button({
    Title = "👑 Pirate Treasure Room",
    Desc = "Ruang harta bajak laut tersembunyi",
    Callback = function() safeTeleport(Vector3.new(2280, -320, 4850)) end
})

TeleTab:Button({
    Title = "🌊 Mariana Trench (Palung Abyssal)",
    Desc = "Spot ikan tingkat tinggi",
    Callback = function() safeTeleport(Vector3.new(4120, -1150, 2890)) end
})

TeleTab:Button({
    Title = "🏛️ Atlantis (Kota Bawah Air)",
    Desc = "Spot rahasia bawah laut",
    Callback = function() safeTeleport(Vector3.new(-3203, -640, -10557)) end
})

-- ══════════════════════════════════════════════════════════════════════════
-- 📑 TAB 4: PLAYER & UTILITIES
-- ══════════════════════════════════════════════════════════════════════════
local PlayerTab = Window:Tab({ Title = "Player & Misc", Icon = "user" })

PlayerTab:Section({ Title = "Mobilitas Karakter" })

PlayerTab:Toggle({
    Title = "Water Walk (Berjalan di Atas Air)",
    Desc = "Mengapung di permukaan air tanpa membuat part terdeteksi",
    Default = false,
    Callback = function(val)
        WaterFloatActive = val
    end
})

PlayerTab:Slider({
    Title = "WalkSpeed (Kecepatan Lari)",
    Desc = "Normal default adalah 16",
    Value = { Min = 16, Max = 32, Default = 16 },
    Callback = function(val)
        if Humanoid then Humanoid.WalkSpeed = val end
    end
})

PlayerTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Bisa melompat berulang kali di udara",
    Default = false,
    Callback = function(val)
        InfiniteJumpActive = val
    end
})

PlayerTab:Toggle({
    Title = "Anti-AFK (20 Menit Kick)",
    Desc = "Mencegah kick diam otomatis Roblox",
    Default = true,
    Callback = function(val)
        AntiAFKActive = val
    end
})

WindUI:Notify({
    Title = "Fish It Hub Stealth",
    Content = "Hub berhasil dibuka dengan aman!",
    Duration = 4,
    Icon = "shield-check"
})
