let dispatch = false;
let calls = []
let callsign;

window.addEventListener('message', (event) => {
    let data = event.data
    if (data.type == 'dispatchcall') {
        callsign = data.callsign
        DispatchCall(data.data)
    }

    if (data.type == 'dispatchopen') {
        dispatch = true;
        $('#dispatch').css('pointer-events', 'all')
        $('#dispatch_clear_all').animate({opacity: '1.0'}, 500).css('pointer-events', 'all')
        $('.dispatch_call').each(function() {
            $(this).slideDown(500)
        })
    }

    if (data.type == 'updateDispatchCall') {
        if (!calls[data.call]) return;
        let cont = calls[data.call];
        let str = ''
        for(var item of data.people) {
            str += item+'    '
        }

        cont.find('.dispatch_officers').find('.dispatch_info_text').html(str)
    }
})

$(() => {
    $('#dispatch_clear_all').click(() => {
        $('#dispatch').html('')
        calls = []
    })

    $('#dispatch_clear_all').tooltip({
        tooltipClass: "tooltip2"
    })
})

let lastCall = 0;
function DispatchCall(data) {

    $('#dispatch').animate({opacity: '1.0'}, 500)
    lastCall = new Date().getTime();

    let container = $(document.createElement('div')).addClass('dispatch_call')
    container.append(`
        <button class = "dispatch_code">${data.code}</button>
        <label for="dispatch_code" class = "dispatch_code_label">${data.title}</label>
        <p class = "dispatch_time">${data.time}</p>
        <br>
        <br>
        <hr>
    `)

    for(var item of data.info) {
        let cont = $(document.createElement('div')).addClass('dispatch_info')
        cont.append(`
            <img src = "img/${item.icon}.png" class = "dispatch_img">
            <label for="dispatch_img" class = "dispatch_info_text">${item.text}</label>
        `)

        if (item.location) {
            cont.find('.dispatch_img').attr('title', 'Mark GPS').tooltip({
                tooltipClass: "tooltip"
            }).click(function() {
                Get('MarkGPS', {
                    call: data.id
                })
            })
        }

        container.append(cont)
    }

    container.append(`
        <div class = "dispatch_officers">
            <img src = "img/person.png" class = "dispatch_people" title = "Join Call">
            <label for="dispatch_img" class = "dispatch_info_text"></label>
        </div>

        <img src = "img/x.png" class = "dispatch_dismiss" title = "Dismiss Event">
    `)

    if (data.hidden) {
        container.find('.dispatch_officers').remove()
    }

    container.find('.dispatch_people').click(function() {
        Get('ToggleCall', {
            call: data.id
        })
    })

    container.find('.dispatch_people').tooltip({
        tooltipClass: "tooltip"
    })

    
    container.find('.dispatch_dismiss').tooltip({
        tooltipClass: "tooltip"
    }).click(function() {
        calls[data.id] = null;
        $(this).parent().fadeOut().remove()
    })

    $('#dispatch').prepend(container)
    calls[data.id] = container;
    setTimeout(() => {
        if ((new Date().getTime() - lastCall > 9800) && !dispatch) {
            $('#dispatch').css('pointer-events', 'none')
            $('#dispatch_clear_all').animate({opacity: '0.0'}, 500).css('pointer-events', 'none')
            $('.dispatch_call').each(function() {
                if (!(callsign != null && $(this).find('.dispatch_officers').find('.dispatch_info_text').html().match(callsign) != null)) {
                    $(this).slideUp(500)
                }
            })
        }
    }, 10000);

    setTimeout(() => {
        if (calls[data.id] && !(callsign != null && container.find('.dispatch_officers').find('.dispatch_info_text').html().match(callsign) != null)) {
            container.slideUp(500).remove()
            calls[data.id] = null;
        }
    }, 300000);
}