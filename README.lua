-- 1. Завантажуємо Bitch Boy V3 (офіційне посилання)
loadstring(game:HttpGet("https://raw.githubusercontent.com/zakater5/LuaRepo/main/YBA/v3.lua"))()

-- 2. Чекаємо завантаження меню (YBA важка, тому даємо 15-20 секунд)
task.wait(18)

-- 3. Функція автоматичного натискання на "Item Auto Farm"
local function autoClickFarm()
    local coreGui = game:GetService("CoreGui")
    local success, err = pcall(function()
        -- Шукаємо по всьому CoreGui, де Bitch Boy ховає своє меню
        for _, gui in pairs(coreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, v in pairs(gui:GetDescendants()) do
                    -- Шукаємо кнопку з ТВОЄЮ назвою
                    if v:IsA("TextButton") and v.Text:find("Item Auto Farm") then
                        -- Емулюємо натискання (MouseButton1Click)
                        -- Використовуємо VirtualInputManager для надійності
                        local x = v.AbsolutePosition.X + (v.AbsoluteSize.X / 2)
                        local y = v.AbsolutePosition.Y + (v.AbsoluteSize.Y / 2) + 36 -- +36 для врахування TopBar
                        
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, true, game, 1)
                        task.wait(0.1)
                        game:GetService("VirtualInputManager"):SendMouseButtonEvent(x, y, 0, false, game, 1)
                        
                        print("✅ Item Auto Farm активовано!")
                        return true
                    end
                end
            end
        end
    end)
    
    if not success then
        warn("Помилка при пошуку кнопки: " .. tostring(err))
    end
    return false
end

-- Запускаємо спробу активації
task.spawn(function()
    -- Робимо 3 спроби з інтервалом у 5 секунд, якщо меню довго вантажиться
    for i = 1, 3 do
        if autoClickFarm() then break end
        task.wait(5)
    end
end)

-- 4. Анти-АФК (щоб не викидало під час фарму)
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
