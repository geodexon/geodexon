Task.Register('SaveSettings', function(source, name, bool)
    local user = GetUser(source)
    if user.data.settings == nil then user.data.settings = {} end
    user.data.settings[name] = bool
    SetUserData(source, 'settings', user.data.settings)
end)

Task.Register('SaveCommandSettings', function(source, name, bool)
    local user = GetUser(source)
    if user.data.settings == nil then user.data.settings = {} end
    if user.data.settings.commands == nil then user.data.settings.commands = {} end
    user.data.settings.commands[name] = bool
    SetUserData(source, 'settings', user.data.settings)
end)