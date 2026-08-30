local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Tải giao diện Orion UI
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "⚡ Greedy Growers | Solo Auto-Harvest", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "GreedyGrowersVIP"
})

local MainTab = Window:MakeTab({Name = "Hệ Thống Sét", Icon = "rbxassetid://4483345998"})
local StatusLabel = MainTab:AddLabel("Trạng Thái: 🟢 Đang chờ trồng cây...")

local AutoHarvest = true
local SoundAlert = true

MainTab:AddToggle({
    Name = "Tự Động Thu Hoạch Khi Sét Đánh",
    Default = true,
    Callback = function(Value) AutoHarvest = Value end
})

-- Hàm tìm Plot (Ô đất) của chính người chơi
local function GetMyPlot()
    for _, plot in pairs(workspace:WaitForChild("Plots"):GetChildren()) do
        if plot:FindFirstChild("Owner") and plot.Owner.Value == LocalPlayer then
            return plot
        elseif plot.Name == LocalPlayer.Name then
            return plot
        end
    end
    return nil
end

-- Hàm tự động kích hoạt Nút Harvest (Bán cây) của bản thân
local function HarvestMyCrop()
    -- Cách 1: Fire RemoteEvent Harvest (Thay tên RemoteEvent chuẩn nếu game dùng Remote)
    local harvestRemote = ReplicatedStorage:FindFirstChild("Harvest", true) or ReplicatedStorage:FindFirstChild("SellCrop", true)
    if harvestRemote and harvestRemote:IsA("RemoteEvent") then
        harvestRemote:FireServer()
    end

    -- Cách 2: Giả lập bấm nút Thu hoạch trên màn hình GUI
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, btn in pairs(pGui:GetDescendants()) do
            if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                if string.find(string.lower(btn.Name), "harvest") or string.find(string.lower(btn.Name), "sell") then
                    for _, signal in pairs({"MouseButton1Click", "Activated"}) do
                        pcall(function() firesignal(btn[signal]) end)
                    end
                end
            end
        end
    end
end

-- Theo dõi ô đất của riêng bạn
task.spawn(function()
    while task.wait(0.1) do
        local myPlot = GetMyPlot()
        if myPlot then
            local crop = myPlot:FindFirstChild("Crop") or myPlot:FindFirstChildOfClass("Model")
            if crop then
                -- Đang có cây trên ô đất
                local multValue = crop:FindFirstChild("Multiplier") or crop:FindFirstChild("X")
                local currentX = multValue and multValue.Value or 1
                
                -- Bắt sự kiện Sét đánh nhắm VÀO CÂY CỦA BẠN (Kiểm tra Object Sét nằm trong Plot của bạn)
                local lightningInMyPlot = false
                for _, obj in pairs(myPlot:GetDescendants()) do
                    local name = string.lower(obj.Name)
                    if string.find(name, "lightning") or string.find(name, "strike") or string.find(name, "warning") then
                        lightningInMyPlot = true
                        break
                    end
                end

                if lightningInMyPlot then
                    StatusLabel:Set("⚠️ SÉT ĐÁNH CÂY CỦA BẠN TẠI: x" .. tostring(currentX) .. "!")
                    
                    if AutoHarvest then
                        HarvestMyCrop()
                        StatusLabel:Set("⚡ ĐÃ TỰ ĐỘNG THU HOẠCH TẠI x" .. tostring(currentX) .. "!")
                    end
                    task.wait(2)
                else
                    StatusLabel:Set("🟢 Cây đang lớn | Hệ số hiện tại: x" .. tostring(currentX))
                end
            else
                StatusLabel:Set("🟢 Đã thu hoạch / Đang chờ trồng cây mới...")
            end
        end
    end
end)

OrionLib:Init()
