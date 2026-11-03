-- ==============================================================================
-- URBAN RELOAD - 100% STABLE NO-CRASH FOV AIM & ESP
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ProtectedGui = gethui and gethui() or CoreGui

if ProtectedGui:FindFirstChild("UrbanReloadTrueSilentHub") then
    ProtectedGui.UrbanReloadTrueSilentHub:Destroy()
end

-- Master Config
getgenv().UR_SilentConfig = {
    SilentAim = {
        Enabled = true,
        TeamCheck = true,
        CheckWall = true,
        HitPart = "UpperTorso",
        FOVRadius = 160, -- Bán kính FOV
        ShowFOV = true,
    },
    ESP = {
        Enabled = true,
        MaxDistance = 150, -- 150 studs (~50m)
    },
    Combat = {
        NoRecoil = true,
    }
}

-- ==============================================================================
-- 1. SCREEN GUI CHÍNH & VÒNG TRÒN FOV AN TOÀN (DÙNG UI FRAME THAY DRAWING)
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadTrueSilentHub"
ScreenGui.Parent = ProtectedGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Vòng tròn FOV vàng cam bằng Roblox UI (Không bị crash)
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "SafeFOVCircle"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 170, 0) -- Màu vàng cam giống hệt ảnh mẫu[span_1](start_span)[span_1](end_span)
FOVStroke.Thickness = 2
FOVStroke.Transparency = 0.2
FOVStroke.Parent = FOVFrame

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0) -- Biến Frame vuông thành hình tròn
FOVCorner.Parent = FOVFrame

RunService.RenderStepped:Connect(function()
    pcall(function()
        if getgenv().UR_SilentConfig.SilentAim.Enabled and getgenv().UR_SilentConfig.SilentAim.ShowFOV then
            local radius = getgenv().UR_SilentConfig.SilentAim.FOVRadius
            FOVFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
            FOVFrame.Visible = true
        else
            FOVFrame.Visible = false
        end
    end)
end)

-- ==============================================================================
-- 2. GIAO DIỆN UI MENU HUB & CỤC TRÒN FPS
-- ==============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 170, 0)
UIStroke.Thickness = 1.5

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleBar.Text = "   URBAN RELOAD // SAFE FOV AIM HUB"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 13
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Cục tròn FPS nổi
local FPSWidget = Instance.new("TextButton")
FPSWidget.Size = UDim2.new(0, 65, 0, 65)
FPSWidget.Position = UDim2.new(0.05, 0, 0.15, 0)
FPSWidget.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
FPSWidget.TextColor3 = Color3.fromRGB(255, 170, 0)
FPSWidget.Font = Enum.Font.GothamBold
FPSWidget.TextSize = 12
FPSWidget.Text = "60\nFPS"
FPSWidget.Visible = false
FPSWidget.Active = true
FPSWidget.Draggable = true
FPSWidget.Parent = ScreenGui
Instance.new("UICorner", FPSWidget).CornerRadius = UDim.new(1, 0)

local WidgetStroke = Instance.new("UIStroke", FPSWidget)
WidgetStroke.Color = Color3.fromRGB(255, 170, 0)
WidgetStroke.Thickness = 2

local lastTick = tick()
RunService.RenderStepped:Connect(function(dt)
    if FPSWidget.Visible and tick() - lastTick >= 0.3 then
        FPSWidget.Text = math.floor(1 / dt) .. "\nFPS"
        lastTick = tick()
    end
end)

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; FPSWidget.Visible = true end)
FPSWidget.MouseButton1Click:Connect(function() MainFrame.Visible = true; FPSWidget.Visible = false end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2.2, 0)
Scroll.ScrollBarThickness = 3
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8)

local function AddHeader(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = Color3.fromRGB(255, 170, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Scroll
end

local function AddToggle(text, category, key)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Scroll
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local function refresh()
        local state = getgenv().UR_SilentConfig[category][key]
        Btn.Text = "   " .. text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
        Btn.TextColor3 = state and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(170, 170, 170)
    end
    refresh()

    Btn.MouseButton1Click:Connect(function()
        getgenv().UR_SilentConfig[category][key] = not getgenv().UR_SilentConfig[category][key]
        refresh()
    end)
end

AddHeader("=== CÀI ĐẶT FOV & AIM ===")
AddToggle("Bật Hỗ Trợ Aim FOV", "SilentAim", "Enabled")
AddToggle("Team Check (Không khóa đồng đội)", "SilentAim", "TeamCheck")
AddToggle("Check Tường (Vật thể chắn)", "SilentAim", "CheckWall")
AddToggle("Hiển thị vòng FOV Vàng Cam", "SilentAim", "ShowFOV")

AddHeader("=== ESP & TỐI ƯU ===")
AddToggle("ESP Định Vị Player (50m)", "ESP", "Enabled")
AddToggle("Chống Rung Tâm Súng (No Recoil)", "Combat", "NoRecoil")

-- ==============================================================================
-- 3. CHECK VẬT THỂ CHẮN (WALL CHECK AN TOÀN)
-- ==============================================================================
local function IsVisible(targetPart)
    if not getgenv().UR_SilentConfig.SilentAim.CheckWall then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, params)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

-- ==============================================================================
-- 4. TIM MỤC TIÊU TRONG VÒNG FOV & BÁM KHÓA AN TOÀN
-- ==============================================================================
local function GetFOVSilentTarget()
    local target, shortestDist = nil, getgenv().UR_SilentConfig.SilentAim.FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not (getgenv().UR_SilentConfig.SilentAim.TeamCheck and player.Team == LocalPlayer.Team) then
                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                    local part = char:FindFirstChild(getgenv().UR_SilentConfig.SilentAim.HitPart) or char:FindFirstChild("Head")
                    if part and IsVisible(part) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist <= getgenv().UR_SilentConfig.SilentAim.FOVRadius and dist < shortestDist then
                                shortestDist = dist
                                target = part
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if getgenv().UR_SilentConfig.SilentAim.Enabled then
            local targetPart = GetFOVSilentTarget()
            if targetPart and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            end
        end
    end)
end)

-- ==============================================================================
-- 5. ESP 50M AN TOÀN (KHÔNG LỖI MEMORY LEAK)
-- ==============================================================================
local espFolder = Instance.new("Folder", ProtectedGui)
espFolder.Name = "UR_Safe_ESP"

RunService.RenderStepped:Connect(function()
    pcall(function()
        espFolder:ClearAllChildren()
        if not getgenv().UR_SilentConfig.ESP.Enabled then return end
        
        local localChar = LocalPlayer.Character
        if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
        local localHrp = localChar.HumanoidRootPart

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - localHrp.Position).Magnitude
                    if dist <= getgenv().UR_SilentConfig.ESP.MaxDistance then
                        local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            local bill = Instance.new("BillboardGui", espFolder)
                            bill.Adornee = hrp
                            bill.Size = UDim2.new(0, 100, 0, 30)
                            bill.AlwaysOnTop = true
                            
                            local txt = Instance.new("TextLabel", bill)
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Color3.fromRGB(255, 170, 0)
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 11
                            txt.TextStrokeTransparency = 0
                            txt.Text = player.Name .. "\n[" .. math.floor(dist / 3) + 1 .. "m]"
                        end
                    end
                end
            end
        end
    end)
end)

-- ==============================================================================
-- 6. NO RECOIL (CHỐNG RUNG TÂM)
-- ==============================================================================
RunService.Stepped:Connect(function()
    if getgenv().UR_SilentConfig.Combat.NoRecoil then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    for _, v in ipairs(tool:GetDescendants()) do
                        if v.Name:lower():find("recoil") or v.Name:lower():find("camshake") then
                            if v:IsA("NumberValue") then v.Value = 0 end
                        end
                    end
                end
            end
        end)
    end
end)

print("Urban Reload Hub Loaded Successfully!")
