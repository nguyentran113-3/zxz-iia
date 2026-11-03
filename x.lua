-- ==============================================================================
-- URBAN RELOAD - PURE HEADSHOT SILENT AIM & 200M ESP (NO CAMERA LOCK)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ProtectedGui = gethui and gethui() or CoreGui

if ProtectedGui:FindFirstChild("UrbanReloadPureSilent") then
    ProtectedGui.UrbanReloadPureSilent:Destroy()
end

-- Master Config (Chỉ giữ lại Silent Aim Head & ESP 200m)
getgenv().UR_PureConfig = {
    SilentAim = {
        Enabled = true,
        TeamCheck = true,
        CheckWall = true,        -- Không bắn xuyên tường
        HitPart = "Head",        -- Bắt buộc nhắm trúng ĐẦU 100%
        FOVRadius = 160,         -- Vòng FOV vàng cam
        ShowFOV = true,
    },
    ESP = {
        Enabled = true,
        MaxDistance = 600,       -- Tầm nhìn ESP xa 200m (~600 studs)
    }
}

-- ==============================================================================
-- 1. VÒNG TRÒN FOV VÀNG CAM (AN TOÀN CHO MOBILE)
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadPureSilent"
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
        if getgenv().UR_PureConfig.SilentAim.Enabled and getgenv().UR_PureConfig.SilentAim.ShowFOV then
            local radius = getgenv().UR_PureConfig.SilentAim.FOVRadius
            FOVFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
            FOVFrame.Visible = true
        else
            FOVFrame.Visible = false
        end
    end)
end)

-- ==============================================================================
-- 2. GIAO DIỆN MENU GỌN NHẸ (CHỈ CÓ BẬT/TẮT SILENT AIM & ESP)
-- ==============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 200)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -100)
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
TitleBar.Text = "   URBAN RELOAD // PURE HEADSHOT SILENT"
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
        local state = getgenv().UR_PureConfig[category][key]
        Btn.Text = "   " .. text .. ": " .. (state and "[ ON ]" or "[ OFF ]")
        Btn.TextColor3 = state and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(170, 170, 170)
    end
    refresh()

    Btn.MouseButton1Click:Connect(function()
        getgenv().UR_PureConfig[category][key] = not getgenv().UR_PureConfig[category][key]
        refresh()
    end)
end

AddToggle("Silent Aim (Đầu 100%)", "SilentAim", "Enabled", 45)
AddToggle("Check Tường (Wall Check)", "SilentAim", "CheckWall", 90)
AddToggle("ESP 200m", "ESP", "Enabled", 135)

-- ==============================================================================
-- 3. WALL CHECK AN TOÀN
-- ==============================================================================
local function IsVisible(targetPart)
    if not getgenv().UR_PureConfig.SilentAim.CheckWall then return true end
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
-- 4. TÌM ĐẦU MỤC TIÊU TRONG VÒNG FOV
-- ==============================================================================
local function GetHeadTarget()
    local target, shortestDist = nil, getgenv().UR_PureConfig.SilentAim.FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not (getgenv().UR_PureConfig.SilentAim.TeamCheck and player.Team == LocalPlayer.Team) then
                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                    local head = char:FindFirstChild("Head") -- Chỉ nhắm vào ĐẦU
                    if head and IsVisible(head) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist <= getgenv().UR_PureConfig.SilentAim.FOVRadius and dist < shortestDist then
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
-- 5. PURE SILENT AIM HOOK (ĐẠN TỰ ĐỘNG BẺ VỀ ĐẦU, CAMERA KHÔNG HỀ BỊ KHÓA)
-- ==============================================================================
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldIndex = mt.__index
    
    mt.__index = newcclosure(function(self, key)
        if getgenv().UR_PureConfig.SilentAim.Enabled and not checkcaller() then
            if self == Mouse and (key == "Hit" or key == "Target") then
                local head = GetHeadTarget()
                if head then
                    if key == "Hit" then
                        return head.CFrame
                    elseif key == "Target" then
                        return head
                    end
                end
            end
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)
end)

pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if getgenv().UR_PureConfig.SilentAim.Enabled and not checkcaller() then
            if method == "Raycast" or method == "FindPartOnRay" then
                local head = GetHeadTarget()
                if head then
                    if method == "Raycast" then
                        local origin = args[1]
                        args[2] = (head.Position - origin).Unit * 1000
                    elseif method:find("FindPartOnRay") then
                        local origin = args[1].Origin
                        args[1] = Ray.new(origin, (head.Position - origin).Unit * 1000)
                    end
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        return oldNamecall(self, unpack(args))
    end)
    setreadonly(mt, true)
end)

-- ==============================================================================
-- 6. ESP 200M ỔN ĐỊNH KHÔNG BAO GIỜ MẤT
-- ==============================================================================
local activeESPs = {}

RunService.RenderStepped:Connect(function()
    pcall(function()
        if not getgenv().UR_PureConfig.ESP.Enabled then
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
                    if dist <= getgenv().UR_PureConfig.ESP.MaxDistance then
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

print("Urban Reload Pure Headshot Silent Aim & 200m ESP Loaded!")
