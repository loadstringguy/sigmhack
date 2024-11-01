if getgenv().sigmhack then warn("Script already loaded or is loading") return end
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

local Library = https://raw.githubusercontent.com/loadstringguy/sigmhack/refs/heads/main/library.lua
local example = library:CreateWindow({
    text = "sigmhack : main"
})
example:AddToggle("Magnets", function(state)
getfenv().mags =(state and true or false)
Workspace = game:GetService("Workspace")

local rangee = 25

Workspace.ChildAdded:Connect(function(Child)

if Child:IsA("BasePart") and Child.Name == "Football" then

Child.Size = Vector3.new(rangee, rangee, rangee)

Child.CanCollide = false

end

local example = library:CreateWindow({
        text = "Physics"
})


end)
