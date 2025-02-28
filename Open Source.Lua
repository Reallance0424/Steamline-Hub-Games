-- do not copy or steal
-- this script is open source and keyless

-- 
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
    AimbotTab = Window:Tab({ Title = "Function", Icon = "crosshair", Desc = "Configure aimbot settings." }),
    BringItemTab = Window:Tab({ Title = "Bring Item", Icon = "box", Desc = "Teleport items to you." }),
    ESPTab = Window:Tab({ Title = "ESP", Icon = "eye", Desc = "ESP options for items & mobs." })
}

Window:SelectTab(1)

-- // ESP System \\ --
local ESPHandles = {}
local ESPItemsEnabled = false
local ESPMobsEnabled = false

local function CreateESP(object, color)
    if not object or not object.PrimaryPart then return end
    if ESPHandles[object] then return end 

    local highlight = Instance.new("Highlight")
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.Parent = object

    local billboard = Instance.new("BillboardGui")
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

    ESPHandles[object] = { Highlight = highlight, Billboard = billboard }
end

local function UpdateESPItems()
    for _, v in pairs(ESPHandles) do
        v.Highlight:Destroy()
        v.Billboard:Destroy()
    end
    ESPHandles = {}

    if ESPItemsEnabled then
        local runtimeItems = workspace:FindFirstChild("RuntimeItems")
        if runtimeItems then
            for _, item in ipairs(runtimeItems:GetDescendants()) do
                if item:IsA("Model") then
                    CreateESP(item, Color3.new(1, 0, 0))
                end
            end
        end
    end
end

Tabs.ESPTab:Toggle({
    Title = "ESP Items",
    Default = false,
    Callback = function(value)
        ESPItemsEnabled = value
        UpdateESPItems()
    end
})

-- Item Selection
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
   Callback = function(selectedItem)
       print("Selected item:", selectedItem)
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
       local selectedItemName = Dropdown:GetValue()
       local runtimeItems = workspace:FindFirstChild("RuntimeItems")
       local player = game.Players.LocalPlayer
       local char = player.Character or player.CharacterAdded:Wait()
       local hrp = char:FindFirstChild("HumanoidRootPart")

       if runtimeItems then
           for _, item in ipairs(runtimeItems:GetDescendants()) do
               if item:IsA("Model") and item.Name == selectedItemName then
                   item:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0, 1, 0))
                   print("Collected:", selectedItemName)
               end
           end
       end
   end
})

-- Weapon & Ammo Bring
local function bringWeaponsAndAmmo()
    local itemsFolder = workspace:FindFirstChild("RuntimeItems")
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            if item:IsA("Model") and (item.Name:find("gun") or item.Name:find("ammo")) then
                item:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0, 1, 0))
            end
        end
    end
end

Tabs.BringItemTab:Button({
    Title = "Bring Weapons & Ammo",
    Callback = function()
        bringWeaponsAndAmmo()
    end
})
