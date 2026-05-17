-- V-Protocol: The Ultimate Mathematical Bridge (Fix v11.0)
getgenv().AutoRollByRarity = true
getgenv().BremsleitungGezogen = false

-- EINSTELLUNG: Ab welcher echten Chance stoppen? (z.B. 5000 für alles ab 1 in 5000)
local MindestChance = 5000

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local RollEvent = Remotes:WaitForChild("RollSeeds")
local PlantsModule = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Registry"):WaitForChild("Plants")

-- 1. DIE LIVE-MATHE-DATENBANK ANLEGEN
local success, plantData = pcall(require, PlantsModule)
local BerechneteLiveChancen = {}

-- Diese Funktion sucht im Modul sauber nach der echten Chance (und ignoriert IDs/Preise)
local function extrahiereEchteChance(tabelle)
    for k, v in pairs(tabelle) do
        if type(v) == "number" and v > 0 and v < 1 then
            -- Wir haben die echte Dezimalzahl gefunden! (z.B. 0.00001)
            return v
        elseif type(v) == "table" then
            local ergebnis = extrahiereEchteChance(v)
            if ergebnis then return ergebnis end
        end
    end
    return nil
end

if success and type(plantData) == "table" then
    print("--- V-PROTOCOL: MATHE-DATENBANK WIRD GELADEN ---")
    for plantName, subTable in pairs(plantData) do
        if type(subTable) == "table" then
            local roherDezimalWert = extrahiereEchteChance(subTable)
            if roherDezimalWert then
                -- Umrechnung: 1 / 0.000010 = 100000
                local echteEingetrageneChance = 1 / roherDezimalWert
                BerechneteLiveChancen[plantName] = echteEingetrageneChance
                print(string.format("Mathe-Index: %s -> Echte Chance: 1 in %.1f", tostring(plantName), echteEingetrageneChance))
            end
        end
    end
else
    warn("Kritischer Fehler: Plants-Modul konnte nicht geladen werden!")
end

-- Absolute Sicherheits-Fallbacks direkt von deinen Schildern, falls das Modul laggt
BerechneteLiveChancen["Mushroom"] = 6000
BerechneteLiveChancen["Mango"] = 4269
BerechneteLiveChancen["Bamboo"] = 640
BerechneteLiveChancen["Melon"] = 32

-- 2. DER UNBESTECHLICHE WACHHUND
local Connection
Connection = RollEvent.OnClientEvent:Connect(function(tabelleVonServer)
    if getgenv().BremsleitungGezogen then return end
    
    -- Wir stellen sicher, dass wir die Liste vom Server bekommen
    if type(tabelleVonServer) == "table" then
        for _, pflanzenName in pairs(tabelleVonServer) do
            -- WICHTIG: Wir filtern hier die Positions-Zahlen (1, 2, 3) heraus!
            -- Wir reagieren NUR, wenn an dieser Stelle der Text-Name der Pflanze steht!
            if type(pflanzenName) == "string" then
                
                -- Jetzt holen wir uns die mathematische Chance aus unserer Live-Datenbank!
                local mathematischeChance = BerechneteLiveChancen[pflanzenName] or 0
                
                print("Roll: " .. tostring(pflanzenName) .. " -> Berechnete Seltenheit: 1 in " .. string.format("%.1f", mathematischeChance))
                
                -- DER REINE ZAHLENVERGLEICH
                if mathematischeChance >= MindestChance then
                    print("🎉 🎉 🎉 V-PROTOCOL MATHE-HIT! NOTBREMSE! 🎉 🎉 🎉")
                    print(string.format("-> Pflanze gestoppt: %s (1 in %.1f)", pflanzenName, mathematischeChance))
                    
                    getgenv().BremsleitungGezogen = true
                    getgenv().AutoRollByRarity = false
                    Connection:Disconnect() -- Reißt den Wachhund ab
                    break
                end
            end
        end
    end
end)

-- 3. DER UNAUFHALTBARE BRUTE-FORCE LOOP
task.spawn(function()
    print("🤖 Loop läuft stabil... Suche alles ab 1 in " .. tostring(MindestChance))
    while getgenv().AutoRollByRarity and not getgenv().BremsleitungGezogen do
        pcall(function()
            RollEvent:FireServer()
        end)
        task.wait(0.35) -- Sicherer Intervall gegen Over-Rolling und Kicks
    end
    print("❌ Loop beendet.")
end)
