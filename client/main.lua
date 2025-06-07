local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local NPC = nil

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(5)
    end
end

local function createNPC()
    RequestModel(GetHashKey(Config.NPC.model))
    while not HasModelLoaded(GetHashKey(Config.NPC.model)) do
        Wait(1)
    end
    
    NPC = CreatePed(4, GetHashKey(Config.NPC.model), Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z - 1.0, Config.NPC.coords.w, false, true)
    SetEntityHeading(NPC, Config.NPC.coords.w)
    FreezeEntityPosition(NPC, true)
    SetEntityInvincible(NPC, true)
    SetBlockingOfNonTemporaryEvents(NPC, true)
    
    loadAnimDict("amb@world_human_stand_impatient@male@no_sign@base")
    TaskPlayAnim(NPC, "amb@world_human_stand_impatient@male@no_sign@base", "base", 8.0, 1.0, -1, 17, 0, false, false, false)
    
    if Config.NPC.blip then
        local blip = AddBlipForCoord(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
        SetBlipSprite(blip, Config.NPC.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.NPC.blip.scale)
        SetBlipColour(blip, Config.NPC.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.NPC.blip.label)
        EndTextCommandSetBlipName(blip)
    end
    
    exports['qb-target']:AddTargetEntity(NPC, {
        options = Config.NPC.targetOptions,
        distance = 2.0
    })
end

local function deleteNPC()
    if NPC then
        DeletePed(NPC)
        NPC = nil
    end
end

local function openMainMenu()
    local playerLevel = PlayerData.metadata.itemselllevel or 1
    local currentXP = PlayerData.metadata.itemsellxp or 0
    local requiredXP = Config.LevelXP[playerLevel] or 0
    local levelBonus = playerLevel * Config.PriceMultiplier * 100
    
    local menu = {
        {
            header = Lang:t('menu.title'),
            isMenuHeader = true,
            icon = 'fas fa-store'
        },
        {
            header = Lang:t('menu.your_level', {level = playerLevel}),
            txt = Lang:t('menu.next_level', {xp = currentXP, required = requiredXP}),
            isMenuHeader = true,
            icon = 'fas fa-star'
        },
        {
            header = Lang:t('menu.level_bonus', {bonus = string.format("%.1f", levelBonus)}),
            isMenuHeader = true,
            icon = 'fas fa-percentage'
        },
        {
            header = Lang:t('menu.sell_items'),
            icon = 'fas fa-dollar-sign',
            params = {
                event = 'alpha-itemsell:client:openSellMenu',
            }
        },
        {
            header = Lang:t('menu.rewards'),
            icon = 'fas fa-gift',
            params = {
                event = 'alpha-itemsell:client:openRewardsMenu',
            }
        },
        {
            header = Lang:t('menu.close'),
            icon = 'fas fa-times',
            params = {
                event = 'qb-menu:client:closeMenu',
            }
        }
    }
    
    exports['qb-menu']:openMenu(menu)
end

local function openSellMenu()
    local playerLevel = PlayerData.metadata.itemselllevel or 1
    local levelBonus = playerLevel * Config.PriceMultiplier * 100
    local playerInventory = QBCore.Functions.GetPlayerData().items
    
    local menu = {
        {
            header = Lang:t('menu.sell_items_title'),
            isMenuHeader = true,
            icon = 'fas fa-dollar-sign'
        },
        {
            header = Lang:t('menu.level_bonus', {bonus = string.format("%.1f", levelBonus)}),
            isMenuHeader = true,
            icon = 'fas fa-percentage'
        },
        {
            header = Lang:t('menu.back'),
            icon = 'fas fa-arrow-left',
            params = {
                event = 'alpha-itemsell:client:openMainMenu',
            }
        }
    }
    
    local inventoryLookup = {}
    for _, item in pairs(playerInventory) do
        if item and item.amount > 0 then
            inventoryLookup[item.name] = {
                amount = item.amount,
                label = item.label
            }
        end
    end
    
    local itemsFound = false
    
    for itemName, itemData in pairs(Config.SellableItems) do
        if inventoryLookup[itemName] then
            itemsFound = true
            
            local basePrice = itemData.basePrice
            local priceWithBonus = math.floor(basePrice * (1 + (playerLevel * Config.PriceMultiplier)))
            
            menu[#menu + 1] = {
                header = itemData.label .. " (x" .. inventoryLookup[itemName].amount .. ")",
                txt = Lang:t('menu.price_per_item', {price = priceWithBonus}),
                icon = 'nui://qb-inventory/html/images/' .. itemName .. '.png',
                params = {
                    event = 'alpha-itemsell:client:inputSellAmount',
                    args = {
                        item = itemName,
                        label = itemData.label,
                        max = inventoryLookup[itemName].amount,
                        price = priceWithBonus
                    }
                }
            }
        end
    end
    
    if not itemsFound then
        menu[#menu + 1] = {
            header = "No sellable items found",
            isMenuHeader = true,
            icon = 'fas fa-times-circle'
        }
    end
    
    exports['qb-menu']:openMenu(menu)
end

local function openRewardsMenu()
    local playerLevel = PlayerData.metadata.itemselllevel or 1
    local currentXP = PlayerData.metadata.itemsellxp or 0
    local requiredXP = Config.LevelXP[playerLevel] or 0
    
    local menu = {
        {
            header = Lang:t('menu.rewards_title'),
            isMenuHeader = true,
            icon = 'fas fa-gift'
        },
        {
            header = Lang:t('menu.your_level', {level = playerLevel}),
            txt = Lang:t('menu.next_level', {xp = currentXP, required = requiredXP}),
            isMenuHeader = true,
            icon = 'fas fa-star'
        },
        {
            header = Lang:t('menu.back'),
            icon = 'fas fa-arrow-left',
            params = {
                event = 'alpha-itemsell:client:openMainMenu',
            }
        }
    }
    
    local rewardsFound = false
    
    for level, reward in pairs(Config.LevelRewards) do
        if level <= playerLevel then
            rewardsFound = true
            
            local rewardText = ""
            if reward.money then
                rewardText = rewardText .. "$" .. reward.money
            end
            
            if reward.item then
                if rewardText ~= "" then
                    rewardText = rewardText .. " + "
                end
                rewardText = rewardText .. reward.item.amount .. "x " .. reward.item.name
            end
            
            menu[#menu + 1] = {
                header = "Level " .. level .. " Reward",
                txt = rewardText,
                icon = 'fas fa-gift',
                params = {
                    isServer = true,
                    event = 'alpha-itemsell:server:claimReward',
                    args = {
                        level = level
                    }
                }
            }
        end
    end
    
    if not rewardsFound then
        menu[#menu + 1] = {
            header = "No rewards available",
            txt = "Reach higher levels to unlock rewards",
            isMenuHeader = true,
            icon = 'fas fa-lock'
        }
    end
    
    exports['qb-menu']:openMenu(menu)
end

local function inputSellAmount(data)
    local dialog = exports['qb-input']:ShowInput({
        header = Lang:t('menu.enter_amount'),
        submitText = "Confirm",
        inputs = {
            {
                text = "Amount (Max: " .. data.max .. ")",
                name = "amount",
                type = "number",
                isRequired = true,
                default = 1
            }
        }
    })
    
    if dialog and dialog.amount then
        local amount = tonumber(dialog.amount)
        if amount and amount > 0 and amount <= data.max then
            TriggerServerEvent('alpha-itemsell:server:sellItem', {
                item = data.item,
                amount = amount,
                price = data.price
            })
        else
            QBCore.Functions.Notify("Invalid amount", "error")
            openSellMenu()
        end
    else
        openSellMenu()
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    createNPC()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    deleteNPC()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
end)

RegisterNetEvent('alpha-itemsell:client:openMainMenu', function()
    openMainMenu()
end)

RegisterNetEvent('alpha-itemsell:client:openSellMenu', function()
    openSellMenu()
end)

RegisterNetEvent('alpha-itemsell:client:openRewardsMenu', function()
    openRewardsMenu()
end)

RegisterNetEvent('alpha-itemsell:client:inputSellAmount', function(data)
    inputSellAmount(data)
end)

RegisterNetEvent('alpha-itemsell:client:levelUp', function(level)
    QBCore.Functions.Notify(Lang:t('info.level_up', {level = level}), 'success')
    
    PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", 1)
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    RequestNamedPtfxAsset("scr_xs_celebration")
    while not HasNamedPtfxAssetLoaded("scr_xs_celebration") do
        Wait(10)
    end
    
    UseParticleFxAssetNextCall("scr_xs_celebration")
    local particleHandle = StartParticleFxLoopedAtCoord("scr_xs_confetti_burst", coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    SetParticleFxLoopedColour(particleHandle, 1.0, 1.0, 1.0, false)
    
    Wait(5000)
    StopParticleFxLooped(particleHandle, 0)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if LocalPlayer.state.isLoggedIn then
            PlayerData = QBCore.Functions.GetPlayerData()
            createNPC()
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        deleteNPC()
    end
end)