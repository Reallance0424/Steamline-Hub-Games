-- do not copy or steal
-- this script is open source and keyless

local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

local Window = WindUI:CreateWindow({
    Title = "Steamline Hub",
    Icon = "target",
    Author = "by reallance0424",
    Folder = "DeadRails",
    Size = UDim2.fromOffset(200, 200),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 120,
})

local Tabs = {
    AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "target", Desc = "Enable Aimbot" }),
    ESPTab = Window:Tab({ Title = "ESP", Icon = "eye", Desc = "ESP for items and NPCs" }),
    BringItemTab = Window:Tab({ Title = "Bring Items", Icon = "box", Desc = "Teleport items to you" })
}

Window:SelectTab(1)

local RunService = game:GetService("RunService")
local Cam = workspace.CurrentCamera
local Player = game:GetService("Players").LocalPlayer

-- **Aimbot Variables**
local aimbotEnabled = false
local validNPCs = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

-- **NPC Detection**
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
    validNPCs = {} -- Reset valid NPCs
    for obj in pairs(tempTable) do
        table.insert(validNPCs, obj)
    end
end

-- **Aimbot Target Selection**
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

-- **Aimbot Function**
local function aim(targetPosition)
    local currentCF = Cam.CFrame
    local newLookVector = currentCF.LookVector:Lerp((targetPosition - currentCF.Position).Unit, 0.581)
    Cam.CFrame = CFrame.new(currentCF.Position, currentCF.Position + newLookVector)
end

-- **Aimbot Toggle UI**
Tabs.AimbotTab:Toggle({
    Title = "Enable Aimbot", -- **This was missing! Now added.**
    Default = false,
    Callback = function(value)
        aimbotEnabled = value
    end
})

-- **Aimbot Logic**
RunService.Heartbeat:Connect(function()
    updateNPCs()
    if aimbotEnabled then
        local target = getTarget()
        if target then
            aim(target.HumanoidRootPart.Position)
        end
    end
end)

-- **ESP Variables**
local ESPHandles = {}
local ESPItemsEnabled = false
local ESPMobsEnabled = false

-- **ESP Function**
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

-- **ESP Clearing Function**
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

-- **ESP Update Functions**
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

-- **Bring Items Section**
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

        if selectedItem and selectedItem.PrimaryPart then
            selectedItem:SetPrimaryPartCFrame(Player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0))
        end
    end
})
