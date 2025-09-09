-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- === ScreenGui ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- === Main Frame ===
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 350)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- === UI Corner ===
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- === Tab Buttons Frame ===
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(0, 120, 1, 0)
tabFrame.Position = UDim2.new(0, 0, 0, 0)
tabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tabFrame.Parent = mainFrame

-- === Content Frame ===
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -120, 1, 0)
contentFrame.Position = UDim2.new(0, 120, 0, 0)
contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
contentFrame.Parent = mainFrame

-- === Tabs ===
local tabs = {"Main", "Alchemy", "Fram", "Settings"} -- ✅ am adăugat Fram
local currentTab = "Main"

-- === Tab Buttons & Content Frames ===
for i, tabName in ipairs(tabs) do
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1, -10, 0, 40)
    tabButton.Position = UDim2.new(0, 5, 0, (i - 1) * 45 + 10)
    tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Text = tabName
    tabButton.Font = Enum.Font.SourceSansBold
    tabButton.TextSize = 16
    tabButton.Parent = tabFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tabButton

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Name = tabName
    frame.Visible = (tabName == currentTab)
    frame.Parent = contentFrame

    tabButton.MouseButton1Click:Connect(function()
        for _, f in ipairs(contentFrame:GetChildren()) do
            f.Visible = false
        end
        frame.Visible = true
        currentTab = tabName
    end)
end

-- === Toggle Function Helper ===
local function createToggle(frame, text, valueRef, posY)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 40)
    toggleFrame.Position = UDim2.new(0, 10, 0, posY)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.3, -5, 0.6, 0)
    button.Position = UDim2.new(0.7, 0, 0.2, 0)
    button.BackgroundColor3 = valueRef() and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 0, 0)
    button.Text = ""
    button.Parent = toggleFrame

    button.MouseButton1Click:Connect(function()
        valueRef(not valueRef())
        button.BackgroundColor3 = valueRef() and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(150, 0, 0)
    end)
end

-- === Main Tab Options ===
local mainFrameContent = contentFrame:FindFirstChild("Main")

getgenv().toggleTalent = false
getgenv().toggleFamily = false
getgenv().autoUseCodes = false
getgenv().getAllQuestsRunning = false
getgenv().waitTime = 0.2

local talentConditions = {31,32,33,34,35}
local familyConditions = {"Wushang","Bai","Xuan","Ling"}
local additionalCodes = {
    "1100Likes!","1KLIKES","900Likes!!","500LIKES","600LIKES","Release",
    "Cultivation","Reborn","SorryForMaintenance","Sorry4Shutdown","BugFIX",
    "SorryForShutdowns","100Likes"
}

local function isTalentConditionMet(num)
    for _, c in ipairs(talentConditions) do if num >= c then return true end end
    return false
end

local function isFamilyConditionMet(name)
    for _, c in ipairs(familyConditions) do if name == c then return true end end
    return false
end

local function redeemCode(code)
    local args = {code}
    game:GetService("ReplicatedStorage").Events.EnterCode:FireServer(unpack(args))
    task.wait(0.5)
end

local function autoUseCodesFunc()
    if getgenv().autoUseCodes then
        local codesFolder = game:GetService("ReplicatedStorage").Modules.Data.DataTemplate:WaitForChild("Codes")
        for _, boolValue in ipairs(codesFolder:GetChildren()) do
            if boolValue:IsA("BoolValue") then redeemCode(boolValue.Name) end
        end
        for _, code in ipairs(additionalCodes) do redeemCode(code) end
        getgenv().autoUseCodes = false
    end
end

-- Talent toggle
createToggle(mainFrameContent, "Auto Roll Talent", function(val)
    if val ~= nil then
        getgenv().toggleTalent = val
        task.spawn(function()
            while getgenv().toggleTalent do
                local text = player.PlayerGui.ScreenGui.Menu.Frame.TalentFrame.Talent.TextLabel.Text
                local num = tonumber(text)
                if num and isTalentConditionMet(num) then getgenv().toggleTalent = false break end
                game:GetService("ReplicatedStorage").Events.RollTalent:FireServer()
                task.wait(getgenv().waitTime)
            end
        end)
    end
    return getgenv().toggleTalent
end, 10)

-- Family toggle
createToggle(mainFrameContent, "Auto Roll Family", function(val)
    if val ~= nil then
        getgenv().toggleFamily = val
        task.spawn(function()
            while getgenv().toggleFamily do
                local text = player.PlayerGui.ScreenGui.Menu.Frame.FamilyFrame.Family.TextLabel.Text
                if isFamilyConditionMet(text) then getgenv().toggleFamily = false break end
                game:GetService("ReplicatedStorage").Events.RollFamily:FireServer()
                task.wait(getgenv().waitTime)
            end
        end)
    end
    return getgenv().toggleFamily
end, 60)

-- Codes toggle
createToggle(mainFrameContent, "Auto Use Codes", function(val)
    if val ~= nil then
        getgenv().autoUseCodes = val
        task.spawn(autoUseCodesFunc)
    end
    return getgenv().autoUseCodes
end, 110)

-- Get All Quests toggle
createToggle(mainFrameContent, "Get All Quests", function(val)
    if val ~= nil then
        getgenv().getAllQuestsRunning = val
        if val then
            task.spawn(function()
                for i=1,200 do
                    if not getgenv().getAllQuestsRunning then break end
                    game:GetService("ReplicatedStorage").Events.Quest:FireServer(i)
                    task.wait(0.1)
                end
                getgenv().getAllQuestsRunning = false
            end)
        end
    end
    return getgenv().getAllQuestsRunning
end, 160)

-- === Fram Tab Options ===
local framFrame = contentFrame:FindFirstChild("Fram")
local framButton = Instance.new("TextButton")
framButton.Size = UDim2.new(1, -20, 0, 40)
framButton.Position = UDim2.new(0, 10, 0, 10)
framButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
framButton.TextColor3 = Color3.fromRGB(255, 255, 255)
framButton.Text = "Fram Example Button"
framButton.Font = Enum.Font.SourceSansBold
framButton.TextSize = 16
framButton.Parent = framFrame
framButton.MouseButton1Click:Connect(function()
    print("Ai apăsat pe butonul din Fram!")
end)

-- === Settings Tab Options ===
local settingsFrame = contentFrame:FindFirstChild("Settings")

-- FPS Boost
local fpsBoostButton = Instance.new("TextButton")
fpsBoostButton.Size = UDim2.new(1, -20, 0, 40)
fpsBoostButton.Position = UDim2.new(0, 10, 0, 10)
fpsBoostButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
fpsBoostButton.TextColor3 = Color3.fromRGB(255,255,255)
fpsBoostButton.Text = "FPS BOOST [OFF]"
fpsBoostButton.Font = Enum.Font.SourceSansBold
fpsBoostButton.TextSize = 16
fpsBoostButton.Parent = settingsFrame

local fpsBoostEnabled = false
fpsBoostButton.MouseButton1Click:Connect(function()
    fpsBoostEnabled = not fpsBoostEnabled
    fpsBoostButton.Text = fpsBoostEnabled and "FPS BOOST [ON]" or "FPS BOOST [OFF]"
    game:GetService("Lighting").GlobalShadows = not fpsBoostEnabled
end)

-- Battery Economy Mode
local batteryButton = Instance.new("TextButton")
batteryButton.Size = UDim2.new(1, -20, 0, 40)
batteryButton.Position = UDim2.new(0, 10, 0, 60)
batteryButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
batteryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
batteryButton.Text = "Battery Economy Mode [OFF]"
batteryButton.Font = Enum.Font.SourceSansBold
batteryButton.TextSize = 16
batteryButton.Parent = settingsFrame

local negruScreenGui = Instance.new("ScreenGui")
negruScreenGui.Name = "NegruFocusGUI"
negruScreenGui.Parent = player.PlayerGui
negruScreenGui.ResetOnSpawn = false
negruScreenGui.IgnoreGuiInset = true

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
blackFrame.Visible = false
blackFrame.ZIndex = 10
blackFrame.Parent = negruScreenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 140, 0, 50)
toggleButton.AnchorPoint = Vector2.new(0.5, 1)
toggleButton.Position = UDim2.new(0.5, 0, 1, -10)
toggleButton.Text = "Focus On/Off"
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.ZIndex = 11
toggleButton.Visible = false
toggleButton.Parent = negruScreenGui

local focusOn = false
toggleButton.MouseButton1Click:Connect(function()
    focusOn = not focusOn
    blackFrame.Visible = focusOn
end)

local batteryModeEnabled = false
batteryButton.MouseButton1Click:Connect(function()
    batteryModeEnabled = not batteryModeEnabled
    batteryButton.Text = batteryModeEnabled and "Battery Economy Mode [ON]" or "Battery Economy Mode [OFF]"
    toggleButton.Visible = batteryModeEnabled
    if not batteryModeEnabled then
        focusOn = false
        blackFrame.Visible = false
    end
end)-- === Buton mic pentru ascundere/afișare GUI cu colțuri rotunjite ===
local toggleGuiButton = Instance.new("TextButton")
toggleGuiButton.Size = UDim2.new(0, 120, 0, 40)
toggleGuiButton.Position = UDim2.new(0, 20, 0, 20) -- inițial sus stânga
toggleGuiButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleGuiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleGuiButton.Font = Enum.Font.SourceSansBold
toggleGuiButton.TextSize = 16
toggleGuiButton.Text = "Hide GUI"
toggleGuiButton.Active = true
toggleGuiButton.Draggable = true -- îl poți muta unde vrei
toggleGuiButton.Parent = screenGui

-- Colțuri rotunjite
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.Parent = toggleGuiButton

local guiVisible = true
toggleGuiButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    mainFrame.Visible = guiVisible
    toggleGuiButton.Text = guiVisible and "Hide GUI" or "Show GUI"
end)-- === Fram Tab Options ===
local framFrame = contentFrame:FindFirstChild("Fram")

-- Buton Works Iron
local worksIronButton = Instance.new("TextButton")
worksIronButton.Size = UDim2.new(1, -20, 0, 40)
worksIronButton.Position = UDim2.new(0, 10, 0, 10)
worksIronButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
worksIronButton.TextColor3 = Color3.fromRGB(255, 255, 255)
worksIronButton.Text = "Works Iron"
worksIronButton.Font = Enum.Font.SourceSansBold
worksIronButton.TextSize = 16
worksIronButton.Parent = framFrame

-- Toggle pentru spamming
getgenv().autoWorksIron = false

worksIronButton.MouseButton1Click:Connect(function()
    getgenv().autoWorksIron = not getgenv().autoWorksIron
    worksIronButton.BackgroundColor3 = getgenv().autoWorksIron and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,80)

    if getgenv().autoWorksIron then
        task.spawn(function()
            while getgenv().autoWorksIron do
                local args = {[1] = "Iron"}
                game:GetService("ReplicatedStorage").Events.HireWorker:FireServer(unpack(args))
                task.wait(1) -- trimite la fiecare 1 secundă
            end
        end)
    end
end)-- === Fram Tab Options ===
local framFrame = contentFrame:FindFirstChild("Fram")

-- Buton Works Iron
local worksIronButton = Instance.new("TextButton")
worksIronButton.Size = UDim2.new(1, -20, 0, 40)
worksIronButton.Position = UDim2.new(0, 10, 0, 10)
worksIronButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
worksIronButton.TextColor3 = Color3.fromRGB(255, 255, 255)
worksIronButton.Text = "Works Iron"
worksIronButton.Font = Enum.Font.SourceSansBold
worksIronButton.TextSize = 16
worksIronButton.Parent = framFrame

getgenv().autoWorksIron = false
worksIronButton.MouseButton1Click:Connect(function()
    getgenv().autoWorksIron = not getgenv().autoWorksIron
    worksIronButton.BackgroundColor3 = getgenv().autoWorksIron and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,80)
    if getgenv().autoWorksIron then
        task.spawn(function()
            while getgenv().autoWorksIron do
                game:GetService("ReplicatedStorage").Events.HireWorker:FireServer("Iron")
                task.wait(1)
            end
        end)
    end
end)

-- Buton Works Gold (sub Iron)
local worksGoldButton = Instance.new("TextButton")
worksGoldButton.Size = UDim2.new(1, -20, 0, 40)
worksGoldButton.Position = UDim2.new(0, 10, 0, 60) -- jos de Iron
worksGoldButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
worksGoldButton.TextColor3 = Color3.fromRGB(255, 255, 255)
worksGoldButton.Text = "Works Gold"
worksGoldButton.Font = Enum.Font.SourceSansBold
worksGoldButton.TextSize = 16
worksGoldButton.Parent = framFrame

getgenv().autoWorksGold = false
worksGoldButton.MouseButton1Click:Connect(function()
    getgenv().autoWorksGold = not getgenv().autoWorksGold
    worksGoldButton.BackgroundColor3 = getgenv().autoWorksGold and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,80)
    if getgenv().autoWorksGold then
        task.spawn(function()
            while getgenv().autoWorksGold do
                game:GetService("ReplicatedStorage").Events.HireWorker:FireServer("Gold")
                task.wait(1)
            end
        end)
    end
end)-- === Fram Tab Options ===
local framFrame = contentFrame:FindFirstChild("Fram")

-- Buton Works Iron
local worksIronButton = Instance.new("TextButton")
worksIronButton.Size = UDim2.new(1, -20, 0, 40)
worksIronButton.Position = UDim2.new(0, 10, 0, 10)
worksIronButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
worksIronButton.TextColor3 = Color3.fromRGB(255, 255, 255)
worksIronButton.Text = "Workers Iorn"
worksIronButton.Font = Enum.Font.SourceSansBold
worksIronButton.TextSize = 16
worksIronButton.Parent = framFrame

getgenv().autoWorksIron = false
worksIronButton.MouseButton1Click:Connect(function()
    getgenv().autoWorksIron = not getgenv().autoWorksIron
    worksIronButton.BackgroundColor3 = getgenv().autoWorksIron and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,80)
    if getgenv().autoWorksIron then
        task.spawn(function()
            while getgenv().autoWorksIron do
                game:GetService("ReplicatedStorage").Events.HireWorker:FireServer("Iron")
                task.wait(1)
            end
        end)
    end
end)

-- Buton Works Gold
local worksGoldButton = Instance.new("TextButton")
worksGoldButton.Size = UDim2.new(1, -20, 0, 40)
worksGoldButton.Position = UDim2.new(0, 10, 0, 60) -- jos de Iron
worksGoldButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
worksGoldButton.TextColor3 = Color3.fromRGB(255, 255, 255)
worksGoldButton.Text = "Workers Gold"
worksGoldButton.Font = Enum.Font.SourceSansBold
worksGoldButton.TextSize = 16
worksGoldButton.Parent = framFrame

getgenv().autoWorksGold = false
worksGoldButton.MouseButton1Click:Connect(function()
    getgenv().autoWorksGold = not getgenv().autoWorksGold
    worksGoldButton.BackgroundColor3 = getgenv().autoWorksGold and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,80)
    if getgenv().autoWorksGold then
        task.spawn(function()
            while getgenv().autoWorksGold do
                game:GetService("ReplicatedStorage").Events.HireWorker:FireServer("Gold")
                task.wait(1)
            end
        end)
    end
end)

-- Buton Works Ruby
local worksRubyButton = Instance.new("TextButton")
worksRubyButton.Size = UDim2.new(1, -20, 0, 40)
worksRubyButton.Position = UDim2.new(0, 10, 0, 110) -- jos de Gold
worksRubyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
worksRubyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
worksRubyButton.Text = "Workers Ruby"
worksRubyButton.Font = Enum.Font.SourceSansBold
worksRubyButton.TextSize = 16
worksRubyButton.Parent = framFrame

getgenv().autoWorksRuby = false
worksRubyButton.MouseButton1Click:Connect(function()
    getgenv().autoWorksRuby = not getgenv().autoWorksRuby
    worksRubyButton.BackgroundColor3 = getgenv().autoWorksRuby and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,80)
    if getgenv().autoWorksRuby then
        task.spawn(function()
            while getgenv().autoWorksRuby do
                game:GetService("ReplicatedStorage").Events.HireWorker:FireServer("Ruby")
                task.wait(1)
            end
        end)
    end
end)-- Helper pentru glow gradient animat pe buton
local function addGlowEffect(button)
    -- Creează un UIGradient
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 0
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })
    gradient.Parent = button
    gradient.Enabled = false -- activăm doar la hover

    -- Efect hover
    button.MouseEnter:Connect(function()
        gradient.Enabled = true
        -- Mică animație pulsantă
        task.spawn(function()
            while gradient.Enabled do
                for i = 0, 360, 5 do
                    gradient.Rotation = i
                    task.wait(0.01)
                    if not gradient.Enabled then break end
                end
            end
        end)
    end)

    button.MouseLeave:Connect(function()
        gradient.Enabled = false
    end)
end-- Tabs Buttons
for _, tb in ipairs(tabFrame:GetChildren()) do
    if tb:IsA("TextButton") then
        addGlowEffect(tb)
    end
end

-- Main Tab Toggles
for _, tf in ipairs(mainFrameContent:GetChildren()) do
    if tf:IsA("Frame") then
        for _, b in ipairs(tf:GetChildren()) do
            if b:IsA("TextButton") then
                addGlowEffect(b)
            end
        end
    end
end

-- Fram Tab Buttons
for _, fb in ipairs(framFrame:GetChildren()) do
    if fb:IsA("TextButton") then
        addGlowEffect(fb)
    end
end

-- Settings Buttons
for _, sb in ipairs(settingsFrame:GetChildren()) do
    if sb:IsA("TextButton") then
        addGlowEffect(sb)
    end
end

-- Toggle Hide/Show GUI Button
addGlowEffect(toggleGuiButton)

-- Black Focus Toggle Button
addGlowEffect(toggleButton)-- === ESP SYSTEM ===
local Workspace = game:GetService("Workspace")
local npcActive = false
local playerActive = false

-- Functie pentru a adauga Highlight
local function addHighlight(model, color, tagName)
    local hl = model:FindFirstChild(tagName)
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = tagName
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.FillColor = color
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.Adornee = model
        hl.Parent = model
    end
end

-- Functie pentru a adauga nume
local function addNameTag(model, text, color, tagName)
    if not model:FindFirstChild("Head") then return end
    local billboard = model.Head:FindFirstChild(tagName)
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = tagName
        billboard.Size = UDim2.new(0,200,0,50)
        billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.AlwaysOnTop = true
        billboard.Parent = model.Head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Font = Enum.Font.SourceSansBold
        label.Text = text
        label.Parent = billboard
    end
end

-- Update NPC
local function updateNPCs()
    for _, npc in pairs(Workspace:WaitForChild("Npc"):GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Head") then
            addHighlight(npc, Color3.fromRGB(255,50,50), "HL_NPC")
            addNameTag(npc, npc.Name, Color3.fromRGB(255,50,50), "NameESP_NPC")
            if npc:FindFirstChild("HL_NPC") then npc.HL_NPC.Enabled = npcActive end
            if npc.Head:FindFirstChild("NameESP_NPC") then npc.Head.NameESP_NPC.Enabled = npcActive end
        end
    end
end

-- Update Players
local function updatePlayers()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
            addHighlight(p.Character, Color3.fromRGB(50,150,255), "HL_Player")
            addNameTag(p.Character, p.Name, Color3.fromRGB(50,150,255), "NameESP_Player")
            if p.Character:FindFirstChild("HL_Player") then p.Character.HL_Player.Enabled = playerActive end
            if p.Character.Head:FindFirstChild("NameESP_Player") then p.Character.Head.NameESP_Player.Enabled = playerActive end
        end
    end
end

-- Buton ESP NPC
createToggle(mainFrameContent, "ESP NPC", function(val)
    if val ~= nil then
        npcActive = val
        updateNPCs()
    end
    return npcActive
end, 210)

-- Buton ESP Players
createToggle(mainFrameContent, "ESP Players", function(val)
    if val ~= nil then
        playerActive = val
        updatePlayers()
    end
    return playerActive
end, 260)

-- Update la spawn NPC + Player
Workspace.Npc.ChildAdded:Connect(updateNPCs)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(updatePlayers)
end)