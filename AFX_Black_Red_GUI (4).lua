
--// XINN SCRIPT + ESP + AIM TARGET SELECTION
--// For your own Roblox Studio experience
--// Place inside StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local Settings = {
    ESP = true,
    Name = true,
    Health = true,
    Distance = true,
    Highlight = true,
    Box = true,
    HeadDot = true,

    AimEnabled = false,
    TeamCheck = false,
    FOVVisible = true,
    FOVRadius = 130,
    TargetPart = "Head"
}

local ESPObjects = {}
local CurrentTarget = nil

--// REMOVE OLD GUI
local old = PG:FindFirstChild("XINN_SCRIPT")
if old then
    old:Destroy()
end

--// MAIN GUI
local gui = Instance.new("ScreenGui")
gui.Name = "XINN_SCRIPT"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
gui.Parent = PG

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(350, 430)
main.Position = UDim2.new(0.5, -175, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(12, 8, 10)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(255, 20, 40)
outline.Thickness = 2
outline.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 0, 50)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "XINN SCRIPT"
title.TextColor3 = Color3.fromRGB(255, 25, 45)
title.TextSize = 23
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35, 32)
close.Position = UDim2.new(1, -43, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(150, 0, 15)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Parent = main

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(35, 32)
minimize.Position = UDim2.new(1, -83, 0, 8)
minimize.BackgroundColor3 = Color3.fromRGB(45, 35, 38)
minimize.Text = "-"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.Parent = main

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -65)
content.Position = UDim2.fromOffset(10, 55)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Color3.fromRGB(255, 20, 40)
content.CanvasSize = UDim2.fromOffset(0, 650)
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = content

local function makeSection(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -5, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 30, 50)
    label.TextSize = 17
    label.Font = Enum.Font.GothamBlack
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = content
end

local function makeToggle(labelText, setting)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -5, 0, 38)
    button.BackgroundColor3 = Color3.fromRGB(35, 25, 28)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = content

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

    local function refresh()
        button.Text = labelText .. " : " ..
            (Settings[setting] and "ON" or "OFF")

        button.BackgroundColor3 = Settings[setting]
            and Color3.fromRGB(130, 0, 15)
            or Color3.fromRGB(35, 25, 28)
    end

    button.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        refresh()
    end)

    refresh()
end

--// ESP CONTROLS
makeSection("PLAYER ESP")

makeToggle("MASTER ESP", "ESP")
makeToggle("NAME ESP", "Name")
makeToggle("HEALTH ESP", "Health")
makeToggle("DISTANCE ESP", "Distance")
makeToggle("HIGHLIGHT", "Highlight")
makeToggle("BOX ESP", "Box")
makeToggle("HEAD DOT", "HeadDot")

--// AIM CONTROLS
makeSection("AIM SETTINGS")

makeToggle("TARGET SELECTION", "AimEnabled")
makeToggle("TEAM CHECK", "TeamCheck")
makeToggle("SHOW FOV CIRCLE", "FOVVisible")

local targetPartButton = Instance.new("TextButton")
targetPartButton.Size = UDim2.new(1, -5, 0, 38)
targetPartButton.BackgroundColor3 = Color3.fromRGB(35, 25, 28)
targetPartButton.TextColor3 = Color3.new(1, 1, 1)
targetPartButton.Font = Enum.Font.GothamBold
targetPartButton.TextSize = 14
targetPartButton.Parent = content

local function refreshTargetPart()
    targetPartButton.Text = "TARGET PART : " .. Settings.TargetPart
end

targetPartButton.MouseButton1Click:Connect(function()
    Settings.TargetPart =
        Settings.TargetPart == "Head"
        and "HumanoidRootPart"
        or "Head"

    refreshTargetPart()
end)

refreshTargetPart()

local radiusButton = Instance.new("TextButton")
radiusButton.Size = UDim2.new(1, -5, 0, 38)
radiusButton.BackgroundColor3 = Color3.fromRGB(35, 25, 28)
radiusButton.TextColor3 = Color3.new(1, 1, 1)
radiusButton.Font = Enum.Font.GothamBold
radiusButton.TextSize = 14
radiusButton.Parent = content

local function refreshRadius()
    radiusButton.Text = "FOV SIZE : " .. Settings.FOVRadius
end

radiusButton.MouseButton1Click:Connect(function()
    Settings.FOVRadius += 20
    if Settings.FOVRadius > 250 then
        Settings.FOVRadius = 70
    end
    refreshRadius()
end)

refreshRadius()

--// FOV CIRCLE
local fov = Instance.new("Frame")
fov.Name = "FOVCircle"
fov.AnchorPoint = Vector2.new(0.5, 0.5)
fov.Size = UDim2.fromOffset(
    Settings.FOVRadius * 2,
    Settings.FOVRadius * 2
)
fov.BackgroundTransparency = 1
fov.Visible = Settings.FOVVisible
fov.Parent = gui

Instance.new("UICorner", fov).CornerRadius = UDim.new(1, 0)

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255, 20, 40)
fovStroke.Thickness = 2
fovStroke.Parent = fov

--// TARGET DISPLAY
local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.fromOffset(230, 30)
targetLabel.Position = UDim2.new(0, 10, 1, -40)
targetLabel.BackgroundColor3 = Color3.fromRGB(15, 10, 12)
targetLabel.TextColor3 = Color3.fromRGB(255, 30, 45)
targetLabel.Text = "TARGET: NONE"
targetLabel.TextSize = 13
targetLabel.Font = Enum.Font.GothamBold
targetLabel.Parent = gui

--// ESP CLEANUP
local function removeESP(player)
    local data = ESPObjects[player]
    if not data then return end

    for _, object in pairs(data) do
        if typeof(object) == "Instance" then
            object:Destroy()
        end
    end

    ESPObjects[player] = nil
end

--// CREATE PLAYER ESP
local function addESP(player, character)
    if player == LP then return end

    removeESP(player)

    local humanoid = character:WaitForChild("Humanoid", 5)
    local head = character:WaitForChild("Head", 5)

    if not humanoid or not head then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "XINN_Highlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 20)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.55
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "XINN_Info"
    billboard.Size = UDim2.fromOffset(230, 40)
    billboard.Adornee = head
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = PG

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = billboard

    local box = Instance.new("SelectionBox")
    box.Name = "XINN_Box"
    box.Adornee = character
    box.Color3 = Color3.fromRGB(255, 0, 20)
    box.LineThickness = 0.04
    box.Parent = character

    local dot = Instance.new("BillboardGui")
    dot.Name = "XINN_HeadDot"
    dot.Size = UDim2.fromOffset(10, 10)
    dot.Adornee = head
    dot.AlwaysOnTop = true
    dot.Parent = PG

    local dotFrame = Instance.new("Frame")
    dotFrame.Size = UDim2.fromScale(1, 1)
    dotFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 20)
    dotFrame.Parent = dot

    Instance.new("UICorner", dotFrame).CornerRadius = UDim.new(1, 0)

    ESPObjects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Box = box,
        Dot = dot,
        Character = character
    }
end

--// PLAYER SETUP
local function setupPlayer(player)
    if player == LP then return end

    player.CharacterAdded:Connect(function(character)
        addESP(player, character)
    end)

    player.CharacterRemoving:Connect(function()
        removeESP(player)
    end)

    if player.Character then
        task.spawn(addESP, player, player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeESP)

--// FIND CLOSEST TARGET INSIDE FOV
local function getClosestTarget()
    local closest = nil
    local shortest = Settings.FOVRadius
    local mousePosition = UIS:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local character = player.Character
            local humanoid = character
                and character:FindFirstChildOfClass("Humanoid")

            local sameTeam = Settings.TeamCheck
                and LP.Team ~= nil
                and player.Team == LP.Team

            if character and humanoid
                and humanoid.Health > 0
                and not sameTeam then

                local part = character:FindFirstChild(Settings.TargetPart)
                    or character:FindFirstChild("HumanoidRootPart")

                if part then
                    local screenPosition, onScreen =
                        Camera:WorldToViewportPoint(part.Position)

                    if onScreen and screenPosition.Z > 0 then
                        local point = Vector2.new(
                            screenPosition.X,
                            screenPosition.Y
                        )

                        local distance = (mousePosition - point).Magnitude

                        if distance < shortest then
                            shortest = distance
                            closest = player
                        end
                    end
                end
            end
        end
    end

    return closest
end

--// UPDATE LOOP
local connection

connection = RunService.RenderStepped:Connect(function()
    if not gui.Parent then
        connection:Disconnect()
        return
    end

    local mousePosition = UIS:GetMouseLocation()

    fov.Position = UDim2.fromOffset(
        mousePosition.X,
        mousePosition.Y
    )

    fov.Size = UDim2.fromOffset(
        Settings.FOVRadius * 2,
        Settings.FOVRadius * 2
    )

    fov.Visible = Settings.FOVVisible

    if Settings.AimEnabled then
        CurrentTarget = getClosestTarget()
    else
        CurrentTarget = nil
    end

    targetLabel.Text = CurrentTarget
        and "TARGET: " .. CurrentTarget.Name
        or "TARGET: NONE"

    for player, data in pairs(ESPObjects) do
        local character = data.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")
        local root = character
            and character:FindFirstChild("HumanoidRootPart")

        local active = Settings.ESP
            and character ~= nil
            and character.Parent ~= nil
            and humanoid ~= nil
            and root ~= nil
            and humanoid.Health > 0

        data.Highlight.Enabled = active and Settings.Highlight or false

        data.Billboard.Enabled = active
            and (Settings.Name or Settings.Health or Settings.Distance)
            or false

        data.Box.Visible = active and Settings.Box or false
        data.Dot.Enabled = active and Settings.HeadDot or false

        if active then
            local info = {}

            if Settings.Name then
                table.insert(info, player.Name)
            end

            if Settings.Health then
                table.insert(
                    info,
                    "HP: " .. math.floor(humanoid.Health)
                )
            end

            if Settings.Distance then
                local myCharacter = LP.Character
                local myRoot = myCharacter
                    and myCharacter:FindFirstChild("HumanoidRootPart")

                if myRoot then
                    local distance = math.floor(
                        (root.Position - myRoot.Position).Magnitude
                    )
                    table.insert(info, distance .. " studs")
                end
            end

            data.Label.Text = table.concat(info, " | ")
        end
    end
end)

--// MINIMIZE
local minimized = false

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized

    main.Size = minimized
        and UDim2.fromOffset(350, 50)
        or UDim2.fromOffset(350, 430)
end)

--// CLOSE
close.MouseButton1Click:Connect(function()
    if connection then
        connection:Disconnect()
    end

    for player in pairs(ESPObjects) do
        removeESP(player)
    end

    gui:Destroy()
end)

print("XINN SCRIPT loaded successfully!")
