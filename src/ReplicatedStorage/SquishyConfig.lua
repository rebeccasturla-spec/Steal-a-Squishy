local SquishyConfig = {}

SquishyConfig.Items = {
    {Name = "Frog Squishy", Rarity = "Common", Price = 100, Income = 5, Weight = 45},
    {Name = "Cat Squishy", Rarity = "Common", Price = 150, Income = 8, Weight = 35},
    {Name = "Bunny Squishy", Rarity = "Uncommon", Price = 400, Income = 18, Weight = 12},
    {Name = "Strawberry Squishy", Rarity = "Rare", Price = 1200, Income = 55, Weight = 5},
    {Name = "Unicorn Squishy", Rarity = "Epic", Price = 5000, Income = 220, Weight = 2},
    {Name = "Dino Squishy", Rarity = "Legendary", Price = 20000, Income = 900, Weight = 0.8},
    {Name = "Rainbow Squishy", Rarity = "Mythic", Price = 100000, Income = 5000, Weight = 0.19},
    {Name = "Mystery Squishy", Rarity = "Secret", Price = 500000, Income = 30000, Weight = 0.01},
}

SquishyConfig.BaseSlots = 10
SquishyConfig.BaseIncomeMultiplier = 1
SquishyConfig.StealCooldown = 2

function SquishyConfig.GetByName(name)
    for _, item in ipairs(SquishyConfig.Items) do
        if item.Name == name then return item end
    end
end

function SquishyConfig.Roll()
    local total = 0
    for _, item in ipairs(SquishyConfig.Items) do total += item.Weight end
    local roll, cursor = math.random() * total, 0
    for _, item in ipairs(SquishyConfig.Items) do
        cursor += item.Weight
        if roll <= cursor then return item end
    end
    return SquishyConfig.Items[1]
end

return SquishyConfig
