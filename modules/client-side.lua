local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

-- Local variables
local prompts = GetRandomIntInRange(0, 0xffffff)
local PostOfficePrompt = nil
local isOpen = false
local coords = nil
local postOffice = nil

-- Functions
local function SetupPostOfficePrompt()
    if not Config.PromptMode then return end
    
    local str = Config.PromptPostOffice and Config.PostTitle or Config.PromptNotice
    PostOfficePrompt = PromptRegisterBegin()
    PromptSetControlAction(PostOfficePrompt, Config.KeyOpenMenu)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(PostOfficePrompt, str)
    PromptSetEnabled(PostOfficePrompt, true)
    PromptSetVisible(PostOfficePrompt, true)
    PromptSetStandardMode(PostOfficePrompt, true)  -- Changé de HoldMode à StandardMode
    PromptSetGroup(PostOfficePrompt, prompts)
    PromptRegisterEnd(PostOfficePrompt)
end

local function CloseUI()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "ui",
        status = false
    })
end

local function OpenPostOffice()
    if isOpen then return end
    
    isOpen = true
    TriggerServerEvent("module_postoffice:get_postbox", coords.price, coords.databaseName)
end

-- Register Event for postbox data reception
RegisterNetEvent("module_postoffice:postbox_data")
AddEventHandler("module_postoffice:postbox_data", function(data)
    if data.postnum then
        SendNUIMessage({
            type = "ui",
            status = true,
            postnum = data.postnum,
            letters = data.letters,
            sendprice = coords.sendprice,
            databaseName = coords.databaseName
        })
        SetNuiFocus(true, true)
    else
        CloseUI()
    end
end)

-- NUI Callbacks
RegisterNUICallback('exit', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('send_letter', function(data, cb)
    TriggerServerEvent("module_postoffice:send_letter", data)
    cb('ok')
end)

RegisterNUICallback('click_letter', function(data, cb)
    TriggerServerEvent("module_postoffice:click_letter", data.id_letter)
    cb('ok')
end)

RegisterNUICallback('delete_letter', function(data, cb)
    TriggerServerEvent("module_postoffice:delete_letter", data.id_letter)
    cb('ok')
end)

RegisterNUICallback('delete_all', function(data, cb)
    TriggerServerEvent("module_postoffice:delete_all", data.postnum)
    cb('ok')
end)

-- Escape key callback
RegisterNUICallback('escape', function(data, cb)
    CloseUI()
    cb('ok')
end)

-- Create blips for post offices
Citizen.CreateThread(function()
    if Config.BlipsMap then
        for _, v in pairs(Config.PostsOffices) do
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.x, v.y, v.z)
            SetBlipSprite(blip, v.sprite, 1)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.RPName)
        end
    end
end)

-- Main thread for prompt and interaction
Citizen.CreateThread(function()
    SetupPostOfficePrompt()
    
    while true do
        local sleep = 1000
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)

        for _, v in pairs(Config.PostsOffices) do
            local distance = #(playerCoords - vector3(v.x, v.y, v.z))
            
            if distance <= 2.0 then
                sleep = 0
                coords = v

                if Config.PromptMode then
                    local PostOfficeGroup = CreateVarString(10, 'LITERAL_STRING', Config.SubInfo)
                    PromptSetActiveGroupThisFrame(prompts, PostOfficeGroup)

                    if Citizen.InvokeNative(0xC92AC953F0A982AE, PostOfficePrompt) then
                        OpenPostOffice()
                    end
                elseif IsControlJustPressed(0, Config.KeyOpenMenu) then
                    OpenPostOffice()
                end

                break
            end
        end

        Citizen.Wait(sleep)
    end
end)

-- Register the notification event
RegisterNetEvent("SendNUIMessage")
AddEventHandler("SendNUIMessage", function(data)
    SendNUIMessage(data)
end)