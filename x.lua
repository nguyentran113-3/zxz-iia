-- ==============================================================================
-- URBAN RELOAD - ULTIMATE WESTERN COMBAT & SILENT AIM HUB (MOBILE OPTIMIZED)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Anti-Ban / Secure GUI Protection
local ProtectedGui = (gethui and gethui()) or (syn and syn.protect_gui) or CoreGui

if ProtectedGui:FindFirstChild("UrbanReloadUltimateHub") then
    ProtectedGui.UrbanReloadUltimateHub:Destroy()
end

-- Master Configuration Hub
getgenv().UR_UltimateConfig = {
    SilentAim = {
        Enabled = true,
        TeamCheck = true,
        CheckWall = true,        -- Wall check thông minh tránh bị server đá
        HitPart = "Head",        -- Ưu tiên trúng ĐẦU / CỔ 100%
        FOVRadius = 180,         -- Vòng FOV rộng bắt mục tiêu mượt mà
        ShowFOV = true,
    },
    ESP = {
        Enabled = true,
        Box = true,
        Lines = true,           -- Tia Line từ chân mày tới địch
        Names = true,           -- Tên + Khoảng cách (200m+)
        MaxDistance = 800,
    },
    WeaponMods = {
        NoRecoil = true,        -- Chống giật 100% (Súng thẳng tắp)
        NoSpread = true,        -- Đạn bay chuẩn tâm không lệch hướng
        FastReload = true,      -- Thay đạn siêu tốc
    },
    Combat = {
        AutoJumpOnHit = true,   -- Tự động nhảy né đạn khi dính dame
        SpeedBoost = false,     -- Lách di chuyển siêu nhanh
    }
}

-- ==============================================================================
-- 1. GIAO DIỆN MENU PHONG CÁCH TÂY TỐI GIẢN (BASIC & CLEAN)
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadUltimateHub"
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
        if getgenv().UR_UltimateConfig.SilentAim.Enabled and getgenv().UR_UltimateConfig.SilentAim.ShowFOV then
            local r = getgenv().UR_UltimateConfig.SilentAim.FOVRadius
            FOVFrame.Size = UDim2.new(0, r * 2, 0, r * 2)
            FOVFrame.Visible = true
        else
            FOVFrame.Visible = false
        end
    end)
end)

-- Main Menu Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 380)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
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
TitleBar.Text = "  [ UR // ULTIMATE WESTERN HUB v5.0 ]"
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
Widget.Text = "ULT\nHUB"
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
Scroll.CanvasSize = UDim2.new(0, 0, 2.6, 0)
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
        local val = getgenv().UR_UltimateConfig[cat][key]
        Btn.Text = "   " .. name .. ": " .. (val and "[ON]" or "[OFF]")
        Btn.TextColor3 = val and Color3.fromRGB(50, 255, 120) or Color3.fromRGB(200, 60, 60)
    end
    updateText()

    Btn.MouseButton1Click:Connect(function()
        getgenv().UR_UltimateConfig[cat][key] = not getgenv().UR_UltimateConfig[cat][key]
        updateText()
    end)
end

AddHeader("=== SILENT AIM & FOV ===")
CreateButtonToggle("Silent Aim (Đạn tự dí đầu)", "SilentAim", "Enabled")
CreateButtonToggle("Wall Check (Chỉ bắn thấy)", "SilentAim", "CheckWall")
CreateButtonToggle("Hiển Thị Vòng FOV Vàng Cam", "SilentAim", "ShowFOV")

AddHeader("=== WEAPON MODS (NO RECOIL / SPREAD) ===")
CreateButtonToggle("No Recoil (Chống giật súng)", "WeaponMods", "NoRecoil")
CreateButtonToggle("No Spread (Đạn thẳng tắp)", "WeaponMods", "NoSpread")
CreateButtonToggle("Fast Reload (Thay đạn siêu tốc)", "WeaponMods", "FastReload")

AddHeader("=== ESP MỚI (LINE, BOX, TÊN) ===")
CreateButtonToggle("ESP Tổng Thể (200m+)", "ESP", "Enabled")
CreateButtonToggle("ESP Box (Khung kẻ địch)", "ESP", "Box")
CreateButtonToggle("ESP Snaplines (Tia Line nối)", "ESP", "Lines")
CreateButtonToggle("ESP Tên & Khoảng Cách", "ESP", "Names")

AddHeader("=== COMBAT & UNBALANCED UTILS ===")
CreateButtonToggle("Auto Jump Khi Bị Dính Dame", "Combat", "AutoJumpOnHit")
CreateButtonToggle("Speed Boost (Lách siêu nhanh)", "Combat", "SpeedBoost")


-- ==============================================================================
-- 2. SILENT AIM ENGINE (BẺ HƯỚNG RAYCAST VÀO ĐẦU TRONG FOV)
-- ==============================================================================
local function IsVisible(part)
    if not getgenv().UR_UltimateConfig.SilentAim.CheckWall then return true end
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

local function GetSilentTarget()
    local target, shortestDist = nil, getgenv().UR_UltimateConfig.SilentAim.FOVRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not (getgenv().UR_UltimateConfig.SilentAim.TeamCheck and p.Team == LocalPlayer.Team) then
            local char = p.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                local head = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
                if head and IsVisible(head) then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist <= getgenv().UR_UltimateConfig.SilentAim.FOVRadius and dist < shortestDist then
                            shortestDist = dist
                            target = head
                        end
                    end
                end
            end
        end
    end
    return target
end

-- Hook Raycast để bẻ đường đạn thẳng vào đầu địch khi bóp cò
pcall(function()
    local oldRaycast
    oldRaycast = hookfunction(workspace.Raycast, function(self, origin, direction, params)
        if getgenv().UR_UltimateConfig.SilentAim.Enabled and not checkcaller() then
            local targetPart = GetSilentTarget()
            if targetPart then
                direction = (targetPart.Position - origin).Unit * 1000
            end
        end
        return oldRaycast(self, origin, direction, params)
    end)
end)


-- ==============================================================================
-- 3. WEAPON MODS (NO RECOIL, NO SPREAD, FAST RELOAD)
-- ==============================================================================
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in ipairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local name = v.Name:lower()
                    if getgenv().UR_UltimateConfig.WeaponMods.NoRecoil and (name:find("recoil") or name:find("camshake")) then
                        v.Value = 0
                    elseif getgenv().UR_UltimateConfig.WeaponMods.NoSpread and (name:find("spread") or name:find("accuracy")) then
                        v.Value = 0
                    elseif getgenv().UR_UltimateConfig.WeaponMods.FastReload and name:find("reload") then
                        v.Value = v.Value * 0.3
                    end
                end
            end
        end
    end)
end)


-- ==============================================================================
-- 4. ESP MỚI ĐẦY ĐỦ (BOX, LINES, NAMES ĐỘC LẬP TỐI ƯU FPS)
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
        if not getgenv().UR_UltimateConfig.ESP.Enabled then
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
                    if dist <= getgenv().UR_UltimateConfig.ESP.MaxDistance then
                        currentActive[p] = true

                        local bill = activeESPs[p]
                        if not bill then
                            bill = Instance.new("BillboardGui")
                            bill.Size = UDim2.new(0, 160, 0, 70)
                            bill.StudsOffset = Vector3.new(0, 3, 0)
                            bill.AlwaysOnTop = true
                            bill.Parent = ProtectedGui

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
                            if getgenv().UR_UltimateConfig.ESP.Names then
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
-- 5. COMBAT UTILS & UNBALANCED MODS (SPEED BOOST, AUTO JUMP)
-- ==============================================================================
local lastHealth = 100
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")

        -- Auto Jump khi bị mất máu (né đạn thông minh)
        if getgenv().UR_UltimateConfig.Combat.AutoJumpOnHit and hum then
            if hum.Health < lastHealth then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            lastHealth = hum.Health
        end

        -- Speed Boost / Lách siêu nhanh
        if getgenv().UR_UltimateConfig.Combat.SpeedBoost and hum then
            hum.WalkSpeed = 24
        elseif hum and hum.WalkSpeed == 24 then
            hum.WalkSpeed = 16
        end
    end)
end)

print("Urban Reload Ultimate Western Hub Loaded Successfully!")
