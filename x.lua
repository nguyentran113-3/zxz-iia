-- ==============================================================================
-- URBAN RELOAD - ULTIMATE HARD LOCK AIMBOT & TRUE SILENT AIM SCRIPT
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Xóa UI cũ nếu có
if CoreGui:FindFirstChild("UrbanReloadUltimateHub") then
    CoreGui.UrbanReloadUltimateHub:Destroy()
end

-- Cấu hình Master Config
getgenv().UR_Config = {
    ESP = {
        Enabled = true,
        MaxDistance = 150, -- 150 studs (~50m)
    },
    Aimbot = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2, -- Giữ chuột phải để dính cứng ngắt
        Bone = "Head", -- Head, Neck, UpperTorso
        LockType = "Hard", -- "Hard" (Khóa cứng ngắt) hoặc "Smooth" (Mượt)
        Smoothness = 1, -- Giá trị từ 1 (Cứng ngắt) đến 10 (Mượt)
        FOV = 200,
    },
    SilentAim = {
        Enabled = false,
        HitPart = "UpperTorso", -- Ưu tiên Cổ hoặc Bụng
        CheckWall = true, -- Không bao giờ bắn xuyên tường (Check Raycast)
        FOV = 300,
    },
    Combat = {
        NoRecoil = true,
    }
}

-- ==============================================================================
-- 1. GIAO DIỆN UI & CỤC TRÒN FPS NỔI
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadUltimateHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 390)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -195)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 255, 128)
UIStroke.Thickness = 1.5

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
Title.Text = "   URBAN RELOAD // ULTIMATE COMBAT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = Title
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Cục tròn FPS nổi khi tắt menu
local FPSWidget = Instance.new("TextButton")
FPSWidget.Size = UDim2.new(0, 60, 0, 60)
FPSWidget.Position = UDim2.new(0.05, 0, 0.15, 0)
FPSWidget.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
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

-- Menu Elements Container
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 1.8, 0)
Scroll.ScrollBarThickness = 3
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8)

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
        local state = getgenv().UR_Config[category][key]
        Btn.Text = "   " .. text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
        Btn.TextColor3 = state and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(170, 170, 170)
    end
    refresh()

    Btn.MouseButton1Click:Connect(function()
        getgenv().UR_Config[category][key] = not getgenv().UR_Config[category][key]
        refresh()
        if callback then callback(getgenv().UR_Config[category][key]) end
    end)
end

local function AddDropdown(text, category, key, options)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 55)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Frame.Parent = Scroll
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -10, 0, 25)
    Lbl.Position = UDim2.new(0, 10, 0, 2)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text .. ": " .. tostring(getgenv().UR_Config[category][key])
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Frame

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(1, -20, 0, 22)
    Switch.Position = UDim2.new(0, 10, 0, 26)
    Switch.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    Switch.Text = "Click để thay đổi tùy chọn"
    Switch.TextColor3 = Color3.fromRGB(100, 200, 255)
    Switch.Font = Enum.Font.Gotham
    Switch.TextSize = 11
    Switch.Parent = Frame
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 4)

    local idx = 1
    Switch.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        getgenv().UR_Config[category][key] = options[idx]
        Lbl.Text = text .. ": " .. tostring(options[idx])
    end)
end

-- Xây dựng các nút trong menu
AddToggle("ESP Định Vị Player (50m)", "ESP", "Enabled")
AddToggle("Aimbot Khóa Cứng Ngắt", "Aimbot", "Enabled")
AddDropdown("Vùng Ngắm Aimbot", "Aimbot", "Bone", {"Head", "Neck", "UpperTorso"})

AddToggle("Silent Aim (Tự hút đạn chuẩn xác)", "SilentAim", "Enabled")
AddToggle("Silent Aim Check Tường (Không xuyên vật thể)", "SilentAim", "CheckWall")
AddDropdown("Vùng Ngắm Silent Aim (Cổ / Bụng)", "SilentAim", "HitPart", {"UpperTorso", "Neck", "Head"})

AddToggle("Chống Rung Tâm Súng (No Recoil)", "Combat", "NoRecoil")
AddToggle("Tăng Tốc FPS Boost", "Combat", "NoRecoil", function(state)
    if state then
        game:GetService("Lighting").GlobalShadows = false
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        end
    end
end)


-- ==============================================================================
-- 2. HỆ THỐNG KIỂM TRA TẦM NHÌN (WALL CHECK TRÁNH BẮN XUYÊN TƯỜNG)
-- ==============================================================================
local function IsTargetVisible(targetPart)
    if not getgenv().UR_Config.SilentAim.CheckWall then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(origin, direction, params)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end


-- ==============================================================================
-- 3. LOGIC REAL SILENT AIM (BẮN DÍNH NGƯỜI CHUẨN XÁC)
-- ==============================================================================
local function GetClosestSilentTarget()
    local target, shortestDist = nil, getgenv().UR_Config.SilentAim.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = player.Character:FindFirstChild(getgenv().UR_Config.SilentAim.HitPart)
                if part and IsTargetVisible(part) then
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
    return target
end

-- Hook meta method để hướng đạn tự động bám vào player được chọn (Cổ / Bụng)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if getgenv().UR_Config.SilentAim.Enabled and (method == "Raycast" or method == "FireServer" or method == "fireServer") then
        local targetPart = GetClosestSilentTarget()
        if targetPart and method == "Raycast" then
            args[2] = (targetPart.Position - args[1]).Unit * 1000
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)


-- ==============================================================================
-- 4. LOGIC AIMBOT KHÓA CỨNG NGẮT VÀO MỤC TIÊU
-- ==============================================================================
local function GetAimbotTarget()
    local target, shortestDist = nil, getgenv().UR_Config.Aimbot.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local bone = player.Character:FindFirstChild(getgenv().UR_Config.Aimbot.Bone)
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
    if getgenv().UR_Config.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(getgenv().UR_Config.Aimbot.Key) then
        local targetBone = GetAimbotTarget()
        if targetBone then
            -- Khóa cứng ngắt trực tiếp CFrame Camera nhắm chuẩn vào vị trí chọn (Đầu/Cổ/Bụng)
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetBone.Position)
            
            if getgenv().UR_Config.Aimbot.Smoothness <= 1 then
                Camera.CFrame = targetCF -- Khóa cứng ngắt 100%
            else
                Camera.CFrame = currentCF:Lerp(targetCF, 1 / getgenv().UR_Config.Aimbot.Smoothness)
            end
        end
    end
end)


-- ==============================================================================
-- 5. ESP 50M (HIỂN THỊ KHOẢNG CÁCH CHUẨN)
-- ==============================================================================
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "UR_ESP_Folder"

RunService.RenderStepped:Connect(function()
    espFolder:ClearAllChildren()
    if not getgenv().UR_Config.ESP.Enabled then return end
    
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
    local localHrp = localChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - localHrp.Position).Magnitude
                if dist <= getgenv().UR_Config.UR_Config and dist <= getgenv().UR_Config.ESP.MaxDistance then
                    local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local bill = Instance.new("BillboardGui", espFolder)
                        bill.Adornee = hrp
                        bill.Size = UDim2.new(0, 100, 0, 30)
                        bill.AlwaysOnTop = true
                        
                        local txt = Instance.new("TextLabel", bill)
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = Color3.fromRGB(255, 50, 50)
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 11
                        txt.TextStrokeTransparency = 0
                        txt.Text = player.Name .. "\n[" .. math.floor(dist / 3) .. "m]"
                    end
                end
            end
        end
    end
end)


-- ==============================================================================
-- 6. NO RECOIL (CHỐNG RUNG TÂM SÚNG)
-- ==============================================================================
RunService.Stepped:Connect(function()
    if getgenv().UR_Config.Combat.NoRecoil then
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

print("Urban Reload Ultimate Script Loaded Successfully!")
