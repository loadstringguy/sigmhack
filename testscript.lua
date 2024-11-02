if getgenv().sigmhack then
    warn("Script already loaded or is loading")
    return
end
getgenv().sigmhack = true

print('Loading AC Bypass!')
if not LPH_OBFUSCATED then
    getfenv().LPH_NO_VIRTUALIZE = function(f) return f end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Handshake = ReplicatedStorage.Remotes.CharacterSoundEvent
local Hooks = {}
local HandshakeInts = {}

LPH_NO_VIRTUALIZE(function()
    for i, v in getgc() do
        if typeof(v) == "function" and islclosure(v) then
            if (#getprotos(v) == 1) and table.find(getconstants(getproto(v, 1)), 4000001) then
                hookfunction(v, function() end)
            end
        end
    end
end)()

Hooks.__namecall = hookmetamethod(game, "__namecall", LPH_NO_VIRTUALIZE(function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}

    if not checkcaller() and (self == Handshake) and (Method == "fireServer") and (string.find(Args[1], "AC")) then
        if (#HandshakeInts == 0) then
            HandshakeInts = {table.unpack(Args[2], 2, 18)}
        else
            for i, v in HandshakeInts do
                Args[2][i + 1] = v
            end
        end
    end

    return Hooks.__namecall(self, ...)
end))

task.wait(1)
print('Success! Now Loading..')

local debris = game:GetService("Debris")
local contentProvider = game:GetService("ContentProvider")
local scriptContext = game:GetService("ScriptContext")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local statsService = game:GetService("Stats")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
local starterGui = game:GetService("StarterGui")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local values = replicatedStorage:FindFirstChild("Values")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/loadstringguy/sigmhack/refs/heads/main/library.lua"))()
local example = Library:CreateWindow({
    text = "sigmhack : main"
})

example:AddToggle("Magnets", function(state)
    getfenv().mags = (state and true or false)
    local Workspace = game:GetService("Workspace")

    local distance = 25

    Workspace.ChildAdded:Connect(function(Child)
        if Child:IsA("BasePart") and Child.Name == "Football" then
            Child.Size = Vector3.new(distance, distance, distance)
            Child.CanCollide = false
        end
    end)
end)

local example = Library:CreateWindow({
    text = "Physics"
})

example:AddToggle("Quick TP", function(state)
    getgenv().tp = (state and true or false)
    local quickTPEnabled = getgenv().tp
    local tpDistance = 2

    local function handleQuickTP()
        if quickTPEnabled then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = character.HumanoidRootPart
                humanoidRootPart.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * tpDistance
            end
        end
    end

    local function onInputBegan(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
            handleQuickTP()
        end
    end

    userInputService.InputBegan:Connect(onInputBegan)
end)

example:AddToggle("Quick TP Mobile Button", function(state)
    getgenv().MobileQuickTPButton = (state and true or false)

    local function createMobileQuickTPButton()
        local screenGui = Instance.new("ScreenGui", player:FindFirstChildOfClass("PlayerGui"))
        local button = Instance.new("TextButton")
        button.Size = UDim2.fromOffset(120, 60)
        button.Position = UDim2.fromScale(0.5, 0.9) - UDim2.fromOffset(60, 30)
        button.Text = "TP"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        button.BackgroundTransparency = 0.8
        button.BorderSizePixel = 2
        button.BorderColor3 = Color3.fromRGB(255, 255, 255)
        button.TextStrokeTransparency = 0.8
        button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 24
        button.AutoButtonColor = false
        button.Visible = true
        button.Parent = screenGui

        QuickTPToggle:OnChanged(function()
        quickTPEnabled = QuickTPToggle.Value
    end)

    MobileQuickTPToggle:OnChanged(function()
        MobileQuickTPButton.Visible = MobileQuickTPToggle.Value
    end)

    MobileQuickTPButton.MouseButton1Click:Connect(function()
        if MobileQuickTPToggle.Value then
            handleQuickTP()
        end
    end)

    example:AddToggle("Ball Path Prediction", function(state)
    getgenv().pathpred = (state and true or false)

    task.spawn(function()
        if not getgenv().pathpred then return end
        local initialVelocity = ball.AssemblyLinearVelocity
        local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
        a0.Parent = workspace.Terrain
        a1.Parent = workspace.Terrain

        local beam = Instance.new("Beam", workspace.Terrain)
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Segments = 500
        beam.Width0 = 0.5
        beam.Width1 = 0.5
        beam.Transparency = NumberSequence.new(0)
        beam.Color = ColorSequence.new(Color3.new(1, 1, 1)) -- White color

        local g = Vector3.new(0, -28, 0)
        local x0 = ball.Position
        local v0 = initialVelocity

        local curve0, curve1, cf1, cf2 = beamProjectile(g, v0, x0, 5)
        beam.CurveSize0 = curve0
        beam.CurveSize1 = curve1
        a0.CFrame = a0.Parent.CFrame:Inverse() * cf1
        a1.CFrame = a1.Parent.CFrame:Inverse() * cf2

        repeat task.wait() until ball.Parent ~= workspace
        beam:Destroy()
    end)
end)
