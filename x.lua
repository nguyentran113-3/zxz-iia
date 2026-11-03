-- ==============================================================================
-- URBAN RELOAD - ADVANCED WESTERN MODULE SILENT AIM & 200M ESP
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ProtectedGui = gethui and gethui() or CoreGui

if ProtectedGui:FindFirstChild("UrbanReloadAdvancedHub") then
    ProtectedGui.UrbanReloadAdvancedHub:Destroy()
end

getgenv().UR_AdvancedConfig = {
    SilentAim = {
        Enabled = true,
        TeamCheck = true,
        CheckWall = true,        -- Bật wall check để không bắn xuyên tường vô lý bị server đá
        HitPart = "Head",        -- Nhắm thẳng vào ĐẦU 100%
        FOVRadius = 180,         -- Vòng FOV rộng rãi
        ShowFOV = true,
    },
    ESP = {
        Enabled = true,
        MaxDistance = 600,       -- ESP tầm xa 200m (~600 studs)
    }
}

-- ==============================================================================
-- 1. VÒNG TRÒN FOV VÀNG CAM
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadAdvancedHub"
ScreenGui.Parent = ProtectedGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "SafeFOVCircle"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 170, 0)
FOVStroke.Thickness = 2
FOVStroke.Transparency = 0.2
FOVStroke.Parent = FOVFrame

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

RunService.RenderStepped:Connect(function()
    pcall(function()
        if getgenv().UR_AdvancedConfig.SilentAim.Enabled and getgenv().UR_AdvancedConfig.SilentAim.ShowFOV then
            local radius = getgenv().UR_AdvancedConfig.SilentAim.FOVRadius
            FOVFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
            FOVFrame.Visible = true
        else
            FOVFrame.Visible = false
        end
    end)
end)

-- ==============================================================================
-- 2. GIAO DIỆN MENU CỰC GỌN (CHỈ CÓ BẬT/TẮT SILENT AIM & ESP)
-- ==============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 180)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -90)
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
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleBar.Text = "   URBAN RELOAD // ADVANCED SILENT HUB"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 11
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local function AddToggle(text, category, key, yPos)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 36)
    Btn.Position = UDim2.new(0, 10, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Parent = MainFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local function refresh()
        local state = getgenv().UR_AdvancedConfig[category][key]
        Btn.Text = "   " .. text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
        Btn.TextColor3 = state and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(170, 170, 170)
    end
    refresh()

    Btn.MouseButton1Click:Connect(function()
        getgenv().UR_AdvancedConfig[category][key] = not getgenv().UR_AdvancedConfig[category][key]
        refresh()
    end)
end

AddToggle("Silent Aim (Đầu 100%)", "SilentAim", "Enabled", 45)
AddToggle("ESP 200m", "ESP", "Enabled", 95)

-- ==============================================================================
-- 3. WALL CHECK AN TOÀN
-- ==============================================================================
local function IsVisible(targetPart)
    if not getgenv().UR_AdvancedConfig.SilentAim.CheckWall then return true end
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
-- 4. TÌM ĐẦU MỤC TIÊU CHUẨN XÁC TRONG FOV
-- ==============================================================================
local function GetBestHeadTarget()
    local target, shortestDist = nil, getgenv().UR_AdvancedConfig.SilentAim.FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not (getgenv().UR_AdvancedConfig.SilentAim.TeamCheck and player.Team == LocalPlayer.Team) then
                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                    local head = char:FindFirstChild("Head")
                    if head and IsVisible(head) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist <= getgenv().UR_AdvancedConfig.SilentAim.FOVRadius and dist < shortestDist then
                                shortestDist = dist
                                target = head
                            end
                        end
                    end
                end
            end
        end
    end
    return target
end

-- ==============================================================================
-- 5. ADVANCED GETGC & UPVALUE HOOK (MÓC SÂU VÀO GỐC XỬ LÝ SÚNG)
-- ==============================================================================
pcall(function()
    if getgc and getupvalues and setupvalue then
        for _, v in pairs(getgc(true)) do
            if typeof(v) == "function" then
                local name = debug.getinfo(v).name
                if name == "fire" or name == "shoot" or name == "Cast" or name == "CreateBullet" or name == "ProcessBullet" then
                    local ups = getupvalues(v)
                    for idx, up in pairs(ups) do
                        if typeof(up) == "table" then
                            RunService.RenderStepped:Connect(function()
                                if getgenv().UR_AdvancedConfig.SilentAim.Enabled then
                                    local head = GetBestHeadTarget()
                                    if head then
                                        pcall(function()
                                            if rawget(up, "MousePos") then
                                                up.MousePos = head.Position
                                            elseif rawget(up, "Destination") then
                                                up.Destination = head.Position
                                            elseif rawget(up, "Direction") then
                                                up.Direction = (head.Position - Camera.CFrame.Position).Unit
                                            end
                                        end)
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- ==============================================================================
-- 6. ESP 200M ỔN ĐỊNH SIÊU MƯỢT
-- ==============================================================================
local activeESPs = {}

RunService.RenderStepped:Connect(function()
    pcall(function()
        if not getgenv().UR_AdvancedConfig.ESP.Enabled then
            for _, gui in pairs(activeESPs) do if gui then gui:Destroy() end end
            activeESPs = {}
            return
        end

        local localChar = LocalPlayer.Character
        if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return end
        local localHrp = localChar.HumanoidRootPart

        local currentPlayers = {}

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - localHrp.Position).Magnitude
                    if dist <= getgenv().UR_AdvancedConfig.ESP.MaxDistance then
                        currentPlayers[player] = true
                        
                        local bill = activeESPs[player]
                        if not bill then
                            bill = Instance.new("BillboardGui")
                            bill.Size = UDim2.new(0, 120, 0, 40)
                            bill.StudsOffset = Vector3.new(0, 2.5, 0)
                            bill.AlwaysOnTop = true
                            bill.Parent = ProtectedGui
                            
                            local txt = Instance.new("TextLabel", bill)
                            txt.Name = "Text"
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Color3.fromRGB(255, 170, 0)
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 12
                            txt.TextStrokeTransparency = 0
                            
                            activeESPs[player] = bill
                        end
                        
                        bill.Adornee = hrp
                        local textLabel = bill:FindFirstChild("Text")
                        if textLabel then
                            textLabel.Text = player.Name .. "\n[" .. math.floor(dist / 3) + 1 .. "m]"
                        end
                    end
                end
            end
        end

        for player, bill in pairs(activeESPs) do
            if not currentPlayers[player] then
                if bill then bill:Destroy() end
                activeESPs[player] = nil
            end
        end
    end)
end)

print("Urban Reload Advanced Memory Silent Aim Loaded Successfully!")
