-- ==============================================================================
-- URBAN RELOAD / GTA 5 STYLE - REWRITTEN & FIXED FULL SCRIPT
-- Features: Real Working Silent Aim (Hookmetamethod), Lock Aimbot, ESP 50m, No Recoil, FPS Widget
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Cleanup Old UI
if CoreGui:FindFirstChild("UrbanReloadHubFixed") then
    CoreGui.UrbanReloadHubFixed:Destroy()
end

-- Master Config
getgenv().Config = {
    ESP = {
        Enabled = true,
        MaxDistance = 150, -- 150 studs (~50m)
    },
    Aimbot = {
        Enabled = true,
        Key = Enum.UserInputType.MouseButton2, -- Giữ chuột phải để Aim
        Bone = "Head", -- Head, Neck, UpperTorso, LowerTorso
        Smoothness = 0.2, -- Độ nhạy bám tâm (0.1 - 1, càng lớn bám càng gắt)
        FOV = 150,
    },
    SilentAim = {
        Enabled = true,
        HitPart = "UpperTorso", -- Ưu tiên Bụng / Cổ
        CheckWall = true, -- Kiểm tra vật cản (Không bắn xuyên tường)
        FOV = 200,
    },
    Combat = {
        NoRecoil = true,
    },
    Performance = {
        FPSBoost = false,
    }
}

-- ==============================================================================
-- 1. UI GUI CỰC MƯỢT + CỤC TRÒN NỔI FPS
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadHubFixed"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 255, 150)
UIStroke.Thickness = 1.5

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Title.Text = "   URBAN RELOAD // FIXED AIMBOT & SILENT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

-- Minimize Button (Nút Tắt/Thu Nhỏ)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = Title
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Floating FPS Circle Widget (Cục tròn nổi hiện FPS khi tắt menu)
local FPSWidget = Instance.new("TextButton")
FPSWidget.Size = UDim2.new(0, 60, 0, 60)
FPSWidget.Position = UDim2.new(0.05, 0, 0.15, 0)
FPSWidget.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
FPSWidget.TextColor3 = Color3.fromRGB(0, 255, 150)
FPSWidget.Font = Enum.Font.GothamBold
FPSWidget.TextSize = 12
FPSWidget.Text = "60\nFPS"
FPSWidget.Visible = false
FPSWidget.Active = true
FPSWidget.Draggable = true
FPSWidget.Parent = ScreenGui
Instance.new("UICorner", FPSWidget).CornerRadius = UDim.new(1, 0)

local WidgetStroke = Instance.new("UIStroke", FPSWidget)
WidgetStroke.Color = Color3.fromRGB(0, 255, 150)
WidgetStroke.Thickness = 2

-- Update FPS Continuous
local lastFrame = tick()
RunService.RenderStepped:Connect(function(dt)
    if FPSWidget.Visible then
        if tick() - lastFrame >= 0.3 then
            local fps = math.floor(1 / dt)
            FPSWidget.Text = fps .. "\nFPS"
            lastFrame = tick()
        end
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FPSWidget.Visible = true
end)

FPSWidget.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FPSWidget.Visible = false
end)

-- Scroll Container
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 1.6, 0)
Scroll.ScrollBarThickness = 3
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8)

-- Helper Functions UI
local function AddToggle(text, category, key, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Scroll
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local function updateText()
        local state = getgenv().Config[category][key]
        Btn.Text = "   " .. text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
        Btn.TextColor3 = state and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(180, 180, 180)
    end
    updateText()

    Btn.MouseButton1Click:Connect(function()
        getgenv().Config[category][key] = not getgenv().Config[category][key]
        updateText()
        if callback then callback(getgenv().Config[category][key]) end
    end)
end

local function AddDropdown(text, category, key, options)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 55)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Frame.Parent = Scroll
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -10, 0, 25)
    Lbl.Position = UDim2.new(0, 10, 0, 2)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text .. ": " .. tostring(getgenv().Config[category][key])
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Frame

    local SwitchBtn = Instance.new("TextButton")
    SwitchBtn.Size = UDim2.new(1, -20, 0, 22)
    SwitchBtn.Position = UDim2.new(0, 10, 0, 26)
    SwitchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    SwitchBtn.Text = "Click để đổi bộ phận ngắm"
    SwitchBtn.TextColor3 = Color3.fromRGB(120, 200, 255)
    SwitchBtn.Font = Enum.Font.Gotham
    SwitchBtn.TextSize = 11
    SwitchBtn.Parent = Frame
    Instance.new("UICorner", SwitchBtn).CornerRadius = UDim.new(0, 4)

    local idx = 1
    SwitchBtn.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        getgenv().Config[category][key] = options[idx]
        Lbl.Text = text .. ": " .. tostring(options[idx])
    end)
end

-- Add UI Controls
AddToggle("ESP Định Vị Player (Tối đa 50m)", "ESP", "Enabled")
AddToggle("Bật Aimbot Khóa Tâm", "Aimbot", "Enabled")
AddDropdown("Vùng ngắm Aimbot", "Aimbot", "Bone", {"Head", "Neck", "UpperTorso", "LowerTorso"})

AddToggle("Bật Silent Aim (Tự hút đạn chuẩn 100%)", "SilentAim", "Enabled")
AddToggle("Check Tường Silent Aim (Không xuyên vật thể)", "SilentAim", "CheckWall")
AddDropdown("Vùng ngắm Silent Aim", "SilentAim", "HitPart", {"UpperTorso", "Neck", "Head", "LowerTorso"})

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
-- 2. HỆ THỐNG KIỂM TRA TẦM NHÌN (WALL CHECK & VISIBILITY)
-- ==============================================================================
local function IsVisible(targetPart)
    if not getgenv().Config.SilentAim.CheckWall then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end


-- ==============================================================================
-- 3. LOGIC REAL SILENT AIM (HOOKMETAMETHOD HOOK HƯỚNG ĐẠN THỰC TẾ)
-- ==============================================================================
local function GetClosestTargetForSilent()
    local closest, shortestDist = nil, getgenv().Config.SilentAim.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = player.Character:FindFirstChild(getgenv().Config.SilentAim.HitPart)
                if part and IsVisible(part) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- Hook Raycast & Mouse Index để Silent Aim hoạt động chuẩn xác 100% trong mọi game
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if getgenv().Config.SilentAim.Enabled and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList" or method == "fireServer" or method == "FireServer") then
        local targetPart = GetClosestTargetForSilent()
        if targetPart then
            if method == "Raycast" then
                -- Sửa hướng Raycast gốc bay thẳng tới target part
                args[2] = (targetPart.Position - args[1]).Unit * 1000
                return OldNamecall(self, unpack(args))
            end
        end
    end
    return OldNamecall(self, ...)
end)

local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, key)
    if getgenv().Config.SilentAim.Enabled and self == Mouse and (key == "Hit" or key == "Target") then
        local targetPart = GetClosestTargetForSilent()
        if targetPart then
            if key == "Hit" then
                return targetPart.CFrame
            elseif key == "Target" then
                return targetPart
            end
        end
    end
    return OldIndex(self, key)
end)


-- ==============================================================================
-- 4. LOGIC AIMBOT KHÓA TÂM (HARD & SMOOTH LOCK)
-- ==============================================================================
local function GetAimbotTarget()
    local target, shortestDist = nil, getgenv().Config.Aimbot.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local bone = player.Character:FindFirstChild(getgenv().Config.Aimbot.Bone)
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
    if getgenv().Config.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(getgenv().Config.Aimbot.Key) then
        local targetPart = GetAimbotTarget()
        if targetPart then
            local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
            local mousePos = UserInputService:GetMouseLocation()
            
            -- Can thiệp di chuyển chuột trực tiếp tạo cảm giác aim tự nhiên & chính xác
            local moveX = (targetPos.X - mousePos.X) * getgenv().Config.Aimbot.Smoothness
            local moveY = (targetPos.Y - mousePos.Y) * getgenv().Config.Aimbot.Smoothness
            
            mousemoverel(moveX, moveY)
        end
    end
end)


-- ==============================================================================
-- 5. ESP BAN KINH 50M (OPTIMIZED)
-- ==============================================================================
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "ESP_Container"

RunService.RenderStepped:Connect(function()
    espFolder:ClearAllChildren()
    if not getgenv().Config.ESP.Enabled then return end
    
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
    local localHrp = localChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - localHrp.Position).Magnitude
                if dist <= getgenv().Config.ESP.MaxDistance then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Adornee = hrp
                        billboard.Size = UDim2.new(0, 100, 0, 30)
                        billboard.AlwaysOnTop = true
                        billboard.Parent = espFolder
                        
                        local text = Instance.new("TextLabel", billboard)
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.BackgroundTransparency = 1
                        text.TextColor3 = Color3.fromRGB(255, 60, 60)
                        text.Font = Enum.Font.GothamBold
                        text.TextSize = 11
                        text.TextStrokeTransparency = 0
                        text.Text = player.Name .. "\n[" .. math.floor(dist / 3) .. "m]"
                    end
                end
            end
        end
    end
end)


-- ==============================================================================
-- 6. NO RECOIL (KHÔNG RUNG TÂM SÚNG)
-- ==============================================================================
RunService.Stepped:Connect(function()
    if getgenv().Config.Combat.NoRecoil then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    for _, v in ipairs(tool:GetDescendants()) do
                        if v.Name:lower():find("recoil") or v.Name:lower():find("spread") then
                            if v:IsA("NumberValue") or v:IsA("IntValue") then
                                v.Value = 0
                            end
                        end
                    end
                end
            end
        end)
    end
end)

print("Urban Reload Hub Fully Rewritten & Loaded!")
