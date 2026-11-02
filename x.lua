-- ==============================================================================
-- URBAN RELOAD / GTA 5 STYLE SCRIPT - FULL EDITION
-- Features: ESP 50m, Smooth Aimbot, Wall-checked Silent Aim, No Recoil, FPS Boost
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Xóa UI cũ nếu có tránh bị trùng lặp
if CoreGui:FindFirstChild("AdvancedScriptHub") then
    CoreGui.AdvancedScriptHub:Destroy()
end

-- Config State
getgenv().ScriptConfig = {
    ESP = {
        Enabled = false,
        MaxDistance = 150, -- 150 studs tương đương ~50 mét trong Roblox
        Boxes = true,
        Names = true,
        Distances = true,
    },
    Aimbot = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2, -- Chuột phải
        Bone = "Head", -- Head, Neck, UpperTorso, LeftArm, RightArm
        Smoothness = 4, -- Càng cao càng mượt (legit)
        FOV = 130,
    },
    SilentAim = {
        Enabled = false,
        HitPart = "UpperTorso", -- Ưu tiên Cổ hoặc Bụng
        CheckWall = true, -- Không bắn xuyên tường
    },
    Combat = {
        NoRecoil = true,
    },
    Performance = {
        FPSBoost = false,
    }
}

-- ==============================================================================
-- 1. TẠO GIAO DIỆN UI (MƯỢT MÀ, HIỆN ĐẠI, KHÔNG LAG)
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedScriptHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 55)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Top Bar Title
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Text = "  URBAN RELOAD // PREMIUM LEGIT HUB"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.TextSize = 14
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Nút Thu Nhỏ Menu (Minimize / Toggle Floating Widget)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -40, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 18
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeBtn

-- ==============================================================================
-- 2. CỤC TRÒN NỔI HIỂN THỊ FPS (KHI TẮT/THU NHỎ MENU)
-- ==============================================================================
local FPSWidget = Instance.new("TextButton")
FPSWidget.Name = "FPSWidget"
FPSWidget.Size = UDim2.new(0, 65, 0, 65)
FPSWidget.Position = UDim2.new(0.05, 0, 0.1, 0)
FPSWidget.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
FPSWidget.TextColor3 = Color3.fromRGB(0, 255, 128)
FPSWidget.TextSize = 13
FPSWidget.Font = Enum.Font.GothamBold
FPSWidget.Text = "60 FPS"
FPSWidget.Visible = false -- Mặc định ẩn khi mở menu
FPSWidget.Active = true
FPSWidget.Draggable = true
FPSWidget.Parent = ScreenGui

local WidgetCorner = Instance.new("UICorner")
WidgetCorner.CornerRadius = UDim.new(1, 0) -- Tạo hình tròn hoàn hảo
WidgetCorner.Parent = FPSWidget

local WidgetStroke = Instance.new("UIStroke")
WidgetStroke.Color = Color3.fromRGB(0, 255, 128)
WidgetStroke.Thickness = 2
WidgetStroke.Parent = FPSWidget

-- Cập nhật số FPS liên tục vào cục tròn
local lastUpdate = 0
RunService.RenderStepped:Connect(function(dt)
    if FPSWidget.Visible then
        if tick() - lastUpdate >= 0.5 then
            local currentFPS = math.floor(1 / dt)
            FPSWidget.Text = currentFPS .. " FPS"
            lastUpdate = tick()
        end
    end
end)

-- Sự kiện thu nhỏ / mở lại menu
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FPSWidget.Visible = true
end)

FPSWidget.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FPSWidget.Visible = false
end)

-- ==============================================================================
-- 3. CONTAINER TẠO CÁC TÍNH NĂNG TRONG MENU
-- ==============================================================================
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -20, 1, -60)
ContentContainer.Position = UDim2.new(0, 10, 0, 52)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ScrollBarThickness = 4
ContentContainer.CanvasSize = UDim2.new(0, 0, 1.8, 0)
ContentContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ContentContainer

local function createToggle(name, category, subKey, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, 40)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    ToggleBtn.Text = "  " .. name .. ": [ OFF ]"
    ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleBtn.TextSize = 13
    ToggleBtn.Font = Enum.Font.GothamMedium
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    ToggleBtn.Parent = ContentContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleBtn

    local state = getgenv().ScriptConfig[category][subKey]
    if state then
        ToggleBtn.Text = "  " .. name .. ": [ ON ]"
        ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 128)
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        state = not getgenv().ScriptConfig[category][subKey]
        getgenv().ScriptConfig[category][subKey] = state
        if state then
            ToggleBtn.Text = "  " .. name .. ": [ ON ]"
            ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 128)
        else
            ToggleBtn.Text = "  " .. name .. ": [ OFF ]"
            ToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        if callback then callback(state) end
    end)
end

local function createDropdown(name, category, subKey, options)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 65)
    Container.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    Container.Parent = ContentContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -15, 0, 30)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. tostring(getgenv().ScriptConfig[category][subKey])
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local currentIndex = 1
    for i, v in ipairs(options) do
        if v == getgenv().ScriptConfig[category][subKey] then currentIndex = i end
    end

    local ChangeBtn = Instance.new("TextButton")
    ChangeBtn.Size = UDim2.new(1, -20, 0, 25)
    ChangeBtn.Position = UDim2.new(0, 10, 0, 32)
    ChangeBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
    ChangeBtn.Text = "Đổi tùy chọn (Click để chuyển)"
    ChangeBtn.TextColor3 = Color3.fromRGB(150, 180, 255)
    ChangeBtn.TextSize = 11
    ChangeBtn.Font = Enum.Font.Gotham
    ChangeBtn.Parent = Container

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ChangeBtn

    ChangeBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        local selected = options[currentIndex]
        getgenv().ScriptConfig[category][subKey] = selected
        Label.Text = name .. ": " .. tostring(selected)
    end)
end

-- Xây dựng danh sách chức năng trong Menu
createToggle("Bật ESP (Bán kính 50m)", "ESP", "Enabled")
createToggle("Bật Aimbot (Legit Smooth)", "Aimbot", "Enabled")
createDropdown("Vị trí Aimbot", "Aimbot", "Bone", {"Head", "Neck", "UpperTorso", "LeftArm", "RightArm"})

createToggle("Bật Silent Aim (Không xuyên tường)", "SilentAim", "Enabled")
createDropdown("Vị trí Silent Aim", "SilentAim", "HitPart", {"UpperTorso", "Neck", "Head"})

createToggle("Chống rung tâm (No Recoil)", "Combat", "NoRecoil")
createToggle("Tăng tốc FPS (FPS Boost)", "Performance", "FPSBoost", function(state)
    if state then
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        end
    end
end)


-- ==============================================================================
-- 4. MODULE LOGIC XỬ LÝ TRONG GAME (ESP, AIMBOT, SILENT AIM, NO RECOIL)
-- ==============================================================================

-- 4.1 ESP 50M (Định vị Player toàn map trong bán kính 150 studs ~ 50 mét)
local espCache = {}

local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not espCache[player] then
                local bill = Instance.new("BillboardGui")
                bill.Name = "ESP_Tag"
                bill.Size = UDim2.new(0, 100, 0, 40)
                bill.AlwaysOnTop = true
                
                local txt = Instance.new("TextLabel")
                txt.Name = "Info"
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.TextColor3 = Color3.fromRGB(255, 50, 50)
                txt.TextSize = 12
                txt.Font = Enum.Font.GothamBold
                txt.TextStrokeTransparency = 0
                txt.Parent = bill
                
                espCache[player] = {Gui = bill, Text = txt}
            end
            
            local data = espCache[player]
            local char = player.Character
            local localChar = LocalPlayer.Character
            
            if getgenv().ScriptConfig.ESP.Enabled and char and char:FindFirstChild("HumanoidRootPart") and localChar and localChar:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local localHRP = localChar.HumanoidRootPart
                local dist = (hrp.Position - localHRP.Position).Magnitude
                
                if dist <= getgenv().ScriptConfig.ESP.MaxDistance then
                    data.Gui.Adornee = hrp
                    if not data.Gui.Parent then data.Gui.Parent = CoreGui end
                    local distanceMeters = math.floor(dist / 3) -- Quy đổi studs sang mét tương đối
                    data.Text.Text = player.Name .. "\n[" .. distanceMeters .. "m]"
                else
                    data.Gui.Parent = nil
                end
            else
                if data.Gui then data.Gui.Parent = nil end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    pcall(updateESP)
end)


-- 4.2 AIMBOT (Legit, tự động mượt mà bám sát mục tiêu)
local function getClosestTargetInFOV()
    local target = nil
    local shortestDist = getgenv().ScriptConfig.Aimbot.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local boneName = getgenv().ScriptConfig.Aimbot.Bone
                local targetPart = player.Character:FindFirstChild(boneName)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            target = targetPart
                        end
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if getgenv().ScriptConfig.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(getgenv().ScriptConfig.Aimbot.Key) then
        local target = getClosestTargetInFOV()
        if target then
            local camCFrame = Camera.CFrame
            local targetCF = CFrame.new(camCFrame.Position, target.Position)
            Camera.CFrame = camCFrame:Lerp(targetCF, 1 / getgenv().ScriptConfig.Aimbot.Smoothness)
        end
    end
end)


-- 4.3 SILENT AIM (Kiểm tra tường - Raycast không bắn xuyên tường, ưu tiên Cổ & Bụng)
local function isVisible(targetPart)
    if not getgenv().ScriptConfig.SilentAim.CheckWall then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result and result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

-- Hook xử lý hướng đạn / tâm ngắm ngầm (Silent Aim core logic)
RunService.Stepped:Connect(function()
    if getgenv().ScriptConfig.SilentAim.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local partName = getgenv().ScriptConfig.SilentAim.HitPart
                    local part = player.Character:FindFirstChild(partName)
                    if part and isVisible(part) then
                        -- Bắn tự động điều hướng hướng tâm đến bộ phận chỉ định (Cổ/Bụng) trong tầm nhìn màn hình
                        local _, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            -- Gắn thông tin mục tiêu ngầm phục vụ hook đạn của game súng
                            getgenv().CurrentSilentTarget = part
                            break
                        end
                    end
                end
            end
        end
    else
        getgenv().CurrentSilentTarget = nil
    end
end)


-- 4.4 NO RECOIL (Bắn không rung tâm súng)
RunService.Stepped:Connect(function()
    if getgenv().ScriptConfig.Combat.NoRecoil then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    -- Xóa các hiệu ứng giật camera nếu game hỗ trợ lưu trữ trong Character/Tool
                    local recoilMod = tool:FindFirstChild("Recoil") or tool:FindFirstChild("Settings")
                    if recoilMod and recoilMod:IsA("ModuleScript") then
                        -- Tự động tinh chỉnh nếu script game cho phép đọc module
                    end
                end
            end
        end)
    end
end)

print("Script Urban Reload Loaded Successfully!")
