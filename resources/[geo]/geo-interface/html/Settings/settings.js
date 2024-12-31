window.addEventListener('message', (event) => {
    let data = event.data

    if (data.interface == 'Settings') {
        OpenSettings(data.settings, data.commands);
    }
})

let defaults = {
    jobinfo: false,
    uihelp: true,
    phonemovement: true,
    locationindicator: true,
    doorlockui: true,
    serverhelp: true
}

function OpenSettings(settings, commands) {
    interFaceOpen = 'Settings'

    UISound('open')
    let pWindow =  CreateWindow('Settings', 'Settings')

    pWindow.find('.img').click(function() {
        CloseMenu()
    })

    let value = $('body').css('--windows') / 2 * 100
    let value2 = Math.floor((localStorage['UISound'] || 1) * 100)
    let value3 = Math.floor((settings['custom_phone']|| 100))
    console.log(value3)

    pWindow.append(`
        <div class = "setcon">
            <input type="checkbox" class="settings_color_option" name="default" value="default">
            <label for="settings_color_option" class="settings_color_option_text"> Purple</label><br>
            <input type="checkbox" class="settings_color_option" name="blue" value="blue">
            <label for="settings_color_option" class="settings_color_option_text"> Blue</label><br>
            <input type="checkbox" class="settings_color_option" name="green" value="green">
            <label for="settings_color_option" class="settings_color_option_text"> Green</label><br>
            <input type="checkbox" class="settings_color_option" name="yellow" value="yellow">
            <label for="settings_color_option" class="settings_color_option_text"> Yellow</label><br>
            <input type="checkbox" class="settings_color_option" name="red" value="red">
            <label for="settings_color_option" class="settings_color_option_text"> Red</label><br>
            <input type="color" class="settings_color_option_rgb" id="custom_bg" name="custom_bg">
            <label for="settings_color_option_rgb" class="settings_color_option_text">Background Color</label><br>
            <input type="color" class="settings_color_option_rgb" id="custom_content" name="custom_content">
            <label for="settings_color_option_rgb" class="settings_color_option_text">Content Color</label><br>
            <input type="color" class="settings_color_option_rgb" id="custom_lighter" name="custom_lighter">
            <label for="settings_color_option_rgb" class="settings_color_option_text">Lighter Color</label><br>

            <input type="color" class="settings_color_option_rgb" id="custom_slider" name="custom_slider">
            <label for="settings_color_option_rgb" class="settings_color_option_text">Automatic Color</label><br>
        
            <input type="range" class="settings_color_option_rgb wider" id="custom_opac" min = 50 max = 100 value = ${value * 2} name="custom_slider">
            <label for="settings_color_option_rgb" class="settings_color_option_text2">Window Opacity</label><br>

            <input type="range" class="settings_color_option_rgb wider" id="custom_sound" value = ${value2} name="custom_slider">
            <label for="settings_color_option_rgb" class="settings_color_option_text2">UI Sounds</label><br>
            
            <input type="range" class="settings_color_option_rgb wider" id="custom_phone" min = 25 max = 100 value = ${value3} name="custom_phone">
            <label for="settings_color_option_rgb" class="settings_color_option_text2">Phone Sounds</label><br>
        </div>

        <div class = "setcon">
            <input type="checkbox" class="settings_setter" name="jobinfo" value="default">
            <label for="settings_setter" class="settings_color_option_text">Job Information Notifications</label><br>

            <input type="checkbox" class="settings_setter" name="uihelp" value="default">
            <label for="settings_setter" class="settings_color_option_text">UI Help Information</label><br>

            <input type="checkbox" class="settings_setter" name="phonemovement" value="default">
            <label for="settings_setter" class="settings_color_option_text">Enable Movement While Holding Phone</label><br>

            <input type="checkbox" class="settings_setter" name="locationindicator" value="default">
            <label for="settings_setter" class="settings_color_option_text">Locational Help Markers</label><br>

            <input type="checkbox" class="settings_setter" name="enablestaminabar" value="default">
            <label for="settings_setter" class="settings_color_option_text">Display Stamina Bar</label><br>

            <input type="checkbox" class="settings_setter" name="doorlockui" value="default">
            <label for="settings_setter" class="settings_color_option_text">Display Door Lock UI</label><br>

            <input type="checkbox" class="settings_setter" name="serverhelp" value="default">
            <label for="settings_setter" class="settings_color_option_text">Server Help</label><br>


            <input type="checkbox" class="settings_setter" name="rpgmode" value="default">
            <label for="settings_setter" class="settings_color_option_text">[Disciple] RPG Mode</label><br>

            <input type="checkbox" class="settings_setter" name="garage" value="default">
            <label for="settings_setter" class="settings_color_option_text">[Property] Show Garage Marker</label><br>

            <br>
            <div class="settings_commands">
            </div>
        </div>
    `)

    $('#settings').css('pointer-events', 'all').css('display', 'inline')
    $('.settings_setter').each(function() {
        $(this).prop('checked', settings[$(this).attr('name')] != null ? settings[$(this).attr('name')] : defaults[$(this).attr('name')])
    })
    
    $('.settings_commands').html(`
        <details>
            <summary>Control Mod Restrictor</summary>
            ${GetCommandList(commands)}
        </details>
    `)

    $('#custom_sound').mouseup(function() {
        UISound('open')
    })

    $('.controlmodrestrictor').click(function() {
        let option = $(this).prop('checked')
        Get('SaveCommandSettings', {
            name: $(this).attr('name'),
            bool: option
        })
    })

    $('.controlmodrestrictor').each(function() {
        $(this).prop('checked', (settings.commands || [])[$(this).attr('name')] != null ? (settings.commands || [])[$(this).attr('name')] : true)
    })

    SettingsInteract()
}

localStorage['hudcolor'] = (localStorage['hudcolor'] || 'purple')
function SettingsInteract() {
    $('.settings_color_option').click(async function() {
        let option = $(this).prop('checked')
        $('.settings_color_option').each(function() {
            $(this).prop('checked', false)
        })
        $(this).prop('checked', option)
        Get('SetHUDColor', {
            color: $(this).attr('value')
        })
    })

    $('.settings_color_option').each(async function() {
        if ($(this).attr('value') == localStorage['hudcolor']) {
            $(this).prop('checked', true)
        }
    })


    if (localStorage['hudcustom'] === 'undefined') localStorage['hudcustom'] = null;
    $('.settings_color_option_rgb').each(function() {
        if (localStorage['hudcustom'] != null) {
            switch ($(this).attr('name')) {
                case 'custom_bg':
                    $(this).val(JSON.parse(localStorage['hudcustom']).bg);
                    break;
                case 'custom_content':
                    $(this).val(JSON.parse(localStorage['hudcustom']).content);
                    break;
                case 'custom_lighter':
                    $(this).val(JSON.parse(localStorage['hudcustom']).lighter);
                    break;
            }
        }
    })

    $('.settings_color_option_rgb').on('input', function() {

        if ($(this).attr('id') == 'custom_opac') {
            $('.window').css('opacity', $(this).val()/100)
            $('body').css('--windows', $(this).val()/100)

            Get('SetWindowOpac', {
                value: $(this).val()/100
            })
            return
        }

        if ($(this).attr('id') == 'custom_sound') {
            Get('UISound', {
                value: $(this).val()/100
            })
            return
        }

        if ($(this).attr('id') == 'custom_phone') {
            return
        }

        $('.settings_color_option').each(function() {
            $(this).prop('checked', false)
        })

        switch ($(this).attr('name')) {
            case 'custom_bg':
                $('html').css('--main-bg', $(this).val())
                break;
            case 'custom_content':
                $('html').css('--main-content', $(this).val())
                break;
            case 'custom_lighter':
                $('html').css('--main-lighter', $(this).val())
                break;
            case 'custom_slider':
                $(this).parent().find('#custom_bg').val($(this).val())
                var val = hexToRgb($(this).parent().find('#custom_bg').val())
                val.r += 24
                val.g += 20
                val.b += 24
                $(this).parent().find('#custom_content').val(rgbToHex(val.r, val.g, val.b))

                val = hexToRgb($(this).parent().find('#custom_bg').val())
                val.r += 93
                val.g += 78
                val.b += 93
                $(this).parent().find('#custom_lighter').val(rgbToHex(val.r, val.g, val.b))

                val = hexToRgb($(this).parent().find('#custom_bg').val())
                val.r += 68
                val.g += 56
                val.b += 68
                $(this).parent().find('#custom_light').val(rgbToHex(val.r, val.g, val.b))
                break;
        }

        Get('SetHUDColor', {
            color: localStorage['hudcolor'],
            custom: {
                bg: $('#custom_bg').val(),
                content: $('#custom_content').val(),
                lighter: $('#custom_lighter').val()
            }
        })
    })

    $('.settings_setter').click(function() {
        let option = $(this).prop('checked')
        Get('SaveSettings', {
            name: $(this).attr('name'),
            bool: option
        })
    })

    $('#custom_phone').on('input', function() {
        console.log(Math.floor($(this).val()))
        Get('SaveSettings', {
            name: $(this).attr('name'),
            bool: Math.floor($(this).val())
        })
    })
}

function GetCommandList(list) {
    let str = ''
    list = JSON.parse(list)

    let newList = []
    for (var item in list) {
        newList.push([item, list[item]])
    }

    newList = newList.sort(function(a, b) {
        return a[1].localeCompare(b[1]);
    })

    for (var item in newList) {
        if (newList[item][1].includes('Modifier')) continue;
        str += `
        <input type="checkbox" class="settings_setter controlmodrestrictor settings_higher" name="${newList[item][0]}" value="default">
        <label for="settings_setter" class = "settings_color_option_text">${newList[item][1]}</label><br></br>
        `
    }

    return str
}


function hexToRgb(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
}

function rgbToHex(r, g, b) {
    return "#" + (1 << 24 | r << 16 | g << 8 | b).toString(16).slice(1);
}

window.addEventListener('done', function() {
    $('.Settings').remove()
})