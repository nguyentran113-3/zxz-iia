-- Greedy Growers Mobile Ultra Script - Powered by WindUI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Load Library WindUI (Tối ưu 100% cho Mobile, Kéo thả & Drag mượt)
local WindUI = loadstring(game:HttpGet("https://tree-hub.verifier.workers.dev/scripts/windui.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Greedy Growers VIP",
    Icon = "zap",
    Author = "Mobile Script",
    Folder = "GreedyGrowersConfig",
    Size = UDim2.fromOffset(360, 240),
    Transparent = true,
    Theme = "Dark"
})

-- NÚT NỔI THU NHỎ / HIỆN MENU TRÊN MOBILE
Window:OpenElement()

local MainTab = Window:Tab({ Title = "Hệ Thống Sét", Icon = "shield-alert" })

-- BIẾN ĐIỀU KHIỂN
local AutoHarvestEnabled = true
local SoundAlertEnabled = true
local MyPlot = nil

MainTab:Toggle({
    Title = "Tự Động Nhặt Cây (Auto Pick)",
    Desc = "Tự nhặt cây tức thì ngay khi sét đánh vào đất bạn",
    Value = true,
    Callback = function(state)
        AutoHarvestEnabled = state
    end
})

MainTab:Toggle({
    Title = "Âm Thanh Cảnh Báo",
    Desc = "Phát tiếng còi khi phát hiện sét",
    Value = true,
    Callback = function(state)
        SoundAlertEnabled = state
    end
})

local StatusParagraph = MainTab:Paragraph({
    Title = "Trạng Thái: 🟢 Đang tìm Plot đất...",
    Desc = "Hệ số cây hiện tại: x1.0"
})

-- 1. TÌM CHÍNH XÁC PLOT ĐẤT CỦA BẠN
local function FindMyPlot()
    local plotsFolder = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("PlotsFolder") or workspace
    for _, plot in pairs(plotsFolder:GetChildren()) do
        local owner = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player")
        if (owner and owner.Value == LocalPlayer) or string.find(plot.Name, LocalPlayer.Name) then
            return plot
        end
    end
    return nil
end

-- 2. HÀM KÍCH HOẠT NHẶT CÂY TỨC THÌ (AUTO COLLECT)
local function AutoPickCrop()
    -- Gửi tín hiệu RemoteEvent về Server
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local name = string.lower(v.Name)
            if string.find(name, "harvest") or string.find(name, "pick") or string.find(name, "collect") or string.find(name, "claim") then
                v:FireServer()
            end
        end
    end

    -- Giả lập bấm nút Nhặt Cây trên màn hình Mobile
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, btn in pairs(pGui:GetDescendants()) do
            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                local txt = string.lower(btn.Name .. (btn:IsA("TextButton") and btn.Text or ""))
                if string.find(txt, "harvest") or string.find(txt, "pick") or string.find(txt, "collect") or string.find(txt, "nhặt") then
                    local pos = btn.AbsolutePosition
                    local size = btn.AbsoluteSize
                    VirtualInputManager:SendTouchEvent(0, pos.X + size.X/2, pos.Y + size.Y/2, 0, game, 0)
                    task.wait(0.02)
                    VirtualInputManager:SendTouchEvent(0, pos.X + size.X/2, pos.Y + size.Y/2, 1, game, 0)
                end
            end
        end
    end
end

-- 3. VÒNG LẶP THEO DÕI SÉT & HỆ SỐ X (CHẠY NGẦM SIÊU TỐC)
task.spawn(function()
    while task.wait(0.05) do
        if not MyPlot or not MyPlot.Parent then
            MyPlot = FindMyPlot()
            if not MyPlot then
                StatusParagraph:SetTitle("Trạng Thái: 🟡 Chưa tìm thấy Plot!")
                StatusParagraph:SetDesc("Vui lòng đứng vào ô đất của bạn.")
            end
        else
            -- Tìm cây trong Plot của bạn
            local myCrop = MyPlot:FindFirstChild("Crop") or MyPlot:FindFirstChildOfClass("Model")
            
            if myCrop then
                -- Đọc chỉ số Multiplier (x)
                local multObj = myCrop:FindFirstChild("Multiplier") or myCrop:FindFirstChild("X") or myCrop:FindFirstChild("Value")
                local currentX = multObj and multObj.Value or "1.0"
                
                -- Bắt sự kiện Sét chỉ nằm trong Plot của BẠN
                local lightningInPlot = false
                for _, obj in pairs(MyPlot:GetDescendants()) do
                    local name = string.lower(obj.Name)
                    if string.find(name, "lightning") or string.find(name, "strike") or string.find(name, "warning") or string.find(name, "thunder") then
                        lightningInPlot = true
                        break
                    end
                end

                if lightningInPlot then
                    StatusParagraph:SetTitle("⚠️ CẢNH BÁO: SÉT ĐÁNH CÂY CỦA BẠN!")
                    StatusParagraph:SetDesc("Đã phát hiện sét tại hệ số: x" .. tostring(currentX))
                    
                    if SoundAlertEnabled then
                        local sound = Instance.new("Sound", game:GetService("SoundService"))
                        sound.SoundId = "rbxassetid://9114223177"
                        sound.Volume = 2
                        sound:Play()
                    end

                    if AutoHarvestEnabled then
                        AutoPickCrop()
                        StatusParagraph:SetTitle("⚡ ĐÃ AUTO NHẶT CÂY THÀNH CÔNG!")
                        StatusParagraph:SetDesc("Đã nhặt cây an toàn ở mức: x" .. tostring(currentX))
                    end
                    task.wait(1.5)
                else
                    StatusParagraph:SetTitle("🟢 Cây an toàn | Đang lớn...")
                    StatusParagraph:SetDesc("Hệ số cây hiện tại: x" .. tostring(currentX))
                end
            else
                StatusParagraph:SetTitle("🟢 Đất trống")
                StatusParagraph:SetDesc("Hãy trồng cây mới để bắt đầu theo dõi.")
            end
        end
    end
end)
