-- Greedy Growers Mobile Native UI (No Library Lag)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Xóa UI cũ nếu có
if game:GetService("CoreGui"):FindFirstChild("GreedyMobileUI") then
    game:GetService("CoreGui").GreedyMobileUI:Destroy()
end

-- 1. TẠO GIAO DIỆN (NATIVE GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GreedyMobileUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Nút nổi thu nhỏ/hiện Menu
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 25
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local ToggleCorner = Instance.new("UICorner", ToggleBtn)
ToggleCorner.CornerRadius = UDim.new(1, 0)

-- Khung Menu Chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 280, 0, 170)
MainFrame.Position = UDim2.new(0.5, -140, 0.4, -85)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local FrameCorner = Instance.new("UICorner", MainFrame)
FrameCorner.CornerRadius = UDim.new(0, 10)

-- Tiêu đề
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "⚡ GREEDY GROWERS VIP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 10)

-- Label Trạng thái & Hệ số X
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: 🟢 Đang tìm Plot..."
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local MultiplierLabel = Instance.new("TextLabel", MainFrame)
MultiplierLabel.Position = UDim2.new(0, 10, 0, 70)
MultiplierLabel.Size = UDim2.new(1, -20, 0, 25)
MultiplierLabel.BackgroundTransparency = 1
MultiplierLabel.Text = "Hệ số cây: x1.0"
MultiplierLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
MultiplierLabel.Font = Enum.Font.SourceSans
MultiplierLabel.TextSize = 14
MultiplierLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Nút Bật/Tắt Auto Pick
local AutoBtn = Instance.new("TextButton", MainFrame)
AutoBtn.Position = UDim2.new(0, 10, 0, 110)
AutoBtn.Size = UDim2.new(1, -20, 0, 40)
AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
AutoBtn.Text = "AUTO NHẶT CÂY: BẬT"
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 15

local BtnCorner = Instance.new("UICorner", AutoBtn)
BtnCorner.CornerRadius = UDim.new(0, 6)

-- Event Bật/Tắt Menu khi bấm nút ⚡
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local AutoHarvest = true
AutoBtn.MouseButton1Click:Connect(function()
    AutoHarvest = not AutoHarvest
    if AutoHarvest then
        AutoBtn.Text = "AUTO NHẶT CÂY: BẬT"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
    else
        AutoBtn.Text = "AUTO NHẶT CÂY: TẮT"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
    end
end)

-- 2. LOGIC TÌM PLOT ĐẤT CỦA BẠN
local MyPlot = nil
local function GetMyPlot()
    local plotsFolder = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("PlotsFolder") or workspace
    for _, plot in pairs(plotsFolder:GetChildren()) do
        local owner = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player")
        if (owner and owner.Value == LocalPlayer) or string.find(plot.Name, LocalPlayer.Name) then
            return plot
        end
    end
    return nil
end

-- 3. HÀM TỰ ĐỘNG NHẶT CÂY
local function AutoPickCrop()
    -- Bắn RemoteEvent
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local name = string.lower(v.Name)
            if string.find(name, "harvest") or string.find(name, "pick") or string.find(name, "collect") then
                v:FireServer()
            end
        end
    end
    -- Click Nút Harvest trên màn hình
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, btn in pairs(pGui:GetDescendants()) do
            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                local txt = string.lower(btn.Name .. (btn:IsA("TextButton") and btn.Text or ""))
                if string.find(txt, "harvest") or string.find(txt, "pick") or string.find(txt, "collect") or string.find(txt, "nhặt") then
                    local pos = btn.AbsolutePosition
                    local size = btn.AbsoluteSize
                    VirtualInputManager:SendTouchEvent(0, pos.X + size.X/2, pos.Y + size.Y/2, 0, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendTouchEvent(0, pos.X + size.X/2, pos.Y + size.Y/2, 1, game, 0)
                end
            end
        end
    end
end

-- 4. VÒNG LẶP QUÉT SÉT & X MULTIPLIER (SIÊU TỐC)
task.spawn(function()
    while task.wait(0.05) do
        if not MyPlot or not MyPlot.Parent then
            MyPlot = GetMyPlot()
            if not MyPlot then
                StatusLabel.Text = "Trạng thái: 🟡 Đang chờ nhận Plot..."
            end
        else
            local crop = MyPlot:FindFirstChild("Crop") or MyPlot:FindFirstChildOfClass("Model")
            if crop then
                local multObj = crop:FindFirstChild("Multiplier") or crop:FindFirstChild("X") or crop:FindFirstChild("Value")
                local currentX = multObj and multObj.Value or "1.0"
                MultiplierLabel.Text = "Hệ số cây: x" .. tostring(currentX)

                -- Bắt sét duy nhất trên Plot của bạn
                local isLightning = false
                for _, obj in pairs(MyPlot:GetDescendants()) do
                    local name = string.lower(obj.Name)
                    if string.find(name, "lightning") or string.find(name, "strike") or string.find(name, "warning") then
                        isLightning = true
                        break
                    end
                end

                if isLightning then
                    StatusLabel.Text = "⚠️ SÉT ĐÁNH TẠI: x" .. tostring(currentX) .. "!"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    
                    if AutoHarvest then
                        AutoPickCrop()
                        StatusLabel.Text = "⚡ ĐÃ NHẶT CÂY THÀNH CÔNG!"
                        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
                    end
                    task.wait(1.5)
                else
                    StatusLabel.Text = "Trạng thái: 🟢 Cây an toàn"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
                end
            else
                StatusLabel.Text = "Trạng thái: 🟢 Đất trống"
                MultiplierLabel.Text = "Hệ số cây: x1.0"
            end
        end
    end
end)
