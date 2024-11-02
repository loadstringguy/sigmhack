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
    for i, v in pairs(getgc()) do
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
            for i, v in pairs(HandshakeInts) do
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
    text = "sigmhack : catching"
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

example:AddToggle("View MS Hitbox", function(state)
    getfenv().mshitbox = (state and true or false)

    local magnetEnabled = true
    local hitboxSize = Vector3.new(25, 25, 25)

    local function createHitbox(target)
        if not target:IsA("BasePart") then return end

        local hitbox = Instance.new("Part")
        hitbox.Size = hitboxSize
        hitbox.Transparency = 0.3
        hitbox.Anchored = true
        hitbox.CanCollide = false
        hitbox.Material = Enum.Material.ForceField
        hitbox.Name = "MagnetHitbox"
        hitbox.CFrame = target.CFrame
        hitbox.Parent = target

        local function updateHitbox()
            while magnetEnabled and target and target.Parent do
                hitbox.CFrame = target.CFrame
                task.wait()
            end
            hitbox:Destroy()
        end

        task.spawn(updateHitbox)
    end

    workspace.ChildAdded:Connect(function(child)
        if child.Name == "Football" and child:IsA("BasePart") and magnetEnabled then
            createHitbox(child)
        end
    end)
end)


local example1 = Library:CreateWindow({
    text = "sigmhack : physics"
})

example1:AddToggle("Quick TP", function(state)
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

example1:AddToggle("Ball Path Prediction", function(state)
    getgenv().pathpred = (state and true or false)
    
    local Grapher = {}

    Grapher.Segment = Instance.new("Part")
    Grapher.Segment.Anchored = true
    Grapher.Segment.Transparency = 0.3
    Grapher.Segment.Material = Enum.Material.Neon
    Grapher.Segment.CanCollide = false
    Grapher.Segment.Size = Vector3.new(0.2, 0.2, 0.2)
    Grapher.Segment.Name = "BeamSegment"

    Grapher.Params = RaycastParams.new()
    Grapher.Params.IgnoreWater = true
    Grapher.Params.FilterType = Enum.RaycastFilterType.Whitelist

    Grapher.CastStep = 3 / 60
    Grapher.LastSavedPower = 60
    Grapher.SegmentLifetime = 8
    Grapher.VisualizerEnabled = true

    function Grapher:GetCollidables()
        local Collidables = {}

        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                table.insert(Collidables, part)
            end
        end
        return Collidables
    end

    function Grapher:WipeMarkers()
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name == "BeamSegment" then
                obj:Destroy()
            end
        end
    end

    function Grapher:GetLanding(origin, velocity, target)
        local elapsed = 0
        local prevPos = origin

        self.Params.FilterDescendantsInstances = self:GetCollidables()

        local highlight = nil

        if target then
            for _, existing in ipairs(game.CoreGui:GetChildren()) do
                if existing:IsA("Highlight") and existing.Adornee == target then
                    wait(4)
                    existing:Destroy()
                end
            end

            highlight = Instance.new("Highlight", game.CoreGui)
            highlight.Adornee = target
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Enabled = true
            highlight.OutlineColor = Grapher.Segment.Color
            highlight.OutlineTransparency = Grapher.Segment.Transparency
            highlight.FillTransparency = 0.7
        end

        while Grapher.VisualizerEnabled do
            elapsed = elapsed + Grapher.CastStep
            local nextPos = origin + velocity * elapsed - Vector3.new(0, 0.5 * 28 * elapsed ^ 2, 0)

            local segment = self.Segment:Clone()
            segment.Position = (prevPos + nextPos) / 2
            segment.Size = Vector3.new(0.2, 0.2, (prevPos - nextPos).magnitude)
            segment.CFrame = CFrame.new(prevPos, nextPos) * CFrame.new(0, 0, -segment.Size.Z / 2)
            segment.Parent = workspace

            task.delay(Grapher.SegmentLifetime, function()
                if segment and segment.Parent then
                    segment:Destroy()
                end
            end)

            prevPos = nextPos

            if target and highlight and (target.Parent ~= workspace or not target:FindFirstChildOfClass("BodyForce")) then
                highlight:Destroy()
                self:WipeMarkers()
                break
            end

            task.wait()
        end
    end

    function Grapher:StartVisualizer()
        Grapher.VisualizerEnabled = true
    end

    function Grapher:StopVisualizer()
        Grapher.VisualizerEnabled = false
        Grapher:WipeMarkers()
    end

    workspace.ChildAdded:Connect(function(child)
        if child.Name == "Football" and child:IsA("BasePart") then
            local connection
            connection = child:GetPropertyChangedSignal("Velocity"):Connect(function()
                if Grapher.VisualizerEnabled then
                    Grapher:GetLanding(child.Position, child.Velocity, child)
                end
                connection:Disconnect()
            end)
        end
    end)

    return Grapher
end)

example1:AddToggle("No Jump Cooldown", function(state)
    getgenv().nojpcd = (state and true or false)
humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
     end
 end)

example1:AddToggle("Optimal Jump", function(state)
    getgenv().opju = (state and true or false)
task.spawn(function()
    if not optimalJumpPredictions.Value then return end
    local initialVelocity = ball.AssemblyLinearVelocity
    local optimalPosition = Vector3.zero
    local currentPosition = ball.Position
    local t = 0

    while true do
        t += 0.05
        initialVelocity += Vector3.new(0, -28 * 0.05, 0)
        currentPosition += initialVelocity * 0.05
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {workspace:FindFirstChild("Models")}
        raycastParams.FilterType = Enum.RaycastFilterType.Include

        local ray = workspace:Raycast(currentPosition, Vector3.new(0, optimalJumpType.Value == "Jump" and -13 or -15, 0), raycastParams)
        local antiCrashRay = workspace:Raycast(currentPosition, Vector3.new(0, -500, 0), raycastParams)

        if ray and t > 0.75 then
            optimalPosition = ray.Position + Vector3.new(0, 2, 0)
            break
        end

        if not antiCrashRay then
            optimalPosition = currentPosition
            break
        end
    end

    local part = Instance.new("Part")
    part.Anchored = true
    part.Material = Enum.Material.Neon
    part.Size = Vector3.new(1.5, 1.5, 1.5)
    part.Position = optimalPosition
    part.CanCollide = false
    part.Shape = Enum.PartType.Ball
    part.Parent = workspace

    repeat task.wait() until ball.Parent ~= workspace

    part:Destroy()
end)
