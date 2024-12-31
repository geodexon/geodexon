local bl = {
	['playerConnecting'] = true
}

State = {}

function Hash(str)

	if bl[str] then
		return str
	end

	if str:match('cfx') then
        return str
    end
	
    return tostring(GetHashKey(str..'-geo'))
end

local seed = 0
local count = 0
local function rseed()
    local time = os.time()
    math.randomseed(time + count)
    count = count + 1
end

local seed = 0
function Random(min, max)
    local time = os.time()
    if time - seed > 5 then
        seed = time
        math.randomseed(time)
    end
    if not max then
        max = min
        min = 1
    end
    return math.random() and math.random() and math.random(min, max)
end

function shuffle(array)
    local output = { }
    rseed()
    local random = math.random
    
    for index = 1, #array do
        local offset = index - 1
        local value = array[index]
        local randomIndex = offset*random()
        local flooredIndex = randomIndex - randomIndex%1
    
        if flooredIndex == offset then
            output[#output + 1] = value
        else
            output[#output + 1] = output[flooredIndex + 1]
            output[flooredIndex + 1] = value
        end
    end
    
    return output
end

--[[ _G.Handler = AddEventHandler
AddEventHandler = function(str, ...)
    _G.Handler(Hash(str), ...)
end

_G.NetHandler = RegisterNetEvent
RegisterNetEvent = function(str)
    _G.NetHandler(Hash(str))
end

_G.NetHandler2 = RegisterNetEvent
RegisterNetEvent = function(str)
    _G.NetHandler2(Hash(str))
end

_G.ServerHandler = TriggerClientEvent
TriggerClientEvent = function(str, ...)
    _G.ServerHandler(Hash(str), ...)
end

_G.EventHandler = TriggerEvent
TriggerEvent = function(str, ...)
    _G.EventHandler(Hash(str), ...)
end ]]

function GetIdent(client)
	local identifiers = GetPlayerIdentifiers(client)
	local result = {steamid = "", license = "", ip = ""}

    for _, identifier in pairs(identifiers) do
		if string.find(identifier,"steam:") then
			result.steamid = identifier
		elseif string.find(identifier,"license:") then
			result.license = identifier
		elseif string.find(identifier,"ip:") then
            result.ip = string.sub(identifier, 4)
        elseif string.find(identifier,"discord:") then
            result.discord = string.sub(identifier, 9)
        elseif string.find(identifier,"fivem:") then
			result.fivem = string.sub(identifier, 7)
		end
	end
	return result
end

function New(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[New(orig_key)] = New(orig_value)
        end
        setmetatable(copy, New(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function GetCharacter(id)
    return exports['geo']:Char(tonumber(id))
end

function GetCharacterByID(id)
    return exports['geo']:CharFromID(tonumber(id))
end

function GetName(char)
    local name = char.first

    if char.username then
        return char.username
    end

    if char.Title then
        name = char.Title..' '..char.last
    else
        name = name..' '..char.last
    end

    return name
end

function UpdateChar(serverID, type, val)
    exports['geo']:UpdateCharacter(serverID, type, val)
end

function Vdist3(vec1, vec2)
    return #(vec1 - vec2)
end

function Vdist4(vec1, vec2)
    local var = #(vec1 - vec2)
    return (var * var)
end

function _TimeSince(time)
    local atime = os.time()
    local val =  time - atime 
    local hours = math.floor(val / 3600)
    val = val - (hours * 3600)

    local minutes = math.floor(val / 60)

    val = val - (minutes * 60)

    return {hours = hours, minutes = minutes, seconds = val}
end

function DeleteEntity(entity)
    return Citizen.InvokeNative(0xFAA3D236, entity)
end

local debug = GetConvar('debug', 'false')
function Log(t, v)

    if type(v) == 'table' then
        v = json.encode(v)
    end

    SQL('INSERT INTO log (type, data) VALUES (?, ?)', t, v)

    if t ~= '[Inventory]' then
        Console('['..t..']', v)
    end
end
-- SELECT a.*, b.username FROM log a JOIN (SELECT * FROM users) AS b ON json_value(a.`data`, "$.user") = b.id

function Console(t, v)
    if type(v) == 'table' then
        v = json.encode(v)
    end

    print(os.date('%X'), t or '', v or '')
end


State.Set = function(_type, ident, stat, Data)
    if _type == nil or ident == nil or stat == nil then
        return false
    end
    if not State.Get(_type, ident, stat) then
        exports.ghmattimysql:execute("INSERT INTO state (type, ident, stat, data) VALUES (@Type, @Ident, @Stat, @Data)", {Type = _type, Ident = tostring(ident), Stat = stat, Data = tostring(Data)})
    else
        exports.ghmattimysql:execute("UPDATE state SET data = @Data WHERE type = @Type and ident = @Ident and stat = @Stat", {Type = _type, Ident = tostring(ident), Stat = stat, Data = tostring(Data)})
    end
    print(('[State] Set [%s %s] State [%s] to [%s]'):format(_type, ident, stat, Data))
end

State.Get = function(_type, ident, stat)
    print(('[State] Requested [%s %s] State [%s]'):format(_type, ident, stat))
    return exports.ghmattimysql:scalarSync("SELECT data FROM state WHERE type = @Type and ident = @Ident and stat = @Stat", {Type = _type, Ident = tostring(ident), Stat = stat}) or false
end

function SplitString(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end


function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function GetUser(src)
    return exports['geo']:GetUser(src)
end

local random = math.random
function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function uuidshort()
    local template ='xxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function comma_value(amount)
    local formatted = amount
    while true do  
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
      if (k==0) then
        break
      end
    end
    return formatted
  end

function SQL(query, ...)
    local prom = promise.new()
    exports.ghmattimysql:execute(query, {...}, function(res)
        prom:resolve(res)
    end)
    return Citizen.Await(prom)
end

function Format(str, ...)
    return string.format(str, ...)
end

function AddProp(model, position, heading)
    if type(model) == 'string' then model = GetHashKey(model) end
    local obj = CreateObjectNoOffset(model, position, true, true, false)
    while not DoesEntityExist(obj) do
        Wait(100)
    end
    Wait(100)
    SetEntityCoords(obj, position)
    SetEntityHeading(obj, heading)
    return obj
end

function CreateAutomobile(...)
    return Citizen.InvokeNative(GetHashKey('CREATE_AUTOMOBILE'), ...)
end

function GetPrice(amount)
    return amount + math.floor(amount * (exports['geo-guilds']:GetTax()) / 100)
end

VehicleClass = {
    Compact = 0,
    Sedan = 1,
    SUV = 2,
    Coupe = 3,
    Muscle = 4,
    SportsClassic = 5,
    Sports = 6,
    Super = 7,
    Motorcycle = 8,
    OffRoad = 9,
    Industrial = 10,
    Utility = 11,
    Van = 12,
    Cycle = 13,
    Boat = 14,
    Helicopter = 15,
    Plane = 16,
    Service = 17,
    Emergency = 18,
    Military = 19,
    Commcerical = 20,
    Trains = 21
}

local discord = {
    webhook = 'https://discord.com/api/webhooks/849440576944341013/JcX4RZyrvUCaXjWRzL3zUXMlou0vzetCEnBMpDunD1MO0ChZrYPZBNyYZTkziVLAKogT'
}

function TimeSince(start)
    local time = GetGameTimer()
    return (time - start)
end

local _rates = {}
function RateLimit(id, time, bool)
    if _rates[id] == nil then _rates[id] = (GetGameTimer() - time) end
    if TimeSince(_rates[id]) >= time then 
        if not bool then _rates[id] = GetGameTimer() end
        return true 
    end
    return false
end

function RateLimitSeconds(id, time, bool)
    local _time = os.time()
    if _rates[id] == nil then _rates[id] = (_time - time) end
    if _time - _rates[id] >= time then 
        if not bool then _rates[id] = _time end
        return true 
    end
    return false
end

function SetData(source, key, val)
    return exports['geo']:SetData(source, key, val)
end

function SetUserData(source, key, val)
    return exports['geo']:SetUserData(source, key, val)
end

Levels = {
    [1] = 0,
    [2] = 300,
    [3] = 600,
    [4] = 1100,
    [5] = 1600,
    [6] = 2300,
    [7] = 3200,
    [8] = 4200,
    [9] = 5500,
    [10] = 7100,
    [11] = 9000,
    [12] = 11300,
    [13] = 14100,
    [14] = 17600,
    [15] = 21700,
    [16] = 26800,
    [17] = 32900,
    [18] = 40200,
    [19] = 49100,
    [20] = 59700,
    [21] = 72500,
    [22] = 87900,
    [23] = 106200,
    [24] = 128100,
    [25] = 154300,
    [26] = 185400,
    [27] = 222400,
    [28] = 266300,
    [29] = 318400,
    [30] = 379900,
    [31] = 452600,
    [32] = 538200,
    [33] = 639000,
    [34] = 757500,
    [35] = 896300,
    [36] = 1058900,
    [37] = 1248900,
    [38] = 1470600,
    [39] = 1728800,
    [40] = 2029100,
    [41] = 2377600,
    [42] = 2781400,
    [43] = 3248500,
    [44] = 3787900,
    [45] = 4409800,
    [46] = 5125300,
    [47] = 5947300,
    [48] = 6889900,
    [49] = 7969000,
    [50] = 9202100,
    [51] = 10608700,
    [52] = 12210500,
    [53] = 14031400,
    [54] = 16097700,
    [55] = 18438200,
    [56] = 21084700,
    [57] = 24072000,
    [58] = 27438000,
    [59] = 31223800,
    [60] = 35474400,
    [61] = 40238200,
    [62] = 45567700,
    [63] = 51519400,
    [64] = 58154100,
    [65] = 65536800,
    [66] = 73737200,
    [67] = 82829300,
    [68] = 92892100,
    [69] = 104008900,
    [70] = 116268000,
    [71] = 129762200,
    [72] = 144588900,
    [73] = 160850100,
    [74] = 178652100,
    [75] = 198105200,
    [76] = 219323600,
    [77] = 242425300,
    [78] = 267530900,
    [79] = 294764300,
    [80] = 324251200,
    [81] = 356119200,
    [82] = 390496800,
    [83] = 427512900,
    [84] = 467296000,
    [85] = 509973200,
    [86] = 555669900,
    [87] = 604508200,
    [88] = 656606500,
    [89] = 712078200,
    [90] = 771030600,
    [91] = 833564500,
    [92] = 899772200,
    [93] = 969737200,
    [94] = 1043532800,
    [95] = 1121221100,
    [96] = 1202852100,
    [97] = 1288462500,
    [98] = 1378075300,
    [99] = 1471698300,
    [100] = 1569323600,
}

function GetLevel(xp)
    local level = 1
    xp = xp or 0
    for k,v in pairs(Levels) do
        if xp >= v then
            level = k
        else
            break
        end
    end

    return level
end