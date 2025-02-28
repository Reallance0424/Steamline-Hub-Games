-- do not copy or steal
-- this script is open source and keyless

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Steamline Hub",
    LoadingTitle = "Loading Steamline Hub...",
    LoadingSubtitle = "by reallance0424",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SteamlineX",
        FileName = "DeadRails_Config"
    },
    Discord = {
        Enabled = false,
        Invite = "", 
        RememberJoins = true
    },
    KeySystem = false
})

local Tabs = {
    AimbotTab = Window:CreateTab("Aimbot", 4483362458),
    ESPTab = Window:CreateTab("ESP", 4483362458),
    BringItemTab = Window:CreateTab("Bring Items", 4483362458)
}

-- Services
local RunService = game:GetService("RunService")
local Cam = workspace.CurrentCamera
local Player = game:GetService("Players").LocalPlayer

-- Aimbot Variables
local aimbotEnabled = false
local validNPCs = {}

-- ESP Variables
local ESPHandles = {}
local ESPItemsEnabled = false
local ESPMobsEnabled = false

-- Function to check if an object is an NPC
local function isNPC(obj)
    return obj:IsA("Model") 
        and obj:FindFirstChild("Humanoid")
        and obj.Humanoid.Health > 0
        and obj:FindFirstChild("Head")
        and obj:FindFirstChild("HumanoidRootPart")
        and not game:GetService("Players"):GetPlayerFromCharacter(obj)
end

-- Update NPCs List
local function updateNPCs()
    validNPCs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isNPC(obj) then
            table.insert(validNPCs, obj)
        end
    end
end

-- Find the nearest NPC
local function getTarget()
    local nearest, minDistance = nil, math.huge
    local viewportCenter = Cam.ViewportSize / 2

    for _, npc in ipairs(validNPCs) do
        local screenPos, visible = Cam:WorldToViewportPoint(npc.HumanoidRootPart.Position)
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

-- Aim at Target
local function aim(targetPosition)
    local currentCF = Cam.CFrame
    local newLookVector = currentCF.LookVector:Lerp((targetPosition - currentCF.Position).Unit, 0.581)
    Cam.CFrame = CFrame.new(currentCF.Position, currentCF.Position + newLookVector)
end

-- Aimbot Toggle
Tabs.AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(value)
        aimbotEnabled = value
    end
})

RunService.Heartbeat:Connect(function()
    updateNPCs()
    if aimbotEnabled then
        local target = getTarget()
        if target then
            aim(target.HumanoidRootPart.Position)
        end
    end
end)

-- **ESP Functions**
local function CreateESP(object, color)
    if not object or not object.PrimaryPart or ESPHandles[object] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Parent = object

    ESPHandles[object] = highlight
end

local function ClearESP(category)
    for obj, handle in pairs(ESPHandles) do
        if handle then
            if (category == "Items" and handle.FillColor == Color3.new(1, 0, 0)) or 
               (category == "Mobs" and handle.FillColor ~= Color3.new(1, 0, 0)) then
                handle:Destroy()
                ESPHandles[obj] = nil
            end
        end
    end
end

local function UpdateESPItems()
    ClearESP("Items")
    local runtimeItems = workspace:FindFirstChild("RuntimeItems")
    if runtimeItems then
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") then
                CreateESP(item, Color3.new(1, 0, 0)) -- Red for items
            end
        end
    end
end

local function UpdateESPMobs()
    ClearESP("Mobs")
    
    local npcFolders = { "NightEnemies", "Animals", "Zombies" }
    for _, folderName in ipairs(npcFolders) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, npc in ipairs(folder:GetDescendants()) do
                if npc:IsA("Model") then
                    CreateESP(npc, Color3.new(0, 1, 0)) -- Green for NPCs
                end
            end
        end
    end
end

-- **ESP Toggle UI**
Tabs.ESPTab:CreateToggle({
    Name = "ESP Items",
    CurrentValue = false,
    Callback = function(value)
        ESPItemsEnabled = value
        if value then
            UpdateESPItems()
        else
            ClearESP("Items")
        end
    end
})

Tabs.ESPTab:CreateToggle({
    Name = "ESP Mobs",
    CurrentValue = false,
    Callback = function(value)
        ESPMobsEnabled = value
        if value then
            UpdateESPMobs()
        else
            ClearESP("Mobs")
        end
    end
})

-- **Item Teleport Section**
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

local Dropdown = Tabs.BringItemTab:CreateDropdown({
    Name = "Choose Item",
    Options = GetItemNames(),
    CurrentOption = "Select an item",
    MultipleOptions = false,
    Callback = function(selectedItem)
    end
})

Tabs.BringItemTab:CreateButton({
    Name = "Refresh Items",
    Callback = function()
        Dropdown:Refresh(GetItemNames())
    end
})

Tabs.BringItemTab:CreateButton({
    Name = "Collect Selected Item",
    Callback = function()
        local selectedItemName = Dropdown.CurrentOption
        if selectedItemName == "Select an item" then return end

        local runtimeItems = workspace:FindFirstChild("RuntimeItems")
        if not runtimeItems then return end

        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") and item.Name == selectedItemName then
                item:SetPrimaryPartCFrame(Player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0))
                break
            end
        end
    end
})

Tabs.BringItemTab:CreateButton({
    Name = "Bring Weapons & Ammo",
    Callback = function()
        local itemsFolder = workspace:FindFirstChild("RuntimeItems")
        if not itemsFolder then return end

        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, item in ipairs(itemsFolder:GetChildren()) do
            if item:IsA("Model") then
                if item.Name:lower():find("gun") or item.Name:lower():find("ammo") then
                    item:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0, 1, 0))
                end
            end
        end
    end
})
