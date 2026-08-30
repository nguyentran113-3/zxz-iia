-- Greedy Growers Fix UI & Auto Collect
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

if game:GetService("CoreGui"):FindFirstChild("GreedyMobileUI") then
    game:GetService("CoreGui").GreedyMobileUI:Destroy()
end

-- 1. NATIVE GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GreedyMobileUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 160)
MainFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "⚡ GREEDY GROWERS FIX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.Size = UDim2.new(1, -20, 0, 22)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: 🟢 Đang theo dõi..."
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local MultiplierLabel = Instance.new("TextLabel", MainFrame)
MultiplierLabel.Position = UDim2.new(0, 10, 0, 65)
MultiplierLabel.Size = UDim2.new(1, -20, 0, 22)
MultiplierLabel.BackgroundTransparency = 1
MultiplierLabel.Text = "Hệ số cây: Chưa nhận"
MultiplierLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
MultiplierLabel.Font = Enum.Font.SourceSans
MultiplierLabel.TextSize = 14
MultiplierLabel.TextXAlignment = Enum.TextXAlignment.Left

local AutoBtn = Instance.new("TextButton", MainFrame)
AutoBtn.Position = UDim2.new(0, 10, 0, 100)
AutoBtn.Size = UDim2.new(1, -20, 0, 45)
AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
AutoBtn.Text = "AUTO NHẶT CÂY: BẬT"
AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 15
Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 6)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local AutoHarvest = true
AutoBtn.MouseButton1Click:Connect(function()
    AutoHarvest = not AutoHarvest
    AutoBtn.Text = AutoHarvest and "AUTO NHẶT CÂY: BẬT" or "AUTO NHẶT CÂY: TẮT"
    AutoBtn.BackgroundColor3 = AutoHarvest and Color3.fromRGB(0, 170, 100) or Color3.fromRGB(170, 50, 50)
end)

-- 2. THAO TÁC NHẶT CÂY (SƯU TẦM)
local function AutoPickCrop()
    -- Cách 1: Bấm nút "Sưu tầm" / "Nhặt" trên màn hình Gui
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, btn in pairs(pGui:GetDescendants()) do
            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                local txt = string.lower(btn.Name .. (btn:IsA("TextButton") and btn.Text or ""))
                if string.find(txt, "sưu tầm") or string.find(txt, "suu tam") or string.find(txt, "nhặt") or string.find(txt, "harvest") or string.find(txt, "collect") then
                    local pos = btn.AbsolutePosition
                    local size = btn.AbsoluteSize
                    VirtualInputManager:SendTouchEvent(0, pos.X + size.X/2, pos.Y + size.Y/2, 0, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendTouchEvent(0, pos.X + size.X/2, pos.Y + size.Y/2, 1, game, 0)
                end
            end
        end
    end
    
    -- Cách 2: Kích hoạt ProximityPrompt (Vòng tròn bấm giữ nhặt cây trên đất)
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(prompt) end)
        end
    end
end

-- 3. QUÉT SÉT & HỆ SỐ X GẦN NHẤT
task.spawn(function()
    while task.wait(0.05) do
        local foundCrop = nil
        local foundX = nil

        -- Tìm BillboardGui chứa chữ "x" (Ví dụ: 4.75x trong ảnh) ở khu vực gần người chơi
        for _, gui in pairs(workspace:GetDescendants()) do
            if gui:IsA("TextLabel") and string.find(string.lower(gui.Text), "x") then
                local parentModel = gui:FindFirstAncestorOfClass("Model")
                if parentModel and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (parentModel:GetPivot().Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 25 then -- Chỉ kiểm tra cây trong bán kính ô đất của bạn
                        foundCrop = parentModel
                        foundX = gui.Text
                        break
                    end
                end
            end
        end

        if foundCrop then
            MultiplierLabel.Text = "Hệ số cây: " .. tostring(foundX)
            
            -- Kiểm tra xem Sét có đánh vào cây này không
            local isLightning = false
            for _, obj in pairs(foundCrop:GetDescendants()) do
                local name = string.lower(obj.Name)
                if string.find(name, "lightning") or string.find(name, "strike") or string.find(name, "warning") or string.find(name, "red") then
                    isLightning = true
                    break
                end
            end

            if isLightning then
                StatusLabel.Text = "⚠️ CẢNH BÁO SÉT ĐÁNH!"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                if AutoHarvest then
                    AutoPickCrop()
                    StatusLabel.Text = "⚡ ĐÃ BẤM SƯU TẦM CÂY!"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
                end
                task.wait(1)
            else
                StatusLabel.Text = "Trạng thái: 🟢 Cây đang lớn"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
            end
        else
            StatusLabel.Text = "Trạng thái: 🟢 Đất trống"
            MultiplierLabel.Text = "Hệ số cây: Chưa nhận"
        end
    end
end)
