-- 1. Запуск самого Bitch Boy
loadstring(game:HttpGet("https://raw.githubusercontent.com/zakater5/LuaRepo/main/YBA/v3.lua"))()

-- 2. Чекаємо завантаження (збільшив час для надійності)
task.wait(20)

-- 3. Спроба активувати через прапорці (Flags)
local function forceEnableFarm()
    -- Перебираємо стандартні назви глобальних таблиць, які юзають топ-скрипти
    local settings_tables = {_G.Settings, _G.Config, shared.Settings, shared.Config}
    
    for _, tbl in pairs(settings_tables) do
        if tbl then
            -- Пробуємо всі можливі назви для автофарму предметів
            tbl["Item Auto Farm"] = true
            tbl["ItemFarm"] = true
            tbl["AutoFarmItems"] = true
            tbl["Items"] = true
            print("✅ Спроба активації через Settings таблицю")
        end
    end

    -- Спроба через бібліотеку прапорців (Rayfield/Lucid style)
    if _G.Rayfield and _G.Rayfield.Flags then
        for i, v in pairs(_G.Rayfield.Flags) do
            if i:find("Item") or i:find("Farm") then
                v:Set(true)
                print("✅ Активовано через Rayfield Flag: " .. i)
            end
        end
    end
end

-- Запускаємо активацію кілька разів
task.spawn(function()
    for i = 1, 5 do
        pcall(forceEnableFarm)
        task.wait(3)
    end
end)

-- 4. Анти-АФК
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
