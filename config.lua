Config = {}

Config.Language = 'ar'

Config.NPC = {
    model = 'a_m_m_business_01',
    coords = vector4(458.57, -705.03, 27.36, 84.93),
    blip = {
        sprite = 500,
        color = 2,
        scale = 0.8,
        label = "تاجر الممنوعات"
    },
    targetOptions = {
        {
            type = "client",
            event = "alpha-itemsell:client:openMainMenu",
            icon = "fas fa-store",
            label = "تاجر الممنوعات"
        }
    }
}

Config.MaxLevel = 20
Config.XPMultiplier = 1.0
Config.LevelXP = {}

for i = 1, Config.MaxLevel do
    Config.LevelXP[i] = math.floor(100 * (i ^ 1.8) * Config.XPMultiplier)
end

Config.PriceMultiplier = 0.05

Config.LevelRewards = {
    [5] = {money = 1000},
    [10] = {money = 5000, item = {name = "phone", amount = 1}},
    [15] = {money = 10000, item = {name = "rolex", amount = 3}},
    [20] = {money = 25000, item = {name = "goldbar", amount = 1}}
}

Config.SellableItems = {
    ["phone"] = {
        basePrice = 750,
        icon = "fas fa-mobile-alt",
        label = "Phone"
    },
    ["rolex"] = {
        basePrice = 650,
        icon = "fas fa-clock",
        label = "Rolex Watch"
    },
    ["diamond_ring"] = {
        basePrice = 1000,
        icon = "fas fa-ring",
        label = "Diamond Ring"
    },
    ["goldbar"] = {
        basePrice = 2500,
        icon = "fas fa-cubes",
        label = "Gold Bar"
    }
}