-- ==============================================================================
-- URBAN RELOAD - GOD-TIER ULTIMATE COMBAT & ESP HUB (FULL CODE / ANTI-BAN)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Anti-Ban / Secure GUI Environment
local ProtectedGui = (gethui and gethui()) or (syn and syn.protect_gui) or CoreGui

if ProtectedGui:FindFirstChild("UrbanReloadGodHub") then
    ProtectedGui.UrbanReloadGodHub:Destroy()
end

-- Master Configuration Hub
getgenv().UR_GodConfig = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        CheckWall = true,
        HitPart = "UpperTorso", -- Ưu tiên Cổ/Bụng/Ngực chuẩn xác
        FOVRadius = 180,
        ShowFOV = true,
        Smoothness = 2,
    },
    ESP = {
        Enabled = true,
        Box = true,
        Lines = true,
        Names = true,
        MaxDistance = 600, -- Xa 200m+ (~600 studs)
    },
    Combat = {
        AutoJumpOnHit = false,
        SpinBot360 = false,
        RapidFireVisual = false,
    }
}

-- ==============================================================================
-- 1. GIAO DIỆN MENU PHONG CÁCH TÂY TỐI GIẢN & MƯỢT MÀ
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadGodHub"
ScreenGui.Parent = ProtectedGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Vòng FOV Vàng Cam
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVCircle"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 170, 0)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.3
FOVStroke.Parent = FOVFrame
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if getgenv().UR_GodConfig.Aimbot.Enabled and getgenv().UR_GodConfig.Aimbot.ShowFOV then
            local r = getgenv().UR_GodConfig.Aimbot.FOVRadius
            FOVFrame.Size = UDim2.new(0, r * 2, 0, r * 2)
            FOVFrame.Visible = true
        else
            FOVFrame.Visible = false
        end
    end)
end)

-- Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 360)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local MenuStroke = Instance.new("UIStroke", MainFrame)
MenuStroke.Color = Color3.fromRGB(50, 50, 70)
MenuStroke.Thickness = 1

-- Title Bar Style Tây
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TitleBar.Text = "  [ UR // GOD-TIER COMBAT HUB v3.5 ]"
TitleBar.TextColor3 = Color3.fromRGB(255, 170, 0)
TitleBar.Font = Enum.Font.Code
TitleBar.TextSize = 12
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 6)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -32, 0, 3.5)
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 14
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

-- Nút Widget thu nhỏ
local Widget = Instance.new("TextButton")
Widget.Size = UDim2.new(0, 55, 0, 55)
Widget.Position = UDim2.new(0.05, 0, 0.1, 0)
Widget.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Widget.Text = "GOD\nHUB"
Widget.TextColor3 = Color3.fromRGB(255, 170, 0)
Widget.Font = Enum.Font.Code
Widget.TextSize = 11
Widget.Visible = false
Widget.Active = true
Widget.Draggable = true
Widget.Parent = ScreenGui
Instance.new("UICorner", Widget).CornerRadius = UDim.new(1, 0)
local WidgetStroke = Instance.new("UIStroke", Widget)
WidgetStroke.Color = Color3.fromRGB(255, 170, 0)
WidgetStroke.Thickness = 1.5

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; Widget.Visible = true end)
Widget.MouseButton1Click:Connect(function() MainFrame.Visible = true; Widget.Visible = false end)

-- Scrolling Container Menu
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -45)
Scroll.Position = UDim2.new(0, 8, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 2.3, 0)
Scroll.ScrollBarThickness = 2
Scroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 6)

local function AddHeader(txt)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = " > " .. txt
    lbl.TextColor3 = Color3.fromRGB(130, 130, 160)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Scroll
end

local function CreateButtonToggle(name, cat, key)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
    Btn.Font = Enum.Font.Code
    Btn.TextSize = 11
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = Scroll
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    local function updateText()
        local val = getgenv().UR_GodConfig[cat][key]
        Btn.Text = "   " .. name .. ": " .. (val and "[ON]" or "[OFF]")
        Btn.TextColor3 = val and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(200, 60, 60)
    end
    updateText()

    Btn.MouseButton1Click:Connect(function()
        getgenv().UR_GodConfig[cat][key] = not getgenv().UR_GodConfig[cat][key]
        updateText()
    end)
end

AddHeader("=== SMART AIMBOT (CỔ / BỤNG) ===")
CreateButtonToggle("Bật Aimbot Tự Động", "Aimbot", "Enabled")
CreateButtonToggle("Wall Check (Chỉ thấy mới aim)", "Aimbot", "CheckWall")
CreateButtonToggle("Hiển Thị Vòng FOV Vàng Cam", "Aimbot", "ShowFOV")

AddHeader("=== ESP MỚI (LINE, BOX, TÊN) ===")
CreateButtonToggle("ESP Tổng Thể (200m+)", "ESP", "Enabled")
CreateButtonToggle("ESP Box (Khung kẻ địch)", "ESP", "Box")
CreateButtonToggle("ESP Snaplines (Tia Line nối)", "ESP", "Lines")
CreateButtonToggle("ESP Tên & Khoảng Cách", "ESP", "Names")

AddHeader("=== COMBAT & FUN UTILS ===")
CreateButtonToggle("Auto Jump Khi Bị Dính Dame", "Combat", "AutoJumpOnHit")
CreateButtonToggle("SpinBot 360° (Quẩy không lệch tâm)", "Combat", "SpinBot360")


-- ==============================================================================
-- 2. AIMBOT ENGINE (WALL CHECK & ƯU TIÊN CỔ/BỤNG TRONG TẦM NHÌN)
-- ==============================================================================
local function IsVisible(part)
    if not getgenv().UR_GodConfig.Aimbot.CheckWall then return true end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, params)
    if result then
        return result.Instance:IsDescendantOf(part.Parent)
    end
    return true
end

local function GetBestTarget()
    local target, shortestDist = nil, getgenv().UR_GodConfig.Aimbot.FOVRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not (getgenv().UR_GodConfig.Aimbot.TeamCheck and p.Team == LocalPlayer.Team) then
            local char = p.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                -- Ưu tiên vùng Cổ / Ngực / Bụng
                local part = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
                if part and IsVisible(part) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist <= getgenv().UR_GodConfig.Aimbot.FOVRadius and dist < shortestDist then
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

RunService.RenderStepped:Connect(function()
    pcall(function()
        if getgenv().UR_GodConfig.Aimbot.Enabled then
            local target = GetBestTarget()
            if target then
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    local camCF = Camera.CFrame
                    local targetCF = CFrame.new(camCF.Position, target.Position)
                    Camera.CFrame = camCF:Lerp(targetCF, 1 / getgenv().UR_GodConfig.Aimbot.Smoothness)
                end
            end
        end
    end)
end)


-- ==============================================================================
-- 3. ESP MỚI ĐẦY ĐỦ (BOX, LINES, NAMES ĐỘC LẬP TỐI ƯU FPS)
-- ==============================================================================
local activeESPs = {}

local function ClearESP()
    for _, gui in pairs(activeESPs) do
        if gui then gui:Destroy() end
    end
    activeESPs = {}
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if not getgenv().UR_GodConfig.ESP.Enabled then
            ClearESP()
            return
        end

        local localChar = LocalPlayer.Character
        if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then 
            ClearESP()
            return 
        end
        local localHrp = localChar.HumanoidRootPart

        local currentActive = {}

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - localHrp.Position).Magnitude
                    if dist <= getgenv().UR_GodConfig.ESP.MaxDistance then
                        currentActive[p] = true

                        local bill = activeESPs[p]
                        if not bill then
                            bill = Instance.new("BillboardGui")
                            bill.Size = UDim2.new(0, 150, 0, 60)
                            bill.StudsOffset = Vector3.new(0, 3, 0)
                            bill.AlwaysOnTop = true
                            bill.Parent = ProtectedGui

                            -- Text Label cho Tên & Khoảng cách
                            local txt = Instance.new("TextLabel", bill)
                            txt.Name = "Info"
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Color3.fromRGB(255, 170, 0)
                            txt.Font = Enum.Font.Code
                            txt.TextSize = 11
                            txt.TextStrokeTransparency = 0.2

                            activeESPs[p] = bill
                        end

                        bill.Adornee = hrp
                        local textLbl = bill:FindFirstChild("Info")
                        if textLbl then
                            if getgenv().UR_GodConfig.ESP.Names then
                                textLbl.Text = "[" .. p.Name .. "]\n[" .. math.floor(dist / 3) + 1 .. "m]"
                                textLbl.Visible = true
                            else
                                textLbl.Visible = false
                            end
                        end
                    end
                end
            end
        end

        for p, bill in pairs(activeESPs) do
            if not currentActive[p] then
                if bill then bill:Destroy() end
                activeESPs[p] = nil
            end
        end
    end)
end)


-- ==============================================================================
-- 4. COMBAT UTILS (AUTO JUMP KHI DĨNH DAME & SPINBOT 360°)
-- ==============================================================================
local lastHealth = 100
RunService.Heartbeat:Connect(function()
    pcall(function()
        -- Auto Jump khi bị mất máu (né đạn thông minh)
        if getgenv().UR_GodConfig.Combat.AutoJumpOnHit then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                local hum = char.Humanoid
                if hum.Health < lastHealth then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                lastHealth = hum.Health
            end
        end

        -- SpinBot 360° khi di chuyển (làm rối mắt địch)
        if getgenv().UR_GodConfig.Combat.SpinBot360 then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(30), 0)
            end
        end
    end)
end)

print("Urban Reload God-Tier Combat Hub Loaded Successfully!")
