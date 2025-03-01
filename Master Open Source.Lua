-- do not copy or steal
-- this script is keyless

loadstring(game:HttpGet('https://sirius.menu/rayfield', true))()

local Window = Rayfield:CreateWindow({
   Name = "Steamline Hub | Dead Rails",
   LoadingTitle = "Loading Steamline Hub...",
   LoadingSubtitle = "by reallance0424",
   Theme = "Default",
   KeySystem = false
})

local AimTab = Window:CreateTab("Aimbot", 4483362458)
local EspTab = Window:CreateTab("ESP", 4483362458)

local RunService = game:GetService("RunService")
local Cam = workspace.CurrentCamera
local Player = game:GetService("Players").LocalPlayer

local validNPCs = {}
local aimbotEnabled = false
local targetPart = "Head" -- ?

local function isNPC(obj)
    return obj:IsA("Model") 
        and obj:FindFirstChild("Humanoid")
        and obj.Humanoid.Health > 0
        and obj:FindFirstChild("HumanoidRootPart") -- Main body part
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
    
    for _, npc in ipairs(validNPCs) do
        local targetPos
        if targetPart == "Random" then
            local parts = npc:GetChildren()
            local validParts = {}
            for _, part in ipairs(parts) do
                if part:IsA("BasePart") then
                    table.insert(validParts, part)
                end
            end
            if #validParts > 0 then
                targetPos = validParts[math.random(1, #validParts)].Position
            else
                targetPos = npc.HumanoidRootPart.Position
            end
        else
            local selectedPart = npc:FindFirstChild(targetPart) or npc.HumanoidRootPart
            targetPos = selectedPart.Position
        end

        local screenPos, visible = Cam:WorldToViewportPoint(targetPos)
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
            aim(target:FindFirstChild(targetPart) and target[targetPart].Position or target.HumanoidRootPart.Position)
        end
    end
end)

local aimbotToggle = AimTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        aimbotEnabled = Value
    end
})

local targetDropdown = AimTab:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "Random"},
    CurrentOption = "Head",
    Flag = "TargetPartDropdown",
    Callback = function(Option)
        targetPart = Option
    end
})

local ESPHandles = {}
local ESPItemsEnabled = false

-- ?
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

    ESPHandles[object] = {Highlight = highlight, Billboard = billboard}
end

-- ?
local function ClearESP()
    for _, handles in pairs(ESPHandles) do
        if handles.Highlight then handles.Highlight:Destroy() end
        if handles.Billboard then handles.Billboard:Destroy() end
    end
    ESPHandles = {}
end

-- ?
local function UpdateItemESP()
    ClearESP()

    if ESPItemsEnabled then
        local runtimeItems = workspace:FindFirstChild("RuntimeItems")
        if runtimeItems then
            for _, item in ipairs(runtimeItems:GetChildren()) do
                if item:IsA("Model") then
                    CreateESP(item, Color3.new(1, 0, 0)) -- Red for Items
                end
            end
        end
    end
end

-- ?
local function AutoUpdateESP()
    while ESPItemsEnabled do
        UpdateItemESP()
        wait(0.5) -- ?
    end
end

-- ?
EspTab:CreateToggle({
    Name = "ESP Items",
    CurrentValue = false,
    Flag = "ESPItemsToggle",
    Callback = function(Value)
        ESPItemsEnabled = Value
        if ESPItemsEnabled then
            coroutine.wrap(AutoUpdateESP)()
        else
            ClearESP()
        end
    end
})

local Tab = Window:CreateTab("Brings", 4483362458) 

local function GetItemNames()
    local items = {}
    local runtimeItems = workspace:FindFirstChild("RuntimeItems")
    if runtimeItems then
        for _, item in ipairs(runtimeItems:GetDescendants()) do
            if item:IsA("Model") then
                table.insert(items, item.Name)
            end
        end
    else
        warn("RuntimeItems folder not found!")
    end
    return items
end

local Dropdown = Tab:CreateDropdown({
   Name = "Choose item",
   Options = GetItemNames(), 
   CurrentOption = "Select an item",
   MultipleOptions = false,
   Flag = "ItemDropdown", 
   Callback = function(selectedItem)
       if type(selectedItem) == "table" then
           selectedItem = selectedItem[1] 
       end
   end,
})

local RefreshButton = Tab:CreateButton({
   Name = "Refresh Items",
   Callback = function()
       Dropdown:Refresh(GetItemNames())
   end,
})

local collectButton = Tab:CreateButton({
   Name = "Collect Selected Item",
   Callback = function()
       local selectedItemName = Dropdown.CurrentOption
       if type(selectedItemName) == "table" then
           selectedItemName = selectedItemName[1] 
       end

       if selectedItemName == "Select an item" then
           warn("No item selected!")
           return
       end

       local runtimeItems = workspace:FindFirstChild("RuntimeItems")
       if not runtimeItems then
           warn("RuntimeItems folder not found!")
           return
       end

       local selectedItem
       for _, item in ipairs(runtimeItems:GetDescendants()) do
           if item:IsA("Model") and item.Name == selectedItemName then
               selectedItem = item
               break
           end
       end

       if not selectedItem then
           warn("Item not found in RuntimeItems:", selectedItemName)
           return
       end

       local Players = game:GetService("Players")
       local LocalPlayer = Players.LocalPlayer
       if not LocalPlayer then
           warn("LocalPlayer not found!")
           return
       end

       local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
       local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

       if not selectedItem.PrimaryPart then
           warn(selectedItem.Name .. " has no PrimaryPart and cannot be moved.")
           return
       end

       selectedItem:SetPrimaryPartCFrame(HumanoidRootPart.CFrame + Vector3.new(0, 1, 0))
       print("Collected:", selectedItem.Name)
   end,
})

local collectAllButton = Tab:CreateButton({
   Name = "Collect All Items",
   Callback = function()
       local runtimeItems = workspace:FindFirstChild("RuntimeItems")
       if not runtimeItems then
           warn("RuntimeItems folder not found!")
           return
       end

       local ps = game:GetService("Players").LocalPlayer
       local ch = ps.Character or ps.CharacterAdded:Wait()
       local HumanoidRootPart = ch:WaitForChild("HumanoidRootPart")

       for _, item in ipairs(runtimeItems:GetDescendants()) do
           if item:IsA("Model") then
               if item.PrimaryPart then
                   local offset = HumanoidRootPart.CFrame.LookVector * 5
                   item:SetPrimaryPartCFrame(HumanoidRootPart.CFrame + offset)
               else
                   warn(item.Name .. " has no PrimaryPart .")
               end
           end
       end 
   end,
})

local ITEM_FOLDER = "RuntimeItems"
local PLAYER = game:GetService("Players").LocalPlayer

-- ?
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

    -- ?
    print("Checking items in", ITEM_FOLDER)
    for _, item in ipairs(itemsFolder:GetChildren()) do
        print("Found item:", item.Name) -- ?
    end

    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item:IsA("Model") then
            local lowerName = item.Name:lower()
            if lowerName:find("gun") or lowerName:find("weapon") or lowerName:find("ammo") 
                or lowerName:find("revolver") or lowerName:find("rifle") or lowerName:find("shotgun") then
                
                if item.PrimaryPart then
                    item:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0, 1, 0)) -- Move item to player
                else
                    -- ?
                    for _, part in ipairs(item:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CFrame = hrp.CFrame + Vector3.new(0, 1, 0)
                        end
                    end
                end
                wait(0.1) -- ?
            end
        end
    end
end

Tab:CreateButton({
    Name = "Bring Weapons & Ammo",
    Callback = function()
        bringWeaponsAndAmmo()
    end
})

local MiscTab = Window:CreateTab("Misc", 4483362458)

local defaultColor = Color3.fromRGB(25, 25, 25)

local ColorPicker = MiscTab:CreateColorPicker({
    Name = "UI Background Color",
    Color = defaultColor,
    Flag = "BackgroundColorPicker",
    Callback = function(Value)
        Rayfield.BackgroundColor3 = Value
    end
})

Rayfield.BackgroundColor3 = defaultColor
