RegisterNetEvent('loc')
AddEventHandler('loc', function(a, arg)
	local data = json.decode(a)
--[[ 	print(json.encode(data))
	print(('vector4(%s, %s, %s, %s)'):format(data.x, data.y, data.z, data.w))
	print(('vector3(%s, %s, %s)'):format(data.x, data.y, data.z))
	print(GetConvar('do4', 'false')) ]]
	if GetConvar('do4', 'false') == 'false' then
        if arg == '5' then
			io.popen('clip','w'):write(("{Title = '', Pos = vector3(%s, %s, %s), Hash = %s, Locked = true, Guilds = {table.unpack(pdRanks)}},"):format(data.x, data.y, data.z, data.w)):close()
            return
        end

        for k,v in pairs(data) do
            data[k] = tonumber(v)
        end

		if not arg then
			io.popen('clip','w'):write(("vector3(%s, %s, %s)"):format(data.x, data.y, data.z)):close()
		else
			io.popen('clip','w'):write(("vector4(%s, %s, %s, %s)"):format(data.x, data.y, data.z, data.w)):close()
		end
	else
		io.popen('clip','w'):write(("vector3(%s, %s, %s)"):format(data.x, data.y, data.z, data.w)):close()
	end
end)

RegisterNetEvent('print')
AddEventHandler('print', function(a)
	print(a)
end)

RegisterNetEvent('State.Get')
AddEventHandler('State.Get', function(resource, _type, ident, stat, count)
    local source = source
    local data = exports.ghmattimysql:scalarSync("SELECT data FROM state WHERE type = @Type and ident = @Ident and stat = @Stat", {Type = _type, Ident = ident, Stat = stat})
	print(('[State] Requested [%s %s] State [%s]'):format(_type, ident, stat))
	TriggerClientEvent('State.Get', source, data or false, count, resource)
end)

RegisterNetEvent('GetVehicleData')
AddEventHandler('GetVehicleData', function(res, prom, plate)
	local source = source
	exports.ghmattimysql:scalar('SELECT data from vehicles where plate = @plate', {plate = plate}, function(result)
		TriggerClientEvent('ReturnPromise', source, res, prom, result)
	end)
end)

RegisterNetEvent("3DSound")
AddEventHandler("3DSound", function(coords,soundName,volume,radius)
	local source = source
    TriggerClientEvent("3DSound", -1, coords,soundName,volume,radius, GetCharacter(source).interior or 'none')
end)


RegisterNetEvent('Ped.Control')
AddEventHandler('Ped.Control', function(ped, bool)
	ped = NetworkGetEntityFromNetworkId(ped)
	Entity(ped).state.controlled = bool
end)

RegisterNetEvent('BugReport')
AddEventHandler('BugReport', function(report)
    local headers = {
        ['Content-Type'] = 'application/json'
      }
    PerformHttpRequest(discord.webhook, function(err, text, header) end, 'POST',
    json.encode({
        username = 'Dumbass',
        avatar_url = "https://i.imgur.com/56Zpphu.png",
        embeds = {{
            author = {
                name = "Bug Reporting Utility",
                icon_url = 'https://static.tvtropes.org/pmwiki/pub/images/tfs_mr_popo.PNG'
            },
            fields = {
                {
                    name = "Bug Report Title",
                    value = report[1]
                },
                {
                    name = "Bug Report Description",
                    value = report[2]
                }
            }
        }}

    }), { ['Content-Type'] = 'application/json'})
end)