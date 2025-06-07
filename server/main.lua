local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if not Player.PlayerData.metadata["itemselllevel"] then
        Player.Functions.SetMetaData("itemselllevel", 1)
    end
    
    if not Player.PlayerData.metadata["itemsellxp"] then
        Player.Functions.SetMetaData("itemsellxp", 0)
    end
    
    if not Player.PlayerData.metadata["claimedrewards"] then
        Player.Functions.SetMetaData("claimedrewards", {})
    end
end)

local function AddXP(src, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return false end
    
    local currentLevel = Player.PlayerData.metadata["itemselllevel"] or 1
    local currentXP = Player.PlayerData.metadata["itemsellxp"] or 0
    
    if currentLevel >= Config.MaxLevel then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.max_level'), 'primary')
        return false
    end
    
    local newXP = currentXP + amount
    Player.Functions.SetMetaData("itemsellxp", newXP)
    
    local requiredXP = Config.LevelXP[currentLevel]
    
    if newXP >= requiredXP then
        local newLevel = currentLevel + 1
        Player.Functions.SetMetaData("itemselllevel", newLevel)
        Player.Functions.SetMetaData("itemsellxp", 0)
        
        TriggerClientEvent('alpha-itemsell:client:levelUp', src, newLevel)
        
        return true
    end
    
    TriggerClientEvent('QBCore:Notify', src, Lang:t('info.gained_xp', {xp = amount}), 'primary')
    
    return false
end

RegisterNetEvent('alpha-itemsell:server:sellItem', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local item = data.item
    local amount = tonumber(data.amount)
    local price = tonumber(data.price)
    
    if not item or not amount or not price or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, "Invalid input", 'error')
        return
    end
    
    if not Config.SellableItems[item] then
        TriggerClientEvent('QBCore:Notify', src, "Invalid item", 'error')
        return
    end
    
    local playerItem = Player.Functions.GetItemByName(item)
    
    if not playerItem or playerItem.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.not_enough'), 'error')
        return
    end
    
    local totalPrice = price * amount
    
    if Player.Functions.RemoveItem(item, amount) then
        Player.Functions.AddMoney("cash", totalPrice)
        
        local xpGained = math.floor(totalPrice / 10)
        if xpGained < 1 then xpGained = 1 end
        
        AddXP(src, xpGained)
        
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove", amount)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.sold_item', {amount = amount, item = Config.SellableItems[item].label, price = totalPrice}), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.not_enough'), 'error')
    end
end)

RegisterNetEvent('alpha-itemsell:server:claimReward', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local level = tonumber(data.level)
    
    if not level or level < 1 or level > Config.MaxLevel then
        TriggerClientEvent('QBCore:Notify', src, "Invalid level", 'error')
        return
    end
    
    local playerLevel = Player.PlayerData.metadata["itemselllevel"] or 1
    
    if playerLevel < level then
        TriggerClientEvent('QBCore:Notify', src, "You haven't reached this level yet", 'error')
        return
    end
    
    if not Config.LevelRewards[level] then
        TriggerClientEvent('QBCore:Notify', src, "No reward available for this level", 'error')
        return
    end
    
    local claimedRewards = Player.PlayerData.metadata["claimedrewards"] or {}
    
    if claimedRewards[tostring(level)] then
        TriggerClientEvent('QBCore:Notify', src, "You've already claimed this reward", 'error')
        return
    end
    
    local reward = Config.LevelRewards[level]
    
    if reward.money then
        Player.Functions.AddMoney("cash", reward.money)
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.money_reward', {amount = reward.money, level = level}), 'success')
    end
    
    if reward.item then
        Player.Functions.AddItem(reward.item.name, reward.item.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[reward.item.name], "add")
        TriggerClientEvent('QBCore:Notify', src, Lang:t('info.item_reward', {amount = reward.item.amount, item = QBCore.Shared.Items[reward.item.name].label, level = level}), 'success')
    end
    
    claimedRewards[tostring(level)] = true
    Player.Functions.SetMetaData("claimedrewards", claimedRewards)
    
    TriggerClientEvent('QBCore:Notify', src, Lang:t('info.reward', {level = level}), 'success')
end)

QBCore.Commands.Add('itemselllevel', 'Check your item selling level', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then return end
    
    local currentLevel = Player.PlayerData.metadata["itemselllevel"] or 1
    local currentXP = Player.PlayerData.metadata["itemsellxp"] or 0
    local requiredXP = Config.LevelXP[currentLevel] or 0
    
    TriggerClientEvent('QBCore:Notify', source, Lang:t('info.level', {level = currentLevel}) .. ' - ' .. Lang:t('info.xp', {current = currentXP, required = requiredXP}), 'primary', 10000)
end)

QBCore.Commands.Add('setitemsellevel', 'Set item selling level (Admin Only)', {{name = 'id', help = 'Player ID'}, {name = 'level', help = 'Level to set'}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local level = tonumber(args[2])
    
    if not Player then
        TriggerClientEvent('QBCore:Notify', src, "Player not found", 'error')
        return
    end
    
    if not level or level < 1 or level > Config.MaxLevel then
        TriggerClientEvent('QBCore:Notify', src, "Invalid level (1-" .. Config.MaxLevel .. ")", 'error')
        return
    end
    
    Player.Functions.SetMetaData("itemselllevel", level)
    Player.Functions.SetMetaData("itemsellxp", 0)
    
    TriggerClientEvent('QBCore:Notify', src, "Set " .. Player.PlayerData.name .. "'s item sell level to " .. level, 'success')
    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, "Your item sell level was set to " .. level, 'primary')
end, 'admin')

QBCore.Commands.Add('resetitemrewards', 'Reset claimed rewards (Admin Only)', {{name = 'id', help = 'Player ID'}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    
    if not Player then
        TriggerClientEvent('QBCore:Notify', src, "Player not found", 'error')
        return
    end
    
    Player.Functions.SetMetaData("claimedrewards", {})
    
    TriggerClientEvent('QBCore:Notify', src, "Reset " .. Player.PlayerData.name .. "'s claimed rewards", 'success')
    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, "Your claimed rewards have been reset", 'primary')
end, 'admin')