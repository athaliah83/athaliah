-- AFX | SIMPLE BLACK & RED GUI
-- For your own Roblox experience:
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.
-- The switches below are UI demos; connect them to your own game systems.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("AFXGui")
if old then old:Destroy() end

local RED = Color3.fromRGB(235, 45, 55)
local BG = Color3.fromRGB(18, 18, 22)
local PANEL = Color3.fromRGB(30, 30, 36)
local WHITE = Color3.fromRGB(245, 245, 248)
local MUTED = Color3.fromRGB(165, 165, 175)
local OFF = Color3.fromRGB(72, 72, 82)

local function make(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 7)}, obj)
end

local gui = make("ScreenGui", {
    Name = "AFXGui",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(430, 310),
    Position = UDim2.new(0.5, -215, 0.5, -155),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
}, gui)
round(main, 10)
make("UIStroke", {Color = RED, Thickness = 1.5}, main)

local header = make("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
}, main)
round(header, 9)

make("Frame", {
    Position = UDim2.new(0, 0, 1, -3),
    Size = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = RED,
    BorderSizePixel = 0,
}, header)

make("TextLabel", {
    Position = UDim2.fromOffset(13, 0),
    Size = UDim2.new(1, -100, 1, 0),
    BackgroundTransparency = 1,
    Text = "AFX  /  BLACK & RED",
    TextColor3 = WHITE,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local minimize = make("TextButton", {
    Size = UDim2.fromOffset(28, 27),
    Position = UDim2.new(1, -64, 0, 8),
    BackgroundColor3 = OFF,
    Text = "–",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true,
}, header)
round(minimize, 5)

local close = make("TextButton", {
    Size = UDim2.fromOffset(28, 27),
    Position = UDim2.new(1, -32, 0, 8),
    BackgroundColor3 = RED,
    Text = "×",
    TextColor3 = WHITE,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true,
}, header)
round(close, 5)

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(8, 53),
    Size = UDim2.new(0, 112, 1, -61),
    BackgroundTransparency = 1,
}, main)
make("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)

local content = make("Frame", {
    Position = UDim2.fromOffset(128, 53),
    Size = UDim2.new(1, -136, 1, -61),
    BackgroundTransparency = 1,
}, main)

local pages, navButtons = {}, {}

local function newPage(name)
    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = RED,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false,
    }, content)

    make("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)

    make("UIPadding", {
        PaddingRight = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 6),
    }, page)

    pages[name] = page
    return page
end

local function showPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end
    for buttonName, button in pairs(navButtons) do
        button.BackgroundColor3 = buttonName == name and RED or PANEL
    end
end

local function addTab(name)
    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = PANEL,
        Text = name,
        TextColor3 = WHITE,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = true,
    }, sidebar)
    round(button, 6)
    navButtons[name] = button
    button.MouseButton1Click:Connect(function()
        showPage(name)
    end)
end

local function addHeading(page, title)
    return make("TextLabel", {
        Size = UDim2.new(1, -2, 0, 27),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = RED,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, page)
end

local function addToggle(page, title, callback)
    local enabled = false
    local row = make("Frame", {
        Size = UDim2.new(1, -2, 0, 34),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
    }, page)
    round(row, 6)

    make("TextLabel", {
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -64, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = WHITE,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local toggle = make("TextButton", {
        Position = UDim2.new(1, -53, 0.5, -10),
        Size = UDim2.fromOffset(44, 20),
        BackgroundColor3 = OFF,
        Text = "OFF",
        TextColor3 = WHITE,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    }, row)
    round(toggle, 5)

    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "ON" or "OFF"
        toggle.BackgroundColor3 = enabled and RED or OFF
        callback(enabled)
    end)
end

local function addButton(page, title, callback)
    local button = make("TextButton", {
        Size = UDim2.new(1, -2, 0, 33),
        BackgroundColor3 = PANEL,
        Text = title,
        TextColor3 = WHITE,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = true,
    }, page)
    round(button, 6)
    make("UIStroke", {Color = Color3.fromRGB(65, 40, 45), Thickness = 1}, button)
    button.MouseButton1Click:Connect(callback)
end

local tabNames = {"Home", "Main", "Rocks", "Rebirth", "Auto Kill", "Teleport", "Status", "Misc"}
for _, name in ipairs(tabNames) do
    addTab(name)
    newPage(name)
end

local home = pages.Home
addHeading(home, "Welcome to AFX")
addButton(home, "Open Main Tab", function()
    showPage("Main")
end)
make("TextLabel", {
    Size = UDim2.new(1, -2, 0, 40),
    BackgroundTransparency = 1,
    Text = "Simple black and red interface.",
    TextColor3 = MUTED,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
}, home)

local mainPage = pages.Main
addHeading(mainPage, "Main Options")
for _, name in ipairs({
    "Jungle Bench", "Jungle Bar Lift", "Jungle Squat",
    "Auto Equip Weight", "Auto Equip Pushups", "Auto Equip Situps",
    "Auto Equip Handstands",
}) do
    addToggle(mainPage, name, function(on)
        print(name, on and "ON" or "OFF", "(demo toggle)")
    end)
end

local rocks = pages.Rocks
addHeading(rocks, "Rock Options")
for _, name in ipairs({"Auto Punch Rock", "Auto Punch No Anim", "Speed Punch", "Normal Punch", "Tiny Rock"}) do
    addToggle(rocks, name, function(on)
        print(name, on and "ON" or "OFF", "(demo toggle)")
    end)
end

local rebirth = pages.Rebirth
addHeading(rebirth, "Rebirth Options")
for _, name in ipairs({"Auto Rebirth", "Auto Size 2", "Hide All Frames"}) do
    addToggle(rebirth, name, function(on)
        print(name, on and "ON" or "OFF", "(demo toggle)")
    end)
end

local kill = pages["Auto Kill"]
addHeading(kill, "Combat Options")
for _, name in ipairs({"Auto Kill Boss", "Auto Collect"}) do
    addToggle(kill, name, function(on)
        print(name, on and "ON" or "OFF", "(demo toggle)")
    end)
end

local teleport = pages.Teleport
addHeading(teleport, "Teleport Options")
addButton(teleport, "Go to Spawn", function()
    -- Example for your own game; change this destination to your spawn location.
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(0, 10, 0)
    end
end)

local status = pages.Status
addHeading(status, "System Status")
make("TextLabel", {
    Size = UDim2.new(1, -2, 0, 58),
    BackgroundColor3 = PANEL,
    Text = "Game: " .. game.Name .. "\nPlayer: " .. player.Name .. "\nGUI: Loaded",
    TextColor3 = WHITE,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
}, status)

local misc = pages.Misc
addHeading(misc, "Miscellaneous")
addToggle(misc, "Infinite Jump UI (demo)", function(on)
    print("Infinite Jump UI demo", on)
end)
addButton(misc, "Reset Character", function()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = 0
    end
end)

-- Drag the window by its header.
local dragging, dragStart, startPosition = false, nil, nil
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    sidebar.Visible = not minimized
    content.Visible = not minimized
    main.Size = minimized and UDim2.fromOffset(250, 44) or UDim2.fromOffset(430, 310)
    minimize.Text = minimized and "+" or "–"
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

showPage("Home")
print("AFX Black & Red GUI loaded")
