local MySQL = exports['oxmysql']

-- Fonction pour récupérer les télégrammes non lus pour un joueur
local function getUnreadTelegrams(playerId, callback)
    MySQL.fetch('SELECT * FROM module_postmsg WHERE read_letter = 0 AND recipient_id = ?', {playerId}, function(results)
        callback(results)
    end)
end

-- Événement pour vérifier les télégrammes non lus et envoyer une notification
RegisterNetEvent('module_postoffice:CheckTelegrams')
AddEventHandler('module_postoffice:CheckTelegrams', function()
    local playerId = source
    getUnreadTelegrams(playerId, function(telegrams)
        for _, telegram in ipairs(telegrams) do
            TriggerClientEvent('module_postoffice:SendNotification', playerId, telegram.subject)
        end
    end)
end)