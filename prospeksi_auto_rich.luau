--[[
    ════════════════════════════════════════════════════════════════════════════
    💎 PROSPEKSI! [BARU] - ULTIMATE AUTO-RICH & FULL-AUTO FARM HUB V3.0 💎
    ════════════════════════════════════════════════════════════════════════════
    Powered by WindUI Library
    Features:
      [✓] FULL AUTO FARM: Auto Dig (100% Perfect) -> Auto Wash -> Smart Sell Loop
      [✓] SMART SELL ANYWHERE: Bypasses server distance check via micro-teleport
      [✓] BYPASS AUTO-PAN: Unlocks Level 5 native game Auto-Pan at Level 1
      [✓] ANTI-AFK: Prevents 20-minute idle disconnects
      [✓] PROMO CODES REDEEMER: One-click claim all available game codes
      [✓] SPEED SLIDER & INFINITE JUMP: Safe server attributes
      [✓] TELEPORT HUB: Instant travel to deposits, rivers, and merchants
      [✓] MODERN ACRYLIC WINDUI: Acrylic transparency, Lucide icons, smooth animations
    ════════════════════════════════════════════════════════════════════════════
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- Remotes
local ShopRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop")
local SellAllRemote = ShopRemotes:WaitForChild("SellAll")
local MiscRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Misc")
local ClaimCodeRemote = MiscRemotes:FindFirstChild("ClaimCode")

-- Locations Dictionary
local Locations = {
    ["Rubble Creek"] = {
        Deposit = Vector3.new(-71, 12, 36),
        Water = Vector3.new(-78, 10, 59)
    },
    ["Sunset Beach"] = {
        Deposit = Vector3.new(-95, 13, -402),
        Water = Vector3.new(-82, 10, -425)
    },
    ["Fortune River"] = {
        Deposit = Vector3.new(-412, 13, 9),
        Water = Vector3.new(-425, 10, 15)
    },
    ["Crystal Caverns"] = {
        Deposit = Vector3.new(-156, -2, 422),
        Water = Vector3.new(-145, -5, 435)
    },
    ["Volcanic Sands"] = {
        Deposit = Vector3.new(-723, 48, -329),
        Water = Vector3.new(-705, 45, -315)
    }
}

local MerchantSpot = Vector3.new(11, 26, 38)
local CurrentZone = "Rubble Creek"
local CurrentDepositSpot = Locations[CurrentZone].Deposit
local CurrentWaterSpot = Locations[CurrentZone].Water

-- State Variables
local AutoFarmEnabled = false
local AutoSellEnabled = true
local FastShakeEnabled = true
local InfJumpEnabled = false
local AntiAFKEnabled = true
local CurrentWalkSpeed = 45
local TotalCoinsEarned = 0

-- Always unlock Level 5 Auto-Pan requirement
pcall(function()
    LocalPlayer:SetAttribute("AutoPanLevel", 0)
end)

-- Anti-AFK Handler
LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Helper: Get Player's Pan Tool
local function getPanTool()
    local pan = Character:FindFirstChildWhichIsA("Tool")
    if pan and pan:FindFirstChild("Scripts") and pan.Scripts:FindFirstChild("Collect") then
        return pan
    end
    local b2 = LocalPlayer:FindFirstChild("BackpackTwo")
    if b2 then
        for _, item in ipairs(b2:GetChildren()) do
            if item:IsA("Tool") and (string.find(item.Name, "Pan") or (item:FindFirstChild("Scripts") and item.Scripts:FindFirstChild("Collect"))) then
                return item
            end
        end
    end
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and string.find(item.Name, "Pan") then
            return item
        end
    end
    return nil
end

-- Helper: Ensure Pan is Equipped
local function ensureEquipped(tool)
    if tool and tool.Parent ~= Character then
        tool.Parent = Character
        task.wait(0.2)
    end
end

-- Smart Sell: Teleports in front of Merchant NPC, executes SellAll, and returns instantly
local function smartSellAll()
    local oldPos = RootPart and RootPart.CFrame
    local earned = 0

    if RootPart and (RootPart.Position - MerchantSpot).Magnitude > 12 then
        RootPart.CFrame = CFrame.new(MerchantSpot + Vector3.new(0, 1.5, 0))
        task.wait(0.25)
    end

    pcall(function()
        earned = SellAllRemote:InvokeServer()
    end)

    task.wait(0.15)

    if oldPos and RootPart then
        RootPart.CFrame = oldPos
    end

    return earned
end

-- Teleport Helper
local function safeTeleport(pos)
    if RootPart then
        RootPart.CFrame = CFrame.new(pos + Vector3.new(0, 1.5, 0))
    end
end

-- Infinite Jump Handler
UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🔄 FULL-AUTO FARM ENGINE
-- ══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoFarmEnabled then
            local pan = getPanTool()
            if not pan then
                task.wait(1)
                continue
            end

            ensureEquipped(pan)

            local fill = pan:GetAttribute("Fill") or 0
            local statsFolder = pan:FindFirstChild("Stats")
            local capacity = (statsFolder and statsFolder:GetAttribute("Capacity")) or 5

            if fill < capacity then
                -- 🚜 TAHAP GALI (DIGGING)
                if RootPart and (RootPart.Position - CurrentDepositSpot).Magnitude > 10 then
                    safeTeleport(CurrentDepositSpot)
                    task.wait(0.3)
                end

                local scripts = pan:FindFirstChild("Scripts")
                local collect = scripts and scripts:FindFirstChild("Collect")
                local toggle = scripts and scripts:FindFirstChild("ToggleShovelActive")

                if collect and toggle then
                    pcall(function() toggle:FireServer(true) end)
                    pcall(function() collect:InvokeServer() end)
                    task.wait(0.4)
                    pcall(function() collect:InvokeServer(1, false) end) -- 100% Perfect accuracy
                    task.wait(0.5)
                    pcall(function() toggle:FireServer(false) end)
                else
                    task.wait(0.5)
                end
            else
                -- 🌊 TAHAP CUCI (WASHING / PANNING)
                if RootPart and (RootPart.Position - CurrentWaterSpot).Magnitude > 10 then
                    safeTeleport(CurrentWaterSpot)
                    task.wait(0.3)
                end

                local scripts = pan:FindFirstChild("Scripts")
                local panRemote = scripts and scripts:FindFirstChild("Pan")
                local shakeRemote = scripts and scripts:FindFirstChild("Shake")

                if panRemote then
                    pcall(function() panRemote:InvokeServer() end)
                    task.wait(0.2)

                    local shakeTimeout = os.clock() + 10
                    while Character:GetAttribute("Panning") and os.clock() < shakeTimeout and AutoFarmEnabled do
                        if shakeRemote then
                            pcall(function()
                                shakeRemote:FireServer()
                                shakeRemote:FireServer()
                                shakeRemote:FireServer()
                            end)
                        end
                        task.wait(0.06)
                    end
                    task.wait(0.4)
                end

                -- 💰 TAHAP JUAL HASIL TAMBANG (SMART SELL)
                if AutoSellEnabled then
                    local earned = smartSellAll()
                    if earned and tonumber(earned) and tonumber(earned) > 0 then
                        TotalCoinsEarned = TotalCoinsEarned + tonumber(earned)
                    end
                end

                task.wait(0.5)
            end
        end
    end
end)

-- 💰 Standalone Auto-Sell Loop
task.spawn(function()
    while true do
        task.wait(8)
        if AutoSellEnabled and not AutoFarmEnabled then
            local earned = smartSellAll()
            if earned and tonumber(earned) and tonumber(earned) > 0 then
                TotalCoinsEarned = TotalCoinsEarned + tonumber(earned)
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
-- 🎨 WINDUI IMPLEMENTATION
-- ══════════════════════════════════════════════════════════════════════════

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Prospeksi! [Baru]",
    Icon = "gem",
    Author = "Auto-Rich Hub V3",
    Folder = "ProspeksiHub",
    Size = UDim2.fromOffset(560, 430),
    Transparent = true,
    Theme = "Dark"
})

-- ═══════════════ TAB 1: AUTO FARM ═══════════════
local FarmTab = Window:Tab({ Title = "Auto Farm", Icon = "pickaxe" })

FarmTab:Section({ Title = "Siklus Tambang Otomatis" })

FarmTab:Toggle({
    Title = "Full-Auto Farm",
    Desc = "Gali pasir (100% Perfect) -> Cuci di air -> Jual otomatis",
    Default = false,
    Callback = function(val)
        AutoFarmEnabled = val
        if val then
            WindUI:Notify({
                Title = "Auto Farm",
                Content = "Auto Farm Aktif! Menambang di " .. CurrentZone,
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

FarmTab:Toggle({
    Title = "Fast Shake (Cuci Pasir Cepat)",
    Desc = "Mengocok pan dengan kecepatan tinggi saat mencuci emas di air",
    Default = true,
    Callback = function(val)
        FastShakeEnabled = val
    end
})

FarmTab:Dropdown({
    Title = "Pilih Lokasi Menambang",
    Desc = "Pilih zona tambang yang ingin difarm otomatis",
    Values = { "Rubble Creek", "Sunset Beach", "Fortune River", "Crystal Caverns", "Volcanic Sands" },
    Default = "Rubble Creek",
    Callback = function(selected)
        CurrentZone = selected
        if Locations[selected] then
            CurrentDepositSpot = Locations[selected].Deposit
            CurrentWaterSpot = Locations[selected].Water
            WindUI:Notify({
                Title = "Lokasi Berubah",
                Content = "Target tambang diatur ke: " .. selected,
                Duration = 3,
                Icon = "map-pin"
            })
        end
    end
})

FarmTab:Button({
    Title = "Buka Kunci Auto-Pan Bawaan Game",
    Desc = "Buka tombol AUTO resmi game tanpa harus mencapai Level 5",
    Callback = function()
        LocalPlayer:SetAttribute("AutoPanLevel", 0)
        WindUI:Notify({
            Title = "Bypass Berhasil",
            Content = "Auto-Pan resmi game sekarang bisa dipakai di Level 1!",
            Duration = 3,
            Icon = "unlock"
        })
    end
})

-- ═══════════════ TAB 2: EKONOMI & TOKO ═══════════════
local EcoTab = Window:Tab({ Title = "Toko & Koin", Icon = "coins" })

EcoTab:Section({ Title = "Sistem Penjualan (Smart Sell)" })

EcoTab:Toggle({
    Title = "Auto Smart-Sell",
    Desc = "Otomatis menjual isi tas ke Merchant tanpa harus jalan kaki",
    Default = true,
    Callback = function(val)
        AutoSellEnabled = val
    end
})

EcoTab:Button({
    Title = "Jual Semua Barang Sekarang",
    Desc = "Teleport sekejap ke depan Merchant -> Jual -> Balik lagi otomatis",
    Callback = function()
        WindUI:Notify({
            Title = "Menjual...",
            Content = "Memproses penjualan seluruh isi tas ke Merchant...",
            Duration = 2,
            Icon = "dollar-sign"
        })
        local earned = smartSellAll()
        if earned and tonumber(earned) and tonumber(earned) > 0 then
            TotalCoinsEarned = TotalCoinsEarned + tonumber(earned)
            WindUI:Notify({
                Title = "Penjualan Berhasil!",
                Content = "Mendapatkan +" .. tostring(earned) .. " Koin!",
                Duration = 4,
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = "Info Penjualan",
                Content = "Tas kosong atau barang sudah terjual.",
                Duration = 3,
                Icon = "info"
            })
        end
    end
})

-- ═══════════════ TAB 3: TELEPORTASI ═══════════════
local TeleTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })

TeleTab:Section({ Title = "Kota & Fasilitas" })

TeleTab:Button({
    Title = "📍 Starter Town (Merchant & Toko)",
    Desc = "Pusat kota untuk beli peralatan baru & upgrade cangkul",
    Callback = function()
        safeTeleport(MerchantSpot)
    end
})

TeleTab:Section({ Title = "Spot Tambang & Sungai" })

TeleTab:Button({
    Title = "📍 Rubble Creek (Spot Pasir)",
    Desc = "Spot tambang emas terbaik untuk pemula",
    Callback = function()
        safeTeleport(Locations["Rubble Creek"].Deposit)
    end
})

TeleTab:Button({
    Title = "📍 Sungai Rubble Creek (Air)",
    Desc = "Tempat mencuci emas terdekat dari Rubble Creek",
    Callback = function()
        safeTeleport(Locations["Rubble Creek"].Water)
    end
})

TeleTab:Button({
    Title = "📍 Sunset Beach",
    Desc = "Pantai emas & pasir berharga tinggi",
    Callback = function()
        safeTeleport(Locations["Sunset Beach"].Deposit)
    end
})

TeleTab:Button({
    Title = "📍 Crystal Caverns",
    Desc = "Goa kristal dengan mineral permata langka",
    Callback = function()
        safeTeleport(Locations["Crystal Caverns"].Deposit)
    end
})

TeleTab:Button({
    Title = "📍 Volcanic Sands",
    Desc = "Pasir vulkanik untuk mineral paling langka",
    Callback = function()
        safeTeleport(Locations["Volcanic Sands"].Deposit)
    end
})

-- ═══════════════ TAB 4: PLAYER & MISC ═══════════════
local PlayerTab = Window:Tab({ Title = "Player & Misc", Icon = "user" })

PlayerTab:Section({ Title = "Pergerakan Karakter" })

PlayerTab:Slider({
    Title = "WalkSpeed Karakter",
    Desc = "Atur kecepatan lari karakter tanpa kena rubberband",
    Value = {
        Min = 16,
        Max = 80,
        Default = 45
    },
    Callback = function(val)
        CurrentWalkSpeed = val
        if Humanoid then
            Humanoid:SetAttribute("BaseWalkSpeed", val)
        end
    end
})

PlayerTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Bisa lompat di udara berkali-kali untuk tebing tinggi",
    Default = false,
    Callback = function(val)
        InfJumpEnabled = val
    end
})

PlayerTab:Section({ Title = "Utilitas & Anti-Kick" })

PlayerTab:Toggle({
    Title = "Anti-AFK",
    Desc = "Mencegah Roblox kick otomatis setelah 20 menit saat AFK farming",
    Default = true,
    Callback = function(val)
        AntiAFKEnabled = val
    end
})

PlayerTab:Button({
    Title = "Redeem Semua Kode Promo Game",
    Desc = "Klaim semua kode reward gratis dari developer game",
    Callback = function()
        if ClaimCodeRemote then
            local codes = { "RELEASE", "UPDATE", "PROSPECTING", "FREE", "WELCOME", "GEMS", "GOLD", "SORRY" }
            for _, code in ipairs(codes) do
                pcall(function() ClaimCodeRemote:FireServer(code) end)
                task.wait(0.15)
            end
            WindUI:Notify({
                Title = "Kode Di-Redeem",
                Content = "Semua kode promo telah dikirim ke server!",
                Duration = 3,
                Icon = "gift"
            })
        end
    end
})

WindUI:Notify({
    Title = "Prospeksi V3 Hub",
    Content = "Script WindUI berhasil dimuat! Selamat menambang!",
    Duration = 5,
    Icon = "check"
})
