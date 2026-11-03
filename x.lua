-- ==============================================================================
-- URBAN RELOAD - ADVANCED WESTERN MODULE SILENT AIM (GETGC HOOK)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ProtectedGui = gethui and gethui() or CoreGui

if ProtectedGui:FindFirstChild("UrbanReloadProHub") then
    ProtectedGui.UrbanReloadProHub:Destroy()
end

getgenv().UR_ProConfig = {
    SilentAim = {
        Enabled = true,
        TeamCheck = true,
        HitPart = "UpperTorso",
        FOVRadius = 160,
        ShowFOV = true,
    },
    ESP = {
        Enabled = true,
        MaxDistance = 150,
    },
    Combat = {
        NoRecoil = true,
    }
}

-- ==============================================================================
-- 1. VÒNG TRÒN FOV VÀNG CAM
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UrbanReloadProHub"
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
        if getgenv().UR_ProConfig.SilentAim.Enabled and getgenv().UR_ProConfig.SilentAim.ShowFOV then
            local radius = getgenv().UR_ProConfig.SilentAim.FOVRadius
            FOVFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
            FOVFrame.Visible = true
        else
            FOVFrame.Visible = false
        end
    end)
end)

-- ==============================================================================
-- 2. TÌM MỤC TIÊU TRONG FOV
-- ==============================================================================
local function GetBestTarget()
    local target, shortestDist = nil, getgenv().UR_ProConfig.SilentAim.FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not (getgenv().UR_ProConfig.SilentAim.TeamCheck and player.Team == LocalPlayer.Team) then
                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                    local part = char:FindFirstChild(getgenv().UR_ProConfig.SilentAim.HitPart) or char:FindFirstChild("Head")
                    if part then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist <= getgenv().UR_ProConfig.SilentAim.FOVRadius and dist < shortestDist then
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

-- ==============================================================================
-- 3. HOOK MODULE SÚNG BẰNG GETGC (CÁCH TỤI TÂY LÁCH SERVER)
-- ==============================================================================
pcall(function()
    if getgc and getupvalues and setupvalue then
        for _, v in pairs(getgc(true)) do
            if typeof(v) == "function" then
                local name = debug.getinfo(v).name
                if name == "fire" or name == "shoot" or name == "Cast" or name == "CreateBullet" then
                    local ups = getupvalues(v)
                    for idx, up in pairs(ups) do
                        if typeof(up) == "table" then
                            -- Thay đổi các biến hướng dẫn đường đạn ngầm trong table của súng
                            RunService.RenderStepped:Connect(function()
                                if getgenv().UR_ProConfig.SilentAim.Enabled then
                                    local target = GetBestTarget()
                                    if target and rawget(up, "Camera") or rawget(up, "MousePos") then
                                        pcall(function()
                                            up.MousePos = target.Position
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
-- 4. ESP 50M ỔN ĐỊNH KHÔNG CHỚP NHÁY
-- ==============================================================================
local activeESPs = {}

RunService.RenderStepped:Connect(function()
    pcall(function()
        if not getgenv().UR_ProConfig.ESP.Enabled then
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
                    if dist <= getgenv().UR_ProConfig.ESP.MaxDistance then
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

-- ==============================================================================
-- 5. NO RECOIL
-- ==============================================================================
RunService.Stepped:Connect(function()
    if getgenv().UR_ProConfig.Combat.NoRecoil then
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

print("Urban Reload Pro Western Script Loaded!")
