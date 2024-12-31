async function Confirm(text) {
    return new Promise(resolve => {
        $('body').css('pointer-events', 'none')
        $('body').append(`
            <div id = "helper_confirm">
                <p id = "helper_confirm_label">${text}</p>
                <hr>
                <button id = "helper_confirm_yes">Confirm</button>
                <button id = "helper_confirm_no">Deny</button>
            </div>
        `)

        $('#helper_confirm').css('pointer-events', 'all')
        $('#helper_confirm_yes').click(function() {
            resolve(true);
            $('#helper_confirm').remove();
            $('body').css('pointer-events', 'all')
        })

        $('#helper_confirm_no').click(function() {
            resolve(false);
            $('#helper_confirm').remove();
            $('body').css('pointer-events', 'all')
        })
    })
}

async function Get(url, json) {
    return new Promise(resolve => {
        fetch(`https://${typeof url == 'string' ? GetParentResourceName() : url[0]}/${typeof url == 'string' ? url : url[1]}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify((json || {ok: true}))
            }).then(resp => resp.json()).then(resp => resolve(resp));
    })
}

window.addEventListener('message', (event) => {
    let data = event.data;
    if (data.type == 'Color') {
        SetColor(data.color, data.custom)
    }

    if (data.type == 'hideAll') {
        $('body').css('display', data.bool ? 'none' : 'inline')
    }

    if (data.type == 'WindowOpac') {
        localStorage['windowopac'] = data.value
        SetColor(localStorage['hudcolor'], localStorage['hudcolor'] == 'custom' ? JSON.parse(localStorage['hudcustom']) : null)
    }

    if (data.type == 'UISound') {
        console.log(data.value)
        localStorage['UISound'] = data.value
    }
})

localStorage['hudcustom'] = localStorage['hudcustom'] == 'null' ? JSON.stringify({
    bg: '#352c35',
    content: '#4d404d',
    lighter: '#927a92'
}) : localStorage['hudcustom']

const toRGBArray = rgbStr => rgbStr.match(/\d+/g).map(Number);

function GetHex(hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? [
        parseInt(result[1], 16),
        parseInt(result[2], 16),
        parseInt(result[3], 16)
     ] : null;
}

function SetColor(color, custom) {
    if (!custom) {
        localStorage['hudcolor'] = color
        $('html')
            .css('--main-bg',  $('html').css(color ? '--main-bg-' + color  : '--main-bg-default'))
            .css('--main-content',  $('html').css(color ? '--main-content-' + color: '--main-content-default'))
            .css('--main-lighter',  $('html').css(color ? '--main-lighter-' + color: '--main-lighter-default'))
            .css('--main-light',  $('html').css(color ? '--main-light-' + color: '--main-light-default'))
    } else {
        localStorage['hudcolor'] = 'custom'
        $('html')
            .css('--main-bg',  custom.bg)
            .css('--main-content',  custom.content)
            .css('--main-lighter',  custom.lighter)
            .css('--main-light',  custom.lighter);
        localStorage['hudcustom'] = JSON.stringify(custom)
    }

    let val = $('html').css('--main-bg')
    let bg;
    if (String(val).includes('#')) {
        bg = GetHex(String(val))
    } else {
        bg = toRGBArray(val)
    }

    if (localStorage['windowopac']) {
        $('html').css('--windows', localStorage['windowopac'])
    }

    $('html').css('--main-bgR', bg[0])
    $('html').css('--main-bgG', bg[1])
    $('html').css('--main-bgB', bg[2])
}

$(function() {
    SetColor(localStorage['hudcolor'], localStorage['hudcolor'] == 'custom' ? JSON.parse(localStorage['hudcustom']) : null)
})

function Loading() {
    $('body').append(`
        <div id = "helper_load">
            <img src = "nui://geo-es/html/img/load.gif" id = "helper_loading">
        </div>
    `)
    $('#helper_load').css('display', 'inline')
 }
 
 function StopLoading() {
     $('#helper_load').remove()
     $('#helper_load').css('display', 'none')
 }