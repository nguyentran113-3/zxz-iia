-- ==============================================================================
-- URBAN RELOAD - DEEP BYPASS & ULTIMATE HARD LOCK AIMBOT SCRIPT
-- ==============================================================================

-- 1. DEEP BYPASS ANTI-CHEAT (Chặn đứng quét CoreGui và Script Executor)
pcall(function()
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then
            return nil
        end
        return old(self, ...)
    end)
end)

pcall(function()
    for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name:lower().endWith and v.Name:lower():find("detector") then
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

-- Xóa UI cũ nếu có tránh trùng lặp
if CoreGui:FindFirstChild("UrbanReloadSecureHub") then
    CoreGui.UrbanReloadSecureHub:Destroy()
end

-- Cấu hình Master Config
getgenv().UR_Config = {
    ESP = {
        Enabled = true,
        MaxDistance = 150, -- 150 studs (~50m)
    },
    Aimbot = {
        Enabled = false,
        Key = Enum.UserInputType.MouseButton2, -- Giữ chuột phải để khóa cứng ngắt
        Bone = "UpperTorso", -- Lựa chọn: Head, Neck, UpperTorso (Ưu tiên Cổ / Bụng)
        Smoothness = 1, -- 1 là khóa cứng ngắt 100%
        FOV = 200,
    },
    Combat = {
        NoRecoil = true,
    }
}

-- ==============================================================================
-- 2. GIAO DIỆN UI & CỤC TRÒN FPS NỔI
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadSecureHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 340)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
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
Title.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Title.Text = "   URBAN RELOAD // SECURE COMBAT HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

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

-- Cục tròn FPS nổi khi tắt menu
local FPSWidget = Instance.new("TextButton")
FPSWidget.Size = UDim2.new(0, 60, 0, 60)
FPSWidget.Position = UDim2.new(0.05, 0, 0.15, 0)
FPSWidget.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
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

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Scroll.ScrollBarThickness = 3
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 8)

local function AddToggle(text, category, key, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 36)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
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
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
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
    Switch.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Switch.Text = "Click để thay đổi bộ phận ngắm"
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

AddToggle("ESP Định Vị Player (50m)", "ESP", "Enabled")
AddToggle("Aimbot Khóa Cứng Ngắt", "Aimbot", "Enabled")
AddDropdown("Vùng Ngắm (Cổ & Bụng)", "Aimbot", "Bone", {"UpperTorso", "Neck", "Head"})
AddToggle("Chống Rung Tâm Súng (No Recoil)", "Combat", "NoRecoil")


-- ==============================================================================
-- 3. AIMBOT HARD LOCK LOGIC
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
            local currentCF = Camera.CFrame
            local targetCF = CFrame.new(currentCF.Position, targetBone.Position)
            if getgenv().UR_Config.Aimbot.Smoothness <= 1 then
                Camera.CFrame = targetCF
            else
                Camera.CFrame = currentCF:Lerp(targetCF, 1 / getgenv().UR_Config.Aimbot.Smoothness)
            end
        end
    end
end)


-- ==============================================================================
-- 4. ESP 50M
-- ==============================================================================
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "UR_Secure_ESP"

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
                if dist <= getgenv().UR_Config.ESP.MaxDistance then
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
-- 5. NO RECOIL
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

print("Urban Reload Secure Hub Loaded Successfully!")
