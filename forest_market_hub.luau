--[[
    ════════════════════════════════════════════════════════════════════════════
    PASAR HUTAN (FOREST MARKET) - WINDUI EDITION V10.0 ULTIMATE
    ════════════════════════════════════════════════════════════════════════════
    Game: Pasar Hutan (Place ID: 108679402300081 / 81032298425434)
    Developer: Project Dukun
    UI Library: WindUI (Lucide Icons, Glassmorphic Acrylic, Modern Fluid Animations)

    TABS:
    [1] 🌾 Kebun    : Auto Farm (Panen + Tanam + Siram), Capacity Monitor, Seed Selector
    [2] 🏪 Dagang   : Auto Dagang Kios (Auto-fill 3 Rak), Auto Cook
    [3] ⛏️ Tambang  : Auto Tambang Batu, Auto Tebang Pohon, Auto Buy Beliung
    [4] 🍄 Tangkap  : Sapu Bersih Map, Auto Jamur/Melati/Kemenyan/Gagak/Tuyul
    [5] 🐷 Ternak   : Status Kandang, Auto Jual Babi, Bangun Kandang
    [6] ⭐ Upgrade  : Upgrade Market (Kios), Upgrade Lahan, Buka Lahan Besar
    [7] 📱 Menu GUI : Buka Toko, Tempa, Dapur Jarak Jauh + Tombol Tutup Bersih
    [8] ⚡ Karakter : Speed, Jump, Fly, Noclip, Infinite Jump, Anti-AFK
    [9] 📍 Teleport : Teleport Kebun, Kios, Tambang, Balai Desa, Bandar Babi
    [10] 🎨 Setting : WindUI Theme Selector, Keybinds
    ════════════════════════════════════════════════════════════════════════════
--]]

local Players     = game:GetService("Players")
local Workspace   = game:GetService("Workspace")
local RS          = game:GetService("ReplicatedStorage")
local UIS         = game:GetService("UserInputService")
local RunService  = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local LP  = Players.LocalPlayer
local PG  = LP:WaitForChild("PlayerGui")
local Cam = Workspace.CurrentCamera

-- ══ REMOTE REGISTRY ══
local RemoteRegistry = require(RS:WaitForChild("RemoteRegistry"))
local RemoteFolder   = RemoteRegistry.folder("Remotes")

local _rc = {}
local function getR(name)
    if _rc[name] ~= nil then return _rc[name] end
    local found = RemoteFolder:FindFirstChild(name)
    if not found then
        local ok, r = pcall(function()
            return RemoteFolder:WaitForChild(name, 2.5)
        end)
        found = (ok and r) or false
    end
    _rc[name] = found
    return found or nil
end

-- ══ HUB STATE ══
local FLY_SPEED = 50
local State = {
    -- Kebun
    AutoFarm        = false,
    FarmSeed        = "Kentang",
    AutoHarvest     = false,
    AutoSiram       = false,
    AutoBuySeed     = false,
    AutoRotateCrop  = false,
    AutoEcoBalance  = false, -- Fitur Auto-Imbang (Eco-Balancer Tanam & Dagang)
    MinCoinReserve  = 100,   -- Batas minimal koin cadangan agar tidak boncos

    -- Dagang & Kios
    AutoDagang      = false,
    AutoSellBabi    = false,
    AutoSellMarket  = false,
    AutoOlahGagak   = false,
    AutoOlahAyam    = false,
    AutoOlahKopi    = false,

    -- Konfigurasi Khusus Box / Rak Dagangan (Slot 1 - 10 Seamless)
    KiosStrategy    = "Otomatis (Semua Rak)", -- Seamless Strategy: "Otomatis (Semua Rak)", "Fokus Crab Satay", "Fokus Kopi Kemenyan", "Fokus Kentang", "Kustom Per-Rak"
    KiosBox1        = "Otomatis",
    KiosBox2        = "Otomatis",
    KiosBox3        = "Otomatis",
    KiosBox4        = "Otomatis",
    KiosBox5        = "Otomatis",
    KiosBox6        = "Otomatis",
    KiosBox7        = "Otomatis",
    KiosBox8        = "Otomatis",
    KiosBox9        = "Otomatis",
    KiosBox10       = "Otomatis",

    -- Alternatif Dagangan (Fallback Jika Stok Utama Habis / Masih Dimasak)
    KiosUseFallback     = false,
    KiosFallbackItem    = "Jangan Isi (Tunggu Sampai Matang)",
    KiosRestockCooldown = 5,

    -- Dapur & Masak (Terpisah)
    AutoCook        = false,
    FastCook        = false,
    AutoCookFav     = false,
    FavCookTarget   = "Semua",

    -- Tambang & Beliung
    AutoTambang     = false,
    AutoTebang      = false,
    AutoBuyBeliung  = false,

    -- Foraging & Tangkap Liar (Jamur, Melati, Kemenyan, Gagak, Tuyul)
    AutoForage      = false,
    AutoGagak       = false,
    AutoTuyul       = false,
    AutoPasarGaib   = false,
    AutoGaibSnipe   = false,
    GaibSnipeTarget = "Semua",
    AutoUseGaibBuff = false,
    GaibBuffChoice  = "MinyakJelangkung",
    AutoPetiArwah   = false,
    AutoClaimJatahPeti = false,
    AutoPetiSmartPull = false,
    PetiPullPackage = 10,
    TuyulRadar      = false,
    AutoInterceptTuyul = false,
    AutoFastTuyul   = false,
    AutoSafeLoot    = false,
    LootTarget      = "Semua",
    AutoReconnect   = false,

    -- Auto Get Bahan Gratis Individual
    AutoGetGagak    = false,
    AutoGetKepiting = false,
    AutoGetDupa     = false,
    AutoGetKemenyan = false,
    AutoGetJamur    = false,
    AutoGetMelati   = false,
    AutoLootDelay   = 5,

    -- Quest & Misi Harian
    AutoClaimQuest  = false,
    AutoPociQuest   = false,
    AutoKlaimLencana= false,

    -- Pusaka & Peti Arwah
    AutoTukarPusaka = false,

    -- Smart Progression & Keahlian
    AutoSmartUpLahan= false,
    AutoSmartUpKios = false,
    AutoSpendKeahlian= false,
    KeahlianFocus   = "Tani",
    MiniHUD         = false,

    -- Speedbuy Toko Grosir
    FastShopItem    = "BibitKentang",
    FastShopAmount  = 20,

    -- Server Hop & Boost Sync
    AutoBoostSync   = false,

    -- Exploit & Bug Abuse
    AutoPetiRaceClaim   = false,  -- Race condition free pull harian
    AutoEarlyKandang    = false,  -- Early harvest kandang sebelum timer
    AutoMultiHarvest    = false,  -- Simultaneous multi-thread harvest
    HiddenShopProbe     = false,  -- Probe item tersembunyi di ShopBuy
    AutoGerobakSwap     = false,  -- Swap skin gerobak saat momen jual
    AutoGuildBoostSnipe = false,  -- Join guild saat boost aktif lalu keluar
    RaceClaimDelay      = 0.05,   -- Jeda antar race-call (detik)

    -- Advanced Exploit (Batch 2)
    AutoBruteforceCode  = false,  -- Bruteforce kode redeem developer
    AutoMiningMultiHit  = false,  -- Simultaneous multi-hit tambang batu
    AutoSiramOrang      = false,  -- Siram lahan player lain untuk EXP
    AutoTradeBoardSnipe = false,  -- Auto-accept trade menguntungkan
    AutoPetiFreeOpen    = false,  -- Probe free chest open tanpa bayar
    TradeBoardMinRatio  = 2.0,    -- Minimum rasio harga untuk auto-accept trade
    BruteforceDelay     = 0.25,   -- Jeda antar code probe (detik)

    -- Karakter & Movement
    WalkSpeed       = 16,
    JumpPower       = 50,
    Fly             = false,
    Noclip          = false,
    InfJump         = false,
    AntiAFK         = true, -- HANYA INI YANG AKTIF SECARA DEFAULT!

    -- ESP & Visuals
    ESP_Items       = false,
    ESP_Animals     = false,
    ESP_Peti        = false,
    ESP_Mining      = false,
    ESP_MaxDist     = 350,

    -- AFK, Webhook & Config
    PotatoMode      = false,
    DiscordWebhook  = "",
    AutoWebhook     = false,
    WebhookInterval = 15,
    AutoSaveConfig  = true,
}

-- ══ CORE UTILS ══
local function getChar() return LP.Character end
local function getHum()  local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function log(msg) print("[PasarHutan WindUI] " .. msg) end

local isActionBusy = false
local miniHUD = nil

local function safeFirePrompt(prompt)
    if not prompt or not prompt.Enabled then return false end
    local root = getRoot()
    if not root then return false end

    local parent = prompt.Parent
    if not parent then return false end

    local targetPos = nil
    if parent:IsA("BasePart") then
        targetPos = parent.Position
    elseif parent:IsA("Attachment") then
        targetPos = parent.WorldPosition
    elseif parent:IsA("Model") then
        targetPos = parent:GetPivot().Position
    end

    if targetPos then
        local dist = (root.Position - targetPos).Magnitude
        local maxDist = prompt.MaxActivationDistance or 8
        if dist > (maxDist + 2) then
            root.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.2, 0))
            task.wait(0.15)
        end
    end

    -- Eksekusi ProximityPrompt dengan multi-metode (mendukung tombol E, Tab, maupun Touch/Tap)
    -- Metode 1: fireproximityprompt bawaan executor
    if fireproximityprompt then
        pcall(function() fireproximityprompt(prompt) end)
        pcall(function() fireproximityprompt(prompt, 0) end)
        pcall(function() fireproximityprompt(prompt, 1, true) end)
    end

    -- Metode 2: InputHoldBegin & InputHoldEnd engine Roblox
    pcall(function()
        if prompt.InputHoldBegin then
            prompt:InputHoldBegin()
            local holdTime = (prompt.HoldDuration and prompt.HoldDuration > 0) and (prompt.HoldDuration + 0.05) or 0.05
            task.wait(holdTime)
            prompt:InputHoldEnd()
        end
    end)

    -- Metode 3: VirtualInputManager simulasi tombol resmi prompt (Tab / E)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        local key = prompt.KeyboardKeyCode or Enum.KeyCode.E
        VIM:SendKeyEvent(true, key, false, game)
        local holdTime = (prompt.HoldDuration and prompt.HoldDuration > 0) and (prompt.HoldDuration + 0.05) or 0.05
        task.wait(holdTime)
        VIM:SendKeyEvent(false, key, false, game)
    end)

    -- Metode 4: Jika tombolnya spesifik Tab atau prompt ActionText mengandung kata Tab / Tap
    local act = (prompt.ActionText or ""):lower()
    if prompt.KeyboardKeyCode == Enum.KeyCode.Tab or act:find("tab") or act:find("tap") then
        pcall(function()
            local VIM = game:GetService("VirtualInputManager")
            VIM:SendKeyEvent(true, Enum.KeyCode.Tab, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.Tab, false, game)
        end)
    end

    -- Metode 5: Fallback jika parent memiliki ClickDetector
    pcall(function()
        local cd = parent:FindFirstChildWhichIsA("ClickDetector", true) or (parent.Parent and parent.Parent:FindFirstChildWhichIsA("ClickDetector"))
        if cd and fireclickdetector then
            fireclickdetector(cd)
        end
    end)

    return true
end

-- ══ ANTI-AFK ══
task.spawn(function()
    while true do
        task.wait(45)
        if State.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ══ MOVEMENT HANDLERS ══
local function applySpeed()
    local h = getHum()
    if h then
        h.WalkSpeed = State.WalkSpeed
        h.JumpPower = State.JumpPower
    end
end
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    applySpeed()
end)

UIS.JumpRequest:Connect(function()
    if State.InfJump then
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.Stepped:Connect(function()
    if State.Noclip then
        local c = getChar()
        if not c then return end
        for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

local flyK = { w=false, s=false, a=false, d=false, up=false, dn=false }
UIS.InputBegan:Connect(function(inp, gui)
    if gui then return end
    local kc = inp.KeyCode
    if kc == Enum.KeyCode.W          then flyK.w  = true end
    if kc == Enum.KeyCode.S          then flyK.s  = true end
    if kc == Enum.KeyCode.A          then flyK.a  = true end
    if kc == Enum.KeyCode.D          then flyK.d  = true end
    if kc == Enum.KeyCode.Space      then flyK.up = true end
    if kc == Enum.KeyCode.LeftShift  then flyK.dn = true end
end)

UIS.InputEnded:Connect(function(inp)
    local kc = inp.KeyCode
    if kc == Enum.KeyCode.W          then flyK.w  = false end
    if kc == Enum.KeyCode.S          then flyK.s  = false end
    if kc == Enum.KeyCode.A          then flyK.a  = false end
    if kc == Enum.KeyCode.D          then flyK.d  = false end
    if kc == Enum.KeyCode.Space      then flyK.up = false end
    if kc == Enum.KeyCode.LeftShift  then flyK.dn = false end
end)

local function enableFly()
    local root = getRoot()
    if not root then return end
    local hum = getHum()
    if hum then hum.PlatformStand = true end

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.zero
    bv.Parent   = root

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P         = 9e4
    bg.CFrame    = root.CFrame
    bg.Parent    = root

    task.spawn(function()
        while State.Fly and root and root.Parent do
            local dir = Vector3.zero
            if flyK.w  then dir = dir + Cam.CFrame.LookVector end
            if flyK.s  then dir = dir - Cam.CFrame.LookVector end
            if flyK.a  then dir = dir - Cam.CFrame.RightVector end
            if flyK.d  then dir = dir + Cam.CFrame.RightVector end
            if flyK.up then dir = dir + Vector3.new(0, 1, 0) end
            if flyK.dn then dir = dir - Vector3.new(0, 1, 0) end

            if dir.Magnitude > 0 then
                bv.Velocity = dir.Unit * FLY_SPEED
            else
                bv.Velocity = Vector3.zero
            end
            bg.CFrame = Cam.CFrame
            RunService.RenderStepped:Wait()
        end
        bv:Destroy()
        bg:Destroy()
        if hum then hum.PlatformStand = false end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- GAME GUI CONTROLLER (OPEN & CLOSE)
-- ════════════════════════════════════════════════════════════════════════════
local function openGameGui(guiName, layerName, remoteName)
    if remoteName then
        local rem = getR(remoteName) or RS:FindFirstChild(remoteName)
        if rem then
            pcall(function()
                if rem:IsA("RemoteEvent") then rem:FireServer()
                elseif rem:IsA("RemoteFunction") then rem:InvokeServer() end
            end)
        end
    end

    if layerName then
        pcall(function()
            local uvModule = RS:FindFirstChild("UIVisibility")
            if uvModule then
                local uv = require(uvModule)
                if uv.Push then uv.Push(layerName) end
            end
        end)
    end

    pcall(function()
        local pvModule = RS:FindFirstChild("PopupVisibility")
        if pvModule then
            local pv = require(pvModule)
            local g = PG:FindFirstChild(guiName)
            if pv.Open then pv.Open(guiName, g) end
        end
    end)

    local g = PG:FindFirstChild(guiName)
    if g then
        g.Enabled = true
        for _, child in ipairs(g:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end
        log("GUI dibuka: " .. guiName)
        return true
    end

    log("GUI " .. guiName .. " tidak ditemukan di PlayerGui!")
    return false
end

local function closeGameGui(guiName, layerName)
    local g = PG:FindFirstChild(guiName)
    if not g then return end

    if layerName then
        pcall(function()
            local uv = RS:FindFirstChild("UIVisibility")
            if uv and uv.Pop then uv.Pop(layerName) end
        end)
    end

    pcall(function()
        local pv = RS:FindFirstChild("PopupVisibility")
        if pv and pv.Close then pv.Close(guiName) end
    end)

    for _, d in ipairs(g:GetDescendants()) do
        if d:IsA("GuiButton") and (d.Name:lower():find("close") or d.Name:lower():find("tutup") or d.Name:lower():find("x")) then
            -- JANGAN PERNAH klik / fire tombol di dalam slot antrean (seperti QSlot di MemasakGui) karena itu tombol cancel pesanan/masakan (CookCancel)!
            if d:FindFirstAncestor("AntrianPanel") or d:FindFirstAncestor("QSlot") or d:FindFirstAncestor("QueueTemplate") or (d.Parent and d.Parent.Name == "Row" and d.Name == "CloseBtn") then
                continue
            end
            pcall(function()
                if getconnections then
                    for _, ev in ipairs({"Activated", "MouseButton1Click"}) do
                        if d[ev] then
                            for _, conn in ipairs(getconnections(d[ev])) do conn:Fire() end
                        end
                    end
                end
            end)
        end
    end

    g.Enabled = false
    for _, child in ipairs(g:GetChildren()) do
        if child:IsA("GuiObject") then
            child.Visible = false
        end
    end
    log("GUI ditutup: " .. guiName)
end

local function closeAllGameGuis()
    local targetGuis = {
        {"ShopGui", "ShopNPC"},
        {"MemasakGui", nil},
        {"CookingGui", nil},
        {"Cooking", nil},
        {"CookGui", nil},
        {"DapurGui", nil},
        {"Dapur", nil},
        {"StoveGui", nil},
        {"TempaGui", nil},
        {"PasarGaibGui", "PasarGaib"},
        {"JualBabiGui", "JualBabi"},
        {"PetiArwahGui", "PetiArwah"},
        {"GerobakGachaGui", "GerobakGacha"},
        {"BalaiGui", "Balai"},
        {"ProfilGui", "Profil"},
        {"TradeGui", "Trade"},
        {"PlotMoveGui", nil},
        {"ConfirmGui", nil},
        {"StallRackGui", nil},
        {"StallRack", nil},
        {"RackGui", nil},
        {"StallGui", nil},
        {"MarketRackGui", nil},
        {"KiosRakGui", nil},
    }
    for _, entry in ipairs(targetGuis) do
        closeGameGui(entry[1], entry[2])
    end
    log("Semua GUI game telah ditutup!")
end

-- ════════════════════════════════════════════════════════════════════════════
-- LAHAN DETECTOR & STATS
-- ════════════════════════════════════════════════════════════════════════════
local function getMyPlot()
    local plots = Workspace:FindFirstChild("Plot")
    if not plots then return nil end

    -- 1. Prioritas Utama: Cek plot yang memiliki LahanPrompt "Upgrade" (hanya ada di plot milik player!)
    for _, p in ipairs(plots:GetChildren()) do
        local l1 = p:FindFirstChild("Lahan1")
        if l1 then
            local prompt = l1:FindFirstChild("LahanPrompt", true)
            if prompt and prompt.ActionText:find("Upgrade") then
                return p
            end
        end
    end

    -- 2. Prioritas Kedua: Cek Papan Nama / Signboard yang tertulis nama player
    local myNames = { LP.Name:lower(), LP.DisplayName:lower() }
    for _, p in ipairs(plots:GetChildren()) do
        for _, desc in ipairs(p:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text ~= "" then
                local txt = desc.Text:lower()
                for _, nm in ipairs(myNames) do
                    if txt:find(nm) then
                        return p
                    end
                end
            end
        end
    end

    -- 3. Prioritas Ketiga: Cek Tanaman dengan OwnerId kita
    for _, p in ipairs(plots:GetChildren()) do
        local l1 = p:FindFirstChild("Lahan1")
        if l1 then
            local t = l1:FindFirstChild("Tanaman")
            if t then
                for _, c in ipairs(t:GetChildren()) do
                    if c:IsA("BasePart") and c:GetAttribute("OwnerId") == LP.UserId then
                        return p
                    end
                end
            end
        end
    end

    -- 4. Fallback: Plot terdekat dengan karakter
    local root = getRoot()
    if root then
        local closestPlot = nil
        local minDist = math.huge
        for _, p in ipairs(plots:GetChildren()) do
            local l1 = p:FindFirstChild("Lahan1")
            if l1 and l1:IsA("BasePart") then
                local d = (root.Position - l1.Position).Magnitude
                if d < minDist then
                    minDist = d
                    closestPlot = p
                end
            end
        end
        return closestPlot
    end

    return nil
end

local function getLahanCFrame(lahan)
    if not lahan then return nil end
    if lahan:IsA("BasePart") then return lahan.CFrame end
    if lahan:IsA("Model") then return lahan:GetPivot() end
    return nil
end

local function getLahanPosition(lahan)
    if not lahan then return nil end
    if lahan:IsA("BasePart") then return lahan.Position end
    if lahan:IsA("Model") then return lahan:GetPivot().Position end
    return nil
end

local function getLahanSize(lahan)
    if not lahan then return Vector3.new(20, 1, 20) end
    if lahan:IsA("BasePart") then return lahan.Size end
    if lahan:IsA("Model") then
        local _, size = lahan:GetBoundingBox()
        return size
    end
    return Vector3.new(20, 1, 20)
end

local function getMyLahans()
    local found = {}
    local plots = Workspace:FindFirstChild("Plot")
    if not plots then return found end

    -- 1. Prioritas Utama: Cari lahan dengan atribut Owner == LP.UserId
    for _, p in ipairs(plots:GetChildren()) do
        for _, desc in ipairs(p:GetDescendants()) do
            if desc.Name:find("Lahan") and (desc:IsA("BasePart") or desc:IsA("Model")) then
                if desc:GetAttribute("Owner") == LP.UserId or desc:GetAttribute("OwnerId") == LP.UserId then
                    table.insert(found, desc)
                end
            end
        end
    end
    if #found > 0 then return found end

    -- 2. Prioritas Kedua: Cek plot yang memiliki LahanPrompt "Upgrade" (hanya ada di plot milik player!)
    for _, p in ipairs(plots:GetChildren()) do
        local l1 = p:FindFirstChild("Lahan1")
        if l1 then
            local prompt = l1:FindFirstChild("LahanPrompt", true)
            if prompt and prompt.ActionText:find("Upgrade") then
                table.insert(found, l1)
                return found
            end
        end
    end

    -- 3. Prioritas Ketiga: Cek Papan Nama / Signboard yang tertulis nama player
    local myNames = { LP.Name:lower(), LP.DisplayName:lower() }
    for _, p in ipairs(plots:GetChildren()) do
        for _, desc in ipairs(p:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text ~= "" then
                local txt = desc.Text:lower()
                for _, nm in ipairs(myNames) do
                    if txt:find(nm) then
                        local l1 = p:FindFirstChild("Lahan1")
                        if l1 then
                            table.insert(found, l1)
                            return found
                        end
                    end
                end
            end
        end
    end

    -- 4. Prioritas Keempat: Cek Tanaman dengan OwnerId
    for _, p in ipairs(plots:GetChildren()) do
        local l1 = p:FindFirstChild("Lahan1")
        if l1 then
            local t = l1:FindFirstChild("Tanaman")
            if t then
                for _, c in ipairs(t:GetChildren()) do
                    if (c:IsA("BasePart") or c:IsA("Model")) and (c:GetAttribute("OwnerId") == LP.UserId or c:GetAttribute("Owner") == LP.UserId) then
                        table.insert(found, l1)
                        return found
                    end
                end
            end
        end
    end

    -- 5. Fallback: Dari getMyPlot()
    local myPlot = getMyPlot()
    if myPlot then
        local l1 = myPlot:FindFirstChild("Lahan1")
        if l1 then
            table.insert(found, l1)
            return found
        end
    end

    return found
end

local function getLahanStats()
    local myLahans = getMyLahans()
    local stats = {
        level        = 1,
        current      = 0,
        max          = 10,
        ready        = 0,
        wet          = 0,
        dry          = 0,
        empty        = 10,
        plotName     = "?",
        upgradePrompt= nil,
        upgradeInfo  = "Maksimal / Perlu Cek",
    }

    if #myLahans == 0 then
        stats.upgradeInfo = "Lahan belum ditemukan (Dekati plot & klaim)"
        return stats
    end

    local l = myLahans[1]
    local parentPlot = l.Parent
    stats.plotName = parentPlot and parentPlot.Name or "?"

    local tFolder = l:FindFirstChild("Tanaman")
    local plants  = tFolder and tFolder:GetChildren() or {}

    local currentCount = 0
    for _, crop in ipairs(plants) do
        if crop:IsA("BasePart") and crop:GetAttribute("Harvested") ~= true then
            currentCount = currentCount + 1
            if crop:GetAttribute("Ready") == true then
                stats.ready = stats.ready + 1
            else
                if crop:GetAttribute("Wet") == true then
                    stats.wet = stats.wet + 1
                else
                    stats.dry = stats.dry + 1
                end
            end
        end
    end

    local lbFolder = parentPlot and parentPlot:FindFirstChild("LahanBesar")
    local lbUnlocked = 0
    if lbFolder then
        for _, b in ipairs(lbFolder:GetChildren()) do
            local hasTanah = b:FindFirstChild("Tanah") or b:FindFirstChild("Tanaman") or b:FindFirstChild("Lahan")
            local bp = b:FindFirstChild("BukaPrompt", true)
            if hasTanah or (not bp) then
                lbUnlocked = lbUnlocked + 1
            end
        end
    end

    local p = l:FindFirstChild("LahanPrompt", true)
    if p then
        stats.upgradePrompt = p
        local act = p.ActionText or ""
        local obj = p.ObjectText or ""
        stats.upgradeInfo = (act ~= "" and act or "Upgrade") .. (obj ~= "" and (" (" .. obj .. ")") or "")
        -- Deteksi level dari teks
        local lvMatch = obj:match("Lv(%d+)") or act:match("Lv(%d+)")
        if lvMatch then
            stats.level = tonumber(lvMatch) or 1
        end
    end

    stats.max     = math.max(1, 10 + (lbUnlocked * 6))
    stats.current = currentCount
    stats.empty   = math.max(0, stats.max - currentCount)

    return stats
end

local function getMyKios()
    return Workspace:FindFirstChild("KiosAktif") and Workspace.KiosAktif:FindFirstChild("Kios_" .. LP.Name)
end

local function getKiosSlotStats()
    local myKios = getMyKios()
    local stats = {
        kiosFound = false,
        totalOwned = 0,
        maxSlots = 5,
        slots = {}
    }
    if not myKios then
        return stats
    end
    stats.kiosFound = true

    -- Scan semua objek di myKios untuk mencari slot berapapun (slot1 s/d slot10+)
    local highestSlot = 5
    for _, child in ipairs(myKios:GetDescendants()) do
        local numStr = child.Name:match("^[Ss]lot(%d+)$") or child.Name:match("^[Rr]ak(%d+)$") or child.Name:match("^[Pp][Ss]lot(%d+)$")
        if numStr then
            local n = tonumber(numStr)
            if n and n > highestSlot then
                highestSlot = n
            end
        end
    end

    local slotsFolder = myKios:FindFirstChild("Slots") or myKios:FindFirstChild("Rak")
    if slotsFolder then
        for _, child in ipairs(slotsFolder:GetChildren()) do
            local numStr = child.Name:match("^[Ss]lot(%d+)$") or child.Name:match("^[Rr]ak(%d+)$") or child.Name:match("^(%d+)$")
            if numStr then
                local n = tonumber(numStr)
                if n and n > highestSlot then
                    highestSlot = n
                end
            end
        end
    end

    -- Market level 5 memiliki hingga 10 slot. Kita scan minimal 10 slot untuk mendeteksi semua rak.
    local scanLimit = math.max(highestSlot, 10)
    local foundMaxSlot = 0

    for i = 1, scanLimit do
        local slot = myKios:FindFirstChild("slot" .. i) 
            or myKios:FindFirstChild("Slot" .. i)
            or myKios:FindFirstChild("Rak" .. i)
            or myKios:FindFirstChild("pSlot" .. i)
            or (slotsFolder and (slotsFolder:FindFirstChild("slot" .. i) or slotsFolder:FindFirstChild("Slot" .. i) or slotsFolder:FindFirstChild(tostring(i))))
            or myKios:FindFirstChild("slot" .. i, true)
            or myKios:FindFirstChild("Slot" .. i, true)
            or myKios:FindFirstChild("Rak" .. i, true)

        if slot then
            if i > foundMaxSlot then
                foundMaxSlot = i
            end

            local prompt = slot:FindFirstChild("RakPrompt") or slot:FindFirstChild("Prompt", true)
            if not prompt then
                for _, p in ipairs(slot:GetDescendants()) do
                    if p:IsA("ProximityPrompt") then
                        local pn = p.Name:lower()
                        local ot = (p.ObjectText or ""):lower()
                        local at = (p.ActionText or ""):lower()
                        if not pn:find("upgrade") and not pn:find("lock") and not pn:find("buka") and not pn:find("buy")
                           and not pn:find("incense") and not ot:find("incense") and not at:find("incense")
                           and not pn:find("dupa") and not ot:find("dupa") and not at:find("dupa") then
                            prompt = p
                            break
                        end
                    end
                end
            end
            local stok = slot:FindFirstChild("Stok")
            local isOwned = false

            -- Deteksi kepemilikan slot secara presisi:
            local bp = slot:FindFirstChild("BukaPrompt", true) 
                or slot:FindFirstChild("LockPrompt", true) 
                or slot:FindFirstChild("UpgradePrompt", true)
                or slot:FindFirstChild("BuyPrompt", true)

            if bp and bp.Enabled then
                -- Ada prompt buka/beli slot, berarti slot ini BELUM dimiliki!
                isOwned = false
            elseif prompt and prompt.Enabled then
                -- Prompt restock aktif dan siap digunakan, slot pasti DIMILIKI!
                isOwned = true
            elseif stok and #stok:GetChildren() > 0 then
                -- Ada stok barang di rak, slot pasti DIMILIKI!
                isOwned = true
            elseif prompt and not bp then
                -- Slot dasar 1-5 di awal biasanya selalu dimiliki
                isOwned = (i <= 5)
            end

            local itemCount = 0
            local itemName = "Kosong"
            local itemAttr = slot:GetAttribute("Item")
            if itemAttr and type(itemAttr) == "string" and itemAttr ~= "" then
                itemName = itemAttr
                isOwned = true
            end
            if stok then
                local val = (itemAttr and stok:FindFirstChild(itemAttr)) or stok:GetChildren()[1]
                if val then
                    itemCount = val:IsA("IntValue") and val.Value or 1
                    itemName = val.Name
                    isOwned = true
                end
            end

            if isOwned then
                stats.totalOwned = stats.totalOwned + 1
            end

            stats.slots[i] = {
                slot = slot,
                owned = isOwned,
                prompt = prompt,
                stok = stok,
                itemName = itemName,
                itemCount = itemCount
            }
        else
            stats.slots[i] = {
                slot = nil,
                owned = false,
                prompt = nil,
                stok = nil,
                itemName = "Terkunci",
                itemCount = 0
            }
        end
    end

    stats.maxSlots = math.max(foundMaxSlot, 5)

    -- Fallback safety: minimal slot 1 pasti terbuka jika Kios aktif
    if stats.totalOwned == 0 and stats.slots[1] and stats.slots[1].slot then
        stats.totalOwned = 1
        stats.slots[1].owned = true
    end

    return stats
end

-- ════════════════════════════════════════════════════════════════════════════
-- TOOLS & HARVEST HELPERS
-- ════════════════════════════════════════════════════════════════════════════
local function getBestCropForLevel()
    local ls = LP:FindFirstChild("leaderstats")
    local lv = ls and ls:FindFirstChild("Lv") and ls.Lv.Value or 1

    -- Prioritas 1: Gunakan bibit yang sudah ada stoknya di tas (Backpack) maupun di tangan (Character)
    local seeds = { "Tomat", "Bawang", "Jagung", "Cabai", "Kentang" }
    for _, sName in ipairs(seeds) do
        for _, cont in ipairs({LP.Character, LP.Backpack}) do
            if cont then
                for _, t in ipairs(cont:GetChildren()) do
                    if t:IsA("Tool") and t.Name:lower():find("bibit") and t.Name:lower():find(sName:lower()) then
                        return sName
                    end
                end
            end
        end
    end

    -- Fallback bibit apapun yang ada di inventory
    for _, cont in ipairs({LP.Character, LP.Backpack}) do
        if cont then
            for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") and t.Name:lower():find("bibit") then
                    for _, sName in ipairs(seeds) do
                        if t.Name:lower():find(sName:lower()) then
                            return sName
                        end
                    end
                end
            end
        end
    end

    -- Prioritas 2: Level unlocking jika benar-benar belum punya bibit sama sekali
    if lv >= 15 then return "Tomat"
    elseif lv >= 10 then return "Bawang"
    elseif lv >= 6 then return "Jagung"
    elseif lv >= 3 then return "Cabai"
    else return "Kentang"
    end
end

local function getSeedTool()
    if State.AutoRotateCrop then
        State.FarmSeed = getBestCropForLevel()
    end

    local targetSeed = (State.FarmSeed or "Kentang"):lower()
    local synonyms = {
        ["kentang"] = {"kentang", "potato"},
        ["cabai"]   = {"cabai", "chili", "chilli", "cabe"},
        ["jagung"]  = {"jagung", "corn"},
        ["bawang"]  = {"bawang", "onion", "shallot"},
        ["tomat"]   = {"tomat", "tomato"},
        ["padi"]    = {"padi", "rice"},
    }
    local targetWords = synonyms[targetSeed] or { targetSeed }

    -- Cek karakter dan backpack untuk bibit yang cocok
    for _, p in ipairs({LP.Character, LP.Backpack}) do
        if p then
            for _, t in ipairs(p:GetChildren()) do
                if t:IsA("Tool") then
                    local nm = t.Name:lower()
                    local isSeed = t:GetAttribute("IsSeed") or nm:find("bibit") or nm:find("seed")
                    if isSeed then
                        for _, word in ipairs(targetWords) do
                            if nm:find(word) then
                                return t
                            end
                        end
                    end
                end
            end
        end
    end

    -- Fallback: Ambil bibit apa saja yang ada di backpack agar panen-tanam tidak macet
    for _, p in ipairs({LP.Character, LP.Backpack}) do
        if p then
            for _, t in ipairs(p:GetChildren()) do
                if t:IsA("Tool") then
                    local nm = t.Name:lower()
                    if t:GetAttribute("IsSeed") or nm:find("bibit") or nm:find("seed") then
                        return t
                    end
                end
            end
        end
    end

    return nil
end

local function getWaterTool()
    for _, p in ipairs({LP.Character, LP.Backpack}) do
        if p then
            for _, t in ipairs(p:GetChildren()) do
                if t:IsA("Tool") then
                    local nm = t.Name:lower()
                    if nm:find("penyiram") or nm:find("water") or nm:find("siram") or nm:find("can") or t:GetAttribute("IsWater") then
                        return t
                    end
                end
            end
        end
    end
    return nil
end

local function isProtectedTool(t)
    if not t or not t:IsA("Tool") then return true end
    local nm = t.Name:lower()
    -- Bibit kebun
    if t:GetAttribute("IsSeed") or nm:find("bibit") or nm:find("seed") then return true end
    -- Alat tambang, cangkul, beliung, alat tebang, alat masak
    if t:GetAttribute("AlatTambang") or nm:find("beliung") or nm:find("pickaxe") or nm:find("cangkul") or nm:find("axe") or nm:find("kapak") or nm:find("pancing") then return true end
    -- Perlengkapan Kios / Pedupaan khusus / Silver Frankincense / Burner / Tempat Dupa
    if nm:find("frankincense") or nm:find("burner") or nm:find("pedupaan") or nm:find("censer") or nm:find("altar") then return true end
    -- Pusaka / Lencana / Gamepass Item
    if nm:find("pusaka") or nm:find("relic") or nm:find("lencana") or nm:find("badge") then return true end
    return false
end

local function getCropTool()
    for _, p in ipairs({LP.Backpack, LP.Character}) do
        if p then
            for _, t in ipairs(p:GetChildren()) do
                if t:IsA("Tool") and not isProtectedTool(t) then
                    local nm = t.Name:lower()
                    if nm:find("kentang") or nm:find("cabai") or nm:find("jagung") or nm:find("bawang") or nm:find("tomat") or nm:find("padi") then
                        return t
                    end
                end
            end
        end
    end
    return nil
end

local function getBestKiosProduct(excludeList)
    excludeList = excludeList or {}
    -- Prioritas 1: Makanan hasil masak (Harga jual 3x - 5x lipat lebih tinggi)
    for _, p in ipairs({LP.Character, LP.Backpack}) do
        if p then
            for _, t in ipairs(p:GetChildren()) do
                if t:IsA("Tool") and not excludeList[t] and not isProtectedTool(t) then
                    local nm = t.Name:lower()
                    local isCookedFood = (nm:find("satay") or nm:find("sate"))
                        or (nm:find("coffee") or nm:find("kopi"))
                        or (nm:find("boiled") or nm:find("rebus"))
                        or nm:find("goreng") or nm:find("sup") or nm:find("soup")
                        or (nm:find("masak") and not nm:find("alat"))
                        or t:GetAttribute("IsFood") == true

                    -- Pastikan BUKAN bahan mentah!
                    if nm:find("river crab") or nm:find("incense") or nm:find("dupa") or nm:find("kemenyan") or nm:find("crow meat") then
                        isCookedFood = false
                    end

                    if isCookedFood then
                        return t
                    end
                end
            end
        end
    end

    -- Prioritas 2: Tanaman hasil kebun (Tomat, Bawang, Jagung, Cabai, Kentang, Padi)
    local priorities = { "tomat", "bawang", "jagung", "cabai", "kentang", "padi" }
    for _, cropName in ipairs(priorities) do
        for _, p in ipairs({LP.Character, LP.Backpack}) do
            if p then
                for _, t in ipairs(p:GetChildren()) do
                    if t:IsA("Tool") and not excludeList[t] and not isProtectedTool(t) then
                        if t.Name:lower():find(cropName) then
                            return t
                        end
                    end
                end
            end
        end
    end

    -- Prioritas 3: Daging olahan (Crow Meat hasil potong Meja Pengolahan)
    for _, p in ipairs({LP.Character, LP.Backpack}) do
        if p then
            for _, t in ipairs(p:GetChildren()) do
                if t:IsA("Tool") and not excludeList[t] and not isProtectedTool(t) then
                    local nm = t.Name:lower()
                    if nm:find("crow meat") or (nm:find("daging") and not nm:find("alat")) then
                        return t
                    end
                end
            end
        end
    end

    -- CATATAN: Dupa/Incense dan River Crab mentah SENGAJA TIDAK dimasukkan ke pilihan Otomatis!
    -- River Crab dibutuhkan untuk masak sate kepiting, sedangkan Dupa dipakai untuk bakar dupa di kios.
    return nil
end

local function findProductByPreference(pref, excludeList)
    excludeList = excludeList or {}
    if not pref or pref == "Otomatis" then
        return getBestKiosProduct(excludeList)
    end
    if pref:find("Jangan Isi") or pref:find("Kosongkan") or pref:find("Tunggu") or pref == "None" then
        return nil
    end

    local function matchTool(t, targetPref)
        if not t:IsA("Tool") or excludeList[t] or isProtectedTool(t) then
            return false
        end
        local nm = t.Name:lower()
        local itId = (t:GetAttribute("ItemId") or ""):lower()
        local tp = targetPref:lower():gsub("%s+", "")

        -- Direct match pada ItemId atau Name
        if itId ~= "" and (itId == tp or itId:gsub("%s+", "") == tp) then
            return true
        end

        if targetPref == "Crab Satay" or targetPref == "Sate Kepiting" then
            return (nm:find("satay") or nm:find("sate")) and (nm:find("crab") or nm:find("kepiting")) or itId == "satekepiting"
        elseif targetPref == "River Crab" or targetPref == "Kepiting Sungai" then
            return (nm:find("river crab") or (nm:find("crab") and not nm:find("satay") and not nm:find("sate")) or (nm:find("kepiting") and not nm:find("sate"))) or itId == "kepitingsungai"
        elseif targetPref == "Incense Coffee" or targetPref == "Kopi Kemenyan" then
            return nm:find("coffee") or nm:find("kopi") or itId == "kopikemenyan"
        elseif targetPref == "Incense" or targetPref == "Dupa" or targetPref == "Kemenyan" then
            return (nm:find("incense") or nm:find("dupa") or nm:find("kemenyan")) and not nm:find("coffee") and not nm:find("kopi")
        elseif targetPref == "Sate Gagak" or targetPref == "Crow Satay" then
            return ((nm:find("satay") or nm:find("sate")) and (nm:find("gagak") or nm:find("crow"))) or itId == "sategagak"
        elseif targetPref == "Crow Meat" or targetPref == "Daging Gagak" then
            return nm:find("crow meat") or (nm:find("daging") and nm:find("gagak")) or itId == "daginggagak"
        elseif targetPref == "Boiled Raja Banana" or targetPref == "Pisang Raja Rebus" or targetPref == "Pisang Rebus" then
            return (nm:find("banana") or nm:find("pisang")) and (nm:find("rebus") or nm:find("raja")) or itId == "pisangrajarebus"
        elseif targetPref == "Jamur Rebus" or targetPref == "Boiled Mushroom" then
            return (nm:find("jamur") or nm:find("mushroom")) and (nm:find("rebus") or nm:find("boiled") or nm:find("sup") or nm:find("soup")) or itId == "jamurrebus"
        elseif targetPref == "Babi Guling" then
            return nm:find("babi") or itId == "babiguling"
        elseif targetPref == "Ayam Potong" then
            return (nm:find("ayam") and nm:find("potong")) or itId == "ayampotong"
        elseif targetPref == "Tumis Kamboja" then
            return nm:find("kamboja") or itId == "tumiskamboja"
        elseif targetPref == "Susu" then
            return nm:find("susu") or nm:find("milk") or itId == "susu"
        elseif targetPref == "Apel" then
            return nm:find("apel") or nm:find("apple") or itId == "apel"
        elseif targetPref == "Paprika" then
            return nm:find("paprika") or itId == "paprika"
        elseif targetPref == "Jeruk" then
            return nm:find("jeruk") or nm:find("orange") or itId == "jeruk"
        elseif targetPref == "Kubis" then
            return nm:find("kubis") or nm:find("cabbage") or itId == "kubis"
        elseif targetPref == "Telur" then
            return nm:find("telur") or nm:find("egg") or itId == "telur"
        elseif targetPref == "Pisang" then
            return (nm:find("pisang") or nm:find("banana")) and not nm:find("rebus") or itId == "pisang"
        elseif targetPref == "Terong" then
            return nm:find("terong") or nm:find("eggplant") or itId == "terong"
        elseif targetPref == "Melati" or targetPref == "Bunga Melati" then
            return nm:find("melati") or nm:find("jasmine") or itId == "melati"
        elseif targetPref == "Tomat" then
            return nm:find("tomat") or nm:find("tomato")
        elseif targetPref == "Bawang" then
            return nm:find("bawang") or nm:find("onion")
        elseif targetPref == "Jagung" then
            return nm:find("jagung") or nm:find("corn") or itId == "jagung"
        elseif targetPref == "Cabai" then
            return nm:find("cabai") or nm:find("chili") or nm:find("cili") or nm:find("pepper") or itId == "cabai"
        elseif targetPref == "Kentang" then
            return nm:find("kentang") or nm:find("potato") or itId == "kentang"
        elseif targetPref == "Padi" then
            return nm:find("padi") or nm:find("rice")
        else
            return nm:find(targetPref:lower()) ~= nil or itId == tp
        end
    end

    -- 1. Coba cari barang prioritas utama (misal: Crab Satay)
    for _, cont in ipairs({LP.Character, LP.Backpack}) do
        if cont then
            for _, t in ipairs(cont:GetChildren()) do
                if matchTool(t, pref) then
                    return t
                end
            end
        end
    end

    -- 2. Jika stok barang utama tidak ada di tas (misal Crab Satay habis & masih dimasak di kompor):
    if State.KiosUseFallback then
        local fb = State.KiosFallbackItem or ""
        -- Jika dipilih "Jangan Isi (Tunggu Sampai Matang)", langsung batalkan / return nil!
        if fb:find("Jangan Isi") or fb:find("Tunggu") or fb:find("Kosongkan") or fb == "" then
            return nil
        end
        if fb:find("Otomatis") then
            return getBestKiosProduct(excludeList)
        else
            for _, cont in ipairs({LP.Character, LP.Backpack}) do
                if cont then
                    for _, t in ipairs(cont:GetChildren()) do
                        if matchTool(t, fb) then
                            return t
                        end
                    end
                end
            end
            -- Jika barang cadangan spesifik juga kosong, kembalikan nil agar rak tidak sembarangan diisi barang mentah!
            return nil
        end
    end

    return nil
end

local function getBeliungTool()
    for _, p in ipairs({LP.Character, LP.Backpack}) do
        if p then
            for _, t in ipairs(p:GetChildren()) do
                if t:IsA("Tool") and (t:GetAttribute("AlatTambang") == true or t.Name:find("Beliung") or t.Name:find("Pickaxe")) then
                    return t
                end
            end
        end
    end
    return nil
end

local function getKapakTool()
    for _, p in ipairs({LP.Character, LP.Backpack}) do
        if p then
            for _, t in ipairs(p:GetChildren()) do
                if t:IsA("Tool") and (t.Name:find("Kapak") or t.Name:find("Axe")) then
                    return t
                end
            end
        end
    end
    return nil
end

local function buySeeds(seedName, batches)
    -- Jika di tas atau karakter sudah ada bibit (misal Bibit Kentang x10), JANGAN BELI!
    if getSeedTool() ~= nil then
        return true
    end

    local ls = LP:FindFirstChild("leaderstats")
    local coins = ls and ls:FindFirstChild("Koin") and ls.Koin.Value or 0

    -- Smart Eco-Balancer: Cek cadangan koin minimal agar tidak boncos
    local minReserve = State.AutoEcoBalance and (State.MinCoinReserve or 100) or 20
    if coins < minReserve then
        log("[Eco-Balance] Pembelian bibit ditahan: Koin saat ini (" .. coins .. ") di bawah batas aman (" .. minReserve .. "). Menunggu penjualan di Kios...")
        return false
    end

    local rem = getR("ShopBuy")
    if rem then
        local targetSeedId = "Bibit" .. seedName
        local qty = math.clamp(math.floor((coins - (State.AutoEcoBalance and (State.MinCoinReserve or 100) or 0)) / 4), 1, (batches or 1) * 5)
        if qty < 1 then qty = 1 end
        local ok, res = pcall(function() return rem:InvokeServer(targetSeedId, qty) end)
        if ok and type(res) == "table" and res.ok then
            log("Berhasil membeli " .. qty .. "x " .. targetSeedId .. " via ShopBuy")
            return true
        end
    end
    return false
end

local function buyBeliung()
    local ls = LP:FindFirstChild("leaderstats")
    local coins = ls and ls:FindFirstChild("Koin") and ls.Koin.Value or 0
    if coins < 500 then
        log("Koin tidak cukup untuk membeli Beliung (Butuh 500, Koin: " .. coins .. ")")
        return false
    end

    local rem = getR("ShopBuy")
    if rem then
        local ok, res = pcall(function() return rem:InvokeServer("BeliungKayu", 1) end)
        log("Membeli BeliungKayu via ShopBuy: " .. tostring(ok))
        return ok
    end
    return false
end

-- ════════════════════════════════════════════════════════════════════════════
-- 1. AUTO FARM KEBUN (ANTI-KICK WITH NATURAL PROXIMITY)
-- ════════════════════════════════════════════════════════════════════════════
local function approachPosition(targetPos, reachDist, maxWait)
    local root = getRoot()
    if not root then return false end

    reachDist = reachDist or 5
    local d = (Vector2.new(root.Position.X, root.Position.Z) - Vector2.new(targetPos.X, targetPos.Z)).Magnitude
    if d <= reachDist then return true end

    -- Di mobile executor, reposisi langsung agar tidak diinterupsi virtual joystick
    root.CFrame = CFrame.new(targetPos + Vector3.new(0, 2.2, 0.8), targetPos)
    task.wait(0.1)
    return true
end

local farmRunning = false
local function doOneFarmCycle()
    if isActionBusy then return end
    isActionBusy = true

    local panenRemote = getR("Panen")
    local tanamRemote = getR("Tanam")
    local siramRemote = getR("Siram")
    local myLahans    = getMyLahans()
    local root        = getRoot()
    local hum         = getHum()

    if not root or not hum or #myLahans == 0 then
        isActionBusy = false
        return
    end
    local lahan = myLahans[1]
    local lPos = getLahanPosition(lahan)
    local lSize = getLahanSize(lahan)
    local lCF = getLahanCFrame(lahan)
    if not lPos or not lCF then
        isActionBusy = false
        return
    end

    -- Posisikan di lahan jika sedang di luar area kebun (> 40 studs)
    local distToLahan = (root.Position - lPos).Magnitude
    if distToLahan > 40 then
        root.CFrame = CFrame.new(lPos + Vector3.new(0, 3.5, 0))
        task.wait(0.3)
    end

    -- 1. Panen (Mendukung BasePart & Model Tanaman)
    local tFolder = lahan:FindFirstChild("Tanaman")
    local readyCrops = {}
    if tFolder then
        for _, crop in ipairs(tFolder:GetChildren()) do
            local isCrop = crop:IsA("BasePart") or crop:IsA("Model")
            local isOwner = crop:GetAttribute("OwnerId") == LP.UserId or crop:GetAttribute("Owner") == LP.UserId
            if isCrop and isOwner
                and crop:GetAttribute("Ready") == true
                and crop:GetAttribute("Harvested") ~= true
            then
                table.insert(readyCrops, crop)
            end
        end
    end

    if #readyCrops > 0 and panenRemote then
        table.sort(readyCrops, function(a, b)
            local posA = a:IsA("BasePart") and a.Position or a:GetPivot().Position
            local posB = b:IsA("BasePart") and b.Position or b:GetPivot().Position
            return (root.Position - posA).Magnitude < (root.Position - posB).Magnitude
        end)
        for _, crop in ipairs(readyCrops) do
            if crop and crop.Parent and crop:GetAttribute("Ready") == true and crop:GetAttribute("Harvested") ~= true then
                local cropPos = crop:IsA("BasePart") and crop.Position or crop:GetPivot().Position
                root.CFrame = CFrame.new(cropPos + Vector3.new(0, 2.2, 0.8), cropPos)
                task.wait(0.12)
                pcall(function() panenRemote:FireServer(crop) end)
                task.wait(0.2)
            end
        end
        task.wait(0.15)
    end

    -- 2. Kapasitas Kebun
    local stats = getLahanStats()
    local maxCap = stats.max
    local currentPlants = tFolder and tFolder:GetChildren() or {}
    local activePlants = {}
    local existingPositions = {}
    for _, p in ipairs(currentPlants) do
        if (p:IsA("BasePart") or p:IsA("Model")) and p:GetAttribute("Harvested") ~= true then
            table.insert(activePlants, p)
            local pPos = p:IsA("BasePart") and p.Position or p:GetPivot().Position
            table.insert(existingPositions, pPos)
        end
    end

    -- 3. Re-tanam (Mendukung AutoFarm Kebun secara seamless)
    if (State.AutoFarm or State.AutoHarvest) and #activePlants < maxCap and tanamRemote and hum then
        local slotsNeeded = maxCap - #activePlants
        local seed = getSeedTool()
        if not seed and (State.AutoBuySeed or State.AutoFarm) then
            buySeeds(State.FarmSeed, math.ceil(slotsNeeded / 5))
            task.wait(0.35)
            seed = getSeedTool()
        end

        if seed then
            hum:EquipTool(seed)
            task.wait(0.2)

            local halfX = math.max((lSize.X / 2) - 3.5, 1)
            local halfZ = math.max((lSize.Z / 2) - 3.5, 1)
            local step  = 4

            local plantedNow = 0
            for dx = -halfX, halfX, step do
                if #activePlants + plantedNow >= maxCap then break end
                for dz = -halfZ, halfZ, step do
                    if #activePlants + plantedNow >= maxCap then break end

                    if not seed or not seed.Parent then
                        seed = getSeedTool()
                        if not seed and (State.AutoBuySeed or State.AutoFarm) then
                            buySeeds(State.FarmSeed, 1)
                            task.wait(0.35)
                            seed = getSeedTool()
                        end
                        if not seed then break end
                        hum:EquipTool(seed)
                        task.wait(0.2)
                    end

                    local candPos = lCF:PointToWorldSpace(Vector3.new(dx, (lSize.Y / 2) + 0.1, dz))
                    local tooClose = false
                    for _, ex in ipairs(existingPositions) do
                        local dist2D = (Vector2.new(candPos.X, candPos.Z) - Vector2.new(ex.X, ex.Z)).Magnitude
                        if dist2D < 3.2 then
                            tooClose = true
                            break
                        end
                    end

                    if not tooClose then
                        root.CFrame = CFrame.new(candPos + Vector3.new(0, 2.2, 0.8), candPos)
                        task.wait(0.12)
                        pcall(function() tanamRemote:FireServer(candPos) end)
                        table.insert(existingPositions, candPos)
                        plantedNow = plantedNow + 1
                        task.wait(0.25)
                    end
                end
            end
            task.wait(0.2)
            currentPlants = tFolder and tFolder:GetChildren() or {}
        end
    end

    -- 4. Siram (Mendukung AutoFarm Kebun / AutoSiram secara otomatis dengan multi-pulse saturasi air)
    if (State.AutoFarm or State.AutoSiram) and siramRemote then
        local needWater = {}
        for _, crop in ipairs(tFolder and tFolder:GetChildren() or {}) do
            local isCrop = crop:IsA("BasePart") or crop:IsA("Model")
            local isOwner = crop:GetAttribute("OwnerId") == LP.UserId or crop:GetAttribute("Owner") == LP.UserId
            if isCrop and isOwner
                and crop:GetAttribute("Ready") ~= true
                and crop:GetAttribute("Wet") ~= true
            then
                table.insert(needWater, crop)
            end
        end

        if #needWater > 0 then
            local waterTool = getWaterTool()
            if waterTool and hum then
                hum:EquipTool(waterTool)
                task.wait(0.2)
                for _, crop in ipairs(needWater) do
                    if crop and crop.Parent and crop:GetAttribute("Wet") ~= true then
                        local cropPos = crop:IsA("BasePart") and crop.Position or crop:GetPivot().Position
                        root.CFrame = CFrame.new(cropPos + Vector3.new(0, 2.2, 0.8), cropPos)
                        task.wait(0.1)
                        for pulse = 1, 6 do
                            if crop:GetAttribute("Wet") == true then break end
                            pcall(function() siramRemote:FireServer() end)
                            task.wait(0.08)
                        end
                    end
                end
            end
        end
    end

    root.CFrame = CFrame.new(lPos + Vector3.new(0, 3.5, 0))
    isActionBusy = false
end

local function autoFarmLoop()
    if farmRunning then return end
    farmRunning = true
    task.spawn(function()
        while State.AutoFarm do
            pcall(doOneFarmCycle)
            task.wait(2)
        end
        farmRunning = false
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- 2. AUTO DAGANG (KIOS)
-- ════════════════════════════════════════════════════════════════════════════
local function getPreferenceForSlot(slotIndex)
    local strat = State.KiosStrategy or "Otomatis (Semua Rak)"
    if strat == "Otomatis (Semua Rak)" or strat == "Otomatis Cuan Tertinggi" or strat == "Otomatis" then
        return "Otomatis"
    elseif strat:find("Crab Satay") or strat:find("Sate Kepiting") then
        return "Crab Satay"
    elseif strat:find("Kopi Kemenyan") or strat:find("Incense Coffee") then
        return "Incense Coffee"
    elseif strat:find("Kentang") then
        return "Kentang"
    elseif strat:find("Hasil Panen") then
        return "Otomatis"
    elseif strat:find("Kustom") then
        return State["KiosBox" .. slotIndex] or "Otomatis"
    end
    return strat
end

local function findStallRackGui()
    local rakGui = PG:FindFirstChild("RakGui")
    if rakGui and rakGui:IsA("ScreenGui") and rakGui.Enabled then
        return rakGui
    end
    for _, name in ipairs({"StallRackGui", "StallRack", "RackGui", "StallGui", "MarketRackGui", "KiosRakGui"}) do
        local g = PG:FindFirstChild(name)
        if g and g:IsA("ScreenGui") and g.Enabled then
            return g
        end
    end
    return nil
end

local function closeStallRackGui(rGui)
    pcall(function()
        if _G.ToggleRak and rGui and rGui.MainFrame and rGui.MainFrame.Visible then
            _G.ToggleRak()
            return
        end
        if rGui then
            local closeBtn = rGui:FindFirstChild("CloseButton", true)
            if closeBtn and isGuiObjectActuallyVisible(closeBtn) then
                clickGuiElement(closeBtn)
            end
        end
        closeGameGui("RakGui")
        closeGameGui("StallRackGui")
    end)
end

local function openStallRackGui()
    local rGui = findStallRackGui()
    if rGui and rGui.MainFrame and rGui.MainFrame.Visible then return rGui end

    if _G.ToggleRak then
        pcall(_G.ToggleRak)
        task.wait(0.25)
        rGui = findStallRackGui()
        if rGui and rGui.MainFrame and rGui.MainFrame.Visible then return rGui end
    end

    local sidebar = PG:FindFirstChild("Sidebar")
    local rakBtn = sidebar and sidebar:FindFirstChild("Rak", true)
    if rakBtn and rakBtn:IsA("GuiButton") and isGuiObjectActuallyVisible(rakBtn) then
        clickGuiElement(rakBtn)
        task.wait(0.25)
        rGui = findStallRackGui()
        if rGui and rGui.MainFrame and rGui.MainFrame.Visible then return rGui end
    end

    openGameGui("RakGui", "Rak")
    task.wait(0.2)
    return findStallRackGui()
end

local function doRestockViaRakAksi()
    local rakAksi = getR("RakAksi")
    if not rakAksi then return false end

    local slotStats = getKiosSlotStats()
    if not slotStats.kiosFound then return false end

    local maxLimit = slotStats.maxSlots or #slotStats.slots or 10
    local restockedCount = 0

    for i = 1, maxLimit do
        local sInfo = slotStats.slots[i]
        if sInfo and sInfo.owned then
            local slotName = "slot" .. i
            local pref = getPreferenceForSlot(i)
            local slotObj = sInfo.slot
            local currentItem = slotObj and slotObj:GetAttribute("Item")

            -- A. Jika slot diset "Jangan Isi" / "Kosongkan"
            if pref:find("Jangan Isi") or pref:find("Kosongkan") or pref:find("Tunggu") or pref == "None" then
                if currentItem and currentItem ~= "" then
                    pcall(function()
                        local res = rakAksi:InvokeServer("ambil", slotName)
                        if res and res.ok then
                            log(("[StallRack] Mengosongkan %s sesuai setting: %s"):format(slotName, pref))
                        end
                    end)
                    task.wait(0.25)
                end
            elseif pref == "Otomatis" then
                -- B. Mode Otomatis
                if currentItem and currentItem ~= "" then
                    -- Sudah ada barang, cukup top up dengan "isi"
                    local res = nil
                    pcall(function()
                        res = rakAksi:InvokeServer("isi", slotName)
                    end)
                    if res and res.ok and (res.n or 0) > 0 then
                        restockedCount = restockedCount + 1
                        log(("[StallRack] Rak %s diisi ulang (+%d)"):format(slotName, res.n or 0))
                    end
                else
                    -- Rak kosong, cari barang jualan terbaik dari tas
                    local prod = getBestKiosProduct()
                    local targetItem = prod and (prod:GetAttribute("ItemId") or prod.Name)

                    if not targetItem then
                        for _, container in ipairs({ LP:FindFirstChildOfClass("Backpack"), LP.Character }) do
                            if container then
                                for _, tool in ipairs(container:GetChildren()) do
                                    if tool:IsA("Tool") and tool:GetAttribute("ItemId") and not isProtectedTool(tool) then
                                        local itemId = tool:GetAttribute("ItemId")
                                        if itemId ~= "Incense" and itemId ~= "Dupa" and not itemId:lower():find("axe") and not itemId:lower():find("pick") then
                                            targetItem = itemId
                                            break
                                        end
                                    end
                                end
                            end
                            if targetItem then break end
                        end
                    end

                    if targetItem then
                        task.wait(0.25)
                        local tRes = nil
                        pcall(function()
                            tRes = rakAksi:InvokeServer("taruh", slotName, targetItem)
                        end)
                        if tRes and tRes.ok then
                            restockedCount = restockedCount + 1
                            log(("[StallRack] Menaruh %s ke %s (+%d)"):format(targetItem, slotName, tRes.n or 0))
                        end
                    end
                end
                task.wait(0.25)
            else
                -- C. Mode Spesifik / Kustom Per-Rak
                local prod = findProductByPreference(pref)
                local desiredItemId = prod and (prod:GetAttribute("ItemId") or prod.Name)

                local isDifferent = false
                if currentItem and currentItem ~= "" then
                    local cNorm = currentItem:lower():gsub("%s+", "")
                    local pNorm = pref:lower():gsub("%s+", "")
                    if desiredItemId then
                        local dNorm = desiredItemId:lower():gsub("%s+", "")
                        isDifferent = (cNorm ~= dNorm)
                    else
                        isDifferent = not cNorm:find(pNorm) and not pNorm:find(cNorm)
                    end
                end

                if isDifferent and desiredItemId then
                    -- Rak berisi barang yang tidak sesuai dengan pilihan user, dan user punya stok barang yang dipilih!
                    -- Ambil barang lama ke tas, lalu taruh barang baru!
                    log(("[StallRack] Menukar isi %s: %s -> %s"):format(slotName, tostring(currentItem), desiredItemId))
                    pcall(function()
                        rakAksi:InvokeServer("ambil", slotName)
                    end)
                    task.wait(0.25)
                    local tRes = nil
                    pcall(function()
                        tRes = rakAksi:InvokeServer("taruh", slotName, desiredItemId)
                    end)
                    if tRes and tRes.ok then
                        restockedCount = restockedCount + 1
                        log(("[StallRack] Berhasil menaruh %s ke %s (+%d)"):format(desiredItemId, slotName, tRes.n or 0))
                    end
                    task.wait(0.25)
                elseif currentItem and currentItem ~= "" then
                    -- Barang di rak sudah sesuai dengan preferensi, cukup top up!
                    local res = nil
                    pcall(function()
                        res = rakAksi:InvokeServer("isi", slotName)
                    end)
                    if res and res.ok and (res.n or 0) > 0 then
                        restockedCount = restockedCount + 1
                        log(("[StallRack] Rak %s diisi ulang (+%d)"):format(slotName, res.n or 0))
                    end
                    task.wait(0.25)
                else
                    -- Rak sedang kosong, taruh barang pilihan jika ada
                    if desiredItemId then
                        local tRes = nil
                        pcall(function()
                            tRes = rakAksi:InvokeServer("taruh", slotName, desiredItemId)
                        end)
                        if tRes and tRes.ok then
                            restockedCount = restockedCount + 1
                            log(("[StallRack] Menaruh %s ke %s (+%d)"):format(desiredItemId, slotName, tRes.n or 0))
                        end
                    end
                    task.wait(0.25)
                end
            end
        end
    end

    if restockedCount > 0 then
        log(("[StallRack] Berhasil restok otomatis via RakAksi: %d rak diisi!"):format(restockedCount))
        pcall(function()
            WindUI:Notify({
                Title = "🏪 Rak Kios Terisi!",
                Desc = ("Berhasil restok %d rak via RakAksi bawaan."):format(restockedCount),
                Duration = 3,
                Icon = "package-check"
            })
        end)
    else
        log("[StallRack] Seluruh rak kios sudah terisi penuh (9/9).")
    end

    return true
end

local function debugScanStallRackGui()
    local rGui = openStallRackGui()
    if not rGui then
        log("[Diagnostik StallRack] GUI RakGui tidak ditemukan di PlayerGui!")
        pcall(function()
            WindUI:Notify({
                Title = "🔍 Diagnostik Stall Rack",
                Desc = "GUI RakGui belum terbuka atau tidak terdeteksi!",
                Duration = 4,
                Icon = "alert-circle"
            })
        end)
        return
    end

    log("[Diagnostik StallRack] GUI terdeteksi: " .. rGui.Name)
    local items = {}
    for _, d in ipairs(rGui:GetDescendants()) do
        if (d:IsA("GuiButton") or d:IsA("TextLabel")) and d.Visible and d.Text ~= "" then
            table.insert(items, d.ClassName .. " | Text: '" .. d.Text .. "' | Name: " .. d.Name)
        end
    end

    for _, it in ipairs(items) do
        print("  🔘 " .. it)
    end

    pcall(function()
        WindUI:Notify({
            Title = "🔍 Diagnostik: " .. rGui.Name,
            Desc = ("Ditemukan %d elemen di %s. Cek console F9!"):format(#items, rGui.Name),
            Duration = 5,
            Icon = "check"
        })
    end)
end

local function stockKiosShelves()
    if isActionBusy then return end
    isActionBusy = true

    local ok, res = pcall(function()
        -- 1. UTAMAKAN REMOTE RESMI RAKAKSI (Instant Stack langsung dari tas ke rak)
        local aksiOk = doRestockViaRakAksi()
        if aksiOk then
            return true
        end

        return false
    end)

    isActionBusy = false
end

local dagangRunning = false
local function autoDagangLoop()
    if dagangRunning then return end
    dagangRunning = true
    task.spawn(function()
        while State.AutoDagang do
            if not isActionBusy then
                local slotStats = getKiosSlotStats()
                if slotStats.kiosFound then
                    local needStock = false
                    local maxLimit = slotStats.maxSlots or #slotStats.slots or 10
                    for i = 1, maxLimit do
                        local sInfo = slotStats.slots[i]
                        if sInfo and sInfo.owned then
                            local pref = getPreferenceForSlot(i)
                            if not pref:find("Jangan Isi") and not pref:find("Kosongkan") and not pref:find("Tunggu") and pref ~= "None" then
                                local count = sInfo.itemCount or 0
                                local stok = sInfo.stok
                                if count < 9 or (not stok or #stok:GetChildren() == 0) then
                                    needStock = true
                                    break
                                end
                            end
                        end
                    end

                    if needStock then
                        pcall(stockKiosShelves)
                        task.wait(State.KiosRestockCooldown or 5)
                    else
                        task.wait(6)
                    end
                end
            end
            task.wait(2)
        end
        dagangRunning = false
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- 2.5. AUTO OLAH MEJA PENGOLAHAN (BATCH MAKS 100X: GAGAK, AYAM, KOPI)
-- ════════════════════════════════════════════════════════════════════════════
local function doAutoOlah()
    if isActionBusy then return end
    local myKios = Workspace:FindFirstChild("KiosAktif") and Workspace.KiosAktif:FindFirstChild("Kios_" .. LP.Name)
    if not myKios then return end
    local pemotongan = myKios:FindFirstChild("pPemotongan")
    if not pemotongan then return end

    local gagakCount = 0
    local ayamCounts = {
        Kampung = 0,
        Kedu    = 0,
        Pelung  = 0,
        Kate    = 0,
        Cemani  = 0,
    }
    local kopiCount = 0

    for _, cont in ipairs({LP.Character, LP.Backpack}) do
        if cont then
            for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") then
                    local nm = t.Name:lower()
                    local c = t:GetAttribute("Count") or tonumber(t.Name:match("x(%d+)")) or 1

                    if nm:find("gagak") and not nm:find("potong") and not nm:find("sate") and not nm:find("daging") then
                        gagakCount = gagakCount + c
                    elseif nm:find("ayam") and not nm:find("potong") and not nm:find("sate") and not nm:find("daging") then
                        if nm:find("kedu") then
                            ayamCounts.Kedu = ayamCounts.Kedu + c
                        elseif nm:find("pelung") then
                            ayamCounts.Pelung = ayamCounts.Pelung + c
                        elseif nm:find("kate") then
                            ayamCounts.Kate = ayamCounts.Kate + c
                        elseif nm:find("cemani") then
                            ayamCounts.Cemani = ayamCounts.Cemani + c
                        else
                            ayamCounts.Kampung = ayamCounts.Kampung + c
                        end
                    elseif (nm:find("kopi") or nm:find("bijikopi")) and not nm:find("bubuk") then
                        kopiCount = kopiCount + c
                    end
                end
            end
        end
    end

    local recipesToRun = {}
    if State.AutoOlahGagak and gagakCount >= 1 then
        table.insert(recipesToRun, { id = "PotongGagak", qty = math.min(100, gagakCount), name = "Gagak" })
    end
    if State.AutoOlahAyam then
        if ayamCounts.Kampung >= 1 then
            table.insert(recipesToRun, { id = "PotongAyamKampung", qty = math.min(100, ayamCounts.Kampung), name = "Ayam Kampung" })
        end
        if ayamCounts.Kedu >= 1 then
            table.insert(recipesToRun, { id = "PotongAyamKedu", qty = math.min(100, ayamCounts.Kedu), name = "Ayam Kedu" })
        end
        if ayamCounts.Pelung >= 1 then
            table.insert(recipesToRun, { id = "PotongAyamPelung", qty = math.min(100, ayamCounts.Pelung), name = "Ayam Pelung" })
        end
        if ayamCounts.Kate >= 1 then
            table.insert(recipesToRun, { id = "PotongAyamKate", qty = math.min(100, ayamCounts.Kate), name = "Ayam Kate" })
        end
        if ayamCounts.Cemani >= 1 then
            table.insert(recipesToRun, { id = "PotongAyamCemani", qty = math.min(100, ayamCounts.Cemani), name = "Ayam Cemani" })
        end
    end
    if State.AutoOlahKopi and kopiCount >= 1 then
        table.insert(recipesToRun, { id = "GilingKopi", qty = math.min(100, kopiCount), name = "Biji Kopi" })
    end

    if #recipesToRun == 0 then return end

    local root = getRoot()
    if not root then return end

    isActionBusy = true
    local oldPos = root.Position
    root.CFrame = CFrame.new(pemotongan.Position + Vector3.new(0, 2.5, 1))
    task.wait(0.3)

    local olahRemote = getR("OlahMulai")
    if olahRemote then
        for _, r in ipairs(recipesToRun) do
            local ok, res = pcall(function() return olahRemote:InvokeServer(r.id, r.qty) end)
            if ok and type(res) == "table" and res.ok then
                log(("⚡ Berhasil memproses batch %dx %s (%s) di Meja Pengolahan!"):format(r.qty, r.name, r.id))
            end
            task.wait(0.35)
        end
    end

    local lahans = getMyLahans()
    if State.AutoFarm and #lahans > 0 then
        root.CFrame = CFrame.new(lahans[1].Position + Vector3.new(0, 3.5, 0))
    else
        root.CFrame = CFrame.new(oldPos)
    end
    task.wait(0.3)
    isActionBusy = false
end

local olahRunning = false
local function autoOlahLoop()
    if olahRunning then return end
    olahRunning = true
    task.spawn(function()
        while State.AutoOlahGagak or State.AutoOlahAyam or State.AutoOlahKopi do
            pcall(doAutoOlah)
            task.wait(6)
        end
        olahRunning = false
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- 3. AUTO TAMBANG & TEBANG
-- ════════════════════════════════════════════════════════════════════════════
local tambangRunning = false
local function autoTambangLoop()
    if tambangRunning then return end
    tambangRunning = true
    task.spawn(function()
        log("[Tambang] Auto Tambang Batu dimulai")
        while State.AutoTambang do
            local hum  = getHum()
            local root = getRoot()
            if not hum or not root then task.wait(1); continue end

            local beliung = getBeliungTool()
            if not beliung and State.AutoBuyBeliung then
                buyBeliung()
                task.wait(0.5)
                beliung = getBeliungTool()
            end

            if not beliung then
                log("[Tambang] Tidak ada Beliung di tas! Nyalakan Auto Beli Beliung atau beli di toko.")
                task.wait(3)
                continue
            end

            if beliung.Parent ~= LP.Character then
                hum:EquipTool(beliung)
                beliung.Parent = LP.Character
                task.wait(0.2)
            end

            -- Cari batu tambang terdekat
            local nearestPart, nearestPrompt, nearestDist = nil, nil, math.huge

            -- 1. Scan folder BahanCraft / Tambang / Batuan jika ada
            local candidateFolders = {
                Workspace:FindFirstChild("BahanCraft"),
                Workspace:FindFirstChild("Tambang"),
                Workspace:FindFirstChild("Batuan"),
                Workspace:FindFirstChild("SpawnBahan"),
            }

            for _, folder in ipairs(candidateFolders) do
                if folder then
                    for _, node in ipairs(folder:GetChildren()) do
                        local nameLower = node.Name:lower()
                        if nameLower:find("batu") or nameLower:find("ore") or nameLower:find("rock") then
                            local prompt = node:FindFirstChildWhichIsA("ProximityPrompt", true)
                            local part = node:FindFirstChild("Batu") or (node:IsA("BasePart") and node) or node:FindFirstChildWhichIsA("BasePart")
                            if prompt and prompt.Enabled and part then
                                local d = (root.Position - part.Position).Magnitude
                                if d < nearestDist then
                                    nearestDist = d
                                    nearestPart = part
                                    nearestPrompt = prompt
                                end
                            end
                        end
                    end
                end
            end

            -- 2. Fallback scan Workspace langsung untuk batuan yang aktif
            if not nearestPart then
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                        local pName = desc.Name:lower()
                        local ot = (desc.ObjectText or ""):lower()
                        local at = (desc.ActionText or ""):lower()
                        local par = desc.Parent
                        local parName = par and par.Name:lower() or ""
                        if ot:find("batu") or at:find("batu") or ot:find("tambang") or at:find("tambang") 
                           or pName:find("batu") or pName:find("tambang") or parName:find("batu") or parName:find("ore") then
                            local part = (par and par:IsA("BasePart") and par) or (par and par:FindFirstChildWhichIsA("BasePart"))
                            if part then
                                local d = (root.Position - part.Position).Magnitude
                                if d < nearestDist then
                                    nearestDist = d
                                    nearestPart = part
                                    nearestPrompt = desc
                                end
                            end
                        end
                    end
                end
            end

            if nearestPart and nearestPrompt and nearestPrompt.Enabled then
                root.CFrame = CFrame.new(nearestPart.Position + Vector3.new(0, 1.8, 2.2), nearestPart.Position)
                task.wait(0.2)

                for hit = 1, 6 do
                    if not State.AutoTambang then break end
                    if not nearestPrompt.Enabled or not nearestPart.Parent then break end

                    if beliung.Parent ~= LP.Character then
                        beliung.Parent = LP.Character
                    end

                    safeFirePrompt(nearestPrompt)
                    local holdT = (nearestPrompt.HoldDuration and nearestPrompt.HoldDuration > 0) and nearestPrompt.HoldDuration or 0.35
                    task.wait(holdT + 0.1)
                end

                -- Ambil drop item di sekitar
                task.wait(0.2)
                for _, drop in ipairs(Workspace:GetChildren()) do
                    if drop:IsA("Tool") or drop:IsA("Model") or drop:IsA("BasePart") then
                        local dName = drop.Name:lower()
                        if dName:find("batu") or dName:find("besi") or dName:find("ore") then
                            local dPos = drop:IsA("BasePart") and drop.Position or drop:GetPivot().Position
                            if (root.Position - dPos).Magnitude < 15 then
                                local p = drop:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if p and p.Enabled then
                                    safeFirePrompt(p)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
        tambangRunning = false
        log("[Tambang] Auto Tambang Batu berhenti")
    end)
end

local tebangRunning = false
local function autoTebangLoop()
    if tebangRunning then return end
    tebangRunning = true
    task.spawn(function()
        while State.AutoTebang do
            local hum  = getHum()
            local root = getRoot()
            if not hum or not root then task.wait(1); continue end

            local kapak = getKapakTool() or getBeliungTool()
            if kapak then
                hum:EquipTool(kapak)
                task.wait(0.2)
            end

            local bc = Workspace:FindFirstChild("BahanCraft")
            if bc then
                local nearestNode, nearestDist = nil, math.huge
                for _, node in ipairs(bc:GetChildren()) do
                    if node.Name:find("Pohon") and node:GetAttribute("Tumbang") ~= true then
                        local part = node:FindFirstChild("Batang") or node:FindFirstChildWhichIsA("BasePart")
                        local prompt = node:FindFirstChild("TebangPrompt", true)
                        if part and prompt then
                            local d = (root.Position - part.Position).Magnitude
                            if d < nearestDist then
                                nearestDist = d
                                nearestNode = node
                            end
                        end
                    end
                end

                if nearestNode then
                    local part = nearestNode:FindFirstChild("Batang") or nearestNode:FindFirstChildWhichIsA("BasePart")
                    local prompt = nearestNode:FindFirstChild("TebangPrompt", true)
                    if part and prompt then
                        root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 2.5), part.Position)
                        task.wait(0.3)
                        for hit = 1, 4 do
                            if nearestNode:GetAttribute("Tumbang") == true then break end
                            safeFirePrompt(prompt)
                            task.wait(0.4)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
        tebangRunning = false
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- 4. AUTO TERNAK & BABI
-- ════════════════════════════════════════════════════════════════════════════
-- 4. AUTO TERNAK & BABI (BATCH jualBanyak)
-- ════════════════════════════════════════════════════════════════════════════
local sellBabiRunning = false
local function doSellBabiBatch()
    local rem = getR("BabiBandar")
    if not rem then return false, "Remote BabiBandar tidak ditemukan" end

    local ok, info = pcall(function() return rem:InvokeServer("info") end)
    if not ok or type(info) ~= "table" or not info.ternak then
        return false, "Gagal mengambil data ternak babi dari Bandar"
    end

    local ids = {}
    local totalEstimasi = 0
    for _, babi in ipairs(info.ternak) do
        -- Jangan jual babi yang dikunci atau sedang bunting
        if not babi.kunci and not babi.bunting then
            table.insert(ids, babi.id)
            totalEstimasi = totalEstimasi + (tonumber(babi.harga) or 0)
        end
    end

    if #ids == 0 then
        return false, "Tidak ada babi siap jual (semua terkunci / bunting)"
    end

    local ok2, res = pcall(function()
        return rem:InvokeServer("jualBanyak", { ids = ids })
    end)

    if ok2 and type(res) == "table" and res.ok then
        log(("🐷 Berhasil menjual batch %d babi! (+~%d Koin)"):format(#ids, totalEstimasi))
        pcall(function()
            WindUI:Notify({
                Title = "🐷 Babi Terjual Batch!",
                Desc = ("Berhasil menjual %d ekor babi (+~%d Koin)"):format(#ids, totalEstimasi),
                Duration = 4,
                Icon = "coins"
            })
        end)
        return true, #ids
    end
    return false, "Gagal respon server jualBanyak"
end

local function autoSellBabiLoop()
    if sellBabiRunning then return end
    sellBabiRunning = true
    task.spawn(function()
        while State.AutoSellBabi do
            pcall(doSellBabiBatch)
            task.wait(8)
        end
        sellBabiRunning = false
    end)
end

local function isGuiObjectActuallyVisible(obj)
    if not obj then return false end
    if not obj:IsA("GuiObject") then
        if obj:IsA("ScreenGui") then return obj.Enabled end
        return false
    end
    local curr = obj
    while curr and curr:IsA("GuiObject") do
        if not curr.Visible then return false end
        curr = curr.Parent
    end
    if curr and curr:IsA("ScreenGui") then
        return curr.Enabled
    end
    return true
end

local function clickGuiElement(element)
    if not element then return false end
    local btn = element
    if not btn:IsA("GuiButton") then
        btn = element:FindFirstAncestorOfClass("GuiButton") or element:FindFirstChildOfClass("GuiButton")
    end
    if not btn then
        btn = element
    end

    -- 1. firesignal bawaan executor (di-wrap per method terpisah agar satu error tidak menghentikan yang lain di mobile)
    if firesignal then
        pcall(function()
            if btn.Activated then firesignal(btn.Activated) end
        end)
        pcall(function()
            if btn.MouseButton1Click then firesignal(btn.MouseButton1Click) end
        end)
        pcall(function()
            if btn.MouseButton1Down then firesignal(btn.MouseButton1Down) end
            if btn.MouseButton1Up then firesignal(btn.MouseButton1Up) end
        end)
        pcall(function()
            if btn.TouchTap then firesignal(btn.TouchTap) end
        end)
    end

    -- 2. getconnections (Mendukung event Activated & MouseButton1Click di mobile executor seperti Delta / Codex / Arceus)
    if getconnections then
        pcall(function()
            if btn.Activated then
                for _, conn in ipairs(getconnections(btn.Activated)) do
                    if conn.Fire then conn:Fire() elseif conn.fire then conn:fire() end
                end
            end
        end)
        pcall(function()
            if btn.MouseButton1Click then
                for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                    if conn.Fire then conn:Fire() elseif conn.fire then conn:fire() end
                end
            end
        end)
        pcall(function()
            if btn.TouchTap then
                for _, conn in ipairs(getconnections(btn.TouchTap)) do
                    if conn.Fire then conn:Fire() elseif conn.fire then conn:fire() end
                end
            end
        end)
    end

    -- 3. VirtualInputManager Touch Tap & Mouse Click (Koordinat tengah elemen di layar)
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        if VIM and btn:IsA("GuiObject") then
            local absPos = btn.AbsolutePosition
            local absSize = btn.AbsoluteSize
            local cx = absPos.X + (absSize.X / 2)
            local cy = absPos.Y + (absSize.Y / 2)
            pcall(function()
                if VIM.SendTouchEvent then
                    VIM:SendTouchEvent(0, 0, cx, cy)
                    task.wait(0.02)
                    VIM:SendTouchEvent(0, 2, cx, cy)
                end
            end)
            pcall(function()
                VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                task.wait(0.02)
                VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
            end)
        end
    end)

    -- 4. VirtualUser fallback
    pcall(function()
        local VU = game:GetService("VirtualUser")
        if VU and btn:IsA("GuiObject") then
            local absPos = btn.AbsolutePosition
            local absSize = btn.AbsoluteSize
            VU:ClickButton1(Vector2.new(absPos.X + absSize.X / 2, absPos.Y + absSize.Y / 2))
        end
    end)

    return true
end

local COOKING_RECIPES = {
    {
        id = "SateKepiting",
        label = "Sate Kepiting",
        output = "SateKepiting",
        cookTime = 90,
        ingredients = { { item = "KepitingSungai", qty = 3 }, { item = "Dupa", qty = 1 } }
    },
    {
        id = "KopiKemenyan",
        label = "Kopi Kemenyan",
        output = "KopiKemenyan",
        cookTime = 90,
        ingredients = { { item = "BubukKopi", qty = 1 }, { item = "Kemenyan", qty = 1 } }
    },
    {
        id = "PisangRebus",
        label = "Pisang Raja Rebus",
        output = "PisangRajaRebus",
        cookTime = 90,
        ingredients = { { item = "Pisang", qty = 1 } }
    },
    {
        id = "TumisKamboja",
        label = "Tumis Kamboja",
        output = "TumisKamboja",
        cookTime = 90,
        ingredients = { { item = "Kamboja", qty = 1 } }
    },
    {
        id = "Bakar",
        label = "Sate Gagak",
        output = "SateGagak",
        cookTime = 60,
        ingredients = { { item = "DagingGagak", qty = 1 } }
    },
    {
        id = "Rebus",
        label = "Jamur Rebus Kuburan",
        output = "JamurRebus",
        cookTime = 60,
        ingredients = { { item = "JamurKuburan", qty = 1 } }
    }
}

local function getInventoryItemCount(itemId)
    local target = itemId:lower():gsub("%s+", "")
    local total = 0
    for _, cont in ipairs({ LP:FindFirstChildOfClass("Backpack"), LP.Character }) do
        if cont then
            for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") then
                    local tId = (t:GetAttribute("ItemId") or t.Name):lower():gsub("%s+", "")
                    local tNm = t.Name:lower():gsub("%s+", "")
                    if tId == target or tNm == target or tNm:find(target, 1, true) or target:find(tNm, 1, true) then
                        local c = tonumber(t:GetAttribute("Count")) or tonumber(t.Name:match("x(%d+)")) or 1
                        total = total + c
                    end
                end
            end
        end
    end
    return total
end

local function canCookRecipe(rec)
    for _, ing in ipairs(rec.ingredients) do
        if getInventoryItemCount(ing.item) < ing.qty then
            return false
        end
    end
    return true
end

local function getKomporPos(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Attachment") then
        return obj.WorldPosition
    elseif obj:IsA("Model") then
        return obj:GetPivot().Position
    elseif obj:IsA("ProximityPrompt") and obj.Parent then
        local p = obj.Parent
        if p:IsA("BasePart") then return p.Position
        elseif p:IsA("Attachment") then return p.WorldPosition
        elseif p:IsA("Model") then return p:GetPivot().Position end
    end
    return nil
end

local function findKompor()
    -- 1. Prioritas Utama: Cari di dalam Plot Kebun / Dapur milik pemain sendiri (Plot memiliki Lahan1, Stove, dsb.)
    local myPlot = getMyPlot()
    if myPlot then
        for _, name in ipairs({"Stove", "pStove", "Kompor", "pKompor", "CookingTable", "Cooking", "Dapur", "Kitchen"}) do
            local obj = myPlot:FindFirstChild(name, true)
            if obj then return obj end
        end
        for _, desc in ipairs(myPlot:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text:upper():find("STOVE") then
                local model = desc:FindFirstAncestorOfClass("Model") or desc:FindFirstAncestorOfClass("BasePart")
                if model then return model end
            end
        end
        for _, p in ipairs(myPlot:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                local at = (p.ActionText or ""):lower()
                local ot = (p.ObjectText or ""):lower()
                local pn = p.Name:lower()
                if at:find("cook") or at:find("masak") or ot:find("stove") or ot:find("kompor") or pn:find("stove") or pn:find("kompor") then
                    return p.Parent or p
                end
            end
        end
    end

    -- 2. Prioritas Kedua: Cari di Kios player
    local myKios = getMyKios()
    if myKios then
        for _, name in ipairs({"pKompor", "Kompor", "pStove", "Stove", "Kitchen", "Dapur", "CookingTable"}) do
            local obj = myKios:FindFirstChild(name, true)
            if obj then return obj end
        end
        for _, desc in ipairs(myKios:GetDescendants()) do
            local nm = desc.Name:lower()
            if (desc:IsA("BasePart") or desc:IsA("Model")) and (nm:find("kompor") or nm:find("stove") or nm:find("dapur") or nm == "cooking") then
                return desc
            end
        end
        for _, p in ipairs(myKios:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                local at = (p.ActionText or ""):lower()
                local ot = (p.ObjectText or ""):lower()
                local pn = p.Name:lower()
                if at:find("masak") or at:find("cook") or ot:find("kompor") or ot:find("stove") or pn:find("kompor") or pn:find("stove") then
                    return p.Parent or p
                end
            end
        end
    end

    -- 3. Fallback: Cari Kompor / ProximityPrompt terdekat dengan karakter
    local root = getRoot()
    local bestObj = nil
    local bestDist = math.huge
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            local at = (desc.ActionText or ""):lower()
            local ot = (desc.ObjectText or ""):lower()
            if at:find("masak") or at:find("cook") or ot:find("kompor") or ot:find("stove") then
                local pos = getKomporPos(desc)
                if pos and root then
                    local d = (root.Position - pos).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestObj = desc.Parent or desc
                    end
                end
            end
        elseif (desc:IsA("BasePart") or desc:IsA("Model")) and (desc.Name == "pKompor" or desc.Name == "Kompor" or desc.Name == "pStove" or desc.Name == "Stove") then
            local pos = getKomporPos(desc)
            if pos and root then
                local d = (root.Position - pos).Magnitude
                if d < bestDist then
                    bestDist = d
                    bestObj = desc
                end
            end
        end
    end
    if bestObj then return bestObj end

    return nil
end

local function getCookingPrompt()
    local kompor = findKompor()
    if not kompor then return nil end
    if kompor:IsA("ProximityPrompt") then return kompor end
    local p = kompor:FindFirstChildOfClass("ProximityPrompt") or kompor:FindFirstChildWhichIsA("ProximityPrompt", true)
    if p then return p end
    if kompor.Parent then
        p = kompor.Parent:FindFirstChildOfClass("ProximityPrompt") or kompor.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
        if p then return p end
    end
    return nil
end

local function countItemInBag(itemName)
    local target = itemName:lower()
    local total = 0
    for _, cont in ipairs({LP.Character, LP.Backpack}) do
        if cont then
            for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") then
                    local nm = t.Name:lower()
                    if nm:find(target) then
                        local c = t:GetAttribute("Count") or tonumber(t.Name:match("x(%d+)")) or 1
                        total = total + c
                    end
                end
            end
        end
    end
    return total
end

local function findCookingGui()
    -- 1. Scan semua ScreenGui untuk mencari UI dengan teks cooking yang sedang AKTIF & TERLIHAT
    for _, g in ipairs(PG:GetChildren()) do
        if g:IsA("ScreenGui") and g.Enabled then
            for _, d in ipairs(g:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text ~= "" and isGuiObjectActuallyVisible(d) then
                    local t = d.Text:lower()
                    if t:find("recipe list") or t:find("pick a recipe") or (t:find("cooking") and t:find("lv")) then
                        return g
                    end
                end
            end
        end
    end

    -- 2. Fallback nama ScreenGui yang umum
    for _, name in ipairs({"CookingGui", "Cooking", "MemasakGui", "CookGui", "DapurGui", "Dapur", "CookingUI", "StoveGui"}) do
        local g = PG:FindFirstChild(name)
        if g and g:IsA("ScreenGui") and g.Enabled then
            for _, child in ipairs(g:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then
                    return g
                end
            end
        end
    end
    return nil
end

-- ══ ANTI-VOID SAFEGUARD ══
task.spawn(function()
    while true do
        task.wait(1)
        local root = getRoot()
        if root and root.Position.Y < -25 then
            local lahans = getMyLahans()
            if #lahans > 0 then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = CFrame.new(lahans[1].Position + Vector3.new(0, 6, 0))
                log("[Anti-Void] Karakter diselamatkan dari void kembali ke lahan kebun!")
            end
        end
    end
end)

local function closeCookingGui(cGui)
    pcall(function()
        pcall(function()
            local RS = game:GetService("ReplicatedStorage")
            local pvMod = RS:FindFirstChild("PopupVisibility")
            if pvMod then
                local pv = require(pvMod)
                if pv and type(pv.Close) == "function" then
                    pv.Close("Memasak")
                    pv.Close("Cooking")
                end
            end
        end)

        -- PERINGATAN KRUSIAL: JANGAN PERNAH loop klik tombol di MemasakGui karena QSlot memiliki 'CloseBtn' yang memanggil CookCancel (membatalkan masakan)!
        if cGui and cGui:IsA("ScreenGui") then
            cGui.Enabled = false
            for _, child in ipairs(cGui:GetChildren()) do
                if child:IsA("GuiObject") then
                    child.Visible = false
                end
            end
        end

        closeGameGui("CookingGui")
        closeGameGui("MemasakGui")
        closeGameGui("Cooking")
        closeGameGui("CookGui")
        closeGameGui("DapurGui")
        closeGameGui("Dapur")
        closeGameGui("CookingUI")
        closeGameGui("StoveGui")
    end)
end

local function doExecuteCooking(specificRecipe)
    if isActionBusy then return false end
    isActionBusy = true

    local root = getRoot()
    if not root then
        isActionBusy = false
        return false
    end

    local cookStove = getR("CookStove")
    local cookQueuePoll = getR("CookQueuePoll")

    if not cookStove or not cookQueuePoll then
        log("[Cook] Remote CookStove atau CookQueuePoll tidak ditemukan!")
        isActionBusy = false
        return false
    end

    local kompor = findKompor()
    local komporPos = getKomporPos(kompor)
    if not komporPos then
        local myKios = getMyKios()
        local pK = myKios and myKios:FindFirstChild("pKompor", true)
        if pK then
            komporPos = getKomporPos(pK)
        end
    end

    if not komporPos then
        log("[Cook] Posisi kompor tidak ditemukan di Kios!")
        isActionBusy = false
        return false
    end

    -- 1. Periksa slot antrean kompor saat ini
    local okQ, qRes = pcall(function() return cookQueuePoll:InvokeServer() end)
    if not okQ or type(qRes) ~= "table" then
        isActionBusy = false
        return false
    end

    local maxQueue = tonumber(qRes.maxQueue) or 3
    local currentSlots = qRes.slots or {}
    local freeSlots = maxQueue - #currentSlots

    if freeSlots <= 0 then
        log(("[Cook] Antrean kompor penuh (%d/%d slot). Menunggu masakan matang..."):format(#currentSlots, maxQueue))
        isActionBusy = false
        return true
    end

    -- 2. Tentukan resep apa yang ingin dimasak
    local targetRecipeName = specificRecipe or State.FavCookTarget or "Semua"
    local recipesToCook = {}

    for i = 1, freeSlots do
        local chosenRec = nil
        if targetRecipeName:find("Semua") or targetRecipeName:find("Otomatis") then
            for _, rec in ipairs(COOKING_RECIPES) do
                if canCookRecipe(rec) then
                    chosenRec = rec
                    break
                end
            end
        else
            for _, rec in ipairs(COOKING_RECIPES) do
                local rNorm = rec.label:lower():gsub("%s+", "")
                local tNorm = targetRecipeName:lower():gsub("%s+", "")
                local idNorm = rec.id:lower()
                local outNorm = rec.output:lower()
                if rNorm:find(tNorm) or tNorm:find(rNorm) or idNorm:find(tNorm) or tNorm:find(idNorm) or outNorm:find(tNorm) or tNorm:find(outNorm) then
                    if canCookRecipe(rec) then
                        chosenRec = rec
                    end
                    break
                end
            end
        end

        if chosenRec then
            table.insert(recipesToCook, chosenRec)
        else
            break
        end
    end

    if #recipesToCook == 0 then
        log("[Cook] Bahan masakan di tas belum mencukupi untuk resep: " .. tostring(targetRecipeName))
        isActionBusy = false
        return false
    end

    -- 3. Coba panggil remote CookStove langsung dari posisi saat ini tanpa teleport
    local cookedCount = 0
    local needApproach = false
    local savedCFrame = nil

    for _, rec in ipairs(recipesToCook) do
        local okC, cRes = pcall(function()
            return cookStove:InvokeServer(rec.id)
        end)

        -- Jika remote membutuhkan karakter berada dekat kompor
        if not (okC and cRes and cRes.ok) and not needApproach then
            needApproach = true
            savedCFrame = root.CFrame
            pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)

            -- Berdiri di lantai depan kompor (sejajar tanah, bukan mengambang di atas kompor)
            local frontPos = komporPos + Vector3.new(0, 0.2, 2.0)
            root.CFrame = CFrame.new(frontPos, komporPos)
            pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
            task.wait(0.2)

            -- Coba masak ulang setelah dekat
            okC, cRes = pcall(function()
                return cookStove:InvokeServer(rec.id)
            end)
        end

        if okC and cRes and cRes.ok then
            cookedCount = cookedCount + 1
            log(("[Cook] Memasak %s berhasil! (Antrean: %s/%d)"):format(rec.label, tostring(cRes.queuePos or cookedCount), maxQueue))
            task.wait(0.2)
        else
            local reason = (cRes and cRes.reason) or "gagal"
            log(("[Cook] Gagal memasak %s: %s"):format(rec.label, tostring(reason)))
            break
        end
    end

    -- Kembalikan posisi karakter ke posisi tepat semula secara mulus (tanpa jatuh dari ketinggian)
    if needApproach and savedCFrame and root and root.Parent then
        root.CFrame = savedCFrame
        pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    end
    isActionBusy = false

    -- Pastikan GUI memasak tidak pernah terbuka menutupi layar
    closeCookingGui(findCookingGui())

    if cookedCount > 0 then
        pcall(function()
            WindUI:Notify({
                Title = "🍳 Memasak Dimulai!",
                Desc = ("Memasak %d pesanan di kompor secara otomatis."):format(cookedCount),
                Duration = 3,
                Icon = "soup"
            })
        end)
        return true
    end

    return false
end

local function debugScanMemasakGui()
    local cGui = findCookingGui()
    if not cGui then
        local prompt = getCookingPrompt()
        if prompt and prompt.Enabled then
            safeFirePrompt(prompt)
            task.wait(0.35)
            cGui = findCookingGui()
        end
    end
    if not cGui then
        openGameGui("MemasakGui")
        openGameGui("CookingGui")
        openGameGui("Cooking")
        task.wait(0.3)
        cGui = findCookingGui()
    end

    if not cGui then
        log("[Diagnostik Dapur] GUI Cooking tidak ditemukan di PlayerGui!")
        pcall(function()
            WindUI:Notify({
                Title = "🔍 Diagnostik Dapur",
                Desc = "GUI Memasak/Cooking belum terbuka atau tidak terdeteksi!",
                Duration = 4,
                Icon = "alert-circle"
            })
        end)
        return
    end

    log("[Diagnostik Dapur] GUI terdeteksi: " .. cGui.Name)
    local items = {}
    for _, d in ipairs(cGui:GetDescendants()) do
        if (d:IsA("GuiButton") or d:IsA("TextLabel")) and d.Visible and d.Text ~= "" then
            table.insert(items, d.ClassName .. " | Text: '" .. d.Text .. "' | Name: " .. d.Name)
        end
    end

    for _, it in ipairs(items) do
        print("  🔘 " .. it)
    end

    local kompor = findKompor()
    local kInfo = kompor and ("Kompor di: " .. kompor:GetFullName()) or "Kompor belum terdeteksi di Kios!"
    log("[Diagnostik Dapur] " .. kInfo)

    pcall(function()
        WindUI:Notify({
            Title = "🔍 Diagnostik: " .. cGui.Name,
            Desc = ("Ditemukan %d elemen di %s. Cek console/F9!"):format(#items, cGui.Name),
            Duration = 5,
            Icon = "check"
        })
    end)
end

local function probeInstantCooking()
    local cGui = findCookingGui()
    if not cGui then
        openGameGui("CookingGui")
        openGameGui("Cooking")
        task.wait(0.3)
        cGui = findCookingGui()
    end

    log("[InstantProbe] Memulai pengujian celah Instant Cook...")
    pcall(function()
        WindUI:Notify({
            Title = "⚡ Probe Instant Cook",
            Desc = "Mencoba probe celah bypass timer 01:30...",
            Duration = 4,
            Icon = "zap"
        })
    end)

    local remotes = {
        getR("CookStove"),
        getR("InstantCook"),
        getR("SkipCook"),
        getR("CookFinish"),
        getR("ClaimCooking"),
        getR("Memasak"),
        getR("Masak"),
        getR("ProsesBahan"),
    }

    local success = false
    local payloads = {
        { action = "instant", slot = 1, cost = 0 },
        { action = "skip", slot = 1, free = true },
        { action = "claim", slot = 1, force = true },
        { action = "finish", slot = 1 },
        { "instant", 1, 0 },
        { "finish", 1 },
        { "claim", 1 },
        "InstantCook",
        "FinishCook",
    }

    for _, rem in ipairs(remotes) do
        if rem then
            for _, p in ipairs(payloads) do
                local ok, res = pcall(function()
                    if rem:IsA("RemoteFunction") then
                        return rem:InvokeServer(p)
                    elseif rem:IsA("RemoteEvent") then
                        rem:FireServer(p)
                        return true
                    end
                end)
                if ok and res and res ~= false then
                    log(("[InstantProbe] Remote %s merespon payload!"):format(rem.Name))
                    success = true
                end
                task.wait(0.08)
            end
        end
    end

    if success then
        pcall(function()
            WindUI:Notify({
                Title = "⚡ Bypass Diterima!",
                Desc = "Server merespon sinyal instant finish!",
                Duration = 6,
                Icon = "check"
            })
        end)
    else
        pcall(function()
            WindUI:Notify({
                Title = "🛡️ Validasi Server-Side",
                Desc = "Timer 01:30 dihitung di server (Produk 10 Robux). Auto-Claim akan langsung klaim begitu 00:00!",
                Duration = 6,
                Icon = "shield"
            })
        end)
    end
end

local cookRunning = false
local function autoCookLoop()
    if cookRunning then return end
    cookRunning = true
    task.spawn(function()
        log("[Cook] Auto Cook dimulai (Cooldown cerdas 12s)")
        while State.AutoCook do
            if not isActionBusy then
                pcall(function()
                    doExecuteCooking(State.FavCookTarget or "Semua")
                end)
            end
            local waitTime = State.FastCook and 6 or 12
            task.wait(waitTime)
        end
        cookRunning = false
        log("[Cook] Auto Cook berhenti")
    end)
end

local cookFavRunning = false
local function autoCookFavLoop()
    if cookFavRunning then return end
    cookFavRunning = true
    task.spawn(function()
        log("[CookFav] Auto Cook Favorit dimulai (Cooldown cerdas 12s)")
        while State.AutoCookFav do
            if not isActionBusy then
                pcall(function()
                    doExecuteCooking(State.FavCookTarget or "Semua")
                end)
            end
            local waitTime = State.FastCook and 6 or 12
            task.wait(waitTime)
        end
        cookFavRunning = false
        log("[CookFav] Auto Cook Favorit berhenti")
    end)
end

local function doCookFavorite(specificMenuId)
    return doExecuteCooking(specificMenuId or State.FavCookTarget or "Semua")
end

-- ════════════════════════════════════════════════════════════════════════════
-- 4.3.B. AUTO-CLAIM QUEST & WANGSIT HARIAN
-- ════════════════════════════════════════════════════════════════════════════
local function claimCompletedQuests()
    local qFetch = getR("QuestFetch")
    local qClaim = getR("QuestClaim")
    if not qFetch or not qClaim then return end

    local ok, res = pcall(function() return qFetch:InvokeServer() end)
    if not ok or type(res) ~= "table" then return end

    -- Claim daily quests
    if res.quests and type(res.quests) == "table" then
        for _, q in ipairs(res.quests) do
            if q.id and not q.claimed and (q.progress or 0) >= (q.target or 1) then
                pcall(function()
                    qClaim:InvokeServer(q.id)
                    log("Klaim Quest Berhasil: " .. tostring(q.text or q.id))
                end)
                task.wait(0.5)
            end
        end
    end

    -- Claim weekly full streak if ready
    if res.rantaiPenuhKlaim then
        pcall(function()
            qClaim:InvokeServer("rantai_penuh")
            log("Klaim Hadiah Mingguan Penuh Berhasil!")
        end)
    end
end

local questRunning = false
local function autoQuestLoop()
    if questRunning then return end
    questRunning = true
    task.spawn(function()
        while State.AutoClaimQuest do
            pcall(claimCompletedQuests)
            task.wait(10)
        end
        questRunning = false
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- 4.3.C. REDEEM KODE HADIAH & PUSAKA TRADE
-- ════════════════════════════════════════════════════════════════════════════
local function redeemCode(code)
    local rCode = getR("RedeemCode")
    if not rCode then return false, "Remote RedeemCode tidak ditemukan" end
    local ok, res = pcall(function() return rCode:InvokeServer(tostring(code):upper():gsub("%s+", "")) end)
    if ok and type(res) == "table" then
        if res.ok then
            return true, "Sukses redeem kode " .. code
        else
            return false, res.reason or "Kode tidak valid"
        end
    end
    return false, "Gagal memproses kode"
end

local function redeemPopularCodes()
    local list = { "PASARHUTAN", "HUTAN", "RILIS", "RELEASE", "NEW", "UPDATE", "MALAM" }
    task.spawn(function()
        for _, c in ipairs(list) do
            local ok, msg = redeemCode(c)
            log("Redeem [" .. c .. "]: " .. tostring(msg))
            task.wait(3.5)
        end
    end)
end

local function doTukarPusaka()
    local rem = getR("PetiArwahTrade")
    if rem then
        pcall(function() rem:InvokeServer() end)
    else
        openGameGui("TukarPusakaGui", "ShopOverlay", "OpenPetiTukar")
    end
end

-- ════════════════════════════════════════════════════════════════════════════
-- 4.4. AUTO JUAL LANGSUNG KE PASAR (BULK SURPLUS INVENTORY)
-- ════════════════════════════════════════════════════════════════════════════
local sellMarketRunning = false
local function autoSellMarketLoop()
    if sellMarketRunning then return end
    sellMarketRunning = true
    task.spawn(function()
        while State.AutoSellMarket do
            if not isActionBusy then
                local cropToSell = nil
                for _, cont in ipairs({LP.Character, LP.Backpack}) do
                    if cont then
                        for _, t in ipairs(cont:GetChildren()) do
                            if t:IsA("Tool") and not isProtectedTool(t) then
                                local nm = t.Name:lower()
                                if nm:find("kentang") or nm:find("jagung") or nm:find("cabai") or nm:find("bawang") or nm:find("tomat") then
                                    local count = t:GetAttribute("Count") or tonumber(t.Name:match("x(%d+)")) or 1
                                    if count >= 30 then
                                        cropToSell = t
                                        break
                                    end
                                end
                            end
                        end
                    end
                    if cropToSell then break end
                end

                if cropToSell then
                    log("[AutoSell] Mengalirkan panen berlebih (" .. cropToSell.Name .. ") ke rak Kios Dagang...")
                    pcall(stockKiosShelves)
                end
            end
            task.wait(6)
        end
        sellMarketRunning = false
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- 4.5. AUTO FORAGING & TANGKAP LIAR
-- ════════════════════════════════════════════════════════════════════════════
local forageRunning = false
local function autoForageLoop()
    if forageRunning then return end
    forageRunning = true
    task.spawn(function()
        while State.AutoForage or State.AutoGagak or State.AutoTuyul do
            local root = getRoot()
            if not root then task.wait(1); continue end

            local targets = {}
            for _, o in ipairs(Workspace:GetDescendants()) do
                if o:IsA("ProximityPrompt") and o.Enabled then
                    local act = (o.ActionText or ""):lower()
                    local obj = (o.ObjectText or ""):lower()
                    local oName = o.Name:lower()
                    local isForage = act:find("ambil") or act:find("petik") or act:find("pungut") or act:find("take") or act:find("pick") or act:find("harvest") or act:find("collect")
                    local isGagak  = obj:find("gagak") or obj:find("crow") or act:find("tangkap") or act:find("catch")
                    local isTuyul  = obj:find("tuyul") or oName:find("tuyul")

                    local shouldPickup = false
                    if State.AutoForage and isForage and not isGagak and not isTuyul then
                        shouldPickup = true
                    elseif State.AutoGagak and isGagak then
                        shouldPickup = true
                    elseif State.AutoTuyul and isTuyul then
                        shouldPickup = true
                    end

                    if shouldPickup then
                        local part = o.Parent:IsA("BasePart") and o.Parent or (o.Parent:IsA("Attachment") and o.Parent.Parent:IsA("BasePart") and o.Parent.Parent or nil)
                        if part then
                            table.insert(targets, { prompt = o, part = part, obj = obj })
                        end
                    end
                end
            end

            if #targets > 0 then
                table.sort(targets, function(a, b)
                    return (root.Position - a.part.Position).Magnitude < (root.Position - b.part.Position).Magnitude
                end)

                local oldPos = root.Position
                for i = 1, math.min(10, #targets) do
                    if not (State.AutoForage or State.AutoGagak or State.AutoTuyul) then break end
                    local item = targets[i]
                    if item.prompt and item.prompt.Enabled and item.part and item.part.Parent then
                        root.CFrame = CFrame.new(item.part.Position + Vector3.new(0, 2, 0))
                        task.wait(0.25)
                        safeFirePrompt(item.prompt)
                        task.wait(0.35)
                    end
                end

                local myLahans = getMyLahans()
                if State.AutoFarm and #myLahans > 0 then
                    root.CFrame = CFrame.new(myLahans[1].Position + Vector3.new(0, 3.5, 0))
                else
                    root.CFrame = CFrame.new(oldPos)
                end
            end

            task.wait(3)
        end
        forageRunning = false
    end)
end

local function sweepAllForagables()
    local root = getRoot()
    if not root then return end

    local targets = {}
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("ProximityPrompt") and o.Enabled then
            local act = o.ActionText:lower()
            if act:find("ambil") or act:find("petik") or act:find("pungut") or act:find("tangkap") then
                local part = o.Parent:IsA("BasePart") and o.Parent or (o.Parent:IsA("Attachment") and o.Parent.Parent:IsA("BasePart") and o.Parent.Parent or nil)
                if part then
                    table.insert(targets, { prompt = o, part = part, obj = o.ObjectText })
                end
            end
        end
    end

    if #targets == 0 then
        log("Tidak ada item liar yang siap diambil saat ini!")
        return
    end

    log("Menyapu " .. #targets .. " item liar di map...")
    local oldPos = root.Position
    for _, item in ipairs(targets) do
        if item.prompt and item.prompt.Enabled and item.part and item.part.Parent then
            root.CFrame = CFrame.new(item.part.Position + Vector3.new(0, 2, 0))
            task.wait(0.25)
            safeFirePrompt(item.prompt)
            task.wait(0.35)
        end
    end

    local myLahans = getMyLahans()
    if #myLahans > 0 then
        root.CFrame = CFrame.new(myLahans[1].Position + Vector3.new(0, 3.5, 0))
    else
        root.CFrame = CFrame.new(oldPos)
    end
    log("Sapuan item liar selesai!")
end

-- ════════════════════════════════════════════════════════════════════════════
-- 4.6. SAFE LOOTING BAHAN ALAM LIAR (ANTI-KICK)
-- ════════════════════════════════════════════════════════════════════════════
local function isAnyLootActive()
    return State.AutoSafeLoot 
        or State.AutoGetGagak 
        or State.AutoGetKepiting 
        or State.AutoGetDupa 
        or State.AutoGetKemenyan 
        or State.AutoGetJamur 
        or State.AutoGetMelati
end

local function doSafeLoot(singleTargetName)
    if isActionBusy then return end
    local root = getRoot()
    if not root then return end

    local candidates = {}
    local seenPrompts = {}

    local function matchItemKey(text, key)
        text = text:lower()
        key = key:lower()
        if key == "kepiting" or key == "crab" then
            return text:find("kepiting") or text:find("crab")
        elseif key == "gagak" or key == "crow" then
            return text:find("gagak") or text:find("crow")
        elseif key == "dupa" or key == "incense" or key == "kemenyan" then
            return (text:find("dupa") or text:find("incense") or text:find("kemenyan")) and not text:find("frankincense")
        elseif key == "jamur" or key == "mushroom" then
            return text:find("jamur") or text:find("mushroom")
        elseif key == "melati" or key == "jasmine" then
            return text:find("melati") or text:find("jasmine") or text:find("flower")
        end
        return text:find(key) ~= nil
    end

    local function checkCandidate(prompt, container)
        if not prompt or not prompt.Enabled or seenPrompts[prompt] then return end
        local obj = (prompt.ObjectText or ""):lower()
        local act = (prompt.ActionText or ""):lower()
        local nameStr = (container and container.Name:lower() or "") .. " " .. (prompt.Parent and prompt.Parent.Name:lower() or "")
        local combined = obj .. " " .. act .. " " .. nameStr

        local allowed = false
        if singleTargetName then
            allowed = matchItemKey(combined, singleTargetName)
        else
            if State.AutoGetGagak and matchItemKey(combined, "gagak") then allowed = true end
            if State.AutoGetKepiting and matchItemKey(combined, "kepiting") then allowed = true end
            if State.AutoGetDupa and matchItemKey(combined, "dupa") then allowed = true end
            if State.AutoGetKemenyan and matchItemKey(combined, "kemenyan") then allowed = true end
            if State.AutoGetJamur and matchItemKey(combined, "jamur") then allowed = true end
            if State.AutoGetMelati and matchItemKey(combined, "melati") then allowed = true end

            if State.AutoSafeLoot then
                if State.LootTarget == "Semua" then
                    allowed = matchItemKey(combined, "kepiting")
                        or matchItemKey(combined, "gagak")
                        or matchItemKey(combined, "dupa")
                        or matchItemKey(combined, "jamur")
                        or matchItemKey(combined, "melati")
                else
                    allowed = matchItemKey(combined, State.LootTarget)
                end
            end
        end

        if allowed then
            local targetPart = (prompt.Parent and prompt.Parent:IsA("BasePart") and prompt.Parent)
                or (container and container:FindFirstChildWhichIsA("BasePart", true))
                or (container and container:IsA("BasePart") and container)
                or (prompt.Parent and prompt.Parent:IsA("Model") and (prompt.Parent.PrimaryPart or prompt.Parent:FindFirstChildWhichIsA("BasePart")))
            if targetPart then
                seenPrompts[prompt] = true
                local dist = (root.Position - targetPart.Position).Magnitude
                table.insert(candidates, { prompt = prompt, part = targetPart, dist = dist, name = prompt.ObjectText })
            end
        end
    end

    -- 1. Scan folder container umum jika ada
    local foldersToScan = {
        Workspace:FindFirstChild("SpawnBahan"),
        Workspace:FindFirstChild("Kepiting"),
        Workspace:FindFirstChild("Crabs"),
        Workspace:FindFirstChild("Crab"),
        Workspace:FindFirstChild("Sungai"),
        Workspace:FindFirstChild("River"),
        Workspace:FindFirstChild("Animals"),
        Workspace:FindFirstChild("Hewan"),
        Workspace:FindFirstChild("Gagak"),
        Workspace:FindFirstChild("Crow"),
        Workspace:FindFirstChild("Spawn"),
        Workspace:FindFirstChild("Items"),
        Workspace:FindFirstChild("Bahan"),
    }

    for _, f in ipairs(foldersToScan) do
        if f then
            for _, child in ipairs(f:GetChildren()) do
                local p = child:FindFirstChildWhichIsA("ProximityPrompt", true) or (child:IsA("ProximityPrompt") and child)
                if p then checkCandidate(p, child) end
            end
        end
    end

    -- 2. Jika belum ditemukan kandidat, scan seluruh Workspace Descendants
    if #candidates == 0 then
        for _, p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled then
                checkCandidate(p, p.Parent)
            end
        end
    end

    if #candidates == 0 then return end
    table.sort(candidates, function(a, b) return a.dist < b.dist end)

    isActionBusy = true
    local oldPos = root.Position
    local takeCount = singleTargetName and 1 or math.min(3, #candidates)
    for i = 1, takeCount do
        local target = candidates[i]
        if target.prompt and target.prompt.Enabled and target.prompt.Parent then
            root.CFrame = CFrame.new(target.part.Position + Vector3.new(0, 1.2, 0))
            task.wait(0.2)
            safeFirePrompt(target.prompt)
            task.wait(0.35)
        end
    end

    local lahans = getMyLahans()
    if State.AutoFarm and #lahans > 0 then
        root.CFrame = CFrame.new(lahans[1].Position + Vector3.new(0, 3.5, 0))
    else
        root.CFrame = CFrame.new(oldPos)
    end
    task.wait(0.2)
    isActionBusy = false
end

local safeLootRunning = false
local function autoSafeLootLoop()
    if safeLootRunning then return end
    safeLootRunning = true
    task.spawn(function()
        while isAnyLootActive() do
            pcall(function() doSafeLoot() end)
            task.wait(State.AutoLootDelay or 5)
        end
        safeLootRunning = false
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- 5. UPGRADE SYSTEM
-- ════════════════════════════════════════════════════════════════════════════
local function doUpgradeMarket()
    local myKios = Workspace:FindFirstChild("KiosAktif") and Workspace.KiosAktif:FindFirstChild("Kios_" .. LP.Name)
    local up = myKios and myKios:FindFirstChild("pShopUpgrade")
    local prompt = up and up:FindFirstChild("UpgradePrompt")
    local root = getRoot()

    if prompt and root then
        root.CFrame = CFrame.new(up.WorldPosition + Vector3.new(0, 1, 1))
        task.wait(0.3)
        safeFirePrompt(prompt)
        task.wait(0.35)

        local cg = PG:FindFirstChild("ConfirmGui")
        if cg then
            for _, b in ipairs(cg:GetDescendants()) do
                if b:IsA("GuiButton") and (b.Name:lower():find("confirm") or (b:FindFirstChild("Label") and b.Label.Text:lower():find("confirm"))) then
                    if getconnections then
                        for _, conn in ipairs(getconnections(b.Activated)) do conn:Fire() end
                    end
                end
            end
        end
        log("Memicu Upgrade Toko")
    else
        log("Prompt Upgrade Toko tidak ditemukan!")
    end
end

local function doUpgradeLahan()
    local stats = getLahanStats()
    if stats.upgradePrompt then
        local root = getRoot()
        if root then root.CFrame = stats.upgradePrompt.Parent.CFrame + Vector3.new(0, 3, 2) end
        task.wait(0.3)
        safeFirePrompt(stats.upgradePrompt)
        task.wait(0.35)
        log("Memicu Lahan upgrade prompt")
    else
        log("Prompt upgrade lahan tidak aktif atau sudah level maksimal!")
    end
end

local function doUnlockLahanBesar()
    local lahans = getMyLahans()
    if #lahans == 0 then return end
    local plot = lahans[1].Parent
    local lb = plot and plot:FindFirstChild("LahanBesar")
    if not lb then log("LahanBesar tidak ditemukan"); return end

    local root = getRoot()
    local unlockedAny = false
    for _, box in ipairs(lb:GetChildren()) do
        local p = box:FindFirstChild("BukaPrompt", true)
        if p and p.Enabled and root then
            root.CFrame = box:GetPivot() + Vector3.new(0, 3, 2)
            task.wait(0.3)
            safeFirePrompt(p)
            task.wait(0.35)
            unlockedAny = true
            log("Membuka petak " .. box.Name)
            break
        end
    end
    if not unlockedAny then
        log("Tidak ada petak LahanBesar yang siap dibuka (Cek level/koin)")
    end
end

local function doBangunKandang(animalName)
    local lahans = getMyLahans()
    if #lahans == 0 then return end
    local plot = lahans[1].Parent
    local kName = "Kandang" .. animalName
    local kandang = plot and plot:FindFirstChild(kName)
    local prompt = kandang and kandang:FindFirstChild("BangunPrompt", true)
    local root = getRoot()

    if prompt and root then
        if prompt.Enabled then
            root.CFrame = kandang.CFrame + Vector3.new(0, 3, 2)
            task.wait(0.3)
            safeFirePrompt(prompt)
            task.wait(0.35)
            log("Memicu Bangun " .. kName)
        else
            log(kName .. " belum dapat dibangun (Persyaratan level belum cukup)")
        end
    else
        log(kName .. " tidak ditemukan di plot kamu!")
    end
end

local function tpToPos(pos)
    local root = getRoot()
    if root then
        root.CFrame = CFrame.new(pos + Vector3.new(0, 3.5, 0))
    end
end

-- ════════════════════════════════════════════════════════════════════════════
-- ESP & VISUAL ENGINE
-- ════════════════════════════════════════════════════════════════════════════
local espFolder = nil
local activeESPEntries = {}

local function getESPFolder()
    if not espFolder or not espFolder.Parent then
        local target = (gethui and gethui()) or game:GetService("CoreGui") or LP:FindFirstChild("PlayerGui")
        espFolder = target:FindFirstChild("PasarHutanESP")
        if not espFolder then
            espFolder = Instance.new("Folder")
            espFolder.Name = "PasarHutanESP"
            espFolder.Parent = target
        end
    end
    return espFolder
end

local function clearAllESP()
    for adornee, entry in pairs(activeESPEntries) do
        pcall(function()
            if entry.bg then entry.bg:Destroy() end
            if entry.hl then entry.hl:Destroy() end
        end)
    end
    activeESPEntries = {}
    if espFolder then
        pcall(function() espFolder:ClearAllChildren() end)
    end
end

local function addESP(part, labelText, color, tagType)
    if not part or not part:IsA("BasePart") or activeESPEntries[part] then return end

    local folder = getESPFolder()

    -- Highlight Chams
    local hl = Instance.new("Highlight")
    hl.Name = "HL_" .. part.Name
    hl.Adornee = part
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0.2
    hl.Parent = folder

    -- Billboard Text
    local bg = Instance.new("BillboardGui")
    bg.Name = "BG_" .. part.Name
    bg.Adornee = part
    bg.Size = UDim2.fromOffset(130, 26)
    bg.StudsOffset = Vector3.new(0, 2.5, 0)
    bg.AlwaysOnTop = true
    bg.Parent = folder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextColor3 = color
    lbl.TextStrokeColor3 = Color3.fromRGB(15, 15, 15)
    lbl.TextStrokeTransparency = 0.2
    lbl.Text = labelText
    lbl.Parent = bg

    activeESPEntries[part] = {
        bg = bg,
        hl = hl,
        lbl = lbl,
        rawText = labelText,
        part = part,
        tagType = tagType
    }
end

task.spawn(function()
    while true do
        task.wait(1.5)
        local anyESP = State.ESP_Items or State.ESP_Animals or State.ESP_Peti or State.ESP_Mining
        if anyESP then
            local root = getRoot()
            local folder = getESPFolder()

            -- 1. Scan ProximityPrompts for Items, Animals, Peti
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled then
                    local p = d.Parent
                    local part = p:IsA("BasePart") and p or (p:IsA("Model") and (p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart")))
                    if part and not activeESPEntries[part] then
                        local a = d.ActionText:lower()
                        local o = d.ObjectText:lower()
                        local dist = root and (root.Position - part.Position).Magnitude or 0
                        if dist <= State.ESP_MaxDist then
                            if State.ESP_Items and (o:find("jamur") or a:find("jamur")) then
                                addESP(part, "🍄 Jamur", Color3.fromRGB(180, 100, 255), "item")
                            elseif State.ESP_Items and (o:find("melati") or a:find("melati")) then
                                addESP(part, "🌸 Melati", Color3.fromRGB(120, 240, 255), "item")
                            elseif State.ESP_Items and (o:find("kemenyan") or a:find("kemenyan") or o:find("dupa")) then
                                addESP(part, "🪵 Kemenyan", Color3.fromRGB(255, 170, 50), "item")
                            elseif State.ESP_Animals and (o:find("gagak") or a:find("gagak")) then
                                addESP(part, "🦅 Gagak", Color3.fromRGB(140, 160, 220), "animal")
                            elseif State.ESP_Animals and (o:find("tuyul") or a:find("tuyul")) then
                                addESP(part, "👶 Tuyul", Color3.fromRGB(50, 255, 120), "animal")
                            elseif State.ESP_Peti and (o:find("peti") or a:find("peti") or o:find("arwah")) then
                                addESP(part, "⚰️ Peti Arwah", Color3.fromRGB(255, 70, 70), "peti")
                            end
                        end
                    end
                end
            end

            -- 2. Scan Mining Rocks
            if State.ESP_Mining then
                local bc = Workspace:FindFirstChild("BahanCraft")
                if bc then
                    for _, r in ipairs(bc:GetChildren()) do
                        local part = r:IsA("BasePart") and r or (r:IsA("Model") and (r.PrimaryPart or r:FindFirstChildWhichIsA("BasePart")))
                        if part and not activeESPEntries[part] then
                            local dist = root and (root.Position - part.Position).Magnitude or 0
                            if dist <= State.ESP_MaxDist then
                                addESP(part, "⛏️ " .. r.Name, Color3.fromRGB(255, 215, 0), "mining")
                            end
                        end
                    end
                end
            end

            -- 3. Update distances and remove collected items
            for part, entry in pairs(activeESPEntries) do
                if not part:IsDescendantOf(Workspace) or not part.Parent then
                    if entry.bg then entry.bg:Destroy() end
                    if entry.hl then entry.hl:Destroy() end
                    activeESPEntries[part] = nil
                else
                    if root then
                        local d = math.floor((root.Position - part.Position).Magnitude)
                        if d > State.ESP_MaxDist + 60 then
                            if entry.bg then entry.bg:Destroy() end
                            if entry.hl then entry.hl:Destroy() end
                            activeESPEntries[part] = nil
                        else
                            entry.lbl.Text = entry.rawText .. " [" .. d .. "m]"
                        end
                    end
                end
            end
        else
            if next(activeESPEntries) ~= nil then
                clearAllESP()
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
-- POTATO MODE (FPS BOOSTER) & DISCORD WEBHOOK
-- ════════════════════════════════════════════════════════════════════════════
local function setPotatoMode(enable)
    local Lighting = game:GetService("Lighting")
    local Terrain = Workspace:FindFirstChildOfClass("Terrain")
    if enable then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1
            if Terrain then
                Terrain.Decoration = false
            end
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostProcessEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                    v.Enabled = false
                end
            end
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part:IsDescendantOf(LP.Character) then
                    part.Material = Enum.Material.SmoothPlastic
                    part.CastShadow = false
                elseif part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Smoke") or part:IsA("Fire") then
                    part.Enabled = false
                end
            end
            settings().Rendering.QualityLevel = 1
        end)
        log("Mode Potato / FPS Booster Aktif!")
    end
end

local function sendDiscordWebhook(url)
    local req = request or http_request or (syn and syn.request) or (http and http.request)
    if not req or not url or not url:find("discord.com/api/webhooks") then
        pcall(function()
            WindUI:Notify({ Title = "Webhook Error", Desc = "URL Discord Webhook tidak valid!", Icon = "alert-circle" })
        end)
        return false
    end

    local ls = LP:FindFirstChild("leaderstats")
    local lv = ls and ls:FindFirstChild("Lv") and ls.Lv.Value or 1
    local kn = ls and ls:FindFirstChild("Koin") and ls.Koin.Value or 0
    local stats = getLahanStats()

    local payload = {
        embeds = {{
            title = "🌾 Pasar Hutan - Laporan AFK Tani",
            description = "Status akun **" .. LP.Name .. "** (" .. LP.DisplayName .. ") saat ini:",
            color = 3066993, -- Hijau Hutan
            fields = {
                { name = "💰 Saldo Koin", value = tostring(kn) .. " Koin", inline = true },
                { name = "⭐ Level Karakter", value = "Lv." .. tostring(lv), inline = true },
                { name = "🌱 Status Lahan", value = "Lv." .. stats.level .. " (" .. stats.current .. "/" .. stats.max .. " Slot)", inline = false },
                { name = "🟢 Siap Panen", value = tostring(stats.ready) .. " tanaman", inline = true },
                { name = "💧 Basah", value = tostring(stats.wet), inline = true },
                { name = "⚠️ Kering", value = tostring(stats.dry), inline = true },
            },
            footer = { text = "Pasar Hutan Hub V10.0 • " .. os.date("%X") }
        }}
    }
    local ok, res = pcall(function()
        return req({
            Url = url,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = game:GetService("HttpService"):JSONEncode(payload)
        })
    end)
    if ok then
        pcall(function()
            WindUI:Notify({ Title = "Webhook Terkirim!", Desc = "Laporan berhasil dikirim ke channel Discord.", Icon = "check-check" })
        end)
    end
    return ok
end

task.spawn(function()
    while true do
        task.wait(60 * math.max(1, State.WebhookInterval or 15))
        if State.AutoWebhook and State.DiscordWebhook ~= "" then
            pcall(function() sendDiscordWebhook(State.DiscordWebhook) end)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
-- COIN HELPER & PASAR GAIB / PETI ARWAH SNIPER
-- ════════════════════════════════════════════════════════════════════════════
local function getCoin()
    local ls = LP:FindFirstChild("leaderstats")
    return ls and ls:FindFirstChild("Koin") and ls.Koin.Value or 0
end

local gaibSnipeRunning = false
local function doGaibSnipe()
    local Lighting = game:GetService("Lighting")
    local isNight = (Lighting.ClockTime >= 18 or Lighting.ClockTime < 6)
    if not isNight then return end

    local pollRem = getR("GaibShopPoll")
    local buyRem  = getR("GaibBuy")
    if not pollRem or not buyRem then return end

    local npcMis = Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("NpcMisterius")
    if not npcMis then return end

    local root = getRoot()
    if root and (root.Position - npcMis.Position).Magnitude > 50 then
        tpToPos(npcMis.Position + Vector3.new(0, 3, 2))
        task.wait(0.4)
    end

    local ok, res = pcall(function() return pollRem:InvokeServer() end)
    if not ok or type(res) ~= "table" or not res.items then return end

    for _, item in ipairs(res.items) do
        local stock = item.Left or item.Stock or 0
        local price = item.Price or 0
        local currentCoin = getCoin()

        local matches = (State.GaibSnipeTarget == "Semua") or (item.Id == State.GaibSnipeTarget)
        if matches and stock > 0 and (currentCoin - price) >= (State.MinCoinReserve or 100) then
            local okBuy, buyRes = pcall(function() return buyRem:InvokeServer(item.Id) end)
            if okBuy and type(buyRes) == "table" and buyRes.ok then
                log(("⚡ Auto-Snipe Pasar Gaib Berhasil: %s seharga %d koin!"):format(tostring(item.Display or item.Id), price))
                pcall(function()
                    WindUI:Notify({
                        Title = "⚡ Snipe Pasar Gaib Sukses!",
                        Desc = ("Berhasil membeli %s (%d Koin)!"):format(item.Display or item.Id, price),
                        Duration = 5,
                        Icon = "shopping-bag"
                    })
                end)
                task.wait(0.4)
            end
        end
    end
end

local function autoGaibSnipeLoop()
    if gaibSnipeRunning then return end
    gaibSnipeRunning = true
    task.spawn(function()
        while State.AutoGaibSnipe do
            pcall(doGaibSnipe)
            task.wait(6)
        end
        gaibSnipeRunning = false
    end)
end

local function checkPetiArwahPity()
    local rem = getR("PetiArwahPity")
    if not rem then
        WindUI:Notify({ Title = "Peti Arwah", Desc = "Remote PetiArwahPity tidak ditemukan", Duration = 3 })
        return nil
    end
    local ok, res = pcall(function() return rem:InvokeServer() end)
    if ok and type(res) == "table" then
        local count = res.count or 0
        local threshold = res.threshold or 100
        local sisa = math.max(0, threshold - count)
        log(("Pity Peti Arwah: %d / %d (Sisa: %d)"):format(count, threshold, sisa))
        WindUI:Notify({
            Title = "👁️ Status Pity Peti Arwah",
            Desc = ("Counter Pity: %d / %d\n(Kurang %d pull lagi ke Guaranteed Rare!)"):format(count, threshold, sisa),
            Duration = 6,
            Icon = "sparkles"
        })
        return count, threshold
    else
        WindUI:Notify({ Title = "Peti Arwah", Desc = "Gagal mengambil data pity (hanya aktif saat malam)", Duration = 3 })
        return nil
    end
end

local smartPetiRunning = false
local function doSmartPetiPull()
    local Lighting = game:GetService("Lighting")
    local isNight = (Lighting.ClockTime >= 18 or Lighting.ClockTime < 6)
    if not isNight then return end

    local pullRem = getR("PetiArwahPull")
    if not pullRem then return end

    local pkg = State.PetiPullPackage or 10
    local cost = (pkg == 50 and 8500) or (pkg == 10 and 1800) or 200
    local currentCoin = getCoin()

    if (currentCoin - cost) < (State.MinCoinReserve or 100) then return end

    local npcPeti = Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("NpcPetiArwah")
    if npcPeti then
        local root = getRoot()
        if root and (root.Position - npcPeti.Position).Magnitude > 50 then
            tpToPos(npcPeti.Position + Vector3.new(0, 3, 2))
            task.wait(0.4)
        end
    end

    local ok, res = pcall(function() return pullRem:InvokeServer(pkg) end)
    if ok and type(res) == "table" and res.ok then
        log(("🔮 Berhasil Smart Pull x%d Peti Arwah!"):format(pkg))
        pcall(function()
            WindUI:Notify({
                Title = "🔮 Smart Pull Berhasil",
                Desc = ("Membuka x%d Peti Arwah! Shards/Pusaka bertambah."):format(pkg),
                Duration = 5,
                Icon = "gift"
            })
        end)
    end
end

local function autoSmartPetiLoop()
    if smartPetiRunning then return end
    smartPetiRunning = true
    task.spawn(function()
        while State.AutoPetiSmartPull do
            pcall(doSmartPetiPull)
            task.wait(10)
        end
        smartPetiRunning = false
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- JATAH PETI ARWAH, BUFF GAIB & BALAI DESA AUTOMATION
-- ════════════════════════════════════════════════════════════════════════════
local function doClaimJatahPeti()
    local rem = getR("PetiArwahJatah")
    if not rem then return false end
    local ok, res = pcall(function() return rem:InvokeServer() end)
    if ok and type(res) == "table" and res.ok then
        log("🎁 Berhasil klaim jatah Peti Arwah gratis!")
        pcall(function()
            WindUI:Notify({
                Title = "🎁 Jatah Peti Arwah Gratis!",
                Desc = "Berhasil klaim jatah gacha Peti Arwah gratis malam ini!",
                Duration = 5,
                Icon = "gift"
            })
        end)
        return true
    end
    return false
end

local function doUseGaibBuff(buffId)
    local rem = getR("GaibUse")
    if not rem then return false end
    local targetBuff = buffId or State.GaibBuffChoice or "MinyakJelangkung"
    local ok, res = pcall(function() return rem:InvokeServer(targetBuff) end)
    if ok and type(res) == "table" and res.ok then
        log("⚡ Berhasil mengaktifkan buff gaib: " .. targetBuff)
        pcall(function()
            WindUI:Notify({
                Title = "⚡ Buff Gaib Aktif!",
                Desc = ("Buff %s berhasil diaktifkan! (Pungut/Masak/Speed meningkat)"):format(targetBuff),
                Duration = 5,
                Icon = "zap"
            })
        end)
        return true
    end
    return false
end

local function doKlaimLencana()
    local ackRem = getR("BalaiPollAck")
    local openRem = getR("BalaiOpen")
    local lencanaRem = getR("BalaiLencana")
    if openRem then pcall(function() openRem:FireServer() end) end
    task.wait(0.2)
    if lencanaRem then pcall(function() lencanaRem:FireServer() end) end
    task.wait(0.2)
    if ackRem then pcall(function() ackRem:FireServer() end) end
    log("🏅 Memeriksa & klaim reward lencana Balai Desa...")
    pcall(function()
        WindUI:Notify({
            Title = "🏅 Lencana Balai Desa",
            Desc = "Mencairkan reward milestone & lencana Balai Desa!",
            Duration = 4,
            Icon = "award"
        })
    end)
end

local function doPociQuest()
    local Lighting = game:GetService("Lighting")
    local isNight = (Lighting.ClockTime >= 18 or Lighting.ClockTime < 6)
    if not isNight then return false end

    local rem = getR("PociQuest")
    if not rem then return false end
    local ok, res = pcall(function() return rem:InvokeServer() end)
    if ok and res then
        log("📜 Interaksi PociQuest berhasil")
        pcall(function()
            WindUI:Notify({
                Title = "📜 Misi Pocong Malam",
                Desc = "Berhasil interaksi / klaim misi rahasia Pocong!",
                Duration = 4,
                Icon = "scroll"
            })
        end)
        return true
    end
    return false
end

-- ════════════════════════════════════════════════════════════════════════════
-- NIGHT & GAIB EVENT MONITOR
-- ════════════════════════════════════════════════════════════════════════════
local lastNightNotified = false
task.spawn(function()
    while true do
        task.wait(3)
        local Lighting = game:GetService("Lighting")
        local isNight = (Lighting.ClockTime >= 18 or Lighting.ClockTime < 6)

        if isNight and not lastNightNotified then
            lastNightNotified = true
            pcall(function()
                WindUI:Notify({
                    Title = "🌙 Malam Telah Tiba!",
                    Desc = "Pasar Gaib telah dibuka! Waktu berburu Peti Arwah & Tuyul.",
                    Duration = 6,
                    Icon = "moon"
                })
            end)
            if State.AutoPasarGaib then
                task.spawn(function()
                    local npcMis = Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("NpcMisterius")
                    if npcMis then
                        tpToPos(npcMis.Position + Vector3.new(0, 3, 2))
                        task.wait(0.4)
                        openGameGui("PasarGaibGui", "PasarGaib", "OpenPasarGaib")
                    end
                end)
            end
            if State.AutoGaibSnipe then
                task.spawn(doGaibSnipe)
            end
            if State.AutoUseGaibBuff then
                task.spawn(function() doUseGaibBuff() end)
            end
            if State.AutoClaimJatahPeti then
                task.spawn(doClaimJatahPeti)
            end
            if State.AutoPetiArwah then
                task.spawn(function()
                    local npcPeti = Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("NpcPetiArwah")
                    if npcPeti then
                        tpToPos(npcPeti.Position + Vector3.new(0, 3, 2))
                        task.wait(0.4)
                        local prompt = npcPeti:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            safeFirePrompt(prompt)
                        end
                    end
                end)
            end
            if State.AutoPetiSmartPull then
                task.spawn(doSmartPetiPull)
            end
            if State.AutoPociQuest then
                task.spawn(doPociQuest)
            end
            if State.AutoKlaimLencana then
                task.spawn(doKlaimLencana)
            end
        elseif not isNight then
            lastNightNotified = false
        end
    end
end)
-- ════════════════════════════════════════════════════════════════════════════
-- TUYUL & GHOST RADAR
-- ════════════════════════════════════════════════════════════════════════════
local notifiedTuyuls = {}
local function scanTuyulRadar()
    if not State.TuyulRadar then return end
    local root = getRoot()
    if not root then return end

    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Enabled then
            local o = d.ObjectText:lower()
            local a = d.ActionText:lower()
            if o:find("tuyul") or a:find("tuyul") then
                local p = d.Parent
                local part = p:IsA("BasePart") and p or (p:IsA("Model") and (p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart")))
                if part and not notifiedTuyuls[part] then
                    local dist = math.floor((root.Position - part.Position).Magnitude)
                    if dist <= 120 then
                        notifiedTuyuls[part] = true
                        pcall(function()
                            WindUI:Notify({
                                Title = "👶 Tuyul Liar Terdeteksi!",
                                Desc = "Tuyul berada di jarak " .. dist .. "m! Menghampiri...",
                                Duration = 5,
                                Icon = "bell"
                            })
                        end)
                        if State.AutoInterceptTuyul then
                            tpToPos(part.Position + Vector3.new(0, 2.5, 0))
                            task.wait(0.3)
                            safeFirePrompt(d)
                            if State.AutoFastTuyul then
                                task.wait(0.2)
                                local cutRem = getR("TuyulLiarCut")
                                local laporRem = getR("TuyulLiarLapor")
                                if cutRem then pcall(function() cutRem:FireServer() end) end
                                task.wait(0.2)
                                if laporRem then pcall(function() laporRem:FireServer() end) end
                            end
                        end
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2.5)
        pcall(scanTuyulRadar)
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
-- SERVER HOP, PLAYER INSPECTION, SPEEDBUY & BOOST ENGINE
-- ════════════════════════════════════════════════════════════════════════════
local function serverHop(lowPop)
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    pcall(function()
        WindUI:Notify({
            Title = "🌐 Server Hopper",
            Desc = lowPop and "Mencari server sepi (1-5 player) untuk monopoli Pasar Gaib & Tuyul..." or "Mencari server baru...",
            Duration = 4,
            Icon = "globe"
        })
    end)

    local placeId = game.PlaceId
    local currentJob = game.JobId
    local cursor = ""
    local foundServer = nil

    for _ = 1, 3 do
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=" .. (lowPop and "Asc" or "Desc") .. "&limit=100" .. (cursor ~= "" and ("&cursor=" .. cursor) or "")
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and res then
            local data = pcall(function() return HttpService:JSONDecode(res) end) and HttpService:JSONDecode(res)
            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.id ~= currentJob and s.playing and s.playing < s.maxPlayers then
                        if lowPop then
                            if s.playing >= 1 and s.playing <= 5 then
                                foundServer = s.id
                                break
                            end
                        else
                            foundServer = s.id
                            break
                        end
                    end
                end
                if foundServer then break end
                cursor = data.nextPageCursor or ""
                if cursor == "" then break end
            else
                break
            end
        else
            break
        end
        task.wait(0.2)
    end

    if foundServer then
        pcall(function()
            WindUI:Notify({
                Title = "🚀 Teleporting...",
                Desc = "Server ditemukan! Berpindah server...",
                Duration = 4,
                Icon = "zap"
            })
        end)
        TeleportService:TeleportToPlaceInstance(placeId, foundServer, LP)
        return true
    else
        pcall(function()
            WindUI:Notify({
                Title = "❌ Server Hopper",
                Desc = "Tidak dapat menemukan server yang cocok saat ini.",
                Duration = 4,
                Icon = "alert-circle"
            })
        end)
        return false
    end
end

local function inspectPlayerInventory(targetName)
    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer then
        pcall(function()
            WindUI:Notify({
                Title = "👁️ Player Inspector",
                Desc = "Player '" .. tostring(targetName) .. "' tidak ditemukan di server!",
                Duration = 4,
                Icon = "user-x"
            })
        end)
        return
    end

    local ls = targetPlayer:FindFirstChild("leaderstats")
    local koin = ls and ls:FindFirstChild("Koin") and ls.Koin.Value or 0
    local lv = ls and ls:FindFirstChild("Lv") and ls.Lv.Value or 1

    local items = {}
    for _, cont in ipairs({targetPlayer.Character, targetPlayer:FindFirstChild("Backpack")}) do
        if cont then
            for _, t in ipairs(cont:GetChildren()) do
                if t:IsA("Tool") then
                    local count = t:GetAttribute("Count") or tonumber(t.Name:match("x(%d+)")) or 1
                    table.insert(items, t.Name .. (count > 1 and (" (" .. count .. ")") or ""))
                end
            end
        end
    end

    local tradeRem = getR("TradeGetInventory")
    if tradeRem then
        pcall(function()
            local inv = tradeRem:InvokeServer(targetPlayer)
            if type(inv) == "table" then
                for k, v in pairs(inv) do
                    table.insert(items, tostring(k) .. ": " .. tostring(v))
                end
            end
        end)
    end

    local itemListStr = #items > 0 and table.concat(items, ", ") or "Tas Kosong / Tersembunyi"
    log("[Inspector] " .. targetPlayer.Name .. " | Lv: " .. lv .. " | Koin: " .. koin .. " | Items: " .. itemListStr)
    pcall(function()
        WindUI:Notify({
            Title = "👤 " .. targetPlayer.DisplayName .. " (@" .. targetPlayer.Name .. ")",
            Desc = "Lv: " .. lv .. " | Koin: " .. koin .. "\nItem: " .. (itemListStr:sub(1, 120)) .. (#itemListStr > 120 and "..." or ""),
            Duration = 8,
            Icon = "user-check"
        })
    end)
end

local function fastBulkBuy(itemName, totalQty)
    local rem = getR("ShopBuy")
    if not rem then
        log("ShopBuy remote tidak tersedia")
        return false
    end

    local ls = LP:FindFirstChild("leaderstats")
    local startCoins = ls and ls:FindFirstChild("Koin") and ls.Koin.Value or 0
    if startCoins < 10 then
        pcall(function()
            WindUI:Notify({
                Title = "🛒 Speedbuy",
                Desc = "Koin tidak cukup!",
                Duration = 3,
                Icon = "alert-circle"
            })
        end)
        return false
    end

    pcall(function()
        WindUI:Notify({
            Title = "⚡ Speedbuy Berjalan",
            Desc = "Membeli " .. totalQty .. "x " .. itemName .. " secara cepat & aman...",
            Duration = 3,
            Icon = "shopping-cart"
        })
    end)

    local bought = 0
    local step = 5
    while bought < totalQty do
        local batch = math.min(step, totalQty - bought)
        local ok, res = pcall(function() return rem:InvokeServer(itemName, batch) end)
        if ok and (type(res) ~= "table" or res.ok ~= false) then
            bought = bought + batch
        else
            pcall(function() rem:InvokeServer(itemName, 1) end)
            bought = bought + 1
        end
        task.wait(0.12) -- Jeda mikro aman bypass rate-limit
    end

    pcall(function()
        WindUI:Notify({
            Title = "✅ Speedbuy Selesai",
            Desc = "Berhasil membeli " .. bought .. "x " .. itemName .. "!",
            Duration = 4,
            Icon = "check"
        })
    end)
    return true
end

local function doSpendKeahlian(category)
    local rem = getR("KeahlianSpend") or getR("SkillSpend") or getR("KeahlianUpgrade")
    if not rem then
        openGameGui("KeahlianGui", "Keahlian")
        return false
    end

    local targetCat = category or State.KeahlianFocus
    local ok, res = pcall(function()
        return rem:InvokeServer(targetCat)
    end)

    if ok and res then
        pcall(function()
            WindUI:Notify({
                Title = "🌟 Keahlian Ditingkatkan",
                Desc = "Poin keahlian dialokasikan ke jalur: " .. tostring(targetCat),
                Duration = 4,
                Icon = "zap"
            })
        end)
        return true
    else
        pcall(function()
            WindUI:Notify({
                Title = "ℹ️ Info Keahlian",
                Desc = "Tidak ada poin keahlian tersisa atau sudah mencapai batas maksimal.",
                Duration = 3,
                Icon = "info"
            })
        end)
        return false
    end
end

local lastBoostActive = false
local function checkCoinBoostActive()
    local isBoost = false
    pcall(function()
        local boostRem = getR("CoinBoostPoll") or getR("ServerBoostState")
        if boostRem then
            local res = boostRem:InvokeServer()
            if type(res) == "table" and (res.Active or res.active or res.multiplier) then
                isBoost = true
            end
        end
    end)
    if not isBoost then
        pcall(function()
            local wsBoost = Workspace:GetAttribute("CoinBoost") or Workspace:GetAttribute("ServerBoost")
            if wsBoost == true or (type(wsBoost) == "number" and wsBoost > 1) then
                isBoost = true
            end
        end)
    end
    return isBoost
end

local function autoBoostSyncLoop()
    while State.AutoBoostSync do
        task.wait(6)
        local isBoost = checkCoinBoostActive()
        if isBoost and not lastBoostActive then
            lastBoostActive = true
            pcall(function()
                WindUI:Notify({
                    Title = "🔥 2X COIN BOOST AKTIF!",
                    Desc = "Server sedang event 2x Koin! Menjual hasil panen & babi untuk cuan maksimal...",
                    Duration = 6,
                    Icon = "flame"
                })
            end)
            task.spawn(doSellBabiBatch)
            task.spawn(stockKiosShelves)
            task.spawn(doAutoOlah)
        elseif not isBoost then
            lastBoostActive = false
        end
    end
end

local function autoMaintainGaibBuff()
    while State.AutoUseGaibBuff do
        task.wait(12)
        local Lighting = game:GetService("Lighting")
        local isNight = (Lighting.ClockTime >= 18 or Lighting.ClockTime < 6)
        if isNight then
            doUseGaibBuff(State.GaibBuffChoice)
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════
-- BUG ABUSE ENGINE: RACE CONDITIONS, HIDDEN ITEMS, EXPLOIT TOOLS
-- ════════════════════════════════════════════════════════════════════════════

-- #1: PetiArwahJatah Race Condition — klaim free pull 3x cepat sebelum server tulis cooldown
local function doPetiJatahRace(tries)
    tries = tries or 3
    local rem = getR("PetiArwahJatah")
    if not rem then
        log("[Race] Remote PetiArwahJatah tidak ditemukan")
        return 0
    end
    local results = {}
    local threads = {}
    for i = 1, tries do
        table.insert(threads, task.spawn(function()
            task.wait((i - 1) * (State.RaceClaimDelay or 0.05))
            local ok, res = pcall(function() return rem:InvokeServer() end)
            table.insert(results, ok and res)
        end))
    end
    -- Tunggu semua thread selesai (maks 2 detik)
    local t0 = os.clock()
    repeat task.wait(0.05) until #results >= tries or (os.clock() - t0) > 2

    local wins = 0
    for _, r in ipairs(results) do
        if r and r ~= false then wins = wins + 1 end
    end
    pcall(function()
        WindUI:Notify({
            Title = "🎁 Peti Race Claim",
            Desc = wins > 0 and ("Berhasil klaim " .. wins .. "x free pull! (Race condition)") or "Server menolak semua klaim (cooldown sudah terkunci).",
            Duration = 5,
            Icon = wins > 0 and "gift" or "alert-circle"
        })
    end)
    return wins
end

local function autoPetiRaceLoop()
    while State.AutoPetiRaceClaim do
        task.wait(28) -- Periksa setiap 28 detik
        local Lighting = game:GetService("Lighting")
        local isNight = (Lighting.ClockTime >= 18 or Lighting.ClockTime < 6)
        if isNight then
            doPetiJatahRace(3)
        end
    end
end

-- #2: OlahMulai Overflow Probe — kirim jumlah olah > stok yang ada
local function probeOlahOverflow()
    local rem = getR("OlahMulai") or getR("OlahItem") or getR("ProsesBahan")
    if not rem then
        log("[Probe] OlahMulai remote tidak ditemukan")
        return
    end
    local targets = {
        { id = "Gagak",          overshoot = 9999 },
        { id = "AyamKampung",    overshoot = 9999 },
        { id = "BijiKopi",       overshoot = 9999 },
    }
    local gainAny = false
    for _, t in ipairs(targets) do
        local ok, res = pcall(function() return rem:InvokeServer(t.id, t.overshoot) end)
        if ok then
            local got = (type(res) == "table" and (res.count or res.amount or res.qty)) or
                        (type(res) == "number" and res) or 0
            if got and got > 0 then
                gainAny = true
                log("[Overflow] " .. t.id .. " → Dapat " .. tostring(got) .. " item!")
            end
        end
        task.wait(0.3)
    end
    pcall(function()
        WindUI:Notify({
            Title = gainAny and "🔓 Overflow Berhasil!" or "🛡️ Overflow Diblokir",
            Desc = gainAny and "Server memberikan item extra saat jumlah melebihi stok!" or "Server memvalidasi stok dengan benar. Exploit tidak bekerja.",
            Duration = 5,
            Icon = gainAny and "zap" or "shield"
        })
    end)
end

-- #3: KandangPanen Early Harvest — koleksi hasil kandang sebelum timer habis
local function doKandangEarlyHarvest()
    local rems = {
        getR("KandangPanen"),
        getR("KandangCollect"),
        getR("PanenTernak"),
        getR("TernakAmbil"),
    }
    local total = 0
    for _, rem in ipairs(rems) do
        if rem then
            for _, anim in ipairs({"Ayam", "Babi", "Sapi"}) do
                local ok, res = pcall(function() return rem:InvokeServer(anim) end)
                if ok and res then
                    local got = (type(res) == "table" and (res.count or res.items or 0)) or
                                (type(res) == "number" and res) or 0
                    total = total + (got or 0)
                end
                task.wait(0.15)
            end
        end
    end
    pcall(function()
        WindUI:Notify({
            Title = "🐔 Early Harvest Kandang",
            Desc = total > 0 and ("Berhasil panen " .. total .. " produk ternak early!") or "Tidak ada produk ready / server memblokir early harvest.",
            Duration = 4,
            Icon = total > 0 and "egg" or "info"
        })
    end)
    return total
end

local function autoKandangEarlyLoop()
    while State.AutoEarlyKandang do
        task.wait(15)
        doKandangEarlyHarvest()
    end
end

-- #4: BalaiLencana Multi-Claim Race — klaim milestone yang sama 2x dalam 1 siklus
local function doBalaiMultiClaimRace()
    local remLencana = getR("BalaiKlaimLencana") or getR("LencanaKlaim") or getR("BalaiClaim")
    if not remLencana then
        log("[Race] BalaiLencana remote tidak ditemukan")
        return
    end
    -- Ambil daftar lencana yang tersedia dulu
    local lencanaIds = {}
    pcall(function()
        local remList = getR("BalaiLencanaList") or getR("LencanaGetList")
        if remList then
            local list = remList:InvokeServer()
            if type(list) == "table" then
                for k, v in pairs(list) do
                    if (v.canClaim or v.ready or v.complete) then
                        table.insert(lencanaIds, v.id or k)
                    end
                end
            end
        end
    end)
    if #lencanaIds == 0 then
        lencanaIds = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 } -- Fallback probe semua ID
    end

    local claimed = 0
    for _, lid in ipairs(lencanaIds) do
        -- Race claim: kirim 2x dalam frame yang sama
        local r1, r2
        local t1 = task.spawn(function()
            local ok, res = pcall(function() return remLencana:InvokeServer(lid) end)
            r1 = ok and res
        end)
        task.wait(State.RaceClaimDelay or 0.05)
        local t2 = task.spawn(function()
            local ok, res = pcall(function() return remLencana:InvokeServer(lid) end)
            r2 = ok and res
        end)
        task.wait(0.3)
        if r1 then claimed = claimed + 1 end
        if r2 then claimed = claimed + 1 end
    end
    pcall(function()
        WindUI:Notify({
            Title = "🏅 Balai Race Claim",
            Desc = claimed > 0 and ("Berhasil klaim " .. claimed .. " reward lencana (double claim)!") or "Server memblokir semua klaim ganda.",
            Duration = 5,
            Icon = claimed > 0 and "award" or "shield"
        })
    end)
end

-- #5: Multi-Thread Simultaneous Harvest — ProximityPrompt pada tanaman yang sama dari 2 thread serentak
local function doMultiHarvestRace()
    local lahans = getMyLahans()
    if #lahans == 0 then return 0 end
    local lahan = lahans[1]
    local tFolder = lahan:FindFirstChild("Tanaman")
    if not tFolder then return 0 end

    local total = 0
    for _, crop in ipairs(tFolder:GetChildren()) do
        if crop:IsA("BasePart") and crop:GetAttribute("Ready") == true then
            local prompt = crop:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                -- Teleport dekat dulu
                tpToPos(crop.Position + Vector3.new(0, 2, 0))
                task.wait(0.1)
                -- Fire dari 2 thread serentak
                task.spawn(function() pcall(function() safeFirePrompt(prompt) end) end)
                task.wait(State.RaceClaimDelay or 0.05)
                task.spawn(function() pcall(function() safeFirePrompt(prompt) end) end)
                total = total + 1
                task.wait(0.2)
            end
        end
    end
    pcall(function()
        WindUI:Notify({
            Title = "⚡ Multi-Harvest Race",
            Desc = total > 0 and ("Mencoba double-harvest " .. total .. " tanaman matang!") or "Tidak ada tanaman matang untuk di-race.",
            Duration = 4,
            Icon = "leaf"
        })
    end)
    return total
end

-- #6: ShopBuy Hidden Item Probe — coba beli item yang tidak tampil di UI tapi ada di database
local function probeHiddenShopItems()
    local HIDDEN_SHOP_IDS = {
        "BibitLangka", "BibitEmas", "BibitMistis",
        "MinyakJelangkungx10", "ArangKeramatx5", "SerpihArwah",
        "KunciPeti", "TiketGaib", "BeliungBesi", "BeliungEmas",
        "PupukAjaib", "EsensiGaib", "TanahSubur",
        "VoucherKoin1000", "VoucherKoin5000",
    }
    local rem = getR("ShopBuy")
    if not rem then
        log("[Probe] ShopBuy tidak ditemukan")
        return {}
    end
    local found = {}
    pcall(function()
        WindUI:Notify({
            Title = "🔍 Hidden Shop Probe",
            Desc = "Memeriksa " .. #HIDDEN_SHOP_IDS .. " item tersembunyi di database toko...",
            Duration = 4,
            Icon = "search"
        })
    end)
    for _, itemId in ipairs(HIDDEN_SHOP_IDS) do
        local ok, res = pcall(function() return rem:InvokeServer(itemId, 1) end)
        if ok and type(res) == "table" and res.ok ~= false and res ~= false then
            table.insert(found, itemId)
            log("[HiddenShop] Item tersembunyi ditemukan: " .. itemId)
        elseif ok and (res == true or (type(res) == "number" and res > 0)) then
            table.insert(found, itemId)
            log("[HiddenShop] Item tersembunyi ditemukan: " .. itemId)
        end
        task.wait(0.18)
    end
    if #found > 0 then
        pcall(function()
            WindUI:Notify({
                Title = "🎉 Item Tersembunyi Ditemukan!",
                Desc = "Berhasil beli: " .. table.concat(found, ", "),
                Duration = 8,
                Icon = "package-open"
            })
        end)
    else
        pcall(function()
            WindUI:Notify({
                Title = "🛡️ Probe Selesai",
                Desc = "Semua item tersembunyi diblokir atau tidak ada di database.",
                Duration = 4,
                Icon = "shield"
            })
        end)
    end
    return found
end

-- #7: Guild Boost Snipe — join guild saat boost event, claim buff, keluar
local function doGuildBoostSnipe()
    local remList = getR("AnggotaGuildList") or getR("GuildList") or getR("AnggotaPoll")
    local remJoin = getR("GuildJoin") or getR("AnggotaJoin")
    local remLeave = getR("GuildLeave") or getR("AnggotaLeave") or getR("GuildKeluar")
    local remBoost = getR("GuildBoost") or getR("GuildBuff") or getR("BoostGuild")

    if not (remList and remJoin) then
        pcall(function()
            WindUI:Notify({
                Title = "⚠️ Guild Boost Snipe",
                Desc = "Remote AnggotaGuild tidak ditemukan. Mungkin fitur guild belum tersedia di game versi ini.",
                Duration = 4,
                Icon = "alert-circle"
            })
        end)
        return false
    end

    -- Temukan guild dengan boost aktif
    local targetGuild = nil
    pcall(function()
        local list = remList:InvokeServer()
        if type(list) == "table" then
            for _, guild in ipairs(list) do
                if guild.boostActive or guild.hasBoost or guild.multiplier then
                    targetGuild = guild.id or guild.name
                    break
                end
            end
        end
    end)

    if not targetGuild then
        pcall(function()
            WindUI:Notify({
                Title = "🏰 Guild Boost Snipe",
                Desc = "Tidak ada guild dengan boost aktif saat ini.",
                Duration = 4,
                Icon = "info"
            })
        end)
        return false
    end

    -- Join guild
    local joinOk = false
    pcall(function()
        local res = remJoin:InvokeServer(targetGuild)
        joinOk = res == true or (type(res) == "table" and res.ok ~= false)
    end)

    if joinOk then
        task.wait(0.5)
        -- Claim boost
        if remBoost then
            pcall(function() remBoost:InvokeServer() end)
        end
        task.wait(0.3)
        -- Keluar guild
        if remLeave then
            pcall(function() remLeave:InvokeServer() end)
        end
        pcall(function()
            WindUI:Notify({
                Title = "🏰 Guild Boost Sniped!",
                Desc = "Berhasil masuk guild '" .. tostring(targetGuild) .. "', snipe buff, lalu keluar!",
                Duration = 5,
                Icon = "shield-check"
            })
        end)
        return true
    end
    return false
end

-- #8: Gerobak Skin Passive Swap — equip skin passive sebelum sell, unequip sesudah
local function doGerobakPassiveSwap(callback)
    local PASSIVE_GEROBAK_SKINS = { "GerobakEmas", "GerobakMistis", "GerobakLangka", "SkinGerobakVIP" }
    local remEquip = getR("GerobakSkinEquip") or getR("EquipGerobak") or getR("GerobakEquip")
    local remUnequip = getR("GerobakSkinUnequip") or getR("UnequipGerobak")

    if not remEquip then
        -- Langsung jalankan callback tanpa swap
        if callback then pcall(callback) end
        return
    end

    -- Equip skin dengan passive terbaik
    local equipped = false
    for _, skinId in ipairs(PASSIVE_GEROBAK_SKINS) do
        local ok = pcall(function() remEquip:InvokeServer(skinId) end)
        if ok then
            equipped = skinId
            break
        end
    end

    if equipped then
        task.wait(0.2)
        log("[GerobakSwap] Equipped: " .. tostring(equipped))
    end

    -- Jalankan aksi (misal: jual di kios)
    if callback then
        pcall(callback)
    end

    task.wait(0.2)
    -- Unequip / kembali ke default
    if remUnequip and equipped then
        pcall(function() remUnequip:InvokeServer() end)
        log("[GerobakSwap] Reverted to default skin")
    end
end

local function autoGerobakSwapSell()
    while State.AutoGerobakSwap do
        task.wait(5)
        if State.AutoDagang then
            doGerobakPassiveSwap(function()
                stockKiosShelves()
            end)
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════
-- BUG ABUSE ENGINE: BATCH 2 — BRUTEFORCE, MINING, TRADE, EXP STEAL
-- ════════════════════════════════════════════════════════════════════════════

-- #9: RedeemCode Bruteforce — probe ratusan kombinasi kode dev otomatis
local function generateBruteCodes()
    local BRUTE_PREFIXES = {
        "PASAR", "DUKUN", "HUTAN", "GAIB", "ARWAH", "TUYUL", "FOREST", "MARKET",
        "PROMO", "FREE", "BONUS", "HADIAH", "GRATIS", "KOIN", "EVENT", "MALAM",
        "PETI", "BABI", "AYAM", "TAMBANG", "LAHAN",
    }
    local BRUTE_SUFFIXES = {
        "2024", "2025", "100", "500", "1000", "001", "01", "1",
        "GRATISS", "FREE", "VIP", "LAUNCH", "UPDATE", "BARU", "GAME",
    }
    local codes = {}
    -- Prefix + angka 1-50
    for _, p in ipairs(BRUTE_PREFIXES) do
        for i = 1, 50 do
            table.insert(codes, p .. tostring(i))
        end
        for _, s in ipairs(BRUTE_SUFFIXES) do
            table.insert(codes, p .. s)
            table.insert(codes, p .. "_" .. s)
        end
    end
    -- Sudah diketahui tapi mungkin punya variasi
    local known = { "PASARHUTAN", "DUKUN2024", "PROJECTDUKUN", "GAIBMALAM",
                    "TUYULAJAIB", "ARWAHLANGKA", "PASARGRATIS", "HUTANFREE" }
    for _, k in ipairs(known) do table.insert(codes, k) end
    return codes
end

local function doBruteforceCode()
    local rem = getR("RedeemCode") or getR("TukarKode") or getR("KodeHadiah")
    if not rem then
        log("[Brute] Remote redeem tidak ditemukan")
        return {}
    end
    local codes = generateBruteCodes()
    local found = {}
    local checked = 0

    pcall(function()
        WindUI:Notify({
            Title = "🔑 Bruteforce Kode",
            Desc = "Mencoba " .. #codes .. " kombinasi kode promo developer...",
            Duration = 5,
            Icon = "key"
        })
    end)

    for _, code in ipairs(codes) do
        if not State.AutoBruteforceCode and checked > 0 then break end
        local ok, res = pcall(function() return rem:InvokeServer(code) end)
        if ok and res then
            local isSuccess = (res == true) or
                              (type(res) == "table" and res.ok ~= false and res.success ~= false) or
                              (type(res) == "string" and not res:lower():find("invalid") and
                               not res:lower():find("expired") and not res:lower():find("used"))
            if isSuccess then
                table.insert(found, code)
                log("[Brute] 🎉 KODE VALID: " .. code)
                pcall(function()
                    WindUI:Notify({
                        Title = "🎉 Kode Ditemukan!",
                        Desc = "Kode '" .. code .. "' berhasil ditukar! Reward masuk tas.",
                        Duration = 8,
                        Icon = "gift"
                    })
                end)
            end
        end
        checked = checked + 1
        task.wait(State.BruteforceDelay or 0.25)
    end

    if #found == 0 then
        pcall(function()
            WindUI:Notify({
                Title = "🔑 Bruteforce Selesai",
                Desc = "Dicoba " .. checked .. " kode. Tidak ada kode baru yang valid saat ini.",
                Duration = 5,
                Icon = "info"
            })
        end)
    end
    return found
end

local function autoBruteforceLoop()
    while State.AutoBruteforceCode do
        doBruteforceCode()
        task.wait(300) -- Ulangi tiap 5 menit (server reset kode per sesi)
    end
end

-- #10: TambangBatu Multi-Hit — mine batu yang sama dari 2 thread serentak
local function doMiningMultiHit()
    local bc = Workspace:FindFirstChild("BahanCraft")
    if not bc then
        log("[MultiHit] Folder BahanCraft tidak ditemukan")
        return 0
    end
    local batuan = {}
    for _, o in ipairs(bc:GetDescendants()) do
        if o:IsA("BasePart") and (o.Name:find("Batu") or o.Name:find("Ore") or o.Name:find("Rock")) then
            local prompt = o:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                table.insert(batuan, { part = o, prompt = prompt })
            end
        end
    end

    local hits = 0
    for _, b in ipairs(batuan) do
        tpToPos(b.part.Position + Vector3.new(0, 2, 0))
        task.wait(0.1)
        -- Double-hit serentak
        task.spawn(function() pcall(function() safeFirePrompt(b.prompt) end) end)
        task.wait(State.RaceClaimDelay or 0.05)
        task.spawn(function() pcall(function() safeFirePrompt(b.prompt) end) end)
        hits = hits + 1
        task.wait(0.3)
    end
    pcall(function()
        WindUI:Notify({
            Title = "⛏️ Mining Multi-Hit",
            Desc = hits > 0 and ("Double-hit " .. hits .. " batu/ore!") or "Tidak ada batu yang bisa ditambang.",
            Duration = 4,
            Icon = "pickaxe"
        })
    end)
    return hits
end

local function autoMiningMultiHitLoop()
    while State.AutoMiningMultiHit do
        task.wait(8)
        doMiningMultiHit()
    end
end

-- #11: SiramTanaman Other Players — siram lahan milik player lain untuk klaim EXP siram
local function doSiramLahanOrang()
    local waterTool = getWaterTool()
    if not waterTool then
        log("[SiramOrang] Tidak punya alat penyiram")
        return 0
    end
    local plots = Workspace:FindFirstChild("Plot")
    if not plots then return 0 end

    local watered = 0
    local myUserId = LP.UserId

    for _, plot in ipairs(plots:GetChildren()) do
        local lahan = plot:FindFirstChild("Lahan1")
        if not lahan then continue end

        -- Pastikan bukan plot kita
        local isOurs = false
        for _, desc in ipairs(plot:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Text ~= "" then
                local t = desc.Text:lower()
                if t:find(LP.Name:lower()) or t:find(LP.DisplayName:lower()) then
                    isOurs = true
                    break
                end
            end
            if desc.GetAttribute and desc:GetAttribute("OwnerId") == myUserId then
                isOurs = true
                break
            end
        end
        if isOurs then continue end

        local tFolder = lahan:FindFirstChild("Tanaman")
        if not tFolder then continue end

        for _, crop in ipairs(tFolder:GetChildren()) do
            if crop:IsA("BasePart") and crop:GetAttribute("Wet") == false then
                tpToPos(crop.Position + Vector3.new(0, 2, 0))
                task.wait(0.15)
                -- Equip penyiram
                pcall(function()
                    local hum = getHum()
                    if hum then hum:EquipTool(waterTool) end
                end)
                task.wait(0.1)
                local prompt = crop:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt.Enabled then
                    safeFirePrompt(prompt)
                    watered = watered + 1
                end
                task.wait(0.2)
            end
        end
    end

    pcall(function()
        WindUI:Notify({
            Title = "💧 Siram Kebun Orang",
            Desc = watered > 0 and ("Menyiram " .. watered .. " tanaman milik player lain (EXP gratis)!") or "Tidak ada tanaman kering milik player lain.",
            Duration = 4,
            Icon = "droplets"
        })
    end)
    return watered
end

local function autoSiramOrangLoop()
    while State.AutoSiramOrang do
        task.wait(20)
        doSiramLahanOrang()
    end
end

-- #12: TradeBoard Auto-Snipe — pantau papan barter & auto-accept offer menguntungkan
local function scanTradeBoard()
    local remBoard = getR("TradeBoardGet") or getR("TradeBoard") or getR("PapanTrade")
    local remAccept = getR("TradeBoardAccept") or getR("TradeAccept") or getR("Terima Trade")
    if not remBoard then return end

    local offers = nil
    pcall(function()
        offers = remBoard:InvokeServer()
    end)
    if type(offers) ~= "table" then return end

    local minRatio = State.TradeBoardMinRatio or 2.0
    local sniped = 0
    for _, offer in ipairs(offers) do
        -- Cek apakah ini penawaran menguntungkan
        local theyGive = offer.giveValue or offer.theirValue or offer.offerPrice or 0
        local weGive = offer.wantValue or offer.ourValue or offer.askPrice or 1
        local ratio = weGive > 0 and (theyGive / weGive) or 0

        if ratio >= minRatio and remAccept then
            local offerId = offer.id or offer.tradeId
            if offerId then
                local ok, res = pcall(function()
                    return remAccept:InvokeServer(offerId)
                end)
                if ok and res then
                    sniped = sniped + 1
                    log("[TradeSnipe] Accepted offer ID " .. tostring(offerId) .. " (ratio " .. string.format("%.1f", ratio) .. "x)")
                    pcall(function()
                        WindUI:Notify({
                            Title = "🔄 Trade Sniped!",
                            Desc = "Berhasil ambil penawaran " .. string.format("%.1f", ratio) .. "x lebih berharga dari harga minta!",
                            Duration = 5,
                            Icon = "check"
                        })
                    end)
                end
            end
        end
        task.wait(0.1)
    end
    return sniped
end

local function autoTradeBoardSnipeLoop()
    while State.AutoTradeBoardSnipe do
        task.wait(5)
        pcall(scanTradeBoard)
    end
end

-- #13: PetiArwahPull Free Open — probe gacha tanpa bayar koin
local function doPetiFreeOpen()
    -- Coba berbagai kombinasi argumen nol/fake
    local rem = getR("PetiArwahPull") or getR("PullArwah") or getR("PetiBuka")
    if not rem then
        log("[FreePeti] Remote PetiArwahPull tidak ditemukan")
        return false
    end

    local attempts = {
        function() return rem:InvokeServer(0) end,           -- cost = 0
        function() return rem:InvokeServer("free") end,       -- mode free
        function() return rem:InvokeServer(1, true) end,      -- amount=1, free=true
        function() return rem:InvokeServer({ free = true, amount = 1 }) end,
        function() return rem:InvokeServer(nil) end,          -- nil cost
    }

    pcall(function()
        WindUI:Notify({
            Title = "⚰️ Free Peti Probe",
            Desc = "Mencoba membuka Peti Arwah tanpa membayar koin...",
            Duration = 4,
            Icon = "flask-conical"
        })
    end)

    for i, attempt in ipairs(attempts) do
        local ok, res = pcall(attempt)
        if ok and res and res ~= false and res ~= nil then
            local gotItem = (type(res) == "table" and (res.item or res.reward or res.result)) or
                            (type(res) == "string" and res ~= "" and not res:lower():find("err"))
            if gotItem then
                log("[FreePeti] ✅ FREE OPEN berhasil via argumen #" .. i)
                pcall(function()
                    WindUI:Notify({
                        Title = "⚰️ FREE PETI BERHASIL!",
                        Desc = "Berhasil buka Peti Arwah GRATIS! Item: " .. tostring(gotItem),
                        Duration = 8,
                        Icon = "gift"
                    })
                end)
                return true
            end
        end
        task.wait(0.3)
    end

    pcall(function()
        WindUI:Notify({
            Title = "🛡️ Free Peti Diblokir",
            Desc = "Server memvalidasi pembayaran koin dengan benar. Tidak bisa gratis.",
            Duration = 4,
            Icon = "shield"
        })
    end)
    return false
end

-- #14: MarketSell Price Spoof — kirim harga jual lebih tinggi ke remote listing
local function doMarketSellSpoof(itemName, spoofPrice)
    local rem = getR("MarketSell") or getR("JualPasar") or getR("ListingBuat")
    if not rem then
        log("[PriceSpoof] Remote MarketSell tidak ditemukan")
        return false
    end

    spoofPrice = spoofPrice or 99999
    -- Coba berbagai format argumen
    local attempts = {
        function() return rem:InvokeServer(itemName, 1, spoofPrice) end,
        function() return rem:InvokeServer({ item = itemName, qty = 1, price = spoofPrice }) end,
        function() return rem:InvokeServer(itemName, spoofPrice, 1) end,
    }

    for _, attempt in ipairs(attempts) do
        local ok, res = pcall(attempt)
        if ok and res and res ~= false then
            log("[PriceSpoof] Listing dibuat dengan harga: " .. spoofPrice)
            pcall(function()
                WindUI:Notify({
                    Title = "💰 Price Spoof Berhasil!",
                    Desc = itemName .. " terdaftar di pasar dengan harga " .. spoofPrice .. " koin!",
                    Duration = 6,
                    Icon = "tag"
                })
            end)
            return true
        end
        task.wait(0.2)
    end

    pcall(function()
        WindUI:Notify({
            Title = "🛡️ Price Spoof Diblokir",
            Desc = "Server memvalidasi batas harga. Harga tidak bisa di-spoof.",
            Duration = 4,
            Icon = "shield"
        })
    end)
    return false
end

-- ════════════════════════════════════════════════════════════════════════════
-- CONFIG MANAGER (AUTO-SAVE & LOAD)
-- ════════════════════════════════════════════════════════════════════════════
local PROFILES_FILE = "PasarHutan_Profiles.json"
local configRegistry = {
    profiles = { "Default" },
    activeProfile = "Default",
    autoLoad = false -- Default auto-load adalah MATI (false) sesuai permintaan
}

local function loadProfileRegistry()
    if not readfile or not isfile or not isfile(PROFILES_FILE) then return end
    pcall(function()
        local content = readfile(PROFILES_FILE)
        local data = game:GetService("HttpService"):JSONDecode(content)
        if type(data) == "table" then
            if type(data.profiles) == "table" and #data.profiles > 0 then
                configRegistry.profiles = data.profiles
            end
            if type(data.activeProfile) == "string" and data.activeProfile ~= "" then
                configRegistry.activeProfile = data.activeProfile
            end
            if type(data.autoLoad) == "boolean" then
                configRegistry.autoLoad = data.autoLoad
            end
        end
    end)
end

local function saveProfileRegistry()
    if not writefile then return end
    pcall(function()
        writefile(PROFILES_FILE, game:GetService("HttpService"):JSONEncode(configRegistry))
    end)
end

local function getProfileFileName(name)
    local safeName = (name or "Default"):gsub("[^%w_%-]", "")
    if safeName == "" then safeName = "Default" end
    return "PasarHutan_Config_" .. safeName .. ".json"
end

local function saveConfig(profileName)
    if not writefile then return false end
    profileName = profileName or configRegistry.activeProfile or "Default"
    local cfg = {}
    for k, v in pairs(State) do
        if type(v) ~= "function" and type(v) ~= "userdata" and type(v) ~= "thread" then
            cfg[k] = v
        end
    end

    local fName = getProfileFileName(profileName)
    local ok = pcall(function()
        writefile(fName, game:GetService("HttpService"):JSONEncode(cfg))
    end)

    if ok then
        local found = false
        for _, p in ipairs(configRegistry.profiles) do
            if p == profileName then found = true; break end
        end
        if not found then
            table.insert(configRegistry.profiles, profileName)
        end
        configRegistry.activeProfile = profileName
        saveProfileRegistry()
        log(("[Config] Profil '%s' berhasil disimpan ke %s"):format(profileName, fName))
    end
    return ok
end

local function loadConfig(profileName)
    if not readfile or not isfile then return false end
    profileName = profileName or configRegistry.activeProfile or "Default"
    local fName = getProfileFileName(profileName)
    if not isfile(fName) then
        if profileName == "Default" and isfile("PasarHutan_Config.json") then
            fName = "PasarHutan_Config.json"
        else
            return false
        end
    end

    local ok = pcall(function()
        local content = readfile(fName)
        local cfg = game:GetService("HttpService"):JSONDecode(content)
        for k, v in pairs(cfg) do
            if State[k] ~= nil then
                State[k] = v
            end
        end
        configRegistry.activeProfile = profileName
        saveProfileRegistry()
        log(("[Config] Profil '%s' berhasil dimuat dari %s"):format(profileName, fName))
    end)
    return ok
end

local function deleteConfig(profileName)
    if not profileName or profileName == "Default" then return false end
    local fName = getProfileFileName(profileName)
    if delfile and isfile and isfile(fName) then
        pcall(function() delfile(fName) end)
    end
    for idx, p in ipairs(configRegistry.profiles) do
        if p == profileName then
            table.remove(configRegistry.profiles, idx)
            break
        end
    end
    if configRegistry.activeProfile == profileName then
        configRegistry.activeProfile = configRegistry.profiles[1] or "Default"
    end
    saveProfileRegistry()
    return true
end

-- Inisialisasi daftar profil
pcall(loadProfileRegistry)

-- Hanya muat config jika Auto-Load secara eksplisit diaktifkan oleh pengguna (Default: MATI)
if configRegistry.autoLoad == true then
    log("[Config] Auto-Load aktif! Memuat profile: " .. tostring(configRegistry.activeProfile))
    pcall(function() loadConfig(configRegistry.activeProfile) end)
else
    log("[Config] Auto-Load nonaktif (Default). Memulai dengan konfigurasi bersih.")
end

-- ════════════════════════════════════════════════════════════════════════════
-- AUTO-RECONNECT & REJOIN WATCHDOG
-- ════════════════════════════════════════════════════════════════════════════
do
    local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if queue_on_teleport then
        pcall(function()
            queue_on_teleport([[
                task.wait(4)
                pcall(function()
                    local code = (readfile and isfile and isfile("d:\\EXECUTOR\\ROBLOX-MCP\\roblox-script\\forest_market_hub.luau") and readfile("d:\\EXECUTOR\\ROBLOX-MCP\\roblox-script\\forest_market_hub.luau")) or game:HttpGet("http://localhost:45678/forest_market_hub.luau")
                    loadstring(code)()
                end)
            ]])
        end)
    end

    local GuiService = game:GetService("GuiService")
    local TeleportService = game:GetService("TeleportService")
    pcall(function()
        GuiService.ErrorMessageChanged:Connect(function()
            if State.AutoReconnect then
                log("Terdeteksi disconnect! Auto-rejoining Pasar Hutan dalam 3 detik...")
                task.wait(3)
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, LP)
                end)
            end
        end)
    end)
end

-- ════════════════════════════════════════════════════════════════════════════
-- CLEANUP PREVIOUS UI & BUBBLES
-- ════════════════════════════════════════════════════════════════════════════
do
    local hui = gethui and gethui() or game:GetService("CoreGui")
    if hui then
        for _, c in ipairs(hui:GetChildren()) do
            if c.Name:find("WindUI") or c.Name:find("PasarHutan") then
                pcall(function() c:Destroy() end)
            end
        end
    end
    if PG:FindFirstChild("PasarHutanHubV8") then pcall(function() PG.PasarHutanHubV8:Destroy() end) end
    if PG:FindFirstChild("PasarHutanHubV9") then pcall(function() PG.PasarHutanHubV9:Destroy() end) end
    if PG:FindFirstChild("PasarHutanWindUI") then pcall(function() PG.PasarHutanWindUI:Destroy() end) end
    if PG:FindFirstChild("PasarHutanBubble") then pcall(function() PG.PasarHutanBubble:Destroy() end) end
    if PG:FindFirstChild("FHubV7") then pcall(function() PG.FHubV7:Destroy() end) end
end

-- ════════════════════════════════════════════════════════════════════════════
-- WINDUI WINDOW INITIALIZATION
-- ════════════════════════════════════════════════════════════════════════════
local WindUI = nil
do
    local windUiUrls = {
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
        "https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua",
    }

    for _, url in ipairs(windUiUrls) do
        local ok, res = pcall(function()
            local code = game:HttpGet(url)
            if code and #code > 100 then
                local fn = loadstring(code)
                if fn then return fn() end
            end
            return nil
        end)
        if ok and res and type(res) == "table" and res.CreateWindow then
            WindUI = res
            break
        end
    end
end

if not WindUI then
    warn("[Pasar Hutan Hub] Gagal memuat UI Library WindUI dari GitHub! Periksa koneksi internet executor.")
    return
end

local Window = nil
do
    local UIService = game:GetService("UserInputService")
    local isMobile = UIService.TouchEnabled and not UIService.KeyboardEnabled
    local camera = Workspace.CurrentCamera
    local vpSize = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local winWidth = math.clamp(math.floor(vpSize.X * 0.85), 340, 580)
    local winHeight = math.clamp(math.floor(vpSize.Y * 0.82), 280, 460)
    if isMobile or vpSize.X < 760 then
        winWidth = math.clamp(math.floor(vpSize.X * 0.92), 310, 500)
        winHeight = math.clamp(math.floor(vpSize.Y * 0.86), 250, 400)
    end

    Window = WindUI:CreateWindow({
        Title = "Forest Market Hub",
        Icon = "trees",
        Author = "by Project Dukun Helper",
        Folder = "PasarHutanWindUI",
        Size = UDim2.fromOffset(winWidth, winHeight),
        Transparent = true,
        Theme = "Dark",
    })
end

pcall(function()
    Window:EditOpenButton({
        Title = "Forest Market",
        Icon = "trees",
        CornerRadius = UDim.new(0, 10),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromRGB(46, 204, 113), Color3.fromRGB(39, 174, 96))
    })
end)

-- ────────────────────────────────────────────────────────────────────────────
-- 1. TAB: KEBUN (🌾)
-- ────────────────────────────────────────────────────────────────────────────
local ParaKebun, ParaKios, ParaMasak, ParaTambang, ParaTangkap, ParaTernak, ParaSlotDetect, ddBoxes = nil, nil, nil, nil, nil, nil, nil, {}
do
local TabKebun = Window:Tab({ Title = "Kebun", Icon = "sprout" })

local SecKebunStats = TabKebun:Section({ Title = "Status & Kapasitas Lahan" })
ParaKebun = SecKebunStats:Paragraph({
    Title = "Kapasitas Lahan",
    Desc = "Memuat data lahan...",
})

local SecKebunAuto = TabKebun:Section({ Title = "Otomatisasi Kebun" })
SecKebunAuto:Toggle({
    Title = "Auto Farm Kebun",
    Desc = "Panen tanaman matang + Tanam bibit + Siram otomatis",
    Value = State.AutoFarm,
    Callback = function(v)
        State.AutoFarm = v
        if v then autoFarmLoop() end
    end
})

SecKebunAuto:Toggle({
    Title = "Auto Siram Tanaman Kering",
    Desc = "Menyiram semua tanaman yang berstatus kering",
    Value = State.AutoSiram,
    Callback = function(v) State.AutoSiram = v end
})

SecKebunAuto:Toggle({
    Title = "Auto Beli Bibit Saat Habis",
    Desc = "Membeli bibit otomatis via ShopBuy bila tas kosong",
    Value = State.AutoBuySeed,
    Callback = function(v) State.AutoBuySeed = v end
})

SecKebunAuto:Dropdown({
    Title = "Pilihan Jenis Bibit (Manual)",
    Values = { "Kentang", "Cabai", "Jagung", "Bawang", "Tomat" },
    Value = State.FarmSeed,
    Callback = function(v)
        State.FarmSeed = v
        log("Bibit dipilih: " .. v)
    end
})

SecKebunAuto:Toggle({
    Title = "Smart Crop Rotator (Pilih Bibit Terbaik)",
    Desc = "Otomatis rotasi bibit tertinggi sesuai Level & prioritas isi tas",
    Value = State.AutoRotateCrop,
    Callback = function(v)
        State.AutoRotateCrop = v
        if v then
            State.FarmSeed = getBestCropForLevel()
            log("Smart Crop Rotator aktif. Bibit otomatis: " .. State.FarmSeed)
        end
    end
})

SecKebunAuto:Toggle({
    Title = "⚖️ Smart Eco-Balancer (Auto-Imbang Tanam & Jual)",
    Desc = "Mencegah boncos: jika panen menumpuk / koin menipis, jual hasil panen dulu sebelum beli bibit baru",
    Value = State.AutoEcoBalance,
    Callback = function(v)
        State.AutoEcoBalance = v
        log("Smart Eco-Balancer: " .. tostring(v))
    end
})

SecKebunAuto:Slider({
    Title = "Cadangan Koin Minimal (Safety Buffer)",
    Step = 25,
    Value = { Min = 25, Max = 1000, Default = State.MinCoinReserve or 100 },
    Callback = function(v) State.MinCoinReserve = v end
})

SecKebunAuto:Button({
    Title = "▶️ Jalankan 1x Siklus Tani Sekarang",
    Desc = "Panen + Tanam + Siram sekali jalan manual",
    Callback = function() task.spawn(doOneFarmCycle) end
})

SecKebunAuto:Button({
    Title = "+ Beli 10 Bibit Sekarang",
    Desc = "Membeli 10 bibit yang dipilih via ShopBuy",
    Callback = function() task.spawn(function() buySeeds(State.FarmSeed, 2) end) end
})

local SecKebunBantu = TabKebun:Section({ Title = "Bantu Kebun Tetangga (EXP Gratis)" })

SecKebunBantu:Toggle({
    Title = "Auto Siram Tanaman Player Lain",
    Desc = "Siram tanaman kering milik player lain di server secara berkala → dapat EXP gratis",
    Value = State.AutoSiramOrang,
    Callback = function(v)
        State.AutoSiramOrang = v
        if v then task.spawn(autoSiramOrangLoop) end
    end
})

SecKebunBantu:Button({
    Title = "💧 Siram Semua Kebun Tetangga Sekarang",
    Desc = "Deteksi & siram semua tanaman kering player lain di seluruh server",
    Callback = function()
        task.spawn(doSiramLahanOrang)
    end
})

-- ────────────────────────────────────────────────────────────────────────────
-- 2. TAB: DAGANG (🏪)
-- ────────────────────────────────────────────────────────────────────────────
end
do
local TabDagang = Window:Tab({ Title = "Dagang", Icon = "store" })
local SecKiosStats = TabDagang:Section({ Title = "Status Rak Kios" })
ParaKios = SecKiosStats:Paragraph({
    Title = "Rak Stall Kios",
    Desc = "Memeriksa slot rak...",
})

local SecKiosAuto = TabDagang:Section({ Title = "Otomatisasi Dagang Kios" })
SecKiosAuto:Toggle({
    Title = "Auto Dagang (Auto-Stock Semua Rak)",
    Desc = "Otomatis mengisi seluruh rak kios jika kosong dengan produk terbaik",
    Value = State.AutoDagang,
    Callback = function(v)
        State.AutoDagang = v
        if v then autoDagangLoop() end
    end
})

SecKiosAuto:Button({
    Title = "📦 Taruh Dagangan ke Seluruh Rak Sekarang",
    Desc = "Isi ulang seluruh rak pajangan kios secara instan",
    Callback = function() task.spawn(stockKiosShelves) end
})

SecKiosAuto:Button({
    Title = "🏪 Buka & Stack Rak (Stall Rack GUI)",
    Desc = "Buka GUI Stall Rack bawaan game & langsung Stack/Fill semua rak dari tas",
    Callback = function()
        task.spawn(function()
            stockKiosShelves()
        end)
    end
})

SecKiosAuto:Button({
    Title = "🔍 Diagnostik Stall Rack GUI",
    Desc = "Pindai hierarki elemen dan tombol pada GUI Stall Rack",
    Callback = function()
        task.spawn(function()
            debugScanStallRackGui()
        end)
    end
})

SecKiosAuto:Toggle({
    Title = "Auto-Jual Surplus ke Pasar (Stok Tas > 30)",
    Desc = "Jual kelebihan panen jika rak kios sudah penuh agar koin cepat cair",
    Value = State.AutoSellMarket,
    Callback = function(v)
        State.AutoSellMarket = v
        if v then autoSellMarketLoop() end
    end
})

local SecBoxConfig = TabDagang:Section({ Title = "Pengaturan Produk per Box / Rak (Slot 1 - 10)" })

local KIOS_BOX_OPTIONS = {
    "Otomatis",
    "Sate Kepiting",
    "Kopi Kemenyan",
    "Babi Guling",
    "Ayam Potong",
    "Pisang Raja Rebus",
    "Tumis Kamboja",
    "Susu",
    "Apel",
    "Paprika",
    "Sate Gagak",
    "Jeruk",
    "Jamur Rebus",
    "Kubis",
    "Kepiting Sungai",
    "Telur",
    "Pisang",
    "Kemenyan",
    "Dupa",
    "Terong",
    "Melati",
    "Cabai",
    "Jagung",
    "Kentang",
    "Crow Meat",
    "Tomat",
    "Bawang",
    "Padi",
    "Jangan Isi (Kosongkan)"
}

local KIOS_STRATEGIES = {
    "Otomatis (Semua Rak)",
    "Kustom Manual Per-Rak (Gunakan Box 1 - 10 di Bawah)",
    "Fokus Crab Satay (Semua Rak)",
    "Fokus Kopi Kemenyan (Semua Rak)",
    "Fokus Kentang (Semua Rak)",
    "Fokus Hasil Panen Bebas (Semua Rak)"
}

SecBoxConfig:Dropdown({
    Title = "⚡ Strategi Dagang Utama (Seamless Auto-Adapt)",
    Desc = "Otomatis rawat & restock seluruh rak yang dimiliki (5, 6, 8, 10 rak). Saat kios naik level/tambah rak, rak baru otomatis langsung terisi tanpa perlu ubah setting!",
    Values = KIOS_STRATEGIES,
    Value = State.KiosStrategy or "Otomatis (Semua Rak)",
    Callback = function(v)
        State.KiosStrategy = v
        saveConfig()
        log("Strategi Kios diset ke: " .. v)
    end
})

ParaSlotDetect = SecBoxConfig:Paragraph({
    Title = "📦 Kapasitas: Memeriksa...",
    Desc = "Mendeteksi jumlah rak yang sudah dibuka/dibeli...",
})

SecBoxConfig:Paragraph({
    Title = "⚙️ Pengaturan Manual Per-Rak (Opsional)",
    Desc = "Digunakan jika kamu memilih mode 'Kustom Manual Per-Rak' di atas. Rak yang belum dibuka otomatis berlabel Terkunci.",
})

for i = 1, 10 do
    ddBoxes[i] = SecBoxConfig:Dropdown({
        Title = ("Rak / Box %d (Slot %d)"):format(i, i),
        Values = KIOS_BOX_OPTIONS,
        Value = State["KiosBox" .. i] or "Otomatis",
        Callback = function(v)
            State["KiosBox" .. i] = v
            saveConfig()
            log(("Box %d diset: %s"):format(i, v))
        end
    })
end

local FALLBACK_OPTIONS = {
    "Jangan Isi (Tunggu Sampai Matang)",
    "Otomatis (Hasil Panen / Makanan Lain)",
    "Tomat",
    "Bawang",
    "Jagung",
    "Cabai",
    "Kentang",
    "Crow Meat"
}

SecBoxConfig:Toggle({
    Title = "Gunakan Barang Alternatif Jika Stok Box Habis",
    Desc = "Jika barang pilihan (misal: Crab Satay) habis & masih dimasak di kompor, otomatis isi rak dengan barang cadangan agar rak tidak kosong",
    Value = State.KiosUseFallback,
    Callback = function(v)
        State.KiosUseFallback = v
        saveConfig()
        log("Kios Use Fallback: " .. tostring(v))
    end
})

SecBoxConfig:Dropdown({
    Title = "Pilihan Barang Cadangan (Fallback)",
    Values = FALLBACK_OPTIONS,
    Value = State.KiosFallbackItem or "Jangan Isi (Tunggu Sampai Matang)",
    Callback = function(v)
        State.KiosFallbackItem = v
        saveConfig()
        log("Kios Fallback diset: " .. v)
    end
})

SecBoxConfig:Slider({
    Title = "Jeda Antar-Restock Rak (Detik)",
    Step = 1,
    Value = { Min = 2, Max = 15, Default = State.KiosRestockCooldown or 5 },
    Callback = function(v)
        State.KiosRestockCooldown = v
        saveConfig()
    end
})

SecBoxConfig:Button({
    Title = "🔄 Reset Semua Rak ke 'Otomatis'",
    Desc = "Kembalikan pengaturan seluruh 10 rak ke pilihan otomatis produk terbaik",
    Callback = function()
        for i = 1, 10 do
            State["KiosBox" .. i] = "Otomatis"
            if ddBoxes[i] and ddBoxes[i].SetValue then
                ddBoxes[i]:SetValue("Otomatis")
            end
        end
        saveConfig()
        log("Semua 10 Box Kios telah direset ke 'Otomatis'!")
    end
})

local SecOlah = TabDagang:Section({ Title = "Meja Pengolahan (Batch Maks 100x)" })

SecOlah:Toggle({
    Title = "Auto Potong Gagak (Batch 100x)",
    Desc = "Otomatis potong Gagak jadi daging berharga tinggi di meja pengolahan",
    Value = State.AutoOlahGagak,
    Callback = function(v)
        State.AutoOlahGagak = v
        if v then autoOlahLoop() end
    end
})

SecOlah:Toggle({
    Title = "Auto Potong Semua Ayam (Batch 100x)",
    Desc = "Otomatis potong Ayam (Kampung, Kedu, Pelung, Kate, Cemani) jadi Daging Potong",
    Value = State.AutoOlahAyam,
    Callback = function(v)
        State.AutoOlahAyam = v
        if v then autoOlahLoop() end
    end
})

SecOlah:Toggle({
    Title = "Auto Giling Biji Kopi (Batch 100x)",
    Desc = "Otomatis giling Kopi jadi Bubuk Kopi untuk resep kopi kemenyan",
    Value = State.AutoOlahKopi,
    Callback = function(v)
        State.AutoOlahKopi = v
        if v then autoOlahLoop() end
    end
})

SecOlah:Button({
    Title = "🔪 Proses Semua Olahan Sekarang (Batch 100x)",
    Desc = "Memotong semua unggas & giling kopi yang ada di tas sekaligus",
    Callback = function() task.spawn(doAutoOlah) end
})

local SecSpeedBuy = TabDagang:Section({ Title = "Speedbuy Toko (Beli Cepat & Grosir)" })

SecSpeedBuy:Dropdown({
    Title = "Pilihan Item Grosir",
    Values = { "BibitKentang", "BibitCabai", "BibitJagung", "BibitBawang", "BibitTomat", "BeliungKayu", "KapakKayu" },
    Value = State.FastShopItem or "BibitKentang",
    Callback = function(v) State.FastShopItem = v end
})

SecSpeedBuy:Slider({
    Title = "Jumlah Pembelian",
    Step = 5,
    Value = { Min = 5, Max = 100, Default = State.FastShopAmount or 20 },
    Callback = function(v) State.FastShopAmount = v end
})

SecSpeedBuy:Button({
    Title = "⚡ Beli Grosir Sekarang (Instan ShopBuy)",
    Desc = "Membeli item terpilih dalam jumlah banyak dengan aman bypass lag UI",
    Callback = function()
        task.spawn(function()
            fastBulkBuy(State.FastShopItem, State.FastShopAmount)
        end)
    end
})
end
do
-- ────────────────────────────────────────────────────────────────────────────
-- 2.5. TAB: DAPUR & MASAK (🍳)
-- ────────────────────────────────────────────────────────────────────────────
local TabMasak = Window:Tab({ Title = "Dapur", Icon = "cooking-pot" })

local SecMasakStats = TabMasak:Section({ Title = "Status Kompor & Dapur" })
ParaMasak = SecMasakStats:Paragraph({
    Title = "Status Dapur Memasak",
    Desc = "Memeriksa status antrean memasak...",
})

SecMasakStats:Button({
    Title = "🍲 Buka / Tutup Menu Kompor (MemasakGui)",
    Desc = "Buka tampilan GUI kompor secara langsung tanpa perlu jalan ke kompor",
    Callback = function()
        task.spawn(function()
            local pGui = LP:FindFirstChild("PlayerGui")
            local mGui = pGui and (pGui:FindFirstChild("MemasakGui") or pGui:FindFirstChild("CookingGui"))
            if mGui then
                mGui.Enabled = not mGui.Enabled
                log("MemasakGui status: " .. tostring(mGui.Enabled))
            else
                local prompt = getCookingPrompt()
                if prompt then
                    safeFirePrompt(prompt)
                else
                    log("Kompor / MemasakGui tidak ditemukan")
                end
            end
        end)
    end
})

SecMasakStats:Button({
    Title = "🍽️ Klaim Semua Makanan Siap (Claim All Ready)",
    Desc = "Mengklaim seluruh masakan yang sudah selesai di antrean kompor",
    Callback = function()
        task.spawn(function()
            doExecuteCooking(State.FavCookTarget or "Semua")
            log("Pemeriksaan klaim makanan antrean selesai dijalankan.")
        end)
    end
})

local SecMasakAuto = TabMasak:Section({ Title = "Otomatisasi Memasak (Auto Cook)" })

SecMasakAuto:Toggle({
    Title = "Auto Cook (Dapur Kompor)",
    Desc = "Memasak bahan makanan secara berkala di dapur",
    Value = State.AutoCook,
    Callback = function(v)
        State.AutoCook = v
        if v then autoCookLoop() end
    end
})

SecMasakAuto:Toggle({
    Title = "Fast-Cook (Percepat Masak 2x Lipat)",
    Desc = "Memasak 2x lipat per siklus & memangkas jeda kompor jadi 0.8 detik (Turbo Mode)",
    Value = State.FastCook,
    Callback = function(v) State.FastCook = v end
})

SecMasakAuto:Toggle({
    Title = "🍲 Auto-Masak Resep Favorit Arwah (Multi-Cuan)",
    Desc = "Otomatis masak Sate Kepiting, Sate Gagak, Jamur Rebus, Kopi Kemenyan saat bahannya siap",
    Value = State.AutoCookFav,
    Callback = function(v)
        State.AutoCookFav = v
        if v then autoCookFavLoop() end
    end
})

SecMasakAuto:Dropdown({
    Title = "Pilihan Resep Favorit",
    Values = {
        "Semua (Otomatis Cuan Tertinggi)",
        "Sate Kepiting",
        "Kopi Kemenyan",
        "Pisang Raja Rebus",
        "Tumis Kamboja",
        "Sate Gagak",
        "Jamur Rebus Kuburan"
    },
    Value = State.FavCookTarget or "Semua (Otomatis Cuan Tertinggi)",
    Callback = function(v)
        State.FavCookTarget = v
        saveConfig()
        log("Resep favorit dipilih: " .. v)
    end
})

SecMasakAuto:Button({
    Title = "🍳 Masak 1x Resep Favorit Sekarang",
    Desc = "Memicu kompor memasak resep favorit yang siap di tas",
    Callback = function() task.spawn(function() doCookFavorite(State.FavCookTarget) end) end
})

local SecMasakDiag = TabMasak:Section({ Title = "Diagnostik & Exploit Dapur" })

SecMasakDiag:Button({
    Title = "🔍 Diagnostik & Pindai Dapur / MemasakGui",
    Desc = "Buka MemasakGui dan cetak seluruh tombol resep / prompt kompor ke konsol",
    Callback = function() task.spawn(debugScanMemasakGui) end
})

SecMasakDiag:Button({
    Title = "⚡ Probe Bypass Timer / Instant Cook (01:30)",
    Desc = "Mencoba remote probe untuk bypass timer antrean 01:30 tanpa bayar 10 Robux",
    Callback = function() task.spawn(probeInstantCooking) end
})
end
do
-- ────────────────────────────────────────────────────────────────────────────
-- 3. TAB: TAMBANG (⛏️)
-- ────────────────────────────────────────────────────────────────────────────
local TabTambang = Window:Tab({ Title = "Tambang", Icon = "pickaxe" })

local SecTambangStats = TabTambang:Section({ Title = "Status Peralatan" })
ParaTambang = SecTambangStats:Paragraph({
    Title = "Beliung & Kapak",
    Desc = "Memeriksa durabilitas...",
})

local SecTambangAuto = TabTambang:Section({ Title = "Otomatisasi Penambangan" })
SecTambangAuto:Toggle({
    Title = "Auto Tambang Batu",
    Desc = "Hancurkan batu di BahanCraft untuk bahan tempa",
    Value = State.AutoTambang,
    Callback = function(v)
        State.AutoTambang = v
        if v then autoTambangLoop() end
    end
})

SecTambangAuto:Toggle({
    Title = "Auto Tebang Pohon",
    Desc = "Tebang pohon liar di map untuk stok kayu",
    Value = State.AutoTebang,
    Callback = function(v)
        State.AutoTebang = v
        if v then autoTebangLoop() end
    end
})

SecTambangAuto:Toggle({
    Title = "Auto Beli Beliung Jika Belum Punya (500 Koin)",
    Desc = "Beli BeliungKayu dari toko bila koin mencukupi",
    Value = State.AutoBuyBeliung,
    Callback = function(v) State.AutoBuyBeliung = v end
})

SecTambangAuto:Button({
    Title = "⛏️ Beli Beliung Kayu Sekarang (500 Koin)",
    Callback = function() task.spawn(buyBeliung) end
})

SecTambangAuto:Button({
    Title = "🪓 Beli Kapak Kayu Sekarang (500 Koin)",
    Callback = function()
        task.spawn(function()
            local rem = getR("ShopBuy")
            if rem then rem:InvokeServer("KapakKayu", 1) end
        end)
    end
})

-- ────────────────────────────────────────────────────────────────────────────
-- 4. TAB: TANGKAP (🍄)
-- ────────────────────────────────────────────────────────────────────────────
end
do
local TabTangkap = Window:Tab({ Title = "Tangkap", Icon = "sparkles" })

local SecTangkapStats = TabTangkap:Section({ Title = "Status Item Liar Map" })
ParaTangkap = SecTangkapStats:Paragraph({
    Title = "Item Liar & Hewan",
    Desc = "Memuat data...",
})

local SecTangkapAuto = TabTangkap:Section({ Title = "Ambil & Tangkap Liar" })
SecTangkapAuto:Button({
    Title = "⚡ Sapu Bersih Semua Item Liar Sekarang (1x Klik)",
    Desc = "Pungut seluruh Jamur, Melati, Kemenyan, & Gagak di map",
    Callback = function() task.spawn(sweepAllForagables) end
})

SecTangkapAuto:Toggle({
    Title = "Auto Ambil Jamur, Melati & Kemenyan",
    Desc = "Memungut bahan alam liar yang baru spawn di map",
    Value = State.AutoForage,
    Callback = function(v)
        State.AutoForage = v
        if v then autoForageLoop() end
    end
})

SecTangkapAuto:Toggle({
    Title = "Auto Tangkap Burung Gagak",
    Desc = "Menangkap burung gagak liar di sekitar map",
    Value = State.AutoGagak,
    Callback = function(v)
        State.AutoGagak = v
        if v then autoForageLoop() end
    end
})

SecTangkapAuto:Toggle({
    Title = "Auto Interaksi Tuyul Liar",
    Desc = "Menghampiri tuyul liar yang berkeliaran di map",
    Value = State.AutoTuyul,
    Callback = function(v)
        State.AutoTuyul = v
        if v then autoForageLoop() end
    end
})

SecTangkapAuto:Toggle({
    Title = "Radar Tuyul Liar (Pop-up & Notifikasi)",
    Desc = "Deteksi kemunculan Tuyul liar dalam jarak 120m dengan notifikasi",
    Value = State.TuyulRadar,
    Callback = function(v) State.TuyulRadar = v end
})

SecTangkapAuto:Toggle({
    Title = "Auto-Intercept Tuyul (Teleport Langsung)",
    Desc = "Langsung samperin & tangkap begitu Tuyul terdeteksi radar",
    Value = State.AutoInterceptTuyul,
    Callback = function(v) State.AutoInterceptTuyul = v end
})

SecTangkapAuto:Toggle({
    Title = "Instant Tuyul Solver (Cut & Lapor)",
    Desc = "Bypass animasi lambat tuyul, langsung selesaikan mini-game & klaim hadiah seketika",
    Value = State.AutoFastTuyul,
    Callback = function(v) State.AutoFastTuyul = v end
})

local SecSafeLoot = TabTangkap:Section({ Title = "Auto-Ambil Bahan Gratis (Individual & Aman)" })

SecSafeLoot:Toggle({
    Title = "🐦 Auto Get Burung Gagak",
    Desc = "Otomatis ambil burung gagak liar (bisa diolah jadi daging di Meja Pengolahan)",
    Value = State.AutoGetGagak,
    Callback = function(v)
        State.AutoGetGagak = v
        if v then autoSafeLootLoop() end
    end
})

SecSafeLoot:Toggle({
    Title = "🦀 Auto Get Kepiting Sungai",
    Desc = "Otomatis ambil kepiting sungai liar (bisa dimasak di kompor / dijual mahal)",
    Value = State.AutoGetKepiting,
    Callback = function(v)
        State.AutoGetKepiting = v
        if v then autoSafeLootLoop() end
    end
})

SecSafeLoot:Toggle({
    Title = "🪔 Auto Get Dupa",
    Desc = "Otomatis ambil dupa wangi gaib di sekitar map",
    Value = State.AutoGetDupa,
    Callback = function(v)
        State.AutoGetDupa = v
        if v then autoSafeLootLoop() end
    end
})

SecSafeLoot:Toggle({
    Title = "🪵 Auto Get Kemenyan",
    Desc = "Otomatis ambil kemenyan mistis (bisa diseduh jadi Kopi Kemenyan)",
    Value = State.AutoGetKemenyan,
    Callback = function(v)
        State.AutoGetKemenyan = v
        if v then autoSafeLootLoop() end
    end
})

SecSafeLoot:Toggle({
    Title = "🍄 Auto Get Jamur Kuburan",
    Desc = "Otomatis ambil jamur kuburan (bisa dimasak Jamur Rebus)",
    Value = State.AutoGetJamur,
    Callback = function(v)
        State.AutoGetJamur = v
        if v then autoSafeLootLoop() end
    end
})

SecSafeLoot:Toggle({
    Title = "🌸 Auto Get Bunga Melati",
    Desc = "Otomatis ambil bunga melati wangi di area liar",
    Value = State.AutoGetMelati,
    Callback = function(v)
        State.AutoGetMelati = v
        if v then autoSafeLootLoop() end
    end
})

SecSafeLoot:Slider({
    Title = "Jeda Waktu Auto-Get (Detik)",
    Step = 1,
    Value = { Min = 3, Max = 15, Default = State.AutoLootDelay or 5 },
    Callback = function(v) State.AutoLootDelay = v end
})

SecSafeLoot:Dropdown({
    Title = "Master Loot: Pilihan Kategori",
    Values = { "Semua", "Kepiting", "Jamur", "Melati", "Gagak", "Dupa", "Kemenyan" },
    Value = State.LootTarget,
    Callback = function(v)
        State.LootTarget = v
        log("Target master loot dipilih: " .. v)
    end
})

SecSafeLoot:Toggle({
    Title = "⚡ Master Auto-Loot (Sesuai Pilihan Kategori)",
    Desc = "Mengambil bahan liar sesuai dropdown kategori di atas secara otomatis",
    Value = State.AutoSafeLoot,
    Callback = function(v)
        State.AutoSafeLoot = v
        if v then autoSafeLootLoop() end
    end
})

local SecQuickGet = TabTangkap:Section({ Title = "Ambil 1x Cepat (Instant Fetch)" })
SecQuickGet:Button({
    Title = "🦀 Ambil 1x Kepiting Terdekat",
    Callback = function() task.spawn(function() doSafeLoot("Kepiting") end) end
})
SecQuickGet:Button({
    Title = "🐦 Ambil 1x Gagak Terdekat",
    Callback = function() task.spawn(function() doSafeLoot("Gagak") end) end
})
SecQuickGet:Button({
    Title = "🪔 Ambil 1x Dupa Terdekat",
    Callback = function() task.spawn(function() doSafeLoot("Dupa") end) end
})
SecQuickGet:Button({
    Title = "🪵 Ambil 1x Kemenyan Terdekat",
    Callback = function() task.spawn(function() doSafeLoot("Kemenyan") end) end
})
SecQuickGet:Button({
    Title = "🍄 Ambil 1x Jamur Terdekat",
    Callback = function() task.spawn(function() doSafeLoot("Jamur") end) end
})
SecQuickGet:Button({
    Title = "🌸 Ambil 1x Melati Terdekat",
    Callback = function() task.spawn(function() doSafeLoot("Melati") end) end
})

local SecGaib = TabTangkap:Section({ Title = "Event Malam & Pasar Gaib" })
SecGaib:Toggle({
    Title = "Auto Teleport Pasar Gaib Saat Malam",
    Desc = "Teleport otomatis ke Pria Misterius saat jam 18:00+ tiba",
    Value = State.AutoPasarGaib,
    Callback = function(v) State.AutoPasarGaib = v end
})

SecGaib:Toggle({
    Title = "Auto-Snipe Item Pasar Gaib (GaibBuy)",
    Desc = "Membeli otomatis item langka (Minyak Jelangkung, Sandal Angin, dll) sebelum habis",
    Value = State.AutoGaibSnipe,
    Callback = function(v)
        State.AutoGaibSnipe = v
        if v then autoGaibSnipeLoop() end
    end
})

SecGaib:Dropdown({
    Title = "Target Snipe Pasar Gaib",
    Desc = "Pilih item tertentu yang ingin di-snipe otomatis",
    Values = { "Semua", "MinyakJelangkung", "ArangKeramat", "SandalAngin", "AirKembang" },
    Value = State.GaibSnipeTarget,
    Callback = function(v) State.GaibSnipeTarget = v end
})

SecGaib:Toggle({
    Title = "Auto Gunakan Buff Gaib (GaibUse)",
    Desc = "Otomatis aktifkan buff (Pungut 2x / Masak 2x / EXP 2x) saat malam",
    Value = State.AutoUseGaibBuff,
    Callback = function(v) State.AutoUseGaibBuff = v end
})

SecGaib:Dropdown({
    Title = "Pilihan Buff Gaib",
    Desc = "Pilih buff mistis yang ingin diaktifkan otomatis",
    Values = { "MinyakJelangkung", "ArangKeramat", "AirKembang", "SandalAngin" },
    Value = State.GaibBuffChoice,
    Callback = function(v) State.GaibBuffChoice = v end
})

SecGaib:Button({
    Title = "⚡ Aktifkan Buff Gaib Sekarang",
    Desc = "Mengaktifkan item buff yang dipilih langsung dari tas",
    Callback = function() doUseGaibBuff(State.GaibBuffChoice) end
})

SecGaib:Button({
    Title = "🌙 Teleport & Buka Pasar Gaib Sekarang",
    Callback = function()
        local npcMis = Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("NpcMisterius")
        if npcMis then
            tpToPos(npcMis.Position + Vector3.new(0, 3, 2))
            task.wait(0.3)
            openGameGui("PasarGaibGui", "PasarGaib", "OpenPasarGaib")
        else
            log("NPC Pria Misterius tidak ditemukan di map")
        end
    end
})

SecGaib:Toggle({
    Title = "Auto Buka Peti Arwah Saat Malam",
    Desc = "Membuka Peti Arwah secara otomatis untuk bonus koin",
    Value = State.AutoPetiArwah,
    Callback = function(v) State.AutoPetiArwah = v end
})

SecGaib:Toggle({
    Title = "Auto Claim Jatah Peti Arwah Gratis",
    Desc = "Mengklaim gacha gratis harian/malam dari Peti Arwah tanpa biaya koin",
    Value = State.AutoClaimJatahPeti,
    Callback = function(v) State.AutoClaimJatahPeti = v end
})

SecGaib:Button({
    Title = "🎁 Klaim Jatah Peti Arwah Sekarang",
    Desc = "Coba klaim free pull Peti Arwah dari server sekarang",
    Callback = function() doClaimJatahPeti() end
})

SecGaib:Button({
    Title = "👁️ Cek Pity Peti Arwah Saat Ini",
    Desc = "Membaca counter jaminan item langka (Pity Threshold) langsung dari server",
    Callback = function() checkPetiArwahPity() end
})

SecGaib:Toggle({
    Title = "Auto Smart Pull Peti Arwah",
    Desc = "Otomatis melakukan gacha Peti Arwah saat koin cukup & malam tiba",
    Value = State.AutoPetiSmartPull,
    Callback = function(v)
        State.AutoPetiSmartPull = v
        if v then autoSmartPetiLoop() end
    end
})

SecGaib:Dropdown({
    Title = "Paket Pull Peti Arwah",
    Desc = "Pilih jumlah tarikan sekali gacha",
    Values = { "1x (200 Koin)", "10x (1.800 Koin)", "50x (8.500 Koin)" },
    Value = "10x (1.800 Koin)",
    Callback = function(v)
        if v:find("50x") then State.PetiPullPackage = 50
        elseif v:find("10x") then State.PetiPullPackage = 10
        else State.PetiPullPackage = 1 end
    end
})

SecGaib:Button({
    Title = "⚰️ Teleport & Interaksi Peti Arwah Sekarang",
    Callback = function()
        local npcPeti = Workspace:FindFirstChild("NPC") and Workspace.NPC:FindFirstChild("NpcPetiArwah")
        if npcPeti then
            tpToPos(npcPeti.Position + Vector3.new(0, 3, 2))
            task.wait(0.3)
            local p = npcPeti:FindFirstChildWhichIsA("ProximityPrompt", true)
            if p and p.Enabled then safeFirePrompt(p) end
        else
            log("Peti Arwah belum spawn (hanya saat malam)")
        end
    end
})

SecGaib:Toggle({
    Title = "Auto Tukar Pusaka (Peti Arwah Trade)",
    Desc = "Otomatis tukar serpihan arwah jadi pusaka mistis saat malam",
    Value = State.AutoTukarPusaka,
    Callback = function(v) State.AutoTukarPusaka = v end
})

SecGaib:Button({
    Title = "🔮 Buka Menu Tukar Pusaka",
    Desc = "Membuka antarmuka penukaran pusaka gaib",
    Callback = function() doTukarPusaka() end
})

SecGaib:Toggle({
    Title = "Auto Misi Pocong Malam (PociQuest)",
    Desc = "Otomatis berinteraksi & klaim misi rahasia Pocong saat malam",
    Value = State.AutoPociQuest,
    Callback = function(v) State.AutoPociQuest = v end
})

SecGaib:Button({
    Title = "📜 Ambil / Klaim Misi Pocong Sekarang",
    Callback = function() doPociQuest() end
})

-- ────────────────────────────────────────────────────────────────────────────
-- 5. TAB: TERNAK (🐷)
-- ────────────────────────────────────────────────────────────────────────────
end
do
local TabTernak = Window:Tab({ Title = "Ternak", Icon = "egg" })

local SecTernakStats = TabTernak:Section({ Title = "Status Kandang" })
ParaTernak = SecTernakStats:Paragraph({
    Title = "Kandang Hewan",
    Desc = "Memeriksa kandang...",
})

local SecTernakAuto = TabTernak:Section({ Title = "Kontrol Ternak" })
SecTernakAuto:Toggle({
    Title = "Auto Jual Babi ke Bandar (Batch Optimal)",
    Desc = "Menjual semua babi siap jual secara massal via remote 'jualBanyak' (Cepat & Efisien)",
    Value = State.AutoSellBabi,
    Callback = function(v)
        State.AutoSellBabi = v
        if v then autoSellBabiLoop() end
    end
})

SecTernakAuto:Button({
    Title = "🐷 Jual Semua Babi Sekarang (Batch jualBanyak)",
    Desc = "Menjual babi yang tidak dikunci dan tidak bunting sekaligus",
    Callback = function()
        task.spawn(function()
            local ok, count = doSellBabiBatch()
            if not ok then
                WindUI:Notify({
                    Title = "🐷 Jual Babi",
                    Desc = tostring(count or "Gagal menjual babi / tidak ada babi siap jual"),
                    Duration = 4,
                    Icon = "info"
                })
            end
        end)
    end
})

SecTernakAuto:Button({
    Title = "🐔 Bangun Kandang Ayam (Plot Sendiri)",
    Callback = function() task.spawn(function() doBangunKandang("Ayam") end) end
})

SecTernakAuto:Button({
    Title = "🐷 Bangun Kandang Babi (Plot Sendiri)",
    Callback = function() task.spawn(function() doBangunKandang("Babi") end) end
})

SecTernakAuto:Button({
    Title = "🐮 Bangun Kandang Sapi (Plot Sendiri)",
    Callback = function() task.spawn(function() doBangunKandang("Sapi") end) end
})

local SecExploitKandang = TabTernak:Section({ Title = "⚡ Exploit Kandang (Bug Abuse)" })

SecExploitKandang:Toggle({
    Title = "Auto Early Harvest Kandang (Bypass Timer)",
    Desc = "Otomatis panen telur/daging dari kandang sebelum timer server habis (KandangPanen race)",
    Value = State.AutoEarlyKandang,
    Callback = function(v)
        State.AutoEarlyKandang = v
        if v then task.spawn(autoKandangEarlyLoop) end
    end
})

SecExploitKandang:Button({
    Title = "🐔 Early Harvest Semua Kandang Sekarang",
    Desc = "Coba panen ternak sebelum timer – kalau berhasil, produk langsung masuk tas",
    Callback = function() task.spawn(doKandangEarlyHarvest) end
})

SecExploitKandang:Toggle({
    Title = "Auto Gerobak Skin Passive Swap (Max Jual)",
    Desc = "Equip skin gerobak dengan passive income sebelum isi rak kios, lalu unequip otomatis",
    Value = State.AutoGerobakSwap,
    Callback = function(v)
        State.AutoGerobakSwap = v
        if v then task.spawn(autoGerobakSwapSell) end
    end
})

SecExploitKandang:Button({
    Title = "🛺 Skin Swap + Isi Kios Sekarang",
    Desc = "Equip skin passive → isi rak kios → unequip",
    Callback = function()
        task.spawn(function()
            doGerobakPassiveSwap(function() stockKiosShelves() end)
        end)
    end
})

-- ────────────────────────────────────────────────────────────────────────────
-- 5.5 TAB: EXPLOIT LAB (🧪)
-- ────────────────────────────────────────────────────────────────────────────
end
do
local TabExploit = Window:Tab({ Title = "Exploit Lab", Icon = "flask-conical" })
local SecExploitNote = TabExploit:Section({ Title = "ℹ️ Bug Abuse Laboratory" })
SecExploitNote:Paragraph({
    Title = "Cara Kerja",
    Desc = "Tab ini berisi exploit race condition, overflow, & hidden item probe. Semua dipanggil via remote resmi game (legal-illegal). Hasil bervariasi tiap update game.",
})

local SecRace = TabExploit:Section({ Title = "🎁 Race Condition Exploits" })

SecRace:Slider({
    Title = "Jeda Race-Call (detik)",
    Step = 0.01,
    Value = { Min = 0.01, Max = 0.2, Default = State.RaceClaimDelay or 0.05 },
    Callback = function(v) State.RaceClaimDelay = v end
})

SecRace:Toggle({
    Title = "Auto Race Claim Peti Arwah Jatah (3x Burst)",
    Desc = "Otomatis kirim 3 claim sekaligus setiap malam sebelum server tulis cooldown harian",
    Value = State.AutoPetiRaceClaim,
    Callback = function(v)
        State.AutoPetiRaceClaim = v
        if v then task.spawn(autoPetiRaceLoop) end
    end
})

SecRace:Button({
    Title = "🎁 Race Claim Peti Jatah Sekarang (3 Thread)",
    Desc = "Kirim 3 klaim bersamaan — kalau race berhasil, dapat 2-3x free pull!",
    Callback = function()
        task.spawn(function() doPetiJatahRace(3) end)
    end
})

SecRace:Button({
    Title = "🏅 Race Double-Claim Lencana Balai Desa",
    Desc = "Klaim milestone lencana 2x dalam 1 siklus via race condition",
    Callback = function()
        task.spawn(doBalaiMultiClaimRace)
    end
})

SecRace:Button({
    Title = "⚡ Race Double-Harvest Tanaman Matang",
    Desc = "Fire ProximityPrompt panen dari 2 thread serentak untuk dapat crop 2x",
    Callback = function()
        task.spawn(doMultiHarvestRace)
    end
})

SecRace:Toggle({
    Title = "Auto Multi-Harvest (Simultaneous Thread)",
    Desc = "Otomatis jalankan double-harvest setiap kali ada tanaman matang",
    Value = State.AutoMultiHarvest,
    Callback = function(v) State.AutoMultiHarvest = v end
})

local SecOverflow = TabExploit:Section({ Title = "🔢 Overflow & Integer Abuse" })

SecOverflow:Button({
    Title = "🔪 Probe OlahMulai Overflow (9999x)",
    Desc = "Kirim request olah dengan jumlah 9999x – jika server tidak validasi, dapat item gratis",
    Callback = function()
        task.spawn(probeOlahOverflow)
    end
})

local SecHidden = TabExploit:Section({ Title = "🔍 Hidden Item & Shop Probe" })

SecHidden:Button({
    Title = "🛒 Probe Item Tersembunyi di ShopBuy",
    Desc = "Coba beli 15 item ID rahasia yang tidak tampil di UI toko (VIP items, event items, dll)",
    Callback = function()
        task.spawn(probeHiddenShopItems)
    end
})

local SecGuild = TabExploit:Section({ Title = "🏰 Guild Exploitation" })

SecGuild:Toggle({
    Title = "Auto Guild Boost Snipe",
    Desc = "Otomatis join guild yang sedang aktif boost → klaim buff → langsung keluar",
    Value = State.AutoGuildBoostSnipe,
    Callback = function(v)
        State.AutoGuildBoostSnipe = v
        if v then
            task.spawn(function()
                while State.AutoGuildBoostSnipe do
                    doGuildBoostSnipe()
                    task.wait(120) -- Coba tiap 2 menit
                end
            end)
        end
    end
})

SecGuild:Button({
    Title = "🏰 Guild Boost Snipe Sekarang",
    Desc = "Cari guild dengan boost aktif, masuk sebentar, snipe buff-nya, lalu keluar",
    Callback = function()
        task.spawn(doGuildBoostSnipe)
    end
})

-- [Batch 2] Bruteforce, Mining, EXP Steal, Trade Snipe, Free Chest, Price Spoof

local SecBrute = TabExploit:Section({ Title = "🔑 Redeem Code Bruteforce" })

SecBrute:Slider({
    Title = "Jeda Antar Probe (detik)",
    Step = 0.05,
    Value = { Min = 0.1, Max = 1.0, Default = State.BruteforceDelay or 0.25 },
    Callback = function(v) State.BruteforceDelay = v end
})

SecBrute:Toggle({
    Title = "Auto Bruteforce Kode Dev (Loop 5 Menit)",
    Desc = "Otomatis coba ratusan kombinasi kode promo/dev setiap 5 menit",
    Value = State.AutoBruteforceCode,
    Callback = function(v)
        State.AutoBruteforceCode = v
        if v then task.spawn(autoBruteforceLoop) end
    end
})

SecBrute:Button({
    Title = "🔑 Jalankan Bruteforce Kode Sekarang",
    Desc = "Coba 1.200+ kombinasi kode: PASAR001, DUKUN2024, GAIBFREE, dll",
    Callback = function()
        task.spawn(doBruteforceCode)
    end
})

local SecMine = TabExploit:Section({ Title = "⛏️ Mining Multi-Hit (Double Drop)" })

SecMine:Toggle({
    Title = "Auto Mining Multi-Hit (Double Drop)",
    Desc = "Otomatis tambang setiap batu/ore dengan 2 thread serentak setiap 8 detik",
    Value = State.AutoMiningMultiHit,
    Callback = function(v)
        State.AutoMiningMultiHit = v
        if v then task.spawn(autoMiningMultiHitLoop) end
    end
})

SecMine:Button({
    Title = "⛏️ Mining Multi-Hit Sekarang",
    Desc = "Double-hit semua batu/ore di sekitar lahan (drop 2x per batu)",
    Callback = function()
        task.spawn(doMiningMultiHit)
    end
})

local SecSiramOrang = TabExploit:Section({ Title = "💧 Siram Kebun Player Lain (EXP Steal)" })

SecSiramOrang:Toggle({
    Title = "Auto Siram Lahan Player Lain (EXP Gratis)",
    Desc = "Otomatis siram tanaman kering milik player lain → klaim EXP siram tanpa punya tanaman sendiri",
    Value = State.AutoSiramOrang,
    Callback = function(v)
        State.AutoSiramOrang = v
        if v then task.spawn(autoSiramOrangLoop) end
    end
})

SecSiramOrang:Button({
    Title = "💧 Siram Kebun Orang Sekarang",
    Desc = "Deteksi + siram semua tanaman kering milik player lain di server",
    Callback = function()
        task.spawn(doSiramLahanOrang)
    end
})

local SecTrade = TabExploit:Section({ Title = "🔄 TradeBoard Auto-Snipe" })

SecTrade:Slider({
    Title = "Minimum Ratio Harga Untuk Auto-Accept",
    Step = 0.5,
    Value = { Min = 1.0, Max = 10.0, Default = State.TradeBoardMinRatio or 2.0 },
    Callback = function(v) State.TradeBoardMinRatio = v end
})

SecTrade:Toggle({
    Title = "Auto Trade Board Snipe (Pantau Terus)",
    Desc = "Pantau papan barter tiap 5 detik & auto-accept trade yang nilainya 2x+ lebih bagus",
    Value = State.AutoTradeBoardSnipe,
    Callback = function(v)
        State.AutoTradeBoardSnipe = v
        if v then task.spawn(autoTradeBoardSnipeLoop) end
    end
})

SecTrade:Button({
    Title = "🔄 Scan & Snipe Trade Board Sekarang",
    Desc = "Periksa semua penawaran aktif dan langsung ambil yang menguntungkan",
    Callback = function()
        task.spawn(scanTradeBoard)
    end
})

local SecFreePeti = TabExploit:Section({ Title = "⚰️ High Risk: Free Chest & Price Spoof" })

SecFreePeti:Paragraph({
    Title = "⚠️ Peringatan",
    Desc = "Exploit di bawah ini memiliki risiko tinggi jika server melakukan logging anomali. Gunakan dengan bijak dan jangan terlalu sering.",
})

SecFreePeti:Button({
    Title = "⚰️ Probe Free Peti Arwah (5 Argumen)",
    Desc = "Coba buka Peti Arwah tanpa bayar koin via manipulasi argumen remote (cost=0, free=true, dll)",
    Callback = function()
        task.spawn(doPetiFreeOpen)
    end
})

SecFreePeti:Input({
    Title = "Item untuk Price Spoof",
    Desc = "Nama item yang akan di-listing di market",
    Value = "BijiKopi",
    Callback = function(v)
        if v and v ~= "" then State._spoofItem = v end
    end
})

SecFreePeti:Slider({
    Title = "Harga Spoof (Koin)",
    Step = 1000,
    Value = { Min = 1000, Max = 999999, Default = 99999 },
    Callback = function(v) State._spoofPrice = v end
})

SecFreePeti:Button({
    Title = "💰 Probe Market Price Spoof",
    Desc = "Coba listing item di pasar player dengan harga jauh di atas limit normal",
    Callback = function()
        task.spawn(function()
            doMarketSellSpoof(State._spoofItem or "BijiKopi", State._spoofPrice or 99999)
        end)
    end
})

-- ────────────────────────────────────────────────────────────────────────────
-- 6. TAB: UPGRADE (⭐)
-- ────────────────────────────────────────────────────────────────────────────
end
do
local TabUpgrade = Window:Tab({ Title = "Upgrade", Icon = "arrow-big-up" })

local SecUpInfo = TabUpgrade:Section({ Title = "Properti & Ekspansi" })
SecUpInfo:Paragraph({
    Title = "Panduan Upgrade",
    Desc = "Upgrade Toko/Market meningkatkan kapasitas koin & slot rak.\nUpgrade Lahan menambah kapasitas lubang tanam kebun.",
})

SecUpInfo:Button({
    Title = "🏪 Upgrade Toko / Market (Kios)",
    Desc = "Memicu upgrade kios dan auto-confirm (10.000 Koin)",
    Callback = function() task.spawn(doUpgradeMarket) end
})

SecUpInfo:Button({
    Title = "🌾 Upgrade Lahan Kebun Utama",
    Desc = "Menaikkan level lahan utama kebun kamu",
    Callback = function() task.spawn(doUpgradeLahan) end
})

SecUpInfo:Button({
    Title = "🌱 Buka Petak Lahan Besar",
    Desc = "Membuka kotak petak tanah kebun ekspansi",
    Callback = function() task.spawn(doUnlockLahanBesar) end
})

SecUpInfo:Button({
    Title = "🔨 Buka Menu Tempa (Upgrade Beliung)",
    Desc = "Membuka pandai besi untuk menempa beliung besi",
    Callback = function() openGameGui("TempaGui", nil, "TempaBuka") end
})

local SecSmartUp = TabUpgrade:Section({ Title = "Smart Auto-Progression (AFK)" })
SecSmartUp:Toggle({
    Title = "Auto Smart Upgrade Lahan (>= 2.500 Koin)",
    Desc = "Otomatis upgrade lahan utama saat koin mencukupi",
    Value = State.AutoSmartUpLahan,
    Callback = function(v) State.AutoSmartUpLahan = v end
})

SecSmartUp:Toggle({
    Title = "Auto Smart Upgrade Kios (>= 10.000 Koin)",
    Desc = "Otomatis upgrade toko pasar saat koin mencukupi",
    Value = State.AutoSmartUpKios,
    Callback = function(v) State.AutoSmartUpKios = v end
})

local SecKeahlian = TabUpgrade:Section({ Title = "Pohon Keahlian & Alokasi Poin" })

SecKeahlian:Dropdown({
    Title = "Fokus Jalur Keahlian",
    Values = { "Tani", "Dagang", "Gaib" },
    Value = State.KeahlianFocus or "Tani",
    Callback = function(v) State.KeahlianFocus = v end
})

SecKeahlian:Toggle({
    Title = "Auto-Alokasi Poin Keahlian",
    Desc = "Otomatis menaikkan skill sesuai fokus saat poin baru didapat dari level-up",
    Value = State.AutoSpendKeahlian,
    Callback = function(v)
        State.AutoSpendKeahlian = v
        if v then doSpendKeahlian(State.KeahlianFocus) end
    end
})

SecKeahlian:Button({
    Title = "🌟 Alokasikan 1 Poin Keahlian Sekarang",
    Desc = "Menaikkan skill pada jalur yang dipilih sekarang",
    Callback = function() doSpendKeahlian(State.KeahlianFocus) end
})

local SecGacha = TabUpgrade:Section({ Title = "Undian Gacha Gerobak" })
SecGacha:Button({
    Title = "🛺 Buka Menu Gacha Gerobak",
    Desc = "Buka menu visual undian gerobak di layar",
    Callback = function() openGameGui("GerobakGachaGui", "GerobakGacha", "BukaGachaGerobak") end
})

SecGacha:Button({
    Title = "🎰 Tarik 1x Gacha Gerobak (5.000 Koin)",
    Desc = "Memicu 1x summon skin gerobak",
    Callback = function()
        local rem = getR("GachaGerobak") or getR("UndiGerobak")
        if rem then
            pcall(function() rem:InvokeServer(1) end)
        else
            openGameGui("GerobakGachaGui", "GerobakGacha", "BukaGachaGerobak")
        end
    end
})

SecGacha:Button({
    Title = "🎰 Tarik 10x Gacha Gerobak (45.000 Koin)",
    Desc = "Memicu 10x summon skin gerobak (Hemat 10%)",
    Callback = function()
        local rem = getR("GachaGerobak") or getR("UndiGerobak")
        if rem then
            pcall(function() rem:InvokeServer(10) end)
        else
            openGameGui("GerobakGachaGui", "GerobakGacha", "BukaGachaGerobak")
        end
    end
})

-- ────────────────────────────────────────────────────────────────────────────
-- 7. TAB: MENU GAME (📱)
-- ────────────────────────────────────────────────────────────────────────────
end
do
local TabMenu = Window:Tab({ Title = "Menu GUI", Icon = "layout-grid" })
local SecMenuAction = TabMenu:Section({ Title = "Kontrol GUI Game" })
SecMenuAction:Button({
    Title = "❌ TUTUP SEMUA MENU GAME YANG TERBUKA",
    Desc = "Menutup bersih semua overlay menu game",
    Callback = function() closeAllGameGuis() end
})

local SecMenuOpen = TabMenu:Section({ Title = "Buka Menu Jarak Jauh" })
SecMenuOpen:Button({
    Title = "🛒 Buka Toko Bibit & Barang (Shop)",
    Callback = function() openGameGui("ShopGui", "ShopNPC") end
})

SecMenuOpen:Button({
    Title = "🍳 Buka Dapur Memasak (Kompor)",
    Callback = function() openGameGui("MemasakGui") end
})

SecMenuOpen:Button({
    Title = "🔨 Buka Tempat Tempa (Blacksmith)",
    Callback = function() openGameGui("TempaGui", nil, "TempaBuka") end
})

SecMenuOpen:Button({
    Title = "🔮 Buka Pasar Gaib (Malam)",
    Callback = function() openGameGui("PasarGaibGui", "PasarGaib", "OpenPasarGaib") end
})

SecMenuOpen:Button({
    Title = "🐷 Buka Bandar / Jual Babi",
    Callback = function() openGameGui("JualBabiGui", "JualBabi", "BukaJualBabi") end
})

SecMenuOpen:Button({
    Title = "⚰️ Buka Peti Arwah",
    Callback = function() openGameGui("PetiArwahGui", "PetiArwah", "OpenPetiArwah") end
})

SecMenuOpen:Button({
    Title = "🛺 Buka Gacha Gerobak",
    Callback = function() openGameGui("GerobakGachaGui", "GerobakGacha", "BukaGachaGerobak") end
})

SecMenuOpen:Button({
    Title = "📜 Buka Balai Desa (Quest & Info)",
    Callback = function() openGameGui("BalaiGui", "Balai", "BalaiOpen") end
})

SecMenuOpen:Button({
    Title = "👤 Buka Profil Karakter",
    Callback = function() openGameGui("ProfilGui", "Profil") end
})

SecMenuOpen:Button({
    Title = "🔄 Buka Menu Trade Player",
    Callback = function() openGameGui("TradeGui", "Trade") end
})

local SecInspector = TabMenu:Section({ Title = "Player & Inventory Inspector" })

local selectedTargetPlayer = LP.Name
local function getOnlinePlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    return names
end

local DropdownPlayers = SecInspector:Dropdown({
    Title = "Pilih Player di Server",
    Values = getOnlinePlayerNames(),
    Value = LP.Name,
    Callback = function(v) selectedTargetPlayer = v end
})

SecInspector:Button({
    Title = "🔄 Refresh Daftar Player",
    Desc = "Memperbarui daftar player yang online di server",
    Callback = function()
        pcall(function()
            DropdownPlayers:SetValues(getOnlinePlayerNames())
        end)
    end
})

SecInspector:Button({
    Title = "👁️ Intip Profil & Isi Tas Player",
    Desc = "Membaca Koin, Level, dan seluruh isi backpack target",
    Callback = function()
        inspectPlayerInventory(selectedTargetPlayer)
    end
})

local SecQuests = TabMenu:Section({ Title = "Misi & Hadiah Quest Harian" })
SecQuests:Toggle({
    Title = "Auto Claim Hadiah Quest (Harian & Mingguan)",
    Desc = "Otomatis claim koin & serpihan saat target quest tercapai",
    Value = State.AutoClaimQuest,
    Callback = function(v)
        State.AutoClaimQuest = v
        if v then autoQuestLoop() end
    end
})

SecQuests:Button({
    Title = "🎁 Klaim Semua Quest yang Selesai Sekarang",
    Callback = function() task.spawn(claimCompletedQuests) end
})

SecQuests:Toggle({
    Title = "Auto Klaim Lencana Balai Desa",
    Desc = "Otomatis mencairkan reward koin & shards dari milestone/lencana Balai Desa",
    Value = State.AutoKlaimLencana,
    Callback = function(v)
        State.AutoKlaimLencana = v
        if v then doKlaimLencana() end
    end
})

SecQuests:Button({
    Title = "🏅 Klaim Semua Lencana Balai Desa Sekarang",
    Desc = "Memicu klaim seluruh reward lencana dan pencapaian desa",
    Callback = function() doKlaimLencana() end
})

SecQuests:Button({
    Title = "📜 Buka Tampilan Menu Quest Harian",
    Callback = function() openGameGui("QuestGui") end
})

local SecRedeem = TabMenu:Section({ Title = "Redeem Kode Hadiah Developer" })
local customCodeInput = ""
SecRedeem:Input({
    Title = "Masukkan Kode Promo",
    Placeholder = "Ketik kode di sini...",
    Callback = function(text) customCodeInput = text end
})

SecRedeem:Button({
    Title = "🎟️ Tukar Kode Promo",
    Callback = function()
        if customCodeInput ~= "" then
            task.spawn(function()
                local ok, msg = redeemCode(customCodeInput)
                log("Redeem: " .. tostring(msg))
            end)
        end
    end
})

SecRedeem:Button({
    Title = "🌟 Auto-Redeem Kumpulan Kode Hadiah",
    Desc = "Mencoba semua kode promo aktif secara berurutan",
    Callback = function() redeemPopularCodes() end
})

-- ────────────────────────────────────────────────────────────────────────────
-- 8. TAB: KARAKTER (⚡)
-- ────────────────────────────────────────────────────────────────────────────
end
do
local TabChar = Window:Tab({ Title = "Karakter", Icon = "zap" })

local SecCharMove = TabChar:Section({ Title = "Kecepatan & Lompat" })
SecCharMove:Slider({
    Title = "WalkSpeed",
    Step = 1,
    Value = { Min = 16, Max = 120, Default = State.WalkSpeed },
    Callback = function(v)
        State.WalkSpeed = v
        local h = getHum()
        if h then h.WalkSpeed = v end
    end
})

SecCharMove:Slider({
    Title = "JumpPower",
    Step = 1,
    Value = { Min = 50, Max = 200, Default = State.JumpPower },
    Callback = function(v)
        State.JumpPower = v
        local h = getHum()
        if h then h.JumpPower = v end
    end
})

local SecCharFly = TabChar:Section({ Title = "Fitur Gerak Khusus" })
SecCharFly:Toggle({
    Title = "Fly (W/A/S/D/Space/Shift)",
    Value = State.Fly,
    Callback = function(v)
        State.Fly = v
        if v then enableFly() end
    end
})

SecCharFly:Slider({
    Title = "Fly Speed",
    Step = 5,
    Value = { Min = 20, Max = 150, Default = FLY_SPEED },
    Callback = function(v) FLY_SPEED = v end
})

SecCharFly:Toggle({
    Title = "Noclip (Tembus Tembok)",
    Value = State.Noclip,
    Callback = function(v) State.Noclip = v end
})

SecCharFly:Toggle({
    Title = "Infinite Jump",
    Value = State.InfJump,
    Callback = function(v) State.InfJump = v end
})

SecCharFly:Toggle({
    Title = "Anti-AFK (Cegah Disconnect)",
    Value = State.AntiAFK,
    Callback = function(v) State.AntiAFK = v end
})

-- ────────────────────────────────────────────────────────────────────────────
-- 9. TAB: TELEPORT (📍)
-- ────────────────────────────────────────────────────────────────────────────
end
do
local TabTp = Window:Tab({ Title = "Teleport", Icon = "map-pin" })

local SecTpLoc = TabTp:Section({ Title = "Lokasi Penting" })
SecTpLoc:Button({
    Title = "🌾 Teleport ke Lahan Kebun Saya",
    Callback = function()
        local lahans = getMyLahans()
        if #lahans > 0 then tpToPos(lahans[1].Position) end
    end
})

SecTpLoc:Button({
    Title = "🏪 Teleport ke Kios Stall Saya",
    Callback = function()
        local myKios = Workspace:FindFirstChild("KiosAktif") and Workspace.KiosAktif:FindFirstChild("Kios_" .. LP.Name)
        if myKios then tpToPos(myKios:GetPivot().Position) end
    end
})

SecTpLoc:Button({
    Title = "⛏️ Teleport ke Area Tambang Batu & Pohon",
    Callback = function()
        local bc = Workspace:FindFirstChild("BahanCraft")
        local rock = bc and (bc:FindFirstChild("BatuKecil") or bc:FindFirstChild("BatuSedang"))
        if rock then tpToPos(rock:GetPivot().Position) end
    end
})

SecTpLoc:Button({
    Title = "🐷 Teleport ke Bandar Babi",
    Callback = function()
        local npc = Workspace:FindFirstChild("BandarBabi", true) or Workspace:FindFirstChild("PedagangBabi", true)
        if npc then tpToPos(npc:GetPivot().Position) end
    end
})

SecTpLoc:Button({
    Title = "🏛️ Teleport ke Balai Desa",
    Callback = function()
        local bd = Workspace:FindFirstChild("BalaiDesa", true)
        if bd then tpToPos(bd:GetPivot().Position) end
    end
})

SecTpLoc:Button({
    Title = "🔨 Teleport ke Tempat Tempa (Forge)",
    Callback = function()
        local tg = Workspace:FindFirstChild("Tempa", true) or Workspace:FindFirstChild("PandaiBesi", true)
        if tg then tpToPos(tg:GetPivot().Position) end
    end
})

-- ────────────────────────────────────────────────────────────────────────────
-- 10. TAB: VISUAL & ESP (👁️)
-- ────────────────────────────────────────────────────────────────────────────
end
do
local TabVisual = Window:Tab({ Title = "Visual ESP", Icon = "eye" })
local SecEspItems = TabVisual:Section({ Title = "ESP Item Liar & Alam" })
SecEspItems:Toggle({
    Title = "ESP Jamur, Melati & Kemenyan",
    Desc = "Sorot posisi Jamur, Bunga Melati, & Dupa dengan nama + jarak",
    Value = State.ESP_Items,
    Callback = function(v)
        State.ESP_Items = v
        if not v and not State.ESP_Animals and not State.ESP_Peti and not State.ESP_Mining then
            clearAllESP()
        end
    end
})

local SecEspEntities = TabVisual:Section({ Title = "ESP Hewan & Entitas Gaib" })
SecEspEntities:Toggle({
    Title = "ESP Burung Gagak & Tuyul Liar",
    Desc = "Sorot burung gagak dan tuyul liar di map",
    Value = State.ESP_Animals,
    Callback = function(v)
        State.ESP_Animals = v
        if not v and not State.ESP_Items and not State.ESP_Peti and not State.ESP_Mining then
            clearAllESP()
        end
    end
})

SecEspEntities:Toggle({
    Title = "ESP Peti Arwah (Malam)",
    Desc = "Sorot lokasi Peti Arwah di map",
    Value = State.ESP_Peti,
    Callback = function(v)
        State.ESP_Peti = v
        if not v and not State.ESP_Items and not State.ESP_Animals and not State.ESP_Mining then
            clearAllESP()
        end
    end
})

local SecEspMining = TabVisual:Section({ Title = "ESP Tambang & Batuan" })
SecEspMining:Toggle({
    Title = "ESP Bebatuan Tambang (BahanCraft)",
    Desc = "Sorot batu kecil & sedang di area tambang",
    Value = State.ESP_Mining,
    Callback = function(v)
        State.ESP_Mining = v
        if not v and not State.ESP_Items and not State.ESP_Animals and not State.ESP_Peti then
            clearAllESP()
        end
    end
})

SecEspMining:Slider({
    Title = "Jarak Maksimal ESP (Meter)",
    Step = 25,
    Value = { Min = 50, Max = 800, Default = State.ESP_MaxDist },
    Callback = function(v) State.ESP_MaxDist = v end
})

SecEspMining:Button({
    Title = "🧹 Bersihkan / Reset Semua ESP",
    Callback = function() clearAllESP() end
})

local SecHUD = TabVisual:Section({ Title = "Compact On-Screen Overlay" })
SecHUD:Toggle({
    Title = "Mini-HUD Status Ringkas (Layar)",
    Desc = "Menampilkan widget ringkas di pojok layar: Koin, Slot Kebun, dan Isi Tas",
    Value = State.MiniHUD,
    Callback = function(v)
        State.MiniHUD = v
        if miniHUD and miniHUD.frame then
            miniHUD.frame.Visible = v
        end
    end
})

-- ────────────────────────────────────────────────────────────────────────────
-- 11. TAB: AFK & ANTI-LAG (⚡)
-- ────────────────────────────────────────────────────────────────────────────
end
do
local TabAFK = Window:Tab({ Title = "AFK & Anti-Lag", Icon = "globe" })
local SecAFKPerf = TabAFK:Section({ Title = "Mode Hemat Performa & Anti-DC" })
SecAFKPerf:Toggle({
    Title = "Potato Mode (Anti-Lag 80% FPS Boost)",
    Desc = "Matikan bayangan, efek kabut tebal, & partikel agar ringan 24/7",
    Value = State.PotatoMode,
    Callback = function(v)
        State.PotatoMode = v
        setPotatoMode(v)
    end
})

SecAFKPerf:Toggle({
    Title = "Auto-Reconnect & Anti-DC (Watchdog)",
    Desc = "Otomatis masuk ulang ke game jika koneksi terputus/kick saat AFK",
    Value = State.AutoReconnect,
    Callback = function(v) State.AutoReconnect = v end
})

local SecAFKWeb = TabAFK:Section({ Title = "Discord Webhook Notifier" })
SecAFKWeb:Input({
    Title = "URL Discord Webhook",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(val)
        State.DiscordWebhook = val
        log("Webhook URL diset: " .. val:sub(1, 40) .. "...")
    end
})

SecAFKWeb:Toggle({
    Title = "Auto Kirim Laporan Berkala",
    Desc = "Kirim rekap koin, panen, & level setiap interval ke Discord",
    Value = State.AutoWebhook,
    Callback = function(v) State.AutoWebhook = v end
})

SecAFKWeb:Slider({
    Title = "Interval Kirim Laporan (Menit)",
    Step = 5,
    Value = { Min = 5, Max = 60, Default = State.WebhookInterval },
    Callback = function(v) State.WebhookInterval = v end
})

SecAFKWeb:Button({
    Title = "📨 Kirim Laporan Test ke Discord Sekarang",
    Desc = "Tes pengiriman status live ke Discord channel kamu",
    Callback = function()
        sendDiscordWebhook(State.DiscordWebhook)
    end
})

local SecServerHop = TabAFK:Section({ Title = "Server Hopper & Snipe" })

SecServerHop:Button({
    Title = "🌐 Cari & Masuk Server Sepi (1-5 Player)",
    Desc = "Monopoli seluruh map Pasar Gaib, Peti Arwah, & Tuyul tanpa saingan player lain",
    Callback = function()
        serverHop(true)
    end
})

SecServerHop:Button({
    Title = "🔄 Lompat ke Server Acak (Server Hop)",
    Desc = "Pindah ke server publik lain secara cepat",
    Callback = function()
        serverHop(false)
    end
})

local SecBoostSync = TabAFK:Section({ Title = "Event & 2x Coin Boost Automation" })

SecBoostSync:Toggle({
    Title = "Auto Jual Cuan Saat 2x Coin Boost Aktif",
    Desc = "Otomatis jual massal babi, isi rak kios, & olah unggas seketika saat event 2x koin berjalan di server",
    Value = State.AutoBoostSync,
    Callback = function(v)
        State.AutoBoostSync = v
        if v then task.spawn(autoBoostSyncLoop) end
    end
})

SecBoostSync:Button({
    Title = "⚡ Cek Status 2x Boost Server Sekarang",
    Desc = "Mendeteksi apakah saat ini server sedang dalam masa pengali 2x Koin",
    Callback = function()
        local active = checkCoinBoostActive()
        pcall(function()
            WindUI:Notify({
                Title = "🔥 Status Server Boost",
                Desc = active and "2x Coin Boost sedang AKTIF! Manfaatkan untuk cuan maksimal." or "Tidak ada Coin Boost aktif saat ini.",
                Duration = 4,
                Icon = active and "flame" or "info"
            })
        end)
    end
})
end

-- ────────────────────────────────────────────────────────────────────────────
-- 12. TAB: SETTINGS & TEMA (🎨)
-- ────────────────────────────────────────────────────────────────────────────
do
local TabSettings = Window:Tab({ Title = "Pengaturan", Icon = "settings" })
local SecTheme = TabSettings:Section({ Title = "Tampilan & Tema WindUI" })

local themeNames = {}
pcall(function()
    for name, _ in pairs(WindUI:GetThemes()) do
        table.insert(themeNames, name)
    end
    table.sort(themeNames)
end)
if #themeNames == 0 then
    themeNames = { "Dark", "Rose", "Plant", "Emerald", "Midnight", "Amber", "MonokaiPro" }
end

SecTheme:Dropdown({
    Title = "Tema Antarmuka",
    Values = themeNames,
    Value = WindUI:GetCurrentTheme() or "Dark",
    Callback = function(themeName)
        pcall(function() WindUI:SetTheme(themeName) end)
    end
})

SecTheme:Toggle({
    Title = "Efek Acrylic (Blur Kaca Transparan)",
    Value = true,
    Callback = function(v)
        pcall(function() WindUI:ToggleAcrylic(v) end)
    end
})

local SecConfig = TabSettings:Section({ Title = "📁 Manajemen Profil Config (Multi-Profile)" })

local selectedProfileInput = configRegistry.activeProfile or "Default"
local ddProfileSelect = nil

SecConfig:Paragraph({
    Title = "ℹ️ Sistem Multi-Config",
    Desc = "Tiap script dijalankan, konfigurasi dimulai dari kondisi bersih (Auto-Load MATI secara default). Buat config baru, simpan dengan nama bebas, lalu muat profil mana yang ingin kamu gunakan kapan saja."
})

SecConfig:Input({
    Title = "Nama Profil Config",
    Desc = "Ketik nama profil untuk disimpan (contoh: Farm_Solo, AFK_Dagang, Full_Auto, Default)",
    Value = selectedProfileInput,
    Placeholder = "Nama profil...",
    Callback = function(v)
        if v and v:gsub("%s+", "") ~= "" then
            selectedProfileInput = v:gsub("[^%w_%-]", "")
        end
    end
})

SecConfig:Button({
    Title = "💾 Simpan Config (Save Profile)",
    Desc = "Menyimpan seluruh toggle & pengaturan saat ini ke nama profil di atas",
    Callback = function()
        local target = (selectedProfileInput and selectedProfileInput ~= "") and selectedProfileInput or configRegistry.activeProfile or "Default"
        local ok = saveConfig(target)
        if ok then
            if ddProfileSelect and ddProfileSelect.SetValues then
                ddProfileSelect:SetValues(configRegistry.profiles)
            end
            pcall(function()
                WindUI:Notify({
                    Title = "💾 Profil Tersimpan!",
                    Desc = ("Pengaturan berhasil disimpan ke profil: %s"):format(target),
                    Duration = 3,
                    Icon = "check"
                })
            end)
        else
            pcall(function()
                WindUI:Notify({
                    Title = "Gagal Menyimpan",
                    Desc = "writefile tidak tersedia di executor ini.",
                    Duration = 3,
                    Icon = "alert-circle"
                })
            end)
        end
    end
})

ddProfileSelect = SecConfig:Dropdown({
    Title = "📂 Pilih Profil Tersimpan",
    Desc = "Pilih salah satu profil yang sudah pernah disimpan untuk dimuat",
    Values = configRegistry.profiles,
    Value = configRegistry.activeProfile,
    Callback = function(v)
        configRegistry.activeProfile = v
        selectedProfileInput = v
        saveProfileRegistry()
    end
})

SecConfig:Button({
    Title = "📥 Muat Config Terpilih (Load Profile)",
    Desc = "Menerapkan seluruh pengaturan dari profil yang dipilih di dropdown",
    Callback = function()
        local target = configRegistry.activeProfile or selectedProfileInput or "Default"
        local ok = loadConfig(target)
        if ok then
            pcall(function()
                WindUI:Notify({
                    Title = "📥 Profil Dimuat!",
                    Desc = ("Profil '%s' berhasil dimuat & diterapkan!"):format(target),
                    Duration = 3,
                    Icon = "check"
                })
            end)
        else
            pcall(function()
                WindUI:Notify({
                    Title = "File Tidak Ditemukan",
                    Desc = ("Profil '%s' belum ada atau gagal dibaca."):format(target),
                    Duration = 3,
                    Icon = "alert-circle"
                })
            end)
        end
    end
})

SecConfig:Toggle({
    Title = "⚡ Auto-Load Config Saat Script Dijalankan",
    Desc = "Jika diaktifkan, profil aktif akan otomatis dimuat tiap kamu menjalankan script. (Default: MATI)",
    Value = configRegistry.autoLoad,
    Callback = function(v)
        configRegistry.autoLoad = v
        saveProfileRegistry()
        log("[Config] Auto-Load saat startup diset ke: " .. tostring(v))
    end
})

SecConfig:Button({
    Title = "🗑️ Hapus Profil Terpilih",
    Desc = "Menghapus file profil yang sedang dipilih di dropdown",
    Callback = function()
        local target = configRegistry.activeProfile
        if target == "Default" then
            pcall(function()
                WindUI:Notify({
                    Title = "Tidak Bisa Dihapus",
                    Desc = "Profil 'Default' adalah profil dasar dan tidak dapat dihapus.",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
            end)
            return
        end
        local ok = deleteConfig(target)
        if ok then
            if ddProfileSelect and ddProfileSelect.SetValues then
                ddProfileSelect:SetValues(configRegistry.profiles)
            end
            pcall(function()
                WindUI:Notify({
                    Title = "🗑️ Profil Dihapus",
                    Desc = ("Profil '%s' berhasil dihapus!"):format(target),
                    Duration = 3,
                    Icon = "trash"
                })
            end)
        end
    end
})

SecConfig:Button({
    Title = "⚠️ Reset Semua Fitur ke OFF (Kondisi Bersih)",
    Desc = "Mematikan semua toggle otomasi (Kebun, Dagang, Masak, Tambang, dll)",
    Callback = function()
        for k, _ in pairs(State) do
            if type(State[k]) == "boolean" and k ~= "AntiAFK" then
                State[k] = false
            end
        end
        pcall(function()
            WindUI:Notify({
                Title = "Hub Direset",
                Desc = "Semua fitur otomasi telah dimatikan!",
                Duration = 3,
                Icon = "refresh-cw"
            })
        end)
    end
})

-- ════════════════════════════════════════════════════════════════════════════
end
-- FLOATING MINIMIZE BUBBLE (DRAGGABLE TOGGLE)
-- ════════════════════════════════════════════════════════════════════════════
local UserInputService = UIS or game:GetService("UserInputService")

local function createFloatingBubble()
    local bubbleGui = Instance.new("ScreenGui")
    bubbleGui.Name = "PasarHutanBubble"
    bubbleGui.ResetOnSpawn = false
    bubbleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local targetParent = hui or LP:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    bubbleGui.Parent = targetParent

    local bubbleBtn = Instance.new("TextButton")
    bubbleBtn.Name = "ToggleBubble"
    bubbleBtn.Size = UDim2.fromOffset(50, 50)
    bubbleBtn.Position = UDim2.new(0, 15, 0.5, -25)
    bubbleBtn.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
    bubbleBtn.BackgroundTransparency = 0.08
    bubbleBtn.Text = "🌲"
    bubbleBtn.TextColor3 = Color3.fromRGB(240, 245, 255)
    bubbleBtn.TextSize = 24
    bubbleBtn.Font = Enum.Font.GothamBold
    bubbleBtn.AutoButtonColor = false
    bubbleBtn.Visible = false -- Muncul otomatis saat window di-minimize
    bubbleBtn.Parent = bubbleGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0) -- Lingkaran bulat sempurna (Circular Emblem Logo)
    corner.Parent = bubbleBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(46, 204, 113)
    stroke.Thickness = 1.6
    stroke.Transparency = 0.2
    stroke.Parent = bubbleBtn

    -- Hover effect
    bubbleBtn.MouseEnter:Connect(function()
        stroke.Color = Color3.fromRGB(74, 222, 128)
        bubbleBtn.BackgroundColor3 = Color3.fromRGB(25, 32, 45)
    end)
    bubbleBtn.MouseLeave:Connect(function()
        stroke.Color = Color3.fromRGB(46, 204, 113)
        bubbleBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
    end)

    -- Draggable Logic
    local dragging = false
    local dragInput, dragStart, startPos
    local hasMoved = false

    bubbleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasMoved = false
            dragStart = input.Position
            startPos = bubbleBtn.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    bubbleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                hasMoved = true
            end
            bubbleBtn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Click / Open Window
    bubbleBtn.Activated:Connect(function()
        if not hasMoved then
            pcall(function()
                Window:Open()
            end)
            bubbleBtn.Visible = false
        end
    end)

    -- Sync dengan event Window Open / Close WindUI
    pcall(function()
        Window:OnClose(function()
            bubbleBtn.Visible = true
        end)
        Window:OnOpen(function()
            bubbleBtn.Visible = false
        end)
    end)

    return bubbleBtn
end

local floatBubble = createFloatingBubble()

-- ════════════════════════════════════════════════════════════════════════════
-- COMPACT MINI HUD (ON-SCREEN STATUS)
-- ════════════════════════════════════════════════════════════════════════════
local function createMiniHUD()
    local hudGui = Instance.new("ScreenGui")
    hudGui.Name = "PasarHutanMiniHUD"
    hudGui.ResetOnSpawn = false
    hudGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local targetParent = hui or LP:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    hudGui.Parent = targetParent

    local hudFrame = Instance.new("Frame")
    hudFrame.Name = "HUDFrame"
    hudFrame.Size = UDim2.fromOffset(260, 60)
    hudFrame.Position = UDim2.new(1, -275, 0, 15)
    hudFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
    hudFrame.BackgroundTransparency = 0.25
    hudFrame.Visible = State.MiniHUD
    hudFrame.Parent = hudGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = hudFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(46, 204, 113)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.4
    stroke.Parent = hudFrame

    local lbl1 = Instance.new("TextLabel")
    lbl1.Name = "Line1"
    lbl1.Size = UDim2.new(1, -16, 0, 24)
    lbl1.Position = UDim2.new(0, 8, 0, 4)
    lbl1.BackgroundTransparency = 1
    lbl1.Font = Enum.Font.GothamBold
    lbl1.TextSize = 12
    lbl1.TextColor3 = Color3.fromRGB(240, 245, 255)
    lbl1.TextXAlignment = Enum.TextXAlignment.Left
    lbl1.Text = "🌾 Lahan: Memuat..."
    lbl1.Parent = hudFrame

    local lbl2 = Instance.new("TextLabel")
    lbl2.Name = "Line2"
    lbl2.Size = UDim2.new(1, -16, 0, 24)
    lbl2.Position = UDim2.new(0, 8, 0, 30)
    lbl2.BackgroundTransparency = 1
    lbl2.Font = Enum.Font.GothamMedium
    lbl2.TextSize = 11
    lbl2.TextColor3 = Color3.fromRGB(180, 220, 200)
    lbl2.TextXAlignment = Enum.TextXAlignment.Left
    lbl2.Text = "💰 Koin: 0 | 📦 Tas: 0 item"
    lbl2.Parent = hudFrame

    return {
        gui = hudGui,
        frame = hudFrame,
        line1 = lbl1,
        line2 = lbl2,
        update = function(koin, lv, stats, bagCount)
            if not State.MiniHUD then
                hudFrame.Visible = false
                return
            end
            hudFrame.Visible = true
            local pStr = stats and ("Plot #" .. stats.plotName .. " (" .. stats.current .. "/" .. stats.max .. ")") or "Kebun"
            lbl1.Text = "🌾 Lv." .. tostring(lv) .. " " .. pStr .. " | 🟢 " .. tostring(stats and stats.ready or 0) .. " Siap"
            lbl2.Text = "💰 " .. tostring(koin) .. " Koin | 📦 Tas: " .. tostring(bagCount or 0) .. " bibit/panen"
        end
    }
end

miniHUD = createMiniHUD()

-- Keyboard shortcut untuk toggle UI (RightControl / Insert)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert) then
        if Window.Closed then
            pcall(function() Window:Open() end)
            if floatBubble then floatBubble.Visible = false end
        else
            pcall(function() Window:Close() end)
            if floatBubble then floatBubble.Visible = true end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════
-- REAL-TIME LIVE STATS UPDATER
-- ════════════════════════════════════════════════════════════════════════════
_G.updaterDebug = { count = 0, errors = {}, lastStats = nil }
task.spawn(function()
    while true do
        task.wait(1.5)
        _G.updaterDebug.count = (_G.updaterDebug.count or 0) + 1

        -- 1. Header Ticker & Title Update
        local ls = LP:FindFirstChild("leaderstats")
        local lv = ls and ls:FindFirstChild("Lv")   and ls.Lv.Value   or 1
        local kn = ls and ls:FindFirstChild("Koin") and ls.Koin.Value or 0

        -- 2. Lahan Stats
        local stats = getLahanStats()
        local maxCap = math.max(1, stats.max)
        local pct   = math.floor(math.clamp(stats.current / maxCap, 0, 1) * 100)
        _G.updaterDebug.lastStats = stats
        local ok1, err1 = pcall(function()
            local plotStr = stats.plotName ~= "?" and (" (Plot #" .. stats.plotName .. ")") or ""
            ParaKebun:SetTitle("Lahan Lv." .. stats.level .. plotStr .. " (" .. stats.current .. "/" .. stats.max .. " Slot • " .. pct .. "%)")
            ParaKebun:SetDesc("🟢 " .. stats.ready .. " Siap Panen | 💧 " .. stats.wet .. " Basah | ⚠️ " .. stats.dry .. " Kering | 🪴 " .. stats.empty .. " Kosong\n" .. stats.upgradeInfo)
        end)
        if not ok1 then table.insert(_G.updaterDebug.errors, "ParaKebun: " .. tostring(err1)) end

        -- Smart Auto Upgrade (Lahan & Kios)
        if State.AutoSmartUpLahan and kn >= 2500 then
            pcall(function()
                local lahans = getMyLahans()
                if #lahans > 0 then
                    local p = lahans[1]:FindFirstChild("LahanPrompt", true)
                    if p and p.ActionText:find("Upgrade") and p.Enabled then
                        doUpgradeLahan()
                    end
                end
            end)
        end
        if State.AutoSmartUpKios and kn >= 10000 then
            pcall(function()
                local myKios = Workspace:FindFirstChild("KiosAktif") and Workspace.KiosAktif:FindFirstChild("Kios_" .. LP.Name)
                local p = myKios and myKios:FindFirstChild("pShopUpgrade")
                local prompt = p and p:FindFirstChild("ProximityPrompt", true)
                if prompt and prompt.Enabled then
                    doUpgradeMarket()
                end
            end)
        end

        -- 3. Kios Stats (Auto-Detect Jumlah Rak Dimiliki)
        local slotStats = getKiosSlotStats()
        if slotStats.kiosFound then
            local kLines = {}
            local maxLimit = slotStats.maxSlots or 5
            for i = 1, maxLimit do
                local sInfo = slotStats.slots[i]
                if sInfo and sInfo.owned then
                    local countStr = sInfo.itemCount > 0 and (" (" .. sInfo.itemCount .. ")") or ""
                    table.insert(kLines, "R" .. i .. ": " .. sInfo.itemName .. countStr)
                else
                    table.insert(kLines, "R" .. i .. ": 🔒")
                end
            end
            pcall(function()
                ParaKios:SetTitle("Kios Stall Pasar (" .. slotStats.totalOwned .. "/" .. maxLimit .. " Rak Terbuka • " .. tostring(kn) .. " Koin)")
                ParaKios:SetDesc(table.concat(kLines, " | "))
            end)
            if ParaSlotDetect then
                pcall(function()
                    ParaSlotDetect:SetTitle("📦 Kapasitas: " .. slotStats.totalOwned .. " dari " .. maxLimit .. " Rak Dimiliki")
                    ParaSlotDetect:SetDesc("Strategi: " .. tostring(State.KiosStrategy or "Otomatis (Semua Rak)") .. " • Sistem otomatis mendeteksi & mengisi semua rak aktif secara seamless!")
                end)
            end
            if ddBoxes and #ddBoxes > 0 then
                for i = 1, 10 do
                    local dd = ddBoxes[i]
                    if dd and dd.SetTitle then
                        pcall(function()
                            local sInfo = slotStats.slots[i]
                            local isUnlocked = (sInfo and sInfo.owned) or (i <= slotStats.totalOwned)
                            if isUnlocked then
                                local itName = (sInfo and sInfo.itemName and sInfo.itemName ~= "") and sInfo.itemName or "Kosong"
                                dd:SetTitle(("Rak %d [Aktif • %s]"):format(i, itName))
                            else
                                dd:SetTitle(("Rak %d [🔒 Terkunci • Butuh Upgrade Kios]"):format(i))
                            end
                        end)
                    end
                end
            end
        else
            pcall(function()
                ParaKios:SetTitle("Kios Stall Pasar (" .. tostring(kn) .. " Koin)")
                ParaKios:SetDesc("Kios belum aktif / klaim lapak kios di pasar")
            end)
            if ParaSlotDetect then
                pcall(function()
                    ParaSlotDetect:SetTitle("📦 Kapasitas: Kios Belum Aktif")
                    ParaSlotDetect:SetDesc("Dekati lapak kosong di pasar dan klaim kios kamu.")
                end)
            end
        end

        -- 3.5. Dapur Stats
        if ParaMasak then
            pcall(function()
                local pGui = LP:FindFirstChild("PlayerGui")
                local mGui = pGui and (pGui:FindFirstChild("MemasakGui") or pGui:FindFirstChild("CookingGui"))
                local qText = "Tertutup"
                if mGui and mGui.Enabled then
                    local qLabel = mGui:FindFirstChild("Queue", true) or mGui:FindFirstChild("Antrean", true)
                    if qLabel and qLabel:IsA("TextLabel") then
                        qText = qLabel.Text
                    else
                        qText = "Terbuka"
                    end
                end
                ParaMasak:SetTitle("Dapur Memasak • Target: " .. tostring(State.FavCookTarget or "Semua"))
                ParaMasak:SetDesc("Auto Cook: " .. (State.AutoCook and "🟢 Aktif" or "⚪ Nonaktif") .. " | Fast-Cook: " .. (State.FastCook and "⚡ 2x" or "Normal") .. "\nStatus Menu: " .. qText)
            end)
        end

        -- 4. Tambang Stats
        local beliung = getBeliungTool()
        pcall(function()
            if beliung then
                local dur = beliung:GetAttribute("Dur") or "?"
                local maxD = beliung:GetAttribute("DurMaks") or "?"
                ParaTambang:SetTitle("Alat: " .. beliung.Name)
                ParaTambang:SetDesc("Durabilitas: " .. dur .. " / " .. maxD .. " • Siap menambang")
            else
                ParaTambang:SetTitle("Alat: Belum Ada Beliung")
                ParaTambang:SetDesc("Beli di Toko / nyalakan toggle Auto Beli Beliung")
            end
        end)

        -- 5. Tangkap Liar Stats
        local liarCount = 0
        pcall(function()
            local sb = Workspace:FindFirstChild("SpawnBahan")
            if sb then
                for _, o in ipairs(sb:GetChildren()) do
                    local p = o:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p and p.Enabled then
                        liarCount = liarCount + 1
                    end
                end
            end
        end)
        pcall(function()
            ParaTangkap:SetTitle("Bahan Liar Gratis: " .. liarCount .. " item")
            ParaTangkap:SetDesc("Tersedia: 🐦 Gagak, 🦀 Kepiting, 🪔 Dupa, 🪵 Kemenyan, 🍄 Jamur, 🌸 Melati")
        end)

        -- 6. Kandang Stats
        local lahans = getMyLahans()
        if #lahans > 0 then
            local plot = lahans[1].Parent
            local tLines = {}
            for _, anim in ipairs({"Ayam", "Babi", "Sapi"}) do
                local k = plot and plot:FindFirstChild("Kandang" .. anim)
                local bp = k and k:FindFirstChild("BangunPrompt", true)
                local st = "Belum Siap"
                if bp then st = bp.Enabled and "Siap Bangun!" or "Terkunci" end
                table.insert(tLines, anim .. ": " .. st)
            end
            pcall(function()
                ParaTernak:SetTitle("Kandang Ternak Plot")
                ParaTernak:SetDesc(table.concat(tLines, " • "))
            end)
        end

        -- 7. Update Mini-HUD
        pcall(function()
            if miniHUD and miniHUD.update then
                local bagCount = 0
                for _, cont in ipairs({LP.Character, LP.Backpack}) do
                    if cont then
                        for _, t in ipairs(cont:GetChildren()) do
                            if t:IsA("Tool") then
                                local c = t:GetAttribute("Count") or tonumber(t.Name:match("x(%d+)")) or 1
                                bagCount = bagCount + c
                            end
                        end
                    end
                end
                miniHUD.update(kn, lv, stats, bagCount)
            end
        end)
    end
end)

-- START AUTOMATION LOOPS (Only run if enabled in State/Config)
if State.AutoFarm then
    autoFarmLoop()
end
if State.AutoDagang then
    autoDagangLoop()
end
if State.AutoOlahGagak or State.AutoOlahAyam or State.AutoOlahKopi then
    autoOlahLoop()
end
if isAnyLootActive and isAnyLootActive() then
    autoSafeLootLoop()
end
if State.AutoCook then
    autoCookLoop()
end
if State.AutoCookFav then
    autoCookFavLoop()
end
if State.AutoClaimQuest then
    autoQuestLoop()
end
if State.AutoSellMarket then
    autoSellMarketLoop()
end
if State.AutoSellBabi then
    autoSellBabiLoop()
end
if State.AutoGaibSnipe then
    autoGaibSnipeLoop()
end
if State.AutoPetiSmartPull then
    autoSmartPetiLoop()
end
if State.AutoClaimJatahPeti then
    task.spawn(doClaimJatahPeti)
end
if State.AutoKlaimLencana then
    task.spawn(doKlaimLencana)
end
if State.AutoBoostSync then
    task.spawn(autoBoostSyncLoop)
end
if State.AutoUseGaibBuff then
    task.spawn(autoMaintainGaibBuff)
end
if State.AutoSpendKeahlian then
    task.spawn(function() doSpendKeahlian(State.KeahlianFocus) end)
end
if State.AutoPetiRaceClaim then
    task.spawn(autoPetiRaceLoop)
end
if State.AutoEarlyKandang then
    task.spawn(autoKandangEarlyLoop)
end
if State.AutoGerobakSwap then
    task.spawn(autoGerobakSwapSell)
end
if State.AutoGuildBoostSnipe then
    task.spawn(function()
        while State.AutoGuildBoostSnipe do
            doGuildBoostSnipe()
            task.wait(120)
        end
    end)
end
if State.AutoBruteforceCode then
    task.spawn(autoBruteforceLoop)
end
if State.AutoMiningMultiHit then
    task.spawn(autoMiningMultiHitLoop)
end
if State.AutoSiramOrang then
    task.spawn(autoSiramOrangLoop)
end
if State.AutoTradeBoardSnipe then
    task.spawn(autoTradeBoardSnipeLoop)
end
log("WindUI Edition V10.0 loaded successfully! (All automations respect initial State/Config)")
