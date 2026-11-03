-- ==============================================================================
-- URBAN RELOAD - PROFESSIONAL SILENT AIM & COMBAT HUB (FULL FEATURES)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Xóa UI cũ nếu có tránh trùng lặp
if CoreGui:FindFirstChild("UrbanReloadProHub") then
    CoreGui.UrbanReloadProHub:Destroy()
end

-- Master Config
getgenv().UR_Settings = {
    SilentAim = {
        Enabled = false,
        TeamCheck = true,
        CheckWall = true, -- Không bắn xuyên tường (Raycast check)
        HitPart = "UpperTorso", -- Ưu tiên Cổ hoặc Bụng
        FOV = 130,
        ShowFOV = true,
    },
    Aimbot = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2, -- Giữ chuột phải để khóa tâm
        Bone = "UpperTorso", -- Head, Neck, UpperTorso
        Smoothness = 1, -- 1 là khóa cứng ngắt 100%
        FOV = 150,
    },
    ESP = {
        Enabled = true,
        MaxDistance = 150, -- 150 studs (~50m) chuẩn bán kính
    },
    Combat = {
        NoRecoil = true,
    },
    Performance = {
        FPSBoost = false,
    }
}

-- ==============================================================================
-- 1. VÒNG TRÒN FOV CIRCLE CHO SILENT AIM (GIỐNG TRONG VIDEO)
-- ==============================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = getgenv().UR_Settings.SilentAim.FOV
FOVCircle.Color = Color3.fromRGB(0, 255, 128)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8

RunService.RenderStepped:Connect(function()
    if getgenv().UR_Settings.SilentAim.Enabled and getgenv().UR_Settings.SilentAim.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = getgenv().UR_Settings.SilentAim.FOV
        FOVCircle.Position = UserInputService:GetMouseLocation()
    else
        FOVCircle.Visible = false
    end
end)

-- ==============================================================================
-- 2. GIAO DIỆN UI CHUẨN DARK THEME & CỤC TRÒN NỔI FPS
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadProHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 255, 128)
UIStroke.Thickness = 1.5

-- Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleBar.Text = "   URBAN RELOAD // PRO COMBAT HUB"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 13
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

-- Nút Thu Nhỏ (-)
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

-- Cục tròn FPS nổi (Hiện khi tắt menu)
local FPSWidget = Instance.new("TextButton")
FPSWidget.Size = UDim2.new(0, 65, 0, 65)
FPSWidget.Position = UDim2.new(0.05, 0, 0.15, 0)
FPSWidget.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
FPSWidget.TextColor3 = Color3.fromRGB(0, 255, 128)
FPSWidget.Font = Enum.Font.GothamBold
FPSWidget.TextSize = 12
FPSWidget.Text = "60\nFPS"
FPSWidget.Visible = false
FPSWidget.Active = true
FPSWidget.Draggable = true
FPSWidget.Parent = ScreenGui
Instance.new("UICorner", FPSWidget).CornerRadius = UDim.new(1, 0)

local WidgetStroke = Instance.new("UIStroke", FPSWidget)
WidgetStroke.Color = Color3.fromRGB(0, 255, 128)
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

-- Scroll Container
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2.3, 0)
Scroll.ScrollBarThickness = 3
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8)

-- UI Helper Functions
local function AddHeader(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = Color3.fromRGB(0, 255, 128)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Scroll
end

local function AddToggle(text, category, key, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Scroll
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local function refresh()
        local state = getgenv().UR_Settings[category][key]
        Btn.Text = "   " .. text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
        Btn.TextColor3 = state and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(170, 170, 170)
    end
    refresh()

    Btn.MouseButton1Click:Connect(function()
        getgenv().UR_Settings[category][key] = not getgenv().UR_Settings[category][key]
        refresh()
        if callback then callback(getgenv().UR_Settings[category][key]) end
    end)
end

local function AddDropdown(text, category, key, options)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 52)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Frame.Parent = Scroll
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -10, 0, 24)
    Lbl.Position = UDim2.new(0, 10, 0, 2)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text .. ": " .. tostring(getgenv().UR_Settings[category][key])
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Frame

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(1, -20, 0, 22)
    Switch.Position = UDim2.new(0, 10, 0, 26)
    Switch.BackgroundColor3 = Color3.fromRGB(35, 35, 46)
    Switch.Text = "Click để thay đổi"
    Switch.TextColor3 = Color3.fromRGB(120, 200, 255)
    Switch.Font = Enum.Font.Gotham
    Switch.TextSize = 11
    Switch.Parent = Frame
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 4)

    local idx = 1
    Switch.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        getgenv().UR_Settings[category][key] = options[idx]
        Lbl.Text = text .. ": " .. tostring(options[idx])
    end)
end

-- Xây dựng các tính năng trong Menu
AddHeader("=== SILENT AIM (TỰ ĐỘNG BẮN TRÚNG) ===")
AddToggle("Bật Silent Aim", "SilentAim", "Enabled")
AddToggle("Team Check (Không bắn đồng đội)", "SilentAim", "TeamCheck")
AddToggle("Check Tường (Không bắn xuyên vật thể)", "SilentAim", "CheckWall")
AddToggle("Hiển thị vòng FOV", "SilentAim", "ShowFOV")
AddDropdown("Vùng Ngắm Silent Aim", "SilentAim", "HitPart", {"UpperTorso", "Neck", "Head", "LowerTorso"})

AddHeader("=== AIMBOT (KHÓA TÂM) ===")
AddToggle("Bật Aimbot Khóa Cứng Ngắt", "Aimbot", "Enabled")
AddDropdown("Vùng Ngắm Aimbot", "Aimbot", "Bone", {"UpperTorso", "Neck", "Head"})

AddHeader("=== ESP & TỐI ƯU HÓA ===")
AddToggle("ESP Định Vị Player (Bán kính 50m)", "ESP", "Enabled")
AddToggle("Chống Rung Tâm Súng (No Recoil)", "Combat", "NoRecoil")
AddToggle("FPS Boost (Tối ưu mượt game)", "Performance", "FPSBoost", function(state)
    if state then
        game:GetService("Lighting").GlobalShadows = false
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        end
    end
end)


-- ==============================================================================
-- 3. HỆ THỐNG KIỂM TRA TẦM NHÌN (WALL CHECK - KHÔNG XUYÊN TƯỜNG)
-- ==============================================================================
local function IsVisible(targetPart)
    if not getgenv().UR_Settings.SilentAim.CheckWall then return true end
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
-- 4. LOGIC SILENT AIM (BẮN TRÚNG NGƯỜI, ƯU TIÊN CỔ & BỤNG)
-- ==============================================================================
local function GetSilentTarget()
    local target, shortestDist = nil, getgenv().UR_Settings.SilentAim.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not (getgenv().UR_Settings.SilentAim.TeamCheck and player.Team == LocalPlayer.Team) then
                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                    local part = char:FindFirstChild(getgenv().UR_Settings.SilentAim.HitPart)
                    if part and IsVisible(part) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local mousePos = UserInputService:GetMouseLocation()
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < shortestDist then
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

-- Hook hướng đạn Raycast an toàn
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if getgenv().UR_Settings.SilentAim.Enabled and method == "Raycast" then
            local targetPart = GetSilentTarget()
            if targetPart then
                args[2] = (targetPart.Position - args[1]).Unit * 1000
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)
end)


-- ==============================================================================
-- 5. AIMBOT KHÓA CỨNG NGẮT VÀO MỤC TIÊU
-- ==============================================================================
local function GetAimbotTarget()
    local target, shortestDist = nil, getgenv().UR_Settings.Aimbot.FOV
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local bone = player.Character:FindFirstChild(getgenv().UR_Settings.Aimbot.Bone)
                if bone then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(bone.Position)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            target = bone
                        end
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if getgenv().UR_Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(getgenv().UR_Settings.Aimbot.Key) then
        local targetBone = GetAimbotTarget()
        if targetBone then
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetBone.Position)
            if getgenv().UR_Settings.Aimbot.Smoothness <= 1 then
                Camera.CFrame = targetCF
            else
                Camera.CFrame = currentCF:Lerp(targetCF, 1 / getgenv().UR_Settings.Aimbot.Smoothness)
            end
        end
    end
end)


-- ==============================================================================
-- 6. ESP BÁN KÍNH 50M (~150 STUDS)
-- ==============================================================================
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "UR_Pro_ESP"

RunService.RenderStepped:Connect(function()
    espFolder:ClearAllChildren()
    if not getgenv().UR_Settings.ESP.Enabled then return end
    
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
    local localHrp = localChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - localHrp.Position).Magnitude
                if dist <= getgenv().UR_Settings.ESP.MaxDistance then
                    local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local bill = Instance.new("BillboardGui", espFolder)
                        bill.Adornee = hrp
                        bill.Size = UDim2.new(0, 100, 0, 30)
                        bill.AlwaysOnTop = true
                        
                        local txt = Instance.new("TextLabel", bill)
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.fromRGB(255, 60, 60)
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


-- ==============================================================================
-- 7. NO RECOIL (CHỐNG RUNG TÂM SÚNG)
-- ==============================================================================
RunService.Stepped:Connect(function()
    if getgenv().UR_Settings.Combat.NoRecoil then
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

print("Urban Reload Professional Hub Loaded Successfully!")
