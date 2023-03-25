local lastdata = nil
ESX = nil
if Config.ESX then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/" .. endpoint,
                       function(errorCode, resultData, resultHeaders)
        data = {data = resultData, code = errorCode, headers = resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bot " .. Config.BotToken
    })

    while data == nil do Citizen.Wait(0) end

    return data
end



function string.starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function mysplit(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function GetRealPlayerName(playerId)
    if Config.ESX then
        local xPlayer = ESX.GetPlayerFromId(playerId)
        return xPlayer.getName()
    else
        return "ESX NICHT AKTIVIERT"
    end
end

function ExecuteCOMM(command)
    if string.starts(command, Config.Prefix) then

        if string.starts(command, Config.Prefix .. "playercount") then

            sendToDiscord("Spieleranzahl", "Atuell sind  : " ..
                              GetNumPlayerIndices(), 16711680)


        elseif string.starts(command, Config.Prefix .. "kick") then

            local t = mysplit(command, " ")

            if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                sendToDiscord("Erfolgreich gekickt",
                              "Erfolgreich gekickt " .. GetPlayerName(t[2]),
                              16711680)
                DropPlayer(t[2], "Gekickt von der DISCORD KONSOLE")

            else

                sendToDiscord("Konnte nicht gefunden werden-",
                              "Die Spieler Id konnte nicht gefunden werden. Vergewisser dich das es die richtige id ist.",
                              16711680)

            end


        elseif string.starts(command, Config.Prefix .. "slay") then

            local t = mysplit(command, " ")

            if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then

                TriggerClientEvent("discordc:kill", t[2])
                TriggerEvent('chat:addMessage', t[2], {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {
                        "Discord Konsole",
                        "^1 Du wurdest von der Discord Konsole getötet"
                    }
                })
                sendToDiscord("Erfolgreich Getötet ",
                              "Erfolgreich Getötet " .. GetPlayerName(t[2]),
                              16711680)

            else

                sendToDiscord("Konnte nicht gefunden werden-",
                              "Die Spieler Id konnte nicht gefunden werden. Vergewisser dich das es die richtige id ist.",
                              16711680)

            end

        elseif string.starts(command, Config.Prefix .. "playerlist") then

           if Config.ESX then
                local count = 0
                local xPlayers = ESX.GetPlayers()
                local players = "Spieler: "
                for i = 1, #xPlayers, 1 do
                    local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                    local job = xPlayer.getJob()
                    discord = "Nicht gefunden"
                    for _, id in ipairs(GetPlayerIdentifiers(xPlayers[i])) do
                        if string.match(id, "discord:") then
                            discord = string.gsub(id, "discord:", "")
                            break
                        end
                    end

                    count = count + 1
                    local players = players .. GetPlayerName(xPlayers[i]) ..
                                        " | " .. GetRealPlayerName(xPlayers[i]) ..
                                        "|ID " .. xPlayers[i] .. "sein Beruf: " ..
                                        job.name .. " |"

                end
                if count == 0 then
                    sendToDiscord("SPIELER LISTE", "Es sind keine spieler online",
                                  16711680)
                else
                    PerformHttpRequest(Config.WebHook,
                                       function(err, text, headers) end, 'BEREITSTELLEN',
                                       json.encode(
                                           {
                            username = 'Aktuelle spieler zahl : ' .. count,
                            content = players,
                            avatar_url = Config.AvatarURL
                        }), {['Content-Type'] = 'application/json'})
                end

            else

                sendToDiscord("Discord BOT", "ESX ist nicht Aktiviert", 16711680)

            end

        elseif string.starts(command, Config.Prefix .. "revive") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    TriggerClientEvent("esx_ambulancejob:revive", t[2])
                    sendToDiscord("Wiederbeleben Erfolgreich",
                                  "Wiederbeleben Erfolgreich " .. GetPlayerName(t[2]),
                                  16711680)

                else

                    sendToDiscord("Konnte nicht gefunden werden",
                                  "Die Spieler Id konnte nicht gefunden werden. Vergewisser dich das es die richtige id ist.",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX ist nicht Aktiviert", 16711680)

            end

        elseif string.starts(command, Config.Prefix .. "setjob") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        if t[3] and t[4] then
                            xPlayer.setJob(tostring(t[3]),t[4])
                            sendToDiscord("Discord BOT",
                                          "Job wurde erfolgreich angepasst/geändert " ..
                                              xPlayer.getName() .. ' Job',
                                          16711680)
                        else
                            sendToDiscord("Discord BOT",
                                          "Job name oder Stufe war falsch bitte vergewissert dich dass du es wie im beispiel gemacht hast : prefix + setjob + id + job_name + grade_number",
                                          16711680)
                        end

                    end

                else

                    sendToDiscord("Konnte nicht gefunden werden",
                                  "Konnte nicht gefunden werden Vergewisser dich das es die richtige id ist",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX ist nicht Aktiviert", 16711680)

            end


        elseif string.starts(command, Config.Prefix .. "getjob") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        job = xPlayer.getJob()
                        if job then
                            sendToDiscord("Discord Bot",
                                          "Target Job : " .. job.name ..
                                              " \n Target Grade : " .. job.grade ..
                                              " " .. job.grade_label, 16711680)

                        end
                    end

                else

                    sendToDiscord("Konnte nicht gefunden werden",
                                  "Konnte nicht gefunden werden Vergewisser dich das es die richtige id ist",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX ist nicht Aktiviert", 16711680)

            end


        elseif string.starts(command, Config.Prefix .. "getmoney") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        money = xPlayer.getMoney()
                        if money then
                            sendToDiscord("Discord Bot",
                                          "Hat aktuell : " .. money ..
                                              "$ in den Taschen", 16711680)

                        end
                    end

                else

                    sendToDiscord("Konnte nicht gefunden werden",
                                  "Konnte nicht gefunden werden Vergewisser dich das es die richtige id ist",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX ist nicht Aktiviert", 16711680)

            end

            -- getbank
        elseif string.starts(command, Config.Prefix .. "getbank") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        money = xPlayer.getAccount('bank')
                        if money then
                            sendToDiscord("Discord Bot",
                                          "Hat aktuell : " ..
                                              money.money ..
                                              "$ auf der Bank",
                                          16711680)

                        end
                    end

                else

                    sendToDiscord("Konnte nicht gefunden werden",
                                  "Konnte nicht gefunden werden Vergewisser dich das es die richtige id ist",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX ist nicht Aktiviert", 16711680)

            end


        elseif string.starts(command, Config.Prefix .. "removemoney") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        if t[3] then
                            xPlayer.removeMoney(tonumber(t[3]))
                            sendToDiscord("Discord BOT",
                                          "Geld wurde erfolgreich abgezogen " ..
                                              xPlayer.getName() .. ' money',
                                          16711680)
                        else
                            sendToDiscord("Discord BOT",
                                          "ID oder Geld war falsch",
                                          16711680)
                        end

                    end

                else

                    sendToDiscord("Konnte nicht gefunden werden",
                                  "Konnte nicht gefunden werden Vergewisser dich das es die richtige id ist",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX ist nicht Aktiviert", 16711680)

            end


        elseif string.starts(command, Config.Prefix .. "addmoney") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        if t[3] then
                            xPlayer.addMoney(tonumber(t[3]))
                            sendToDiscord("Discord BOT",
                                          "Du hast erfolgreich geld hinzugefügt " ..
                                              xPlayer.getName() .. ' money',
                                          16711680)
                        else
                            sendToDiscord("Discord BOT",
                                          "ID oder Geld war falsch",
                                          16711680)
                        end

                    end

                else

                    sendToDiscord("Konnte nicht gefunden werden",
                                  "Konnte nicht gefunden werden Vergewisser dich das es die richtige id ist",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX ist nicht Aktiviert", 16711680)

            end


        elseif string.starts(command, Config.Prefix .. "addbank") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        if t[3] then
                            xPlayer.addAccountMoney('bank', tonumber(t[3]))
                            sendToDiscord("Discord BOT",
                                          "You Succesfuly added to " ..
                                              xPlayer.getName() .. ' bank money',
                                          16711680)
                        else
                            sendToDiscord("Discord BOT",
                                          "ID oder geht war falsch",
                                          16711680)
                        end

                    end

                else

                    sendToDiscord("Konnte nicht gefunden werden",
                                  "Konnte nicht gefunden werden Vergewisser dich das es die richtige id ist",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX ist nicht Aktiviert", 16711680)

            end


        elseif string.starts(command, Config.Prefix .. "removebank") then

            if Config.ESX then

                local t = mysplit(command, " ")
                if t[2] ~= nil and GetPlayerName(t[2]) ~= nil then
                    local xPlayer = ESX.GetPlayerFromId(t[2])
                    if xPlayer then

                        if t[3] then
                            xPlayer.removeAccountMoney('bank',
                                                            tonumber(t[3]))
                            sendToDiscord("Discord BOT",
                                          "You Succesfuly removed from " ..
                                              xPlayer.getName() .. ' bank money',
                                          16711680)
                        else
                            sendToDiscord("Discord BOT",
                                          "ID war oder Geld war falsch",
                                          16711680)
                        end

                    end

                else

                    sendToDiscord("Konnte nicht gefunden werden",
                                  "Konnte nicht gefunden werden Vergewisser dich das es die richtige id ist",
                                  16711680)

                end

            else

                sendToDiscord("Discord BOT", "ESX ist nicht Aktiviert", 16711680)

            end


        elseif string.starts(command, Config.Prefix .. "notific") then

            local safecom = command
            local t = mysplit(command, " ")
            if t[2] ~= nil and GetPlayerName(t[2]) ~= nil and t[3] ~= nil then

                TriggerClientEvent('chat:addMessage', t[2], {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {
                        "Discord Console",
                        "^1 " ..
                            string.gsub(safecom, "!notific " .. t[2] .. " ", "")
                    }
                })

                sendToDiscord("Erfolgreich gesendet",
                              "Erfolgreich gesendet " ..
                                  string.gsub(safecom,
                                              "!notific " .. t[2] .. " ", "") ..
                                  " Zu " .. GetPlayerName(t[2]), 16711680)

            else

                sendToDiscord("Konnte nicht gefunden werden", "Invalid InPut", 16711680)
            end


        elseif string.starts(command, Config.Prefix .. "announce") then

            local safecom = command
            local t = mysplit(command, " ")
            if t[2] ~= nil then

                TriggerClientEvent('chat:addMessage', -1, {
                    color = {255, 0, 0},
                    multiline = true,
                    args = {
                        "Discord Console",
                        "^1 " ..
                            string.gsub(safecom, Config.Prefix .. "announce", "")
                    }
                })
                sendToDiscord("Erfolgreich gesendet",
                              "Erfolgreich gesendet : " ..
                                  string.gsub(safecom,
                                              Config.Prefix .. "announce", "") ..
                                  " | Zu " .. GetNumPlayerIndices() ..
                                  " Spielr auf den Server", 16711680)

            else

                sendToDiscord("Konnte nicht gefunden werden", "Error", 16711680)
            end

        else

            sendToDiscord("Discord Command",
                          "Command wurde nicht gefunden werdeb",
                          16711680)

        end
    end

end

Citizen.CreateThread(function()

    sendToDiscord('Discord Command','Discord Command Bot ist Online',16711680)
    while true do

        local chanel =
            DiscordRequest("GET", "channels/" .. Config.ChannelID, {})
        if chanel.data then
            local data = json.decode(chanel.data)
            local lst = data.last_message_id
            local lastmessage = DiscordRequest("GET", "channels/" ..
                                                   Config.ChannelID ..
                                                   "/messages/" .. lst, {})
            if lastmessage.data then
                local lstdata = json.decode(lastmessage.data)
                if lastdata == nil then lastdata = lstdata.id end

                if lastdata ~= lstdata.id and lstdata.author.username ~=
                    Config.ReplyUserName then

                    ExecuteCOMM(lstdata.content)
                    lastdata = lstdata.id

                end
            end
        end
        Citizen.Wait(Config.WaitEveryTick)
    end
end)

function sendToDiscord(name, message, color)
    local connect = {
        {
            ["color"] = color,
            ["title"] = "SVService" .. name .. "SVService",
            ["description"] = message,
            ["footer"] = {["text"] = "Developed By Squex"}
        }
    }
    PerformHttpRequest(Config.WebHook, function(err, text, headers) end, 'POST',
                       json.encode({
        username = Config.ReplyUserName,
        embeds = connect,
        avatar_url = Config.AvatarURL
    }), {['Content-Type'] = 'application/json'})
end
