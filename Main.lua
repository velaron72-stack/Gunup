local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local HIGHLIGHT_COLOR = Color3.fromRGB(255, 220, 0)
local TP_OFFSET = Vector3.new(0, 3, 0)
local TP_DELAY = 0.05
local AUTO_GRAB = true
local SCAN_INTERVAL = 0.75
local GUN_NAME = "GunDrop"

if PG:FindFirstChild("GunDropTP") then PG.GunDropTP:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "GunDropTP"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PG

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 75)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
title.Text = "GunDrop TP"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BorderSizePixel = 0
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.9, 0, 0, 30)
tpBtn.Position = UDim2.new(0.05, 0, 0, 35)
tpBtn.BackgroundColor3 = Color3.fromRGB(45, 80, 140)
tpBtn.Text = "TP к стволу"
tpBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
tpBtn.Font = Enum.Font.Gotham
tpBtn.TextSize = 13
tpBtn.BorderSizePixel = 0
tpBtn.Parent = frame
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

local savedCFrame = nil
local highlight = nil
local currentGun = nil

local function attachHighlight(part)
    if highlight and highlight.Parent == part then return end
    if highlight then highlight:Destroy() end
    if part:FindFirstChild("GunDropHL") then part.GunDropHL:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = "GunDropHL"
    hl.Adornee = part
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = HIGHLIGHT_COLOR
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.Parent = part

    local bb = Instance.new("BillboardGui")
    bb.Name = "GunDropBillboard"
    bb.Size = UDim2.new(0, 80, 0, 24)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Gun"
    label.TextColor3 = HIGHLIGHT_COLOR
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = bb

    highlight = hl
end

local function clearHighlight()
    if highlight then
        highlight:Destroy()
        highlight = nil
    end
end

local function findDroppedGun()
    local found = workspace:FindFirstChild(GUN_NAME, true)
    if found then
        if found:IsA("BasePart") then
            return found
        elseif found:IsA("Tool") and found:FindFirstChild("Handle") then
            return found.Handle
        end
    end
    return nil
end

local function refreshHighlight()
    local gun = findDroppedGun()
    if gun then
        if gun ~= currentGun then
            currentGun = gun
            attachHighlight(gun)
        end
    else
        if currentGun then
            currentGun = nil
            clearHighlight()
        end
    end
end

tpBtn.MouseButton1Click:Connect(function()
    local gun = findDroppedGun()
    if not gun then
        tpBtn.Text = "Ты че еблан?"
        tpBtn.BackgroundColor3 = Color3.fromRGB(140, 45, 45)
        task.delay(2, function()
            tpBtn.Text = "TP к стволу"
            tpBtn.BackgroundColor3 = Color3.fromRGB(45, 80, 140)
        end)
        return
    end

    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    savedCFrame = hrp.CFrame
    hrp.CFrame = CFrame.new(gun.Position + TP_OFFSET)

    if AUTO_GRAB then
        pcall(function()
            firetouchinterest(hrp, gun, 0)
            firetouchinterest(hrp, gun, 1)
        end)
    end

    task.delay(TP_DELAY, function()
        if savedCFrame and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = savedCFrame
            savedCFrame = nil
        end
    end)

    tpBtn.Text = "TP + возврат"
    task.delay(0.8, function()
        tpBtn.Text = "TP к стволу"
    end)
end)

workspace.DescendantAdded:Connect(function(obj)
    if obj.Name == GUN_NAME then
        task.wait(0.05)
        refreshHighlight()
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    if obj.Name == GUN_NAME then
        task.wait(0.05)
        refreshHighlight()
    end
end)

task.spawn(function()
    while gui.Parent do
        refreshHighlight()
        task.wait(SCAN_INTERVAL)
    end
end)

print("[GunDropTP] loaded")
