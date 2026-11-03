-- ==============================================================================
-- URBAN RELOAD - ULTIMATE BYPASS & FOV SILENT AIM HUB (FIXED KICK)
-- ==============================================================================

-- 1. HỆ THỐNG BYPASS ANTI-CHEAT CHUYÊN SÂU (CHẶN QUÉT EXECUTOR & KICK)
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" or tostring(self):lower():find("anticheat") or tostring(self):lower():find("detector") then
            return nil
        end
        return oldNamecall(self, ...)
    end)
end)

pcall(function()
    for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name:lower():find("detect") or v.Name:lower():find("anti") then
            v:Destroy()
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Xóa UI cũ nếu có
if CoreGui:FindFirstChild("UrbanReloadUltimateBypassHub") then
    CoreGui.UrbanReloadUltimateBypassHub:Destroy()
end

-- Master Config
getgenv().UR_BypassConfig = {
    SilentAim = {
        Enabled = false,
        TeamCheck = true,
        CheckWall = true, -- Không bắn xuyên tường (Wall Check)
        HitPart = "UpperTorso", -- Ưu tiên Cổ hoặc Bụng
        FOVRadius = 150, -- Bán kính vòng tròn FOV tùy chỉnh to nhỏ
        ShowFOV = true,
    },
    ESP = {
        Enabled = true,
        MaxDistance = 150, -- 150 studs (~50m chuẩn bán kính)
    },
    Combat = {
        NoRecoil = true,
    }
}

-- ==============================================================================
-- 2. VÒNG TRÒN FOV CỐ ĐỊNH GIỮA MÀN HÌNH (MÀU VÀNG CAM)
-- ==============================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = getgenv().UR_BypassConfig.SilentAim.FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 170, 0) -- Màu vàng cam y hệt mẫu
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 0.9

RunService.RenderStepped:Connect(function()
    if getgenv().UR_BypassConfig.SilentAim.Enabled and getgenv().UR_BypassConfig.SilentAim.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = getgenv().UR_BypassConfig.SilentAim.FOVRadius
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        FOVCircle.Visible = false
    end
end)

-- ==============================================================================
-- 3. GIAO DIỆN UI & CỤC TRÒN NỔI FPS
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadUltimateBypassHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 380)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -190)
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
TitleBar.Text = "   URBAN RELOAD // SECURE BYPASS HUB"
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

-- Cục tròn FPS nổi khi tắt menu
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
        local state = getgenv().UR_BypassConfig[category][key]
        Btn.Text = "   " .. text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
        Btn.TextColor3 = state and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(170, 170, 170)
    end
    refresh()

    Btn.MouseButton1Click:Connect(function()
        getgenv().UR_BypassConfig[category][key] = not getgenv().UR_BypassConfig[category][key]
        refresh()
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
    Lbl.Text = text .. ": " .. tostring(getgenv().UR_BypassConfig[category][key])
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Frame

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(1, -20, 0, 22)
    Switch.Position = UDim2.new(0, 10, 0, 26)
    Switch.BackgroundColor3 = Color3.fromRGB(35, 35, 46)
    Switch.Text = "Click để đổi bộ phận"
    Switch.TextColor3 = Color3.fromRGB(120, 200, 255)
    Switch.Font = Enum.Font.Gotham
    Switch.TextSize = 11
    Switch.Parent = Frame
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 4)

    local idx = 1
    Switch.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        getgenv().UR_BypassConfig[category][key] = options[idx]
        Lbl.Text = text .. ": " .. tostring(options[idx])
    end)
end

AddHeader("=== SILENT AIM (VÒNG TRÒN FOV) ===")
AddToggle("Bật Silent Aim (Trong Vòng FOV)", "SilentAim", "Enabled")
AddToggle("Team Check (Không bắn đồng đội)", "SilentAim", "TeamCheck")
AddToggle("Check Tường (Không bắn xuyên vật thể)", "SilentAim", "CheckWall")
AddToggle("Hiển thị vòng FOV", "SilentAim", "ShowFOV")
AddDropdown("Vùng Ngắm Silent Aim", "SilentAim", "HitPart", {"UpperTorso", "Neck", "Head"})

AddHeader("=== ESP & TỐI ƯU ===")
AddToggle("ESP Định Vị Player (50m)", "ESP", "Enabled")
AddToggle("Chống Rung Tâm Súng (No Recoil)", "Combat", "NoRecoil")


-- ==============================================================================
-- 4. WALL CHECK (KHÔNG XUYÊN TƯỜNG)
-- ==============================================================================
local function IsVisible(targetPart)
    if not getgenv().UR_BypassConfig.SilentAim.CheckWall then return true end
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
-- 5. LOGIC SILENT AIM BẮN TRONG VÒNG TRÒN FOV
-- ==============================================================================
local function GetFOVSilentTarget()
    local target, shortestDist = nil, getgenv().UR_BypassConfig.SilentAim.FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not (getgenv().UR_BypassConfig.SilentAim.TeamCheck and player.Team == LocalPlayer.Team) then
                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                    local part = char:FindFirstChild(getgenv().UR_BypassConfig.SilentAim.HitPart)
                    if part and IsVisible(part) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist <= getgenv().UR_BypassConfig.SilentAim.FOVRadius and dist < shortestDist then
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

pcall(function()
    local mouseMt = getrawmetatable(Mouse)
    setreadonly(mouseMt, false)
    local oldMouseIndex = mouseMt.__index
    mouseMt.__index = newcclosure(function(self, key)
        if getgenv().UR_BypassConfig.SilentAim.Enabled then
            local targetPart = GetFOVSilentTarget()
            if targetPart then
                if key == "Hit" then
                    return targetPart.CFrame
                elseif key == "Target" then
                    return targetPart
                end
            end
        end
        return oldMouseIndex(self, key)
    end)
end)


-- ==============================================================================
-- 6. ESP 50M
-- ==============================================================================
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "UR_Bypass_ESP"

RunService.RenderStepped:Connect(function()
    espFolder:ClearAllChildren()
    if not getgenv().UR_BypassConfig.ESP.Enabled then return end
    
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
    local localHrp = localChar.HumanoidRootPart

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - localHrp.Position).Magnitude
                if dist <= getgenv().UR_BypassConfig.ESP.MaxDistance then
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


-- ==============================================================================
-- 7. NO RECOIL
-- ==============================================================================
RunService.Stepped:Connect(function()
    if getgenv().UR_BypassConfig.Combat.NoRecoil then
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

print("Urban Reload Secure Bypass Hub Loaded!")
