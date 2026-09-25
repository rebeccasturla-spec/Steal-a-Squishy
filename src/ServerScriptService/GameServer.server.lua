local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Config = require(ReplicatedStorage:WaitForChild("SquishyConfig"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local BuySquishy = Remotes:WaitForChild("BuySquishy")
local StealSquishy = Remotes:WaitForChild("StealSquishy")
local LockBase = Remotes:WaitForChild("LockBase")
local UpgradeBase = Remotes:WaitForChild("UpgradeBase")

local Store = DataStoreService:GetDataStore("StealASquishy_v1")
local data, bases, cooldown = {}, {}, {}

local function makePart(parent, name, position, size)
    local p = parent:FindFirstChild(name) or Instance.new("Part")
    p.Name, p.Anchored, p.Size, p.Position = name, true, size, position
    p.Parent = parent
    return p
end

local function setupMap()
    local folder = workspace:FindFirstChild("Bases") or Instance.new("Folder")
    folder.Name, folder.Parent = "Bases", workspace
    for i = 1, 6 do
        local base = folder:FindFirstChild("Base"..i) or Instance.new("Model")
        base.Name, base.Parent = "Base"..i, folder
        local pos = Vector3.new((i-1)*25, 1, 30)
        makePart(base, "Spawn", pos, Vector3.new(8,1,8))
        makePart(base, "Deposit", pos + Vector3.new(0,0,8), Vector3.new(10,1,10))
        bases[i] = {model=base, owner=nil, locked=false}
    end
end

local function stats(player)
    local ls = player:FindFirstChild("leaderstats") or Instance.new("Folder")
    ls.Name, ls.Parent = "leaderstats", player
    local cash = ls:FindFirstChild("Cash") or Instance.new("IntValue")
    cash.Name, cash.Parent = "Cash", ls
    return cash
end

local function getBase(player)
    for _, b in ipairs(bases) do if b.owner == player then return b end end
end

local function save(player)
    if not data[player] then return end
    pcall(function()
        Store:SetAsync("player_"..player.UserId, {
            Cash=stats(player).Value,
            Squishies=data[player].squishies,
            Upgrade=data[player].upgrade
        })
    end)
end

local function load(player)
    local d = {squishies={}, upgrade=1}
    local ok, saved = pcall(function() return Store:GetAsync("player_"..player.UserId) end)
    stats(player).Value = 1000
    if ok and type(saved)=="table" then
        stats(player).Value = tonumber(saved.Cash) or 1000
        d.squishies = type(saved.Squishies)=="table" and saved.Squishies or {}
        d.upgrade = tonumber(saved.Upgrade) or 1
    end
    data[player]=d
end

setupMap()

Players.PlayerAdded:Connect(function(player)
    stats(player)
    load(player)
    for _, b in ipairs(bases) do
        if not b.owner then b.owner=player; break end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    save(player)
    local b=getBase(player)
    if b then b.owner=nil; b.locked=false end
    data[player]=nil; cooldown[player]=nil
end)

BuySquishy.OnServerEvent:Connect(function(player)
    local d=data[player]; if not d then return end
    if #d.squishies >= Config.BaseSlots*d.upgrade then return end
    local item=Config.Roll()
    local cash=stats(player)
    if cash.Value >= item.Price then
        cash.Value -= item.Price
        table.insert(d.squishies,item.Name)
    end
end)

LockBase.OnServerEvent:Connect(function(player)
    local b=getBase(player)
    if b then b.locked=not b.locked end
end)

UpgradeBase.OnServerEvent:Connect(function(player)
    local d=data[player]; if not d then return end
    local cost=5000*d.upgrade
    if stats(player).Value >= cost then
        stats(player).Value-=cost
        d.upgrade+=1
    end
end)

StealSquishy.OnServerEvent:Connect(function(thief, victim, index)
    if typeof(victim)~="Instance" or not victim:IsA("Player") or victim==thief then return end
    if typeof(index)~="number" then return end
    if cooldown[thief] and os.clock()-cooldown[thief] < Config.StealCooldown then return end
    local vb,tb=getBase(victim),getBase(thief)
    local vd,td=data[victim],data[thief]
    if not vb or not tb or not vd or not td or vb.locked then return end
    index=math.floor(index)
    local name=vd.squishies[index]
    if not name or #td.squishies >= Config.BaseSlots*td.upgrade then return end
    table.remove(vd.squishies,index)
    table.insert(td.squishies,name)
    cooldown[thief]=os.clock()
end)

task.spawn(function()
    while true do
        task.wait(1)
        for player,d in pairs(data) do
            if player.Parent then
                local income=0
                for _,name in ipairs(d.squishies) do
                    local item=Config.GetByName(name)
                    if item then income += item.Income end
                end
                stats(player).Value += math.floor(income*d.upgrade)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(60)
        for player in pairs(data) do if player.Parent then task.spawn(save,player) end end
    end
end)
