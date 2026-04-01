local player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

-- Очистка старого GUI
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "YBA_Safe_Fast_V2" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "YBA_Safe_Fast_V2"
local MainFrame = Instance.new("Frame", ScreenGui)
local FarmBtn = Instance.new("TextButton", MainFrame)

MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.85, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 125, 0, 45)
MainFrame.Active = true
MainFrame.Draggable = true

FarmBtn.Size = UDim2.new(0.9, 0, 0.8, 0)
FarmBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
FarmBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FarmBtn.Text = "FARM: OFF"
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.TextSize = 14

_G.ProFarm = false
local ignoredItems = {} -- Таблиця для багнутих предметів

-- Пошук найближчого (з перевіркою на ігнор)
local function getClosestItem()
    local target = nil
    local dist = math.huge
    local items = workspace:FindFirstChild("Item_Spawns") and workspace.Item_Spawns:FindFirstChild("Items")
    
    if items then
        for _, v in pairs(items:GetChildren()) do
            if not ignoredItems[v] and v:IsA("Model") and v:FindFirstChildWhichIsA("BasePart", true) then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local mag = (hrp.Position - v:GetModelCFrame().p).Magnitude
                    if mag < dist then
                        dist = mag
                        target = v
                    end
                end
            end
        end
    end
    return target
end

local function teleport(targetCFrame)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local distance = (hrp.Position - targetCFrame.p).Magnitude
        local info = TweenInfo.new(distance / 350, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, info, {CFrame = targetCFrame})
        tween:Play()
        
        -- Тайм-аут на політ (3 секунди макс)
        local completed = false
        local conn
        conn = tween.Completed:Connect(function() completed = true end)
        
        task.delay(3, function() if not completed then tween:Cancel() end end)
        tween.Completed:Wait()
        if conn then conn:Disconnect() end
    end
end

-- NoClip
RunService.Stepped:Connect(function()
    if _G.ProFarm and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- ЛОГІКА ЗБОРУ
local function startFarming()
    while _G.ProFarm do
        local item = getClosestItem()
        if item then
            local remote = item:FindFirstChild("Remote", true)
            local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
            
            if remote or prompt then
                teleport(item:GetModelCFrame() * CFrame.new(0, 3, 0))
                
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = item:GetModelCFrame()
                    
                    -- Спроба підбору з перевіркою на "зависання"
                    local startTime = tick()
                    while item.Parent and tick() - startTime < 0.7 do
                        if remote then remote:FireServer() end
                        if prompt and fireproximityprompt then fireproximityprompt(prompt) end
                        task.wait(0.1)
                    end
                    
                    -- Якщо предмет все ще тут після 0.7с — він багнутий
                    if item.Parent then
                        ignoredItems[item] = true
                        print("⚠️ Предмет проігноровано (баг)")
                    end
                end
            end
        end
        task.wait(0.2)
    end
end

FarmBtn.MouseButton1Click:Connect(function()
    _G.ProFarm = not _G.ProFarm
    FarmBtn.Text = _G.ProFarm and "FARM: ON" or "FARM: OFF"
    FarmBtn.BackgroundColor3 = _G.ProFarm and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(45, 45, 45)
    
    if _G.ProFarm then
        ignoredItems = {} -- Очищаємо список багів при старті
        task.spawn(startFarming)
    end
end)

-- Анти-АФК
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
