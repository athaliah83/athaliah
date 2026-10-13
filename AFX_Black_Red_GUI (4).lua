-- AFX ALPHA FOR X GUI
-- Visual GUI + working controls for your own Roblox experience
-- Place in StarterPlayer > StarterPlayerScripts > LocalScript

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local RED = Color3.fromRGB(255, 20, 40)
local DARK = Color3.fromRGB(12, 7, 10)
local PANEL = Color3.fromRGB(23, 13, 17)
local WHITE = Color3.fromRGB(245, 240, 245)
local MUTED = Color3.fromRGB(165, 155, 165)

local old = playerGui:FindFirstChild("AFX_BloodDevil")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "AFX_BloodDevil"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 50
gui.Parent = playerGui

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    make("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, obj)
end

local function stroke(obj, color, thickness)
    make("UIStroke", {
        Color = color or RED,
        Thickness = thickness or 1,
        Transparency = 0.15
    }, obj)
end

local function label(parent, text, size, pos, color, font)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Position = pos,
        Size = size,
        Text = text,
        TextColor3 = color or WHITE,
        TextSize = 14,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    }, parent)
end

local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.92, 0, 0, 390),
    BackgroundColor3 = DARK,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, gui)
main.Size = UDim2.new(0.92, 0, 0.72, 0)
main.ClipsDescendants = false
make("UISizeConstraint", {
    MinSize = Vector2.new(300, 350),
    MaxSize = Vector2.new(650, 560)
}, main)
corner(main, 12)
stroke(main, RED, 2)

local glow = make("Frame", {
    Name = "RedGlow",
    Position = UDim2.new(0, 4, 0, 4),
    Size = UDim2.new(1, -8, 1, -8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0
}, main)
corner(glow, 10)
stroke(glow, Color3.fromRGB(120, 0, 15), 1)

-- Header
local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Color3.fromRGB(22, 5, 9),
    BorderSizePixel = 0
}, main)

local logo = label(header, "鬼", UDim2.new(0, 42, 1, 0),
    UDim2.new(0, 10, 0, 0), RED, Enum.Font.GothamBlack)
logo.TextSize = 28
logo.TextXAlignment = Enum.TextXAlignment.Center

local title = label(header, "The Blood Devil | AFX",
    UDim2.new(1, -110, 1, 0), UDim2.new(0, 54, 0, 0),
    WHITE, Enum.Font.GothamBold)
title.TextSize = 18
title.RichText = false

local close = make("TextButton", {
    Position = UDim2.new(1, -43, 0, 5),
    Size = UDim2.new(0, 36, 0, 36),
    BackgroundColor3 = Color3.fromRGB(55, 9, 17),
    Text = "X",
    TextColor3 = WHITE,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = true
}, header)
corner(close, 8)
stroke(close, RED, 1)

-- Drag window
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

close.Activated:Connect(function()
    gui:Destroy()
end)

-- Tabs
local tabs = make("Frame", {
    Position = UDim2.new(0, 12, 0, 57),
    Size = UDim2.new(1, -24, 0, 39),
    BackgroundTransparency = 1
}, main)

local tabLayout = make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 6)
}, tabs)

local content = make("Frame", {
    Position = UDim2.new(0, 12, 0, 104),
    Size = UDim2.new(1, -24, 1, -116),
    BackgroundColor3 = Color3.fromRGB(9, 7, 10),
    BorderSizePixel = 0
}, main)
corner(content, 9)
stroke(content, Color3.fromRGB(90, 12, 24), 1)

local pages = {}
local tabButtons = {}
local selectedTab = "Farming"

for _, name in ipairs({"Farming", "Rebirth", "Settings"}) do
    local btn = make("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1/3, -5, 1, 0),
        BackgroundColor3 = PANEL,
        Text = name == "Farming" and "⌂  Farming"
            or name == "Rebirth" and "⟳  Rebirth"
            or "⚙  Settings",
        TextColor3 = WHITE,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        LayoutOrder = #tabButtons + 1
    }, tabs)
    corner(btn, 7)
    stroke(btn, RED, 1)

    local page = make("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, -14, 1, -14),
        Position = UDim2.new(0, 7, 0, 7),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = RED,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = name == "Farming"
    }, content)

    make("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)

    pages[name] = page
    tabButtons[name] = btn

    btn.Activated:Connect(function()
        selectedTab = name
        for tabName, p in pairs(pages) do
            p.Visible = tabName == name
            tabButtons[tabName].BackgroundColor3 =
                tabName == name
                and Color3.fromRGB(150, 0, 20)
                or PANEL
        end
    end)
end

tabButtons.Farming.BackgroundColor3 = Color3.fromRGB(150, 0, 20)

local function heading(page, text)
    local h = label(page, text, UDim2.new(1, -8, 0, 30),
        UDim2.new(0, 4, 0, 0), RED, Enum.Font.GothamBold)
    h.TextSize = 19
    return h
end

local function info(page, text)
    local l = label(page, text, UDim2.new(1, -8, 0, 24),
        UDim2.new(0, 4, 0, 0), WHITE, Enum.Font.Gotham)
    l.TextSize = 13
    return l
end

local function toggleRow(page, text, initial, callback)
    local row = make("Frame", {
        Size = UDim2.new(1, -4, 0, 37),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0
    }, page)
    corner(row, 7)
    stroke(row, Color3.fromRGB(70, 25, 35), 1)

    local dot = make("Frame", {
        Position = UDim2.new(0, 7, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = RED,
        BorderSizePixel = 0
    }, row)
    corner(dot, 10)

    label(row, text, UDim2.new(1, -85, 1, 0),
        UDim2.new(0, 35, 0, 0), WHITE)

    local on = initial == true
    local track = make("TextButton", {
        Position = UDim2.new(1, -51, 0.5, -12),
        Size = UDim2.new(0, 43, 0, 24),
        BackgroundColor3 = on and RED or Color3.fromRGB(55, 53, 65),
        Text = "",
        AutoButtonColor = false
    }, row)
    corner(track, 15)

    local knob = make("Frame", {
        Position = on and UDim2.new(1, -21, 0, 3)
            or UDim2.new(0, 3, 0, 3),
        Size = UDim2.new(0, 18, 0, 18),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0
    }, track)
    corner(knob, 12)

    local function render()
        track.BackgroundColor3 = on and RED
            or Color3.fromRGB(55, 53, 65)
        knob.Position = on and UDim2.new(1, -21, 0, 3)
            or UDim2.new(0, 3, 0, 3)
    end

    track.Activated:Connect(function()
        on = not on
        render()
        if callback then callback(on) end
    end)

    if callback then callback(on) end
    return function() return on end
end

local function actionButton(page, text, callback)
    local btn = make("TextButton", {
        Size = UDim2.new(1, -4, 0, 40),
        BackgroundColor3 = Color3.fromRGB(170, 0, 25),
        Text = text,
        TextColor3 = WHITE,
        TextSize = 15,
        Font = Enum.Font.GothamBold
    }, page)
    corner(btn, 7)
    stroke(btn, RED, 1)
    btn.Activated:Connect(callback)
    return btn
end

-- Farming page
local farming = pages.Farming
heading(farming, "💪  Farming")
local strengthLabel = info(farming, "Strength: 0")
local rebirthLabel = info(farming, "Rebirths: 0")
info(farming, "REBIRTH RATE")
local rateLabel = info(farming, "Rebirths 1H: 0 | 1D: 0 | 1W: 0 | 1M: 0")

toggleRow(farming, "Auto Train (visual only)", false)
toggleRow(farming, "Auto Collect (visual only)", false)
toggleRow(farming, "Auto Sell (visual only)", false)
toggleRow(farming, "Auto Lift (visual only)", false)

-- Rebirth page
local rebirth = pages.Rebirth
heading(rebirth, "⟳  Rebirth")
info(rebirth, "Rebirths: 0")
info(rebirth, "Rebirth Rate:")
info(rebirth, "1H: 0 | 1D: 0 | 1W: 0 | 1M: 0")

toggleRow(rebirth, "Auto Rebirth (visual only)", false)
toggleRow(rebirth, "Fast Rebirth (visual only)", false)
toggleRow(rebirth, "Controlled Speed (visual only)", false)

actionButton(rebirth, "Rebirth (demo)", function()
    local msg = info(rebirth, "Demo only: connect this to your own game's rebirth system.")
    msg.TextColor3 = RED
end)

-- Settings page
local settings = pages.Settings
heading(settings, "⚙  Settings")

toggleRow(settings, "Show FPS (display toggle)", false, function(on)
    -- UI placeholder; no FPS counter is created here.
end)

toggleRow(settings, "Anti AFK (visual only)", false)

local function numberSetting(page, text, default, min, max, callback)
    local row = make("Frame", {
        Size = UDim2.new(1, -4, 0, 42),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0
    }, page)
    corner(row, 7)
    stroke(row, Color3.fromRGB(70, 25, 35), 1)

    label(row, text, UDim2.new(0.43, 0, 1, 0),
        UDim2.new(0, 8, 0, 0), WHITE)

    local input = make("TextBox", {
        Position = UDim2.new(0.46, 0, 0.5, -14),
        Size = UDim2.new(0.34, 0, 0, 28),
        BackgroundColor3 = DARK,
        Text = tostring(default),
        TextColor3 = WHITE,
        PlaceholderText = tostring(default),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false
    }, row)
    corner(input, 5)
    stroke(input, RED, 1)

    local apply = make("TextButton", {
        Position = UDim2.new(1, -47, 0.5, -14),
        Size = UDim2.new(0, 40, 0, 28),
        BackgroundColor3 = RED,
        Text = "SET",
        TextColor3 = WHITE,
        TextSize = 11,
        Font = Enum.Font.GothamBold
    }, row)
    corner(apply, 5)

    local function update()
        local value = tonumber(input.Text)
        if value then
            value = math.clamp(value, min, max)
            input.Text = tostring(value)
            callback(value)
        else
            input.Text = tostring(default)
        end
    end

    apply.Activated:Connect(update)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then update() end
    end)
end

local desiredSpeed = 16
local desiredJump = 50

local function applyCharacterSettings()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.WalkSpeed = desiredSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = desiredJump
end

numberSetting(settings, "WalkSpeed", 16, 0, 100, function(value)
    desiredSpeed = value
    applyCharacterSettings()
end)

numberSetting(settings, "JumpPower", 50, 0, 200, function(value)
    desiredJump = value
    applyCharacterSettings()
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyCharacterSettings()
end)

local themeRow = make("Frame", {
    Size = UDim2.new(1, -4, 0, 38),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
}, settings)
corner(themeRow, 7)

label(themeRow, "Theme", UDim2.new(0.4, 0, 1, 0),
    UDim2.new(0, 8, 0, 0), WHITE)

local themeBtn = make("TextButton", {
    Position = UDim2.new(0.45, 0, 0, 4),
    Size = UDim2.new(0.5, 0, 0, 30),
    BackgroundColor3 = Color3.fromRGB(70, 0, 12),
    Text = "RED  ◀",
    TextColor3 = WHITE,
    TextSize = 13,
    Font = Enum.Font.GothamBold
}, themeRow)
corner(themeBtn, 5)

local redTheme = true
themeBtn.Activated:Connect(function()
    redTheme = not redTheme
    local accent = redTheme
        and Color3.fromRGB(255, 20, 40)
        or Color3.fromRGB(150, 65, 255)

    themeBtn.Text = redTheme and "RED  ◀" or "PURPLE  ◀"
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("UIStroke") then
            obj.Color = accent
        end
    end
    close.TextColor3 = accent
end)

-- Small open/close button after minimizing
local reopen = make("TextButton", {
    Visible = false,
    Position = UDim2.new(0, 12, 0.5, -22),
    Size = UDim2.new(0, 110, 0, 44),
    BackgroundColor3 = DARK,
    Text = "AFX  ☠",
    TextColor3 = RED,
    TextSize = 16,
    Font = Enum.Font.GothamBold
}, gui)
corner(reopen, 9)
stroke(reopen, RED, 2)

-- Minimize by tapping the logo
logo.Active = true
logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        main.Visible = false
        reopen.Visible = true
    end
end)

reopen.Activated:Connect(function()
    main.Visible = true
    reopen.Visible = false
end)

print("AFX Blood Devil GUI loaded successfully.")

