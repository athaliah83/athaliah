-- AFX BLOOD DEVIL GUI
-- Intro + Main Menu | Mobile Friendly
-- For your own Roblox Studio experience
-- Place in StarterPlayer > StarterPlayerScripts as a LocalScript

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Colors
local RED = Color3.fromRGB(255, 35, 55)
local DARK = Color3.fromRGB(12, 7, 10)
local PANEL = Color3.fromRGB(28, 15, 20)
local WHITE = Color3.fromRGB(245, 240, 245)
local MUTED = Color3.fromRGB(165, 155, 165)

-- Remove old copy
local oldGui = playerGui:FindFirstChild("AFXScriptGUI")
if oldGui then
    oldGui:Destroy()
end

-- Helpers
local function make(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function round(object, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, object)
end

local function outline(object, color, thickness)
    make("UIStroke", {
        Color = color or RED,
        Thickness = thickness or 1
    }, object)
end

local function addLabel(parent, text, size, position, textSize, color)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Size = size,
        Position = position,
        Text = text,
        TextColor3 = color or WHITE,
        TextSize = textSize or 14,
        Font = Enum.Font.GothamBold,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

local gui = make("ScreenGui", {
    Name = "AFXScriptGUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 50
}, playerGui)

-- Intro screen
local intro = make("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = DARK,
    BorderSizePixel = 0
}, gui)

local introTitle = addLabel(
    intro,
    "AFX BLOOD DEVIL",
    UDim2.new(0.9, 0, 0, 60),
    UDim2.new(0.05, 0, 0.28, 0),
    30,
    RED
)

addLabel(
    intro,
    "WELCOME BACK",
    UDim2.new(0.9, 0, 0, 30),
    UDim2.new(0.05, 0, 0.40, 0),
    15,
    WHITE
)

addLabel(
    intro,
    player.Name,
    UDim2.new(0.9, 0, 0, 35),
    UDim2.new(0.05, 0, 0.46, 0),
    22,
    RED
)

local barBack = make("Frame", {
    Size = UDim2.new(0.65, 0, 0, 8),
    Position = UDim2.new(0.175, 0, 0.56, 0),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
}, intro)
round(barBack, 8)

local barFill = make("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = RED,
    BorderSizePixel = 0
}, barBack)
round(barFill, 8)

local percent = addLabel(
    intro,
    "LOADING 0%",
    UDim2.new(0.9, 0, 0, 25),
    UDim2.new(0.05, 0, 0.59, 0),
    13,
    WHITE
)

local skip = make("TextButton", {
    Size = UDim2.new(0, 110, 0, 38),
    Position = UDim2.new(0.5, -55, 0.69, 0),
    BackgroundColor3 = RED,
    Text = "SKIP",
    TextColor3 = WHITE,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    Visible = false
}, intro)
round(skip, 8)

-- Main window
local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.9, 0, 0.65, 0),
    BackgroundColor3 = DARK,
    BorderSizePixel = 0,
    Visible = false
}, gui)
make("UISizeConstraint", {
    MinSize = Vector2.new(280, 300),
    MaxSize = Vector2.new(600, 520)
}, main)
round(main, 12)
outline(main, RED, 2)

-- Header
local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Color3.fromRGB(35, 5, 12),
    BorderSizePixel = 0
}, main)
round(header, 10)

addLabel(
    header,
    "☠  AFX Alpha For X",
    UDim2.new(1, -60, 1, 0),
    UDim2.new(0, 8, 0, 0),
    17,
    RED
)

local closeButton = make("TextButton", {
    Size = UDim2.new(0, 34, 0, 34),
    Position = UDim2.new(1, -40, 0, 7),
    BackgroundColor3 = RED,
    Text = "X",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold
}, header)
round(closeButton, 7)

-- Tabs
local tabs = make("Frame", {
    Position = UDim2.new(0, 8, 0, 56),
    Size = UDim2.new(1, -16, 0, 38),
    BackgroundTransparency = 1
}, main)

make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder
}, tabs)

-- Content panel
local content = make("Frame", {
    Position = UDim2.new(0, 8, 0, 101),
    Size = UDim2.new(1, -16, 1, -110),
    BackgroundColor3 = Color3.fromRGB(18, 10, 14),
    BorderSizePixel = 0
}, main)
round(content, 8)
outline(content, Color3.fromRGB(100, 15, 30), 1)

local pages = {}
local buttons = {}

local function makePage(name)
    local page = make("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, -14, 1, -14),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = RED,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false
    }, content)

    make("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    pages[name] = page
    return page
end

local function heading(page, text)
    addLabel(
        page,
        text,
        UDim2.new(1, -8, 0, 34),
        UDim2.new(0, 4, 0, 0),
        18,
        RED
    )
end

local function info(page, text)
    local row = make("Frame", {
        Size = UDim2.new(1, -4, 0, 32),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0
    }, page)
    round(row, 6)

    addLabel(
        row,
        text,
        UDim2.new(1, -12, 1, 0),
        UDim2.new(0, 6, 0, 0),
        13,
        WHITE
    )
end

local function toggle(page, text)
    local row = make("Frame", {
        Size = UDim2.new(1, -4, 0, 40),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0
    }, page)
    round(row, 7)

    local textLabel = make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -75, 1, 0),
        Text = text,
        TextColor3 = WHITE,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, row)

    local on = false
    local button = make("TextButton", {
        Position = UDim2.new(1, -58, 0.5, -12),
        Size = UDim2.new(0, 48, 0, 24),
        BackgroundColor3 = Color3.fromRGB(60, 55, 65),
        Text = "OFF",
        TextColor3 = WHITE,
        TextSize = 11,
        Font = Enum.Font.GothamBold
    }, row)
    round(button, 12)

    button.Activated:Connect(function()
        on = not on
        button.Text = on and "ON" or "OFF"
        button.BackgroundColor3 = on
            and RED
            or Color3.fromRGB(60, 55, 65)
    end)
end

local function actionButton(page, text, callback)
    local button = make("TextButton", {
        Size = UDim2.new(1, -4, 0, 40),
        BackgroundColor3 = Color3.fromRGB(150, 0, 25),
        Text = text,
        TextColor3 = WHITE,
        TextSize = 14,
        Font = Enum.Font.GothamBold
    }, page)
    round(button, 7)
    outline(button, RED, 1)
    button.Activated:Connect(callback)
end

-- Create tabs and pages
local tabNames = {"Farming", "Rebirth", "Settings"}

for index, name in ipairs(tabNames) do
    local button = make("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1/3, -5, 1, 0),
        BackgroundColor3 = PANEL,
        Text = name,
        TextColor3 = WHITE,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        LayoutOrder = index
    }, tabs)
    round(button, 6)

    local page = makePage(name)
    buttons[name] = button

    button.Activated:Connect(function()
        for tabName, tabPage in pairs(pages) do
            tabPage.Visible = tabName == name
            buttons[tabName].BackgroundColor3 =
                tabName == name and RED or PANEL
        end
    end)
end

-- Farming page
local farming = pages.Farming
heading(farming, "FARMING")
info(farming, "Player: " .. player.Name)
info(farming, "Strength: display demo")
toggle(farming, "Auto Train (visual only)")
toggle(farming, "Auto Collect (visual only)")
toggle(farming, "Auto Sell (visual only)")
toggle(farming, "Auto Lift (visual only)")

-- Rebirth page
local rebirth = pages.Rebirth
heading(rebirth, "REBIRTH")
info(rebirth, "Rebirths: display demo")
toggle(rebirth, "Fast Rebirth (visual only)")
toggle(rebirth, "Controlled Speed (visual only)")
actionButton(rebirth, "Rebirth Demo", function()
    info(rebirth, "Demo button pressed; no rebirth was performed.")
end)

-- Settings page
local settings = pages.Settings
heading(settings, "SETTINGS")
toggle(settings, "Show FPS (visual toggle only)")
toggle(settings, "Anti AFK (visual toggle only)")

local themeButton = make("TextButton", {
    Size = UDim2.new(1, -4, 0, 38),
    BackgroundColor3 = RED,
    Text = "Change Theme: RED / PURPLE",
    TextColor3 = WHITE,
    TextSize = 13,
    Font = Enum.Font.GothamBold
}, settings)
round(themeButton, 7)

local purple = false
themeButton.Activated:Connect(function()
    purple = not purple
    local accent = purple
        and Color3.fromRGB(160, 70, 255)
        or RED

    themeButton.BackgroundColor3 = accent
    for _, object in ipairs(gui:GetDescendants()) do
        if object:IsA("UIStroke") then
            object.Color = accent
        elseif object:IsA("TextButton") then
            if object.Text == "Farming"
                or object.Text == "Rebirth"
                or object.Text == "Settings" then
                object.BackgroundColor3 = PANEL
            end
        end
    end
end)

-- Open/close
closeButton.Activated:Connect(function()
    main.Visible = false
end)

-- Intro progress and skip
local finished = false

local function showMain()
    if finished then return end
    finished = true
    intro.Visible = false
    main.Visible = true
    pages.Farming.Visible = true
    buttons.Farming.BackgroundColor3 = RED
end

skip.Activated:Connect(showMain)

task.spawn(function()
    for progress = 1, 100 do
        if finished then return end
        barFill.Size = UDim2.new(progress / 100, 0, 1, 0)
        percent.Text = "LOADING " .. progress .. "%"
        if progress >= 10 then
            skip.Visible = true
        end
        task.wait(0.025)
    end
    task.wait(0.4)
    showMain()
end)

print("AFX Alpha For X GUI loaded.")
