-- Made by reallance0424
-- This script is open source
-- This script is keyless
-- do not copy

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
}

Window:SelectTab(1)

-- Aimbot Mobs
local RunService = game:GetService("RunService")
local Cam = workspace.CurrentCamera
local Player = game:GetService("Players").LocalPlayer
local validNPCs = {}
local aimbotEnabled = false
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local function isNPC(obj)
    return obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 
        and obj:FindFirstChild("Head") and obj:FindFirstChild("HumanoidRootPart")
        and not game:GetService("Players"):GetPlayerFromCharacter(obj)
end

local function updateNPCs()
    validNPCs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isNPC(obj) then
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

-- ESP Mobs and Item
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

    ESPHandles[object] = {Highlight = highlight, Billboard = billboard, Color = color}
end

local function ClearESP()
    for obj, handles in pairs(ESPHandles) do
        if handles.Highlight then handles.Highlight:Destroy() end
        if handles.Billboard then handles.Billboard:Destroy() end
        ESPHandles[obj] = nil
    end
end

local function UpdateESPItems()
    if not ESPItemsEnabled then
        ClearESP()
        return
    end

    ClearESP()
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
    if not ESPMobsEnabled then
        ClearESP()
        return
    end

    ClearESP()
    local nightEnemies = workspace:FindFirstChild("NightEnemies")
    if nightEnemies then
        for _, enemy in ipairs(nightEnemies:GetDescendants()) do
            if enemy:IsA("Model") then
                CreateESP(enemy, Color3.new(0, 0, 1))
            end
        end
    end
end

Tabs.AimbotTab:Toggle({
    Title = "ESP Items",
    Default = false,
    Callback = function(value)
        ESPItemsEnabled = value
        UpdateESPItems()
    end
})

Tabs.AimbotTab:Toggle({
    Title = "ESP Mobs",
    Default = false,
    Callback = function(value)
        ESPMobsEnabled = value
        UpdateESPMobs()
    end
})

-- Bring item
local ITEM_FOLDER = "RuntimeItems"
local PLAYER = game:GetService("Players").LocalPlayer

local function bringWeaponsAndAmmo()
    local itemsFolder = workspace:FindFirstChild(ITEM_FOLDER)
    if not itemsFolder then return end

    local char = PLAYER.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart

    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item:IsA("Model") then
            local lowerName = item.Name:lower()
            if lowerName:find("gun") or lowerName:find("weapon") or lowerName:find("ammo") then
                if item.PrimaryPart then
                    item:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0, 1, 0))
                else
                    for _, part in ipairs(item:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CFrame = hrp.CFrame + Vector3.new(0, 1, 0)
                        end
                    end
                end
                wait(0.1)
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
