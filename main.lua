local CoreGui = game:GetService("CoreGui")
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local RollEvent = Remotes:WaitForChild("RollSeeds")
local BuyEvent = Remotes:WaitForChild("BuySeed")
local PlantsModule = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Registry"):WaitForChild("Plants")

if CoreGui:FindFirstChild("VProtocolRollUI") then CoreGui.VProtocolRollUI:Destroy() end

getgenv().AutoRollActive = false
getgenv().AutoBuyActive = false
getgenv().SelectedTiers = {["Secret"] = true, ["Exotic"] = true, ["Divine"] = true, ["Prismatic"] = true}
getgenv().StopMode = "OrBetter"

local success, plantData = pcall(require, PlantsModule)
local PflanzenSeltenheiten = {}
if success and type(plantData) == "table" then
    for name, data in pairs(plantData) do
        if type(data) == "table" and data.Rarity then
            PflanzenSeltenheiten[name] = data.Rarity
        end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VProtocolRollUI"
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 510)
Main.Position = UDim2.new(0.5, -160, 0.5, -255)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 2
Main.BorderColor3 = Color3.fromRGB(0, 255, 150)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -35, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "  V-PROTOCOL MULTI-ROLL & BUY"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -35, 0, 0)
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 16
Close.Parent = Main
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 40)
ToggleBtn.Position = UDim2.new(0, 10, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
ToggleBtn.Text = "AUTO-ROLL: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 15
ToggleBtn.Parent = Main

local BuyBtn = Instance.new("TextButton")
BuyBtn.Size = UDim2.new(1, -20, 0, 35)
BuyBtn.Position = UDim2.new(0, 10, 0, 90)
BuyBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 15)
BuyBtn.Text = "AUTO-BUY: OFF"
BuyBtn.TextColor3 = Color3.fromRGB(255, 180, 100)
BuyBtn.Font = Enum.Font.SourceSansBold
BuyBtn.TextSize = 14
BuyBtn.Parent = Main

local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(1, -20, 0, 30)
ModeBtn.Position = UDim2.new(0, 10, 0, 130)
ModeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ModeBtn.Text = "MODUS: ODER BESSER (>=)"
ModeBtn.TextColor3 = Color3.fromRGB(150, 180, 255)
ModeBtn.Font = Enum.Font.SourceSansBold
ModeBtn.TextSize = 13
ModeBtn.Parent = Main

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -215)
Scroll.Position = UDim2.new(0, 10, 0, 170)
Scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Scroll.BorderSizePixel = 0
Scroll.CanvasSize = UDim2.new(0, 0, 0, 280)
Scroll.ScrollBarThickness = 6
Scroll.Parent = Main

local Tiers = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Secret", "Exotic", "Divine", "Prismatic"}
local TierRang = {["Common"]=1,["Uncommon"]=2,["Rare"]=3,["Epic"]=4,["Legendary"]=5,["Secret"]=6,["Exotic"]=7,["Divine"]=8,["Prismatic"]=9}

for i, tier in ipairs(Tiers) do
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 25)
    Btn.Position = UDim2.new(0, 5, 0, (i - 1) * 30)
    
    if getgenv().SelectedTiers[tier] then
        Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
        Btn.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    
    Btn.Text = "  " .. tier
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Font = Enum.Font.Code
    Btn.TextSize = 13
    Btn.Parent = Scroll
    
    Btn.MouseButton1Click:Connect(function()
        getgenv().SelectedTiers[tier] = not getgenv().SelectedTiers[tier]
        if getgenv().SelectedTiers[tier] then
            Btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
            Btn.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)
end

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoRollActive = not getgenv().AutoRollActive
    if getgenv().AutoRollActive then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 60, 30)
        ToggleBtn.Text = "AUTO-ROLL: ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
        ToggleBtn.Text = "AUTO-ROLL: OFF"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

BuyBtn.MouseButton1Click:Connect(function()
    getgenv().AutoBuyActive = not getgenv().AutoBuyActive
    if getgenv().AutoBuyActive then
        BuyBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 15)
        BuyBtn.Text = "AUTO-BUY: ON"
        BuyBtn.TextColor3 = Color3.fromRGB(255, 180, 100)
    else
        BuyBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 15)
        BuyBtn.Text = "AUTO-BUY: OFF"
        BuyBtn.TextColor3 = Color3.fromRGB(150, 120, 90)
    end
end)

ModeBtn.MouseButton1Click:Connect(function()
    if getgenv().StopMode == "OrBetter" then
        getgenv().StopMode = "Exact"
        ModeBtn.Text = "MODUS: NUR EXAKTE TREFFER (==)"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 45)
        ModeBtn.TextColor3 = Color3.fromRGB(255, 150, 255)
    else
        getgenv().StopMode = "OrBetter"
        ModeBtn.Text = "MODUS: ODER BESSER (>=)"
        ModeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        ModeBtn.TextColor3 = Color3.fromRGB(150, 180, 255)
    end
end)

local function resumeRolling()
    task.wait(0.5)
    if not getgenv().AutoRollActive then
        getgenv().AutoRollActive = true
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 60, 30)
        ToggleBtn.Text = "AUTO-ROLL: ON"
        ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

BuyEvent.OnClientEvent:Connect(function(...)
    if not getgenv().AutoRollActive then
        print("🛒 Kauf vom Spieler oder Auto-Buy registriert! Setze Auto-Roll fort...")
        resumeRolling()
    end
end)

RollEvent.OnClientEvent:Connect(function(tab)
    if not getgenv().AutoRollActive then return end
    if type(tab) == "table" then
        for _, name in pairs(tab) do
            if type(name) == "string" then
                local rStr = PflanzenSeltenheiten[name] or "Prismatic"
                print("Roll: " .. name .. " [" .. rStr .. "]")
                
                local matchFound = false
                if getgenv().StopMode == "Exact" then
                    if getgenv().SelectedTiers[rStr] then matchFound = true end
                elseif getgenv().StopMode == "OrBetter" then
                    local currentRank = TierRang[rStr] or 1
                    for selectedTier, active in pairs(getgenv().SelectedTiers) do
                        if active then
                            local selectedRank = TierRang[selectedTier] or 1
                            if currentRank >= selectedRank then
                                matchFound = true
                                break
                            end
                        end
                    end
                end
                
                if matchFound then
                    print("🎉 TARGET FOUND: " .. name .. " (" .. rStr .. ")")
                    getgenv().AutoRollActive = false
                    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
                    ToggleBtn.Text = "AUTO-ROLL: OFF"
                    ToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
                    
                    if getgenv().AutoBuyActive then
                        task.wait(0.1)
                        print("🤖 Auto-Buy triggert für Index [1]!")
                        pcall(function() BuyEvent:FireServer(1) end)
                    end
                    break
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        if getgenv().AutoRollActive then
            pcall(function() RollEvent:FireServer() end)
        end
        task.wait(0.35)
    end
end)
