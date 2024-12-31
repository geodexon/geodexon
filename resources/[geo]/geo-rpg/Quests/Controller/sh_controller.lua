local _q = json.decode(LoadResourceFile(GetCurrentResourceName(), 'Quests/Controller/Quests.json'))
Quests = {}

for k,v in pairs(_q) do
    Quests[v.quest_id] = v
end