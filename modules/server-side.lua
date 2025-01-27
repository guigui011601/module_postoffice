local VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local VORPdb = exports.oxmysql

-- Helper functions
local function GeneratePostboxNumber()
    local letters = {"A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
    local number = math.random(000, 999)  -- 3 chiffres
    local lastLetter = letters[math.random(1, #letters)]  -- 1 lettre aléatoire
    return "PR" .. number .. lastLetter
end

local function GetCharacterPostbox(charid, cb)
    local query = "SELECT postnum FROM module_postboxs WHERE charid = ? LIMIT 1"
    exports.oxmysql:execute(query, {tostring(charid)}, function(result)
        if result and #result > 0 then
            cb(result[1].postnum)
        else
            cb(nil)
        end
    end)
end

local function GetLetters(postbox, cb)
    local query = "SELECT * FROM module_postmsg WHERE postbox = ? ORDER BY id DESC"
    exports.oxmysql:execute(query, {postbox}, function(result)
        cb(result or {})
    end)
end

-- Event handlers
RegisterServerEvent("module_postoffice:get_postbox")
AddEventHandler("module_postoffice:get_postbox", function(price, databaseName)
    local _source = source
    print("^2get_postbox triggered by^7", _source)
    print("Price:", price)
    print("DatabaseName:", databaseName)
    
    local User = VORPcore.getUser(_source)
    if not User then 
        print("^1No user found^7")
        return 
    end
    
    local Character = User.getUsedCharacter
    if not Character then 
        print("^1No character found^7")
        return 
    end
    
    local charid = Character.charIdentifier
    local money = Character.money

    GetCharacterPostbox(charid, function(postbox)
        if postbox then
            GetLetters(postbox, function(letters)
                TriggerClientEvent("module_postoffice:postbox_data", _source, {
                    postnum = postbox,
                    letters = letters
                })
            end)
        else
            if money >= price then
                local newPostbox = GeneratePostboxNumber()
                
                exports.oxmysql:execute("INSERT INTO module_postboxs (identifier, charid, postnum) VALUES (?, ?, ?)",
                    {Character.identifier, tostring(charid), newPostbox})
                
                Character.removeCurrency(0, price)
                TriggerClientEvent("vorp:TipRight", _source, Config.Created, 3000)
                
                TriggerClientEvent("module_postoffice:postbox_data", _source, {
                    postnum = newPostbox,
                    letters = {}
                })
            else
                TriggerClientEvent("vorp:TipRight", _source, Config.NoMoney .. price .. Config.NoMoneyEnd, 3000)
                TriggerClientEvent("module_postoffice:postbox_data", _source, {
                    postnum = nil,
                    letters = {}
                })
            end
        end
    end)
end)

RegisterServerEvent("module_postoffice:send_letter")
AddEventHandler("module_postoffice:send_letter", function(data)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local charid = Character.charIdentifier
    local money = Character.money
    local firstname = Character.firstname
    local lastname = Character.lastname
    local rp_names = firstname .. " " .. lastname

    if money >= data.sendprice then
        -- Check if recipient postbox exists
        exports.oxmysql:execute("SELECT postnum FROM module_postboxs WHERE postnum = ? LIMIT 1",
            {data.recipiant}, function(result)
            if result and #result > 0 then
                -- Get sender's postbox
                GetCharacterPostbox(charid, function(sender_postbox)
                    if sender_postbox then
                        -- Insert letter
                        exports.oxmysql:execute([[
                            INSERT INTO module_postmsg 
                            (sender, rp_names, sender_postbox, postbox, letter, subject) 
                            VALUES (?, ?, ?, ?, ?, ?)
                        ]], {
                            tostring(charid),
                            rp_names,
                            sender_postbox,
                            data.recipiant,
                            data.letter,
                            data.subject
                        })

                        Character.removeCurrency(0, data.sendprice)
                        TriggerClientEvent("vorp:TipRight", _source, Config.LetterSended, 3000)
                        
                        -- Get recipient character to send notification
                        exports.oxmysql:execute("SELECT charid FROM module_postboxs WHERE postnum = ?", 
                            {data.recipiant}, function(recipientResult)
                            if recipientResult and #recipientResult > 0 then
                                local recipientCharId = recipientResult[1].charid
                                local Players = GetPlayers()
                                
                                for _, playerId in ipairs(Players) do
                                    local playerUser = VORPcore.getUser(playerId)
                                    if playerUser then
                                        local playerChar = playerUser.getUsedCharacter
                                        if playerChar and tostring(playerChar.charIdentifier) == recipientCharId then
                                            TriggerClientEvent("SendNUIMessage", playerId, {
                                                type = "module_postoffice:SendNotification",
                                                subject = data.subject
                                            })

                                            if Config.DLC then
                                                local mayor = exports.module_nations:getMayor(data.databaseName)
                                                if mayor then
                                                    TriggerClientEvent("vorp:TipBottom", mayor.source, Config.LetterMayor .. " " .. firstname.. " " ..lastname .. " " .. Config.LetterMayorTo .. " " .. data.recipiant, 6000)
                                                end
                                            end
                                            break
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)
            else
                TriggerClientEvent("vorp:TipRight", _source, Config.NoFound, 3000)
            end
        end)
    else
        TriggerClientEvent("vorp:TipRight", _source, Config.NoSendMoney01 .. data.sendprice .. Config.NoSendMoney02, 3000)
    end
end)

RegisterServerEvent("module_postoffice:click_letter")
AddEventHandler("module_postoffice:click_letter", function(id_letter)
    exports.oxmysql:execute("UPDATE module_postmsg SET read_letter = 1 WHERE id = ?", {id_letter})
end)

RegisterServerEvent("module_postoffice:delete_letter")
AddEventHandler("module_postoffice:delete_letter", function(id_letter)
    local _source = source
    exports.oxmysql:execute("DELETE FROM module_postmsg WHERE id = ?", {id_letter})
    TriggerClientEvent("vorp:TipRight", _source, Config.LetterDeleted, 3000)
end)

RegisterServerEvent("module_postoffice:delete_all")
AddEventHandler("module_postoffice:delete_all", function(postbox)
    local _source = source
    exports.oxmysql:execute("DELETE FROM module_postmsg WHERE postbox = ?", {postbox})
    TriggerClientEvent("vorp:TipRight", _source, Config.LetterDeleteds, 3000)
end)

-- DLC Nations Support
if Config.DLC then
    exports('GetPostboxes', function(townName)
        local query = "SELECT * FROM module_postboxs WHERE databaseName = ?"
        local result = MySQL.Sync.fetchAll(query, {townName})
        return result
    end)

    exports('GetLettersSent', function(townName)
        local query = "SELECT * FROM module_postmsg WHERE databaseName = ?"
        local result = MySQL.Sync.fetchAll(query, {townName})
        return result
    end)
end