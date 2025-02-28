-- do not copy or steal
-- this script is open source and keyless

local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

local Window = WindUI:CreateWindow({
    Title = "Steamline X Hub",
    Icon = "target",
    Author = "by reallance0424",
    Folder = "DeadRails",
    Size = UDim2.fromOffset(200, 200),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 120,
})

local Tabs = {
local AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "target", Desc = "Enable Aimbot" })
local ESPTab = Window:Tab({ Title = "Item ESP", Icon = "box", Desc = "See items through walls" })
local BringitemTab = Window:Tab({ Title = "Mob ESP", Icon = "users", Desc = "See NPCs through walls" })
}

Windows:SelectTab(1)

local RunService = game:GetService("RunService")
local Cam = workspace.CurrentCamera
local Player = game:GetService("Players").LocalPlayer

local validNPCs = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local function isNPC(obj)
    return obj:IsA("Model") 
        and obj:FindFirstChild("Humanoid")
        and obj.Humanoid.Health > 0
        and obj:FindFirstChild("Head")
        and obj:FindFirstChild("HumanoidRootPart")
        and not game:GetService("Players"):GetPlayerFromCharacter(obj)
end

local function updateNPCs()
    local tempTable = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isNPC(obj) then
            tempTable[obj] = true
        end
    end
    for i = #validNPCs, 1, -1 do
        if not tempTable[validNPCs[i]] then
            table.remove(validNPCs, i)
        end
    end
    for obj in pairs(tempTable) do
        if not table.find(validNPCs, obj) then
            table.insert(validNPCs, obj)
        end
    end
end

local function getTarget()
    local nearest, minDistance = nil, math.huge
    local viewportCenter = Cam.ViewportSize / 2
    raycastParams.FilterDescendantsInstances = {Player.Character}
    
    for _, npc in ipairs(validNPCs) do
        local predictedPos = npc.HumanoidRootPart.Position
        local screenPos, visible = Cam:WorldToViewportPoint(predictedPos)
        if visible and screenPos.Z > 0 then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearest = npc
            end
        end
    end
    return nearest
end

local function aim(targetPosition)
    local currentCF = Cam.CFrame
    local newLookVector = currentCF.LookVector:Lerp((targetPosition - currentCF.Position).Unit, 0.581)
    Cam.CFrame = CFrame.new(currentCF.Position, currentCF.Position + newLookVector)
end

local aimbotEnabled = false

RunService.Heartbeat:Connect(function()
    updateNPCs()
    if aimbotEnabled then
        local target = getTarget()
        if target then
            aim(target.HumanoidRootPart.Position)
        end
    end
end)

Tabs.AimbotTab:Toggle({
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(value)
        aimbotEnabled = value
    end
})

local ESPHandles = {}
local ESPItemsEnabled = false
local ESPMobsEnabled = false

local function CreateESP(object, color)
    if not object or not object.PrimaryPart then return end

    if ESPHandles[object] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Parent = object

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Adornee = object.PrimaryPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object

    local textLabel = Instance.new("TextLabel")
    textLabel.Text = object.Name
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.TextColor3 = color
    textLabel.BackgroundTransparency = 1
    textLabel.TextSize = 7
    textLabel.Parent = billboard

    ESPHandles[object] = { Highlight = highlight, Billboard = billboard, Color = color }
end

local function ClearESP(category)
    for obj, handles in pairs(ESPHandles) do
        if category == "Items" and handles.Color == Color3.new(1, 0, 0) then
            if handles.Highlight then handles.Highlight:Destroy() end
            if handles.Billboard then handles.Billboard:Destroy() end
            ESPHandles[obj] = nil
        elseif category == "Mobs" and handles.Color ~= Color3.new(1, 0, 0) then
            if handles.Highlight then handles.Highlight:Destroy() end
            if handles.Billboard then handles.Billboard:Destroy() end
            ESPHandles[obj] = nil
        end
    end
end

local function UpdateESPItems()
    ClearESP("Items")
    local runtimeItems = workspace:FindFirstChild("RuntimeItems")
    if runtimeItems then
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") then
                CreateESP(item, Color3.new(1, 0, 0))
            end
        end
    end
end

local function UpdateESPMobs()
    ClearESP("Mobs")

    local baseplates = workspace:FindFirstChild("Baseplates")
    if baseplates and #baseplates:GetChildren() >= 2 then
        local secondBaseplate = baseplates:GetChildren()[2]
        local centerBaseplate = secondBaseplate and secondBaseplate:FindFirstChild("CenterBaseplate")
        local animals = centerBaseplate and centerBaseplate:FindFirstChild("Animals")
        if animals then
            for _, animal in ipairs(animals:GetDescendants()) do
                if animal:IsA("Model") then
                    CreateESP(animal, Color3.new(1, 0, 1))
                end
            end
        end
    end

    local nightEnemies = workspace:FindFirstChild("NightEnemies")
    if nightEnemies then
        for _, enemy in ipairs(nightEnemies:GetDescendants()) do
            if enemy:IsA("Model") then
                CreateESP(enemy, Color3.new(0, 0, 1))
            end
        end
    end

    local destroyedHouse = workspace:FindFirstChild("RandomBuildings") and workspace.RandomBuildings:FindFirstChild("DestroyedHouse")
    local zombiePart = destroyedHouse and destroyedHouse:FindFirstChild("StandaloneZombiePart")
    local zombies = zombiePart and zombiePart:FindFirstChild("Zombies")
    if zombies then
        for _, zombie in ipairs(zombies:GetChildren()) do
            if zombie:IsA("Model") then
                CreateESP(zombie, Color3.new(0, 1, 0))
            end
        end
    end
end

Tabs.ESPTab:Toggle({
    Title = "ESP Items",
    Default = false,
    Callback = function(value)
        ESPItemsEnabled = value
        if value then
            UpdateESPItems()
        else
            ClearESP("Items")
        end
    end
})

Tabs.ESPTab:Toggle({
    Title = "ESP Mobs",
    Default = false,
    Callback = function(value)
        ESPMobsEnabled = value
        if value then
            UpdateESPMobs()
        else
            ClearESP("Mobs")
        end
    end
})

local function GetItemNames()
    local items = {}
    local runtimeItems = workspace:FindFirstChild("RuntimeItems")
    if runtimeItems then
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") then
                table.insert(items, item.Name)
            end
        end
    end
    return items
end

local Dropdown = Tabs.BringItemTab:Dropdown({
    Title = "Choose Item",
    Options = GetItemNames(),
    CurrentOption = "Select an item",
    MultipleOptions = false,
    Flag = "ItemDropdown",
    Callback = function(selectedItem)
        if type(selectedItem) == "table" then
            selectedItem = selectedItem[1]
        end
    end
})

Tabs.BringItemTab:Button({
    Title = "Refresh Items",
    Callback = function()
        Dropdown:Refresh(GetItemNames())
    end
})

Tabs.BringItemTab:Button({
    Title = "Collect Selected Item",
    Callback = function()
        local selectedItemName = Dropdown.CurrentOption
        if type(selectedItemName) == "table" then
            selectedItemName = selectedItemName[1]
        end

        if selectedItemName == "Select an item" then return end

        local runtimeItems = workspace:FindFirstChild("RuntimeItems")
        if not runtimeItems then return end

        local selectedItem
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") and item.Name == selectedItemName then
                selectedItem = item
                break
            end
        end

        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

        if selectedItem and selectedItem.PrimaryPart then
            selectedItem:SetPrimaryPartCFrame(HumanoidRootPart.CFrame + Vector3.new(0, 1, 0))
        end
    end
})

Tabs.BringItemTab:Button({
    Title = "Collect All Items",
    Callback = function()
        local runtimeItems = workspace:FindFirstChild("RuntimeItems")
        if not runtimeItems then return end

        local ps = game:GetService("Players").LocalPlayer
        local ch = ps.Character
        local HumanoidRootPart = ch:FindFirstChild("HumanoidRootPart")

        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") and item.PrimaryPart then
                item:SetPrimaryPartCFrame(HumanoidRootPart.CFrame + HumanoidRootPart.CFrame.LookVector * 5)
            end
        end
    end
})

local ITEM_FOLDER = "RuntimeItems"
local PLAYER = game:GetService("Players").LocalPlayer

-- Function to bring weapons & ammo
local function bringWeaponsAndAmmo()
    local itemsFolder = workspace:FindFirstChild(ITEM_FOLDER)
    if not itemsFolder then
        warn("No items folder found!")
        return
    end

    local char = PLAYER.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        warn("Character not found!")
        return
    end

    local hrp = char.HumanoidRootPart

    -- Debugging: Print all item names in the folder
    print("Checking items in", ITEM_FOLDER)
    for _, item in ipairs(itemsFolder:GetChildren()) do
        print("Found item:", item.Name) -- Debugging line
    end

    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item:IsA("Model") then
            local lowerName = item.Name:lower()
            if lowerName:find("gun") or lowerName:find("weapon") or lowerName:find("ammo") 
                or lowerName:find("revolver") or lowerName:find("rifle") or lowerName:find("shotgun") then
                
                if item.PrimaryPart then
                    item:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0, 1, 0)) -- Move item to player
                else
                    -- If no PrimaryPart, attempt to move all parts
                    for _, part in ipairs(item:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CFrame = hrp.CFrame + Vector3.new(0, 1, 0)
                        end
                    end
                end
                wait(0.1) -- Prevents crashes
            end
        end
    end
end

-- Button to bring weapons & ammo
Tabs.BringItemTab:Button({
    Name = "Bring Weapons & Ammo",
    Callback = function()
        bringWeaponsAndAmmo()
    end
})
