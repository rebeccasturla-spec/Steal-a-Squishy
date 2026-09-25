local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local r=ReplicatedStorage:WaitForChild("Remotes")

local gui=Instance.new("ScreenGui")
gui.Name="SquishyUI"
gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")

local function button(label,y,event)
    local b=Instance.new("TextButton")
    b.Size=UDim2.fromOffset(190,48)
    b.Position=UDim2.new(0,20,1,y)
    b.Text=label
    b.TextScaled=true
    b.Parent=gui
    b.Activated:Connect(function() event:FireServer() end)
end

button("Buy Squishy",-175,r.BuySquishy)
button("Lock / Unlock Base",-115,r.LockBase)
button("Upgrade Base",-55,r.UpgradeBase)
