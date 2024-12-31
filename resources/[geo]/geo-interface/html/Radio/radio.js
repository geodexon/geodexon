window.addEventListener('message', function(ev) {
    switch(ev.data.interface) {
        case 'radio':
            RadioIcons(ev.data.amount);
            break;
        case 'radio-int':
            RadioMenu(ev.data.channel);
            break;
        case 'radio.voice':
            VoiceColor(ev.data.talking);
            break;
    }
})

$(function() {
    RadioIcons(1)
    $('#radio_channel_text').on('input', function() {
        if ($(this).val() > 1000) {
            $(this).val(1000)
        }
    })

    $('#radio_channel_text').keypress(function (e) {
        if(e.which == 13) {
            e.preventDefault();
            $.post(`http://${GetParentResourceName()}/radio.channel`, JSON.stringify({
                channel: $('#radio_channel_text').val(),
            }));
        }
    });

    $('#radio_on').mouseenter(() => {
        let elem = $(document.createElement('p'))
        elem.html('Toggle Radio')
        elem.attr('id', 'radio_info')

        elem.css('right', parseInt($('#radio_on').css('right')) + (50 * (screen.width/1920)))
        elem.css('top', $('#radio_on').css('top'))

        $('body').append(elem)
    }).mouseleave(() => {
        $('#radio_info').remove()
    })

    $('#radio_on').click(() => {
        $.post(`http://${GetParentResourceName()}/radio.toggle`, JSON.stringify({
        }));
    })

    $('#radio_volume').mouseenter(() => {
        let elem = $(document.createElement('p'))
        elem.html('+/- Volume')
        elem.attr('id', 'radio_info')

        elem.css('right', parseInt($('#radio_volume').css('right')) + (50 * (screen.width/1920)))
        elem.css('top', $('#radio_volume').css('top'))

        $('body').append(elem)
    }).mouseleave(() => {
        $('#radio_info').remove()
    })

    $('#radio_volume').mousedown((event) => {
        switch(event.which) {
            case 1:
                $.post(`http://${GetParentResourceName()}/radio.volumeup`, JSON.stringify({
                }));
                break;
            case 3:
                $.post(`http://${GetParentResourceName()}/radio.volumedown`, JSON.stringify({
                }));
                break;
        }
    })

    $('#radio_clicks').mouseenter(() => {
        let elem = $(document.createElement('p'))
        elem.html('Toggle Clicks')
        elem.attr('id', 'radio_info')

        elem.css('right', parseInt($('#radio_clicks').css('right')) + (50 * (screen.width/1920)))
        elem.css('top', $('#radio_clicks').css('top'))

        $('body').append(elem)
    }).mouseleave(() => {
        $('#radio_info').remove()
    })

    $('#radio_clicks').click(() => {
        $.post(`http://${GetParentResourceName()}/radio.clicks`, JSON.stringify({
        }));
    })
})

let _rbgcolor = 'var(--main-light)'
let _ricons = 1;

function RadioIcons(amount) {
    _ricons = amount

    $('#radio_setter').css('height', (amount * 33.3333333) + '%').css('background-color', _rbgcolor)
    //let elem = $('#radio').html('')

    /* for (let index = 0; index < amount; index++) {
        let box = $(document.createElement('div'))
        box.attr('id', 'radio_icon');
        box.css('background-color', _rbgcolor)
        elem.append(box)
        box.css('height', box.css('width'))
    } */
}

function RadioMenu(channel) {
    interFaceOpen = 'radio'
    $('#radio_int').css('display', 'inline')
    $('#radio_channel_text').focus()
    $('#radio_channel_text').val(channel)
}

let onRadio = false;
function VoiceColor(bool) {
    switch(bool) {
        case 'radio':
            onRadio = true;
            _rbgcolor = 'rgb(242, 245, 63)'
            break;
        case 1:
            if (!onRadio)  _rbgcolor = 'lightgray';
            break;
        case false:
            onRadio = false;
            _rbgcolor = 'var(--main-light)'
            break;
    }

    RadioIcons(_ricons)
}