-- Tối ưu cho Mobile (Delta, Fluxus, Hydrogen, Codex...)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Load Library UI chuẩn Mobile (Kavo UI)
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("⚡ Greedy Growers Mobile VIP", "Midnight")

-- TAB CHÍNH
local MainTab = Window:NewTab("⚡ Auto Harvest")
local MainSection = MainTab:NewSection("Hệ Thống Bắt Sét & Nhặt Cây")

-- BIẾN ĐIỀU KHIỂN
local AutoHarvestEnabled = true
local MyPlot = nil

MainSection:NewToggle("Tự Động Nhặt Cây (Auto Pick)", "Tự nhặt cây khi phát hiện sét ở plot của bạn", function(state)
    AutoHarvestEnabled = state
end)

local StatusLabel = MainSection:NewLabel("Trạng thái: 🟢 Đang tìm Plot của bạn...")
local MultiplierLabel = MainSection:NewLabel("Hệ số hiện tại: x1.0")

-- 1. HÀM TÌM PLOT ĐẤT CỦA BẠN (TỰ ĐỘNG CHÍNH XÁC)
local function FindMyPlot()
    local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("PlotsFolder") or workspace
    for _, plot in pairs(plots:GetChildren()) do
        -- Kiểm tra Owner qua Value hoặc Tên
        local ownerVal = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player")
        if (ownerVal and ownerVal.Value == LocalPlayer) or string.find(plot.Name, LocalPlayer.Name) then
            return plot
        end
    end
    return nil
end

-- 2. HÀM KÍCH HOẠT NHẶT CÂY TỰ ĐỘNG (MOBILE COMPATIBLE)
local function AutoPickCrop()
    -- Cách 1: Gửi Remote Event trực tiếp về Server (Nhanh nhất)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and (string.find(string.lower(v.Name), "harvest") or string.find(string.lower(v.Name), "pick") or string.find(string.lower(v.Name), "collect")) then
            v:FireServer()
        end
    end

    -- Cách 2: Tự động bấm nút Harvest trên GUI Mobile
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        for _, btn in pairs(pGui:GetDescendants()) do
            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                local btnText = string.lower(btn.Name .. (btn:IsA("TextButton") and btn.Text or ""))
                if string.find(btnText, "harvest") or string.find(btnText, "pick") or string.find(btnText, "collect") or string.find(btnText, "nhặt") then
                    -- Mô phỏng thao tác chạm màn hình Mobile
                    local pos = btn.AbsolutePosition
                    local size = btn.AbsoluteSize
                    VirtualInputManager:SendTouchEvent(0, pos.X + size.X/2, pos.Y + size.Y/2, 0, game, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendTouchEvent(0, pos.X + size.X/2, pos.Y + size.Y/2, 1, game, 0)
                end
            end
        end
    end
end

-- 3. VÒNG LẶP THEO DÕI SÉT & HỆ SỐ X (CHẠY NGẦM KHÔNG LAG)
task.spawn(function()
    while task.wait(0.1) do
        if not MyPlot or not MyPlot.Parent then
            MyPlot = FindMyPlot()
            if not MyPlot then
                StatusLabel:UpdateLabel("Trạng thái: 🟡 Đang chờ bạn nhận Plot đất...")
            end
        else
            -- Tìm cây đang trồng trong Plot của bạn
            local myCrop = MyPlot:FindFirstChild("Crop") or MyPlot:FindFirstChildOfClass("Model")
            
            if myCrop then
                -- Lấy hệ số X (Multiplier)
                local multObj = myCrop:FindFirstChild("Multiplier") or myCrop:FindFirstChild("X") or myCrop:FindFirstChild("Value")
                local currentX = multObj and multObj.Value or "1.0"
                MultiplierLabel:UpdateLabel("Hệ số cây hiện tại: x" .. tostring(currentX))
                
                -- Kiểm tra SÉT chỉ xuất hiện TRONG PLOT CỦA BẠN
                local lightningDetected = false
                for _, obj in pairs(MyPlot:GetDescendants()) do
                    local objName = string.lower(obj.Name)
                    if string.find(objName, "lightning") or string.find(objName, "strike") or string.find(objName, "warning") or string.find(objName, "danger") then
                        lightningDetected = true
                        break
                    end
                end

                if lightningDetected then
                    StatusLabel:UpdateLabel("⚠️ CẢNH BÁO: SÉT ĐÁNH CÂY CỦA BẠN TẠI x" .. tostring(currentX) .. "!")
                    
                    if AutoHarvestEnabled then
                        AutoPickCrop()
                        StatusLabel:UpdateLabel("⚡ ĐÃ NHẶT CÂY THÀNH CÔNG TẠI x" .. tostring(currentX) .. "!")
                    end
                    task.wait(1.5)
                else
                    StatusLabel:UpdateLabel("🟢 Cây an toàn | Đang lớn...")
                end
            else
                StatusLabel:UpdateLabel("🟢 Đất trống | Hãy trồng cây mới...")
                MultiplierLabel:UpdateLabel("Hệ số hiện tại: x1.0")
            end
        end
    end
end)
