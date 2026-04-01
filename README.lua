-- 1. Запуск зашифрованого скрипта
loadstring(game:HttpGet("https://raw.githubusercontent.com/zakater5/LuaRepo/main/YBA/v3.lua"))()

-- 2. Чекаємо початкове завантаження
task.wait(15)

local VIM = game:GetService("VirtualInputManager")
local player = game:GetService("Players").LocalPlayer

local function clickButton(v)
    -- Отримуємо точні координати кнопки на твоєму екрані
    local x = v.AbsolutePosition.X + (v.AbsoluteSize.X / 2)
    local y = v.AbsolutePosition.Y + (v.AbsoluteSize.Y / 2) + 56 -- Додаємо офсет для TopBar мобілок/ПК

    -- Імітуємо натискання (Down -> Wait -> Up)
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    print("🎯 Авто-тап по: " .. v.Text)
end

-- 3. Цикл пошуку кнопки
task.spawn(function()
    local activated = false
    local attempts = 0
    
    while not activated and attempts < 30 do -- Шукаємо протягом 30 секунд
        local coreGui = game:GetService("CoreGui")
        
        -- Перебираємо всі елементи інтерфейсу
        for _, gui in pairs(coreGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, v in pairs(gui:GetDescendants()) do
                    -- Шукаємо саме ту кнопку, яку ти назвав
                    if v:IsA("TextButton") and v.Text:find("Item Auto Farm") then
                        -- Перевіряємо, чи кнопка видима (Visible)
                        if v.Visible and v.AbsolutePosition.Y > 0 then
                            clickButton(v)
                            activated = true
                            break
                        end
                    end
                end
            end
        end
        
        if not activated then
            attempts = attempts + 1
            task.wait(2) -- Чекаємо 2 секунди перед наступною спробою
        end
    end
end)

-- 4. Анти-АФК (щоб не викидало під час роботи фарму)
player.Idled:Connect(function()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0))
end)
