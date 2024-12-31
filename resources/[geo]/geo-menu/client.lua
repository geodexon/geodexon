RequestStreamedTextureDict('commonmenu')

Menu = {}
local keys = { up = 172, down = 173, left = 174, right = 175, select = 176, back = 177, shift = 21}
local buttonPressed = nil
local menuIndex= {}
local multi = 0
local awaitClose = false
Menu.Menus = {}
Menu.OptionCount = 0
Menu.ActiveOption = 1
Menu.ExtraOffset = -0.03

local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
	SetTextColour(color.r, color.g, color.b, color.a)
	SetTextFont(font)
	SetTextScale(scale, scale)

	if shadow then
		SetTextDropShadow(2, 2, 0, 0, 0)
	end

	if center then
		SetTextCentre(center)
	elseif alignRight then
		SetTextWrap(Menu.Menus[Menu.CurrentMenu].x - Menu.Menus[Menu.CurrentMenu].Width / 2, Menu.Menus[Menu.CurrentMenu].x + Menu.Menus[Menu.CurrentMenu].Width / 2 - 0.005)
		SetTextRightJustify(true)
	end

    SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

local function drawTitle()
    if Menu.CurrentMenu then
        DrawSprite("commonmenu", "gradient_nav", Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y, Menu.Menus[Menu.CurrentMenu].Width, Menu.Menus[Menu.CurrentMenu].Height, 0.0, table.unpack(Menu.Menus[Menu.CurrentMenu].TitleColor))
        DrawSprite("commonmenu", "header_gradient_script", Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y, Menu.Menus[Menu.CurrentMenu].Width, Menu.Menus[Menu.CurrentMenu].Height, 0.0, table.unpack(Menu.Menus[Menu.CurrentMenu].TitleColor))
        DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.055, Menu.Menus[Menu.CurrentMenu].Width, 0.03, 0, 0, 0, 150)
        drawText(Menu.Menus[Menu.CurrentMenu].Title, Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y - Menu.Menus[Menu.CurrentMenu].Height / 2 + 0.015, 1, { r = 255, g = 255, b = 255, a = 255 }, 0.8, true, 1, false)
        drawText((Menu.ActiveOption)..' / '..Menu.OptionCount, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.0425, 0, {r = 255, g = 255, b = 255, a = 255}, 0.3, false, false, true)
        drawText(Menu.Menus[Menu.CurrentMenu].SubTitle, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.0425, 0, {r = 255, g = 255, b = 255, a = 255}, 0.3, false, false, false)
    end
end

function Menu.CreateMenu(MenuName, title, subTitle)
    Menu.Menus[MenuName] = {
        Width = 0.2,
        Height = 0.08,
        x = 0.875,
        y = 0.09,
        Title = title,
        SubTitle = subTitle,
        TitleColor = {116, 53, 171, 255},
        ButtonColor = {0, 0, 0, 150},
        MaxOptions = 12,
        ActiveColor = {255, 255, 255, 255},
        LastOption = 1
    }
end

function Menu.CreateSubMenu(id, parent, subtitle)
    Menu.Menus[id] = json.decode(json.encode(Menu.Menus[parent]))
    Menu.Menus[id].Title = subtitle
    Menu.Menus[id].Parent = parent
end

function Menu.OpenMenu(menu)
    awaitClose = true
    TriggerEvent('Menu.CloseMenu', function()
        awaitClose = false
    end)
    while awaitClose do
        Wait(0)
    end
    if Menu.Menus[menu] ~= nil then
        Menu.OptionCount = 0
        Menu.ExtraOffset = -0.03
        Menu.CurrentMenu = menu
        Menu.ActiveOption = Menu.Menus[menu].LastOption or 1
        menuIndex[#menuIndex + 1] = menu
    end
end

function Menu.Button(Text, Sub)
    if Menu.CurrentMenu then
        Menu.OptionCount = Menu.OptionCount + 1
        local multiplier
        if Menu.ActiveOption <= Menu.Menus[Menu.CurrentMenu].MaxOptions and Menu.OptionCount <= Menu.Menus[Menu.CurrentMenu].MaxOptions then
            multiplier = Menu.OptionCount
        elseif Menu.OptionCount > Menu.ActiveOption - Menu.Menus[Menu.CurrentMenu].MaxOptions and Menu.OptionCount <= Menu.ActiveOption then
            multiplier = Menu.OptionCount - (Menu.ActiveOption - Menu.Menus[Menu.CurrentMenu].MaxOptions)
        end
        if multiplier then
            if Menu.OptionCount == Menu.ActiveOption then
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), Menu.Menus[Menu.CurrentMenu].Width, 0.03, table.unpack(Menu.Menus[Menu.CurrentMenu].ActiveColor))
                drawText(Text, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 0, g = 0, b = 0, a = 255}, 0.3, false, false, false)
                if Sub ~= nil then
                    drawText(Sub, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 0, g = 0, b = 0, a = 255}, 0.3, false, false, true)
                end
            else
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), Menu.Menus[Menu.CurrentMenu].Width, 0.03, table.unpack(Menu.Menus[Menu.CurrentMenu].ButtonColor))
                drawText(Text, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.3, false, false, false)
                if Sub ~= nil then
                    drawText(Sub, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.3, false, false, true)
                end
            end
        else
            Menu.ExtraOffset = Menu.ExtraOffset - 0.03
        end
        if buttonPressed == keys.select and Menu.OptionCount == Menu.ActiveOption then
            buttonPressed = nil
            return true
        end
    end
end

function Menu.EmptyButton(Text, Sub)
    Menu.ExtraOffset = Menu.ExtraOffset + 0.03

    DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), Menu.Menus[Menu.CurrentMenu].Width, 0.03, table.unpack(Menu.Menus[Menu.CurrentMenu].ButtonColor))
    drawText(Text, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.3, false, false, false)
    if Sub ~= nil then
        drawText(Sub, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.3, false, false, true)
    end
end

function Menu.EmptyButtonSmall(Text, Sub)
    Menu.ExtraOffset = Menu.ExtraOffset + 0.03

    DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), Menu.Menus[Menu.CurrentMenu].Width, 0.03, table.unpack(Menu.Menus[Menu.CurrentMenu].ButtonColor))
    drawText(Text, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5) + 0.0049, Menu.Menus[Menu.CurrentMenu].y + 0.076 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.25, false, false, false)
    if Sub ~= nil then
        drawText(Sub, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5) + 0.0049, Menu.Menus[Menu.CurrentMenu].y + 0.076 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.25, false, false, false)
    end
end

function Menu.Extra(str)
    local lr = #str

    if not Menu.CurrentMenu then
        return  
    end

    DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.05) + (0.015 * lr), Menu.Menus[Menu.CurrentMenu].Width, 0.03 * lr, table.unpack(Menu.Menus[Menu.CurrentMenu].ButtonColor))
    for k,v in pairs(str) do
        drawText(v[1], Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5),Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.05) + (0.03 * k) - 0.015, 0, {r = 255, g = 255, b = 255, a = 255}, 0.3, false, false, false)
        if v[2] ~= nil then
            drawText(v[2], Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.05) + (0.03 * k) - 0.015, 0, {r = 255, g = 255, b = 255, a = 255}, 0.3, false, false, true)
        end
    end
end

function Menu.CheckBox(Text, bool, callback)
    if Menu.CurrentMenu then
        Menu.OptionCount = Menu.OptionCount + 1
        local multiplier
        if Menu.ActiveOption <= Menu.Menus[Menu.CurrentMenu].MaxOptions and Menu.OptionCount <= Menu.Menus[Menu.CurrentMenu].MaxOptions then
            multiplier = Menu.OptionCount
        elseif Menu.OptionCount > Menu.ActiveOption - Menu.Menus[Menu.CurrentMenu].MaxOptions and Menu.OptionCount <= Menu.ActiveOption then
            multiplier = Menu.OptionCount - (Menu.ActiveOption - Menu.Menus[Menu.CurrentMenu].MaxOptions)
        end
        if multiplier then
            if Menu.OptionCount == Menu.ActiveOption then
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), Menu.Menus[Menu.CurrentMenu].Width, 0.03, table.unpack(Menu.Menus[Menu.CurrentMenu].ActiveColor))
                drawText(Text, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 0, g = 0, b = 0, a = 255}, 0.3, false, false, false)
                if Sub ~= nil then
                    drawText(Sub, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 0, g = 0, b = 0, a = 255}, 0.3, false, false, true)
                end
                if not bool then
                    DrawRect(Menu.Menus[Menu.CurrentMenu].x + (Menu.Menus[Menu.CurrentMenu].Width * 0.45), Menu.Menus[Menu.CurrentMenu].y + 0.08515 + (0.03 * (Menu.OptionCount) + Menu.ExtraOffset), 0.016, 0.026, 255, 255, 255, 150)
                    DrawRect(Menu.Menus[Menu.CurrentMenu].x + (Menu.Menus[Menu.CurrentMenu].Width * 0.45), Menu.Menus[Menu.CurrentMenu].y + 0.08525 + (0.03 * (Menu.OptionCount) + Menu.ExtraOffset), 0.014, 0.023, 0, 0, 0, 255)
                else
                    DrawRect(Menu.Menus[Menu.CurrentMenu].x + (Menu.Menus[Menu.CurrentMenu].Width * 0.45), Menu.Menus[Menu.CurrentMenu].y + 0.08515 + (0.03 * (Menu.OptionCount) + Menu.ExtraOffset), 0.016, 0.026, 0, 0, 0, 150)
                    DrawRect(Menu.Menus[Menu.CurrentMenu].x + (Menu.Menus[Menu.CurrentMenu].Width * 0.45), Menu.Menus[Menu.CurrentMenu].y + 0.08525 + (0.03 * (Menu.OptionCount) + Menu.ExtraOffset), 0.013, 0.022, 255, 255, 255, 255)
                    DrawSprite('commonmenu', "shop_tick_icon", Menu.Menus[Menu.CurrentMenu].x + (Menu.Menus[Menu.CurrentMenu].Width * 0.45), Menu.Menus[Menu.CurrentMenu].y + 0.086 + (0.03 * (Menu.OptionCount) + Menu.ExtraOffset), 0.026, 0.046, 0.0, 100, 100, 100, 255)
                end
            else
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), Menu.Menus[Menu.CurrentMenu].Width, 0.03, table.unpack(Menu.Menus[Menu.CurrentMenu].ButtonColor))
                drawText(Text, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.3, false, false, false)
                if Sub ~= nil then
                    drawText(Sub, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.074 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.3, false, false, true)
                end
                if bool then
                    DrawRect(Menu.Menus[Menu.CurrentMenu].x + (Menu.Menus[Menu.CurrentMenu].Width * 0.45), Menu.Menus[Menu.CurrentMenu].y + 0.08515 + (0.03 * (Menu.OptionCount) + Menu.ExtraOffset), 0.016, 0.026, 0, 0, 0, 150)
                    DrawRect(Menu.Menus[Menu.CurrentMenu].x + (Menu.Menus[Menu.CurrentMenu].Width * 0.45), Menu.Menus[Menu.CurrentMenu].y + 0.08525 + (0.03 * (Menu.OptionCount) + Menu.ExtraOffset), 0.013, 0.022, 255, 255, 255, 255)
                    DrawSprite('commonmenu', "shop_tick_icon", Menu.Menus[Menu.CurrentMenu].x + (Menu.Menus[Menu.CurrentMenu].Width * 0.45), Menu.Menus[Menu.CurrentMenu].y + 0.086 + (0.03 * (Menu.OptionCount) + Menu.ExtraOffset), 0.026, 0.046, 0.0, 100, 100, 100, 255)
                else
                    DrawRect(Menu.Menus[Menu.CurrentMenu].x + (Menu.Menus[Menu.CurrentMenu].Width * 0.45), Menu.Menus[Menu.CurrentMenu].y + 0.08515 + (0.03 * (Menu.OptionCount) + Menu.ExtraOffset), 0.016, 0.026, 255, 255, 255, 150)
                    DrawRect(Menu.Menus[Menu.CurrentMenu].x + (Menu.Menus[Menu.CurrentMenu].Width * 0.45), Menu.Menus[Menu.CurrentMenu].y + 0.08525 + (0.03 * (Menu.OptionCount) + Menu.ExtraOffset), 0.013, 0.023, 0, 0, 0, 255)
                end
            end
        else
            Menu.ExtraOffset = Menu.ExtraOffset - 0.03
        end
        if buttonPressed == keys.select and Menu.OptionCount == Menu.ActiveOption then
            buttonPressed = nil
            bool = not bool
            if callback then
                Citizen.CreateThreadNow(function()
                    callback(bool)
                end)
            end
            return true
        end
    end
end

function Menu.Slider(Text, items, currentIndex, callback, Sub)
    if Menu.CurrentMenu then
        Menu.OptionCount = Menu.OptionCount + 1
        local multiplier
        if Menu.ActiveOption <= Menu.Menus[Menu.CurrentMenu].MaxOptions and Menu.OptionCount <= Menu.Menus[Menu.CurrentMenu].MaxOptions then
            multiplier = Menu.OptionCount
        elseif Menu.OptionCount > Menu.ActiveOption - Menu.Menus[Menu.CurrentMenu].MaxOptions and Menu.OptionCount <= Menu.ActiveOption then
            multiplier = Menu.OptionCount - (Menu.ActiveOption - Menu.Menus[Menu.CurrentMenu].MaxOptions)
        end
        if multiplier then
            local num = 0
            if type(items) == 'table' then
                for k,v in pairs(items) do
                    num = num + 1
                end
                items = num
            end
            if currentIndex == -1 then
                currentIndex = 1
            end
            local percent = (currentIndex/items) * (Menu.Menus[Menu.CurrentMenu].Width - 0.015)
            local width = (percent)
            local offset = (Menu.Menus[Menu.CurrentMenu].x - ((Menu.Menus[Menu.CurrentMenu].Width - width - 0.014) / 2))
            if Menu.OptionCount == Menu.ActiveOption then
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), Menu.Menus[Menu.CurrentMenu].Width, 0.03, table.unpack(Menu.Menus[Menu.CurrentMenu].ActiveColor))
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), Menu.Menus[Menu.CurrentMenu].Width, 0.02, table.unpack(Menu.Menus[Menu.CurrentMenu].ActiveColor))
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.0825 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), Menu.Menus[Menu.CurrentMenu].Width - 0.01, 0.015, 0, 0, 0, 150)
                DrawRect(offset, Menu.Menus[Menu.CurrentMenu].y + 0.0825 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), width, 0.011, table.unpack(Menu.Menus[Menu.CurrentMenu].ActiveColor))
                drawText(Text, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5) + 0.0049, Menu.Menus[Menu.CurrentMenu].y + 0.076 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 0, g = 0, b = 0, a = 255}, 0.25, false, false, false)
                drawText(Sub or currentIndex..' / '..items, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.076 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 0, g = 0, b = 0, a = 255}, 0.25, false, false, true)
                
                if buttonPressed == keys.right then
                    if currentIndex + 1 + multi > items then
                        currentIndex = 1
                    else
                        currentIndex = currentIndex + 1 + multi
                    end
                    buttonPressed = nil
                elseif buttonPressed == keys.left then
                    if currentIndex - 1 - multi == 0 then
                        currentIndex = items
                    else
                        currentIndex = currentIndex + -1 - multi
                    end
                    buttonPressed = nil
                elseif buttonPressed == keys.select then
                    buttonPressed = nil
                    callback(currentIndex)
                    Menu.OptionCount = Menu.OptionCount + 1
                    Menu.ExtraOffset = Menu.ExtraOffset + 0.02
                    return true
                end
                if currentIndex > items then
                    currentIndex = 0
                elseif currentIndex < 1 then
                    currentIndex = items
                end
                Citizen.CreateThreadNow(function()
                    callback(currentIndex)
                end)
            else
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), Menu.Menus[Menu.CurrentMenu].Width, 0.03, table.unpack(Menu.Menus[Menu.CurrentMenu].ButtonColor))
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), Menu.Menus[Menu.CurrentMenu].Width, 0.02, table.unpack(Menu.Menus[Menu.CurrentMenu].ButtonColor))
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.0825 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), Menu.Menus[Menu.CurrentMenu].Width - 0.01, 0.015, 0, 0, 0, 150)
                DrawRect(offset, Menu.Menus[Menu.CurrentMenu].y + 0.0825 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), width, 0.011, table.unpack(Menu.Menus[Menu.CurrentMenu].ActiveColor))
                drawText(Text, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5) + 0.0049, Menu.Menus[Menu.CurrentMenu].y + 0.076 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.25, false, false, false)
                drawText(Sub or currentIndex..' / '..items, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.076 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.25, false, false, true)
            end

            Menu.ExtraOffset = Menu.ExtraOffset + 0.02
        else
            Menu.ExtraOffset = Menu.ExtraOffset - 0.03
        end
    end
end

function Menu.SliderStep(Text, min, max, step, currentIndex, callback)
    if Menu.CurrentMenu then
        if tostring(currentIndex):sub(3) == 0 then
            currentIndex = math.floor( currentIndex )
        end
        Menu.OptionCount = Menu.OptionCount + 1
        local multiplier
        if Menu.ActiveOption <= Menu.Menus[Menu.CurrentMenu].MaxOptions and Menu.OptionCount <= Menu.Menus[Menu.CurrentMenu].MaxOptions then
            multiplier = Menu.OptionCount
        elseif Menu.OptionCount > Menu.ActiveOption - Menu.Menus[Menu.CurrentMenu].MaxOptions and Menu.OptionCount <= Menu.ActiveOption then
            multiplier = Menu.OptionCount - (Menu.ActiveOption - Menu.Menus[Menu.CurrentMenu].MaxOptions)
        end
        if multiplier then

            local nOff = 0
            local nOff2 = 0
            if min < 0 then
                nOff = min
                nOff2 = currentIndex - min
            else
                nOff2 = currentIndex
            end
            local total = max - nOff

            local percent = (nOff2/total) * (Menu.Menus[Menu.CurrentMenu].Width - 0.015)
            local width = (percent)
            local offset = (Menu.Menus[Menu.CurrentMenu].x - ((Menu.Menus[Menu.CurrentMenu].Width - width - 0.014) / 2))
            if Menu.OptionCount == Menu.ActiveOption then
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), Menu.Menus[Menu.CurrentMenu].Width, 0.03, table.unpack(Menu.Menus[Menu.CurrentMenu].ActiveColor))
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), Menu.Menus[Menu.CurrentMenu].Width, 0.02, table.unpack(Menu.Menus[Menu.CurrentMenu].ActiveColor))
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.0825 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), Menu.Menus[Menu.CurrentMenu].Width - 0.01, 0.015, 0, 0, 0, 150)
                DrawRect(offset, Menu.Menus[Menu.CurrentMenu].y + 0.0825 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), width, 0.011, table.unpack(Menu.Menus[Menu.CurrentMenu].ActiveColor))
                drawText(Text, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5) + 0.0049, Menu.Menus[Menu.CurrentMenu].y + 0.076 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 0, g = 0, b = 0, a = 255}, 0.25, false, false, false)
                drawText(currentIndex..' / '..max, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.076 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 0, g = 0, b = 0, a = 255}, 0.25, false, false, true)
                if buttonPressed == keys.right then
                    local newNum = tonumber(string.format("%.1f",currentIndex + step ))
                    if newNum > max then
                        currentIndex = min
                    else
                        currentIndex = newNum
                    end
                    buttonPressed = nil
                elseif buttonPressed == keys.left then
                    local newNum = tonumber(string.format("%.1f",currentIndex - step ))
                    if newNum < min then
                        currentIndex = max
                    else
                        currentIndex = newNum
                    end
                    buttonPressed = nil
                elseif buttonPressed == keys.select then
                    buttonPressed = nil
                    callback(currentIndex)
                    Menu.OptionCount = Menu.OptionCount + 1
                    Menu.ExtraOffset = Menu.ExtraOffset + 0.02
                    return true
                end
                if currentIndex > max then
                    currentIndex = min
                elseif currentIndex < min then
                    currentIndex = max
                end
                Citizen.CreateThreadNow(function()
                    callback(currentIndex)
                end)
            else
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), Menu.Menus[Menu.CurrentMenu].Width, 0.03, table.unpack(Menu.Menus[Menu.CurrentMenu].ButtonColor))
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.085 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), Menu.Menus[Menu.CurrentMenu].Width, 0.02, table.unpack(Menu.Menus[Menu.CurrentMenu].ButtonColor))
                DrawRect(Menu.Menus[Menu.CurrentMenu].x, Menu.Menus[Menu.CurrentMenu].y + 0.0825 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), Menu.Menus[Menu.CurrentMenu].Width - 0.01, 0.015, 0, 0, 0, 150)
                DrawRect(offset, Menu.Menus[Menu.CurrentMenu].y + 0.0825 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset + 0.025), width, 0.011, table.unpack(Menu.Menus[Menu.CurrentMenu].ActiveColor))
                drawText(Text, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5) + 0.0049, Menu.Menus[Menu.CurrentMenu].y + 0.076 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.25, false, false, false)
                drawText(currentIndex..' / '..max, Menu.Menus[Menu.CurrentMenu].x - (Menu.Menus[Menu.CurrentMenu].Width * 0.5), Menu.Menus[Menu.CurrentMenu].y + 0.076 + ((0.03 * Menu.OptionCount) + Menu.ExtraOffset), 0, {r = 255, g = 255, b = 255, a = 255}, 0.25, false, false, true)
            end

            Menu.ExtraOffset = Menu.ExtraOffset + 0.02
        else
            Menu.ExtraOffset = Menu.ExtraOffset - 0.03
        end
    end
end

function Menu.ComboBox(Text, items, currentIndex, callback)
    if Menu.CurrentMenu then
        if Menu.Button(Text, '&lt; '..(items[currentIndex] or 'Unknown')..' &gt;') then
            return true
        end
        if Menu.OptionCount == Menu.ActiveOption then
            if buttonPressed == keys.right then
                if currentIndex + 1 > #items then
                    currentIndex = 1
                else
                    currentIndex = currentIndex + 1
                end
            elseif buttonPressed == keys.left then
                if currentIndex - 1 == 0 then
                    currentIndex = #items
                else
                    currentIndex = currentIndex + -1
                end
            end
            callback(currentIndex)
        end
    end
end

function Menu.IsOpen(menu)
    return Menu.CurrentMenu == menu
end

function Menu.Display(cycleTime)
    if Menu.CurrentMenu then
        drawTitle()
        buttonPressed = nil
        local canSpeed = true
	    if cycleTime == nil then
	    	canSpeed = false
        end
        Menu.Menus[Menu.CurrentMenu].LastOption = Menu.ActiveOption

        if Menu.Flag then
            Menu.Flag = false
            goto skip
        end

        if IsControlJustPressed(0, keys.down) then
            Menu.ActiveOption = Menu.ActiveOption + 1
        elseif IsControlJustPressed(0, keys.up) then
            Menu.ActiveOption = Menu.ActiveOption - 1
        elseif IsControlJustPressed(0, keys.select) then
            buttonPressed = keys.select
        elseif IsControlJustPressed(0, keys.back) then
            if Menu.Menus[Menu.CurrentMenu].Parent then
                Menu.CurrentMenu = Menu.Menus[Menu.CurrentMenu].Parent
                Menu.ActiveOption = Menu.Menus[Menu.CurrentMenu].LastOption
            else
                Menu.CloseMenu()
            end
        elseif IsControlJustPressed(0, 11) then
            Menu.ActiveOption = Menu.ActiveOption + 11
            if Menu.ActiveOption > Menu.OptionCount then
                Menu.ActiveOption = Menu.OptionCount
            end
        elseif IsControlJustPressed(0, 10) then
            Menu.ActiveOption = Menu.ActiveOption - 11
            if Menu.ActiveOption < 1 then
                Menu.ActiveOption = 1
            end
        end

        Citizen.CreateThreadNow(function()
            if IsControlJustPressed(0, keys.left) then
                buttonPressed = keys.left
                for i=1,4 do
                    Wait(250)
                    if not IsControlPressed(0, keys.left) then
                        canSpeed = false
                        multi = 0
                        break
                    end
                end
                if canSpeed then
                    while IsControlPressed(0, keys.left) do
                        Wait(cycleTime)
                        buttonPressed = keys.left
                        if IsControlPressed(0, keys.shift) then
                            multi = 50
                        else
                            multi = 0
                        end
                    end
                end
            elseif IsControlJustPressed(0, keys.right) then
                buttonPressed = keys.right
                for i=1,4 do
                    Wait(250)
                    if not IsControlPressed(0, keys.right) then
                        canSpeed = false
                        multi = 0
                        break
                    end
                end
                if canSpeed then
                    while IsControlPressed(0, keys.right) do
                        Wait(cycleTime)
                        buttonPressed = keys.right
                        if IsControlPressed(0, keys.shift) then
                            multi = 50
                        else
                            multi = 0
                        end
                    end
                end
            end
        end)

        ::skip::

        if Menu.ActiveOption > Menu.OptionCount then
            Menu.ActiveOption = 1
        elseif Menu.ActiveOption < 1 then
            Menu.ActiveOption = Menu.OptionCount
        end
        Menu.OptionCount = 0
        Menu.ExtraOffset = -0.03
    end
end

function Menu.CloseMenu()
    Menu.CurrentMenu = nil
    Menu.OptionCount = 0
    Menu.ExtraOffset = -0.03
end

AddEventHandler('Menu.CloseMenu', function(callback)
    Menu.CurrentMenu = nil
    Menu.OptionCount = 0
    Menu.ExtraOffset = -0.03
    callback()
end)

function Menu.SetSubtitle(id, subtitle)
    Menu.Menus[id].SubTitle = subtitle
end

function Menu.SetTitleBackgroundColor(id, r, g, b, a)
    Menu.Menus[id].TitleColor = {r, g, b, a}
end

function Menu.SetMenuBackgroundColor(id, r, g, b, a)
    Menu.Menus[id].ButtonColor = {r, g, b, a}
end

function Menu.SetMenuX(id, x)
    Menu.Menus[id].x = x
end

function Menu.SetMenuY(id, y)
    Menu.Menus[id].y = y
end

function Menu.IsMenuOpened(id)
    return id == Menu.CurrentMenu
end

function Menu.IsAnyMenuOpened()
    return (Menu.CurrentMenu ~= nil)
end

function Menu.MenuButton(text, id)
    if Menu.Button(text) then
        Menu.OpenMenu(id)
        return true
    end
end

function Menu.AddOption(num)
    Menu.ActiveOption = Menu.ActiveOption + num
end

function Menu.DoesExist(id)
    return Menu.Menus[id] ~= nil
end