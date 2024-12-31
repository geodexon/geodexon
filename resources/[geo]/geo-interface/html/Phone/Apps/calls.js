let calls = []

async function OpenCalls() {
    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Calls</p>
                <i class="fas fa-external-link-alt phone_message_new"></i>
            </div>

            <div class = "cContainer" style = "overflow-y:scroll;height:28.5em;margin-bottom:5em;">
        </div>
    `)

    UpdateCalls()
    $('.phone_message_new').click(function() {
        NewCall()
    })
}

function NewCall() {
    $('#phone_contacts_new').remove()
    $('#phone_contacts_new').css('height', '11.2em')
    let elem = $('#app_container')

    elem.append(`
        <div id = "phone_contacts_new">
            <p>New Call</p>
            <hr>

            <input style = "height:auto;" type = "number" class = "phone_ad_inut phone_fullname" placeholder = "To">

            <i class="fas fa-times-circle phone_contact_deny" title = "dick"></i>
            <i class="fas fa-check-circle phone_contact_accept" title = "dick"></i>
        </div>
    `)

    $('#phone_contacts_new').animate({ bottom: '0em' }, 500)
    $('.phone_contact_deny').click(function() {
        $('#phone_contacts_new').animate({ bottom: '-11.2em' }, 500, function() {
            $(this).remove()
        })
    })

    $('.phone_contact_accept').click(async function() {
        let text = $('.phone_ad_inut').val();
        $('#phone_contacts_new').animate({ bottom: '-11.2em' }, 500, function() {
            $(this).remove()
        })

        if (text.length <= 0) return;
        Get('phonecall', {
            action: `call ${text}`
        })
        calls.unshift([text, 'Outgoing'])
        UpdateCalls()
    })
}

function UpdateCalls() {
    if (currentApp == 'calls') {
        $('.cContainer').html('')
        for (var item of calls) {
            $('.cContainer').append(`
                <div class = "phone_message" num = ${item[0]}>
                    <i class="fas fa-user-circle phone_message_icon"></i>
                    <p1>${formatPhoneNumber(String(item[0]))}</p1>
                    <p2 style = "margin-bottom:0.2em;">${item[1]}</p2>
                    <i class="fas fa-phone phone_recent_call" title = "Call" num = ${item[0]} style = "position:absolute;color:white;right:0.25em;top:0.5em;font-size:1.5em;"></i>
                </div>
            `)

            $('.phone_recent_call').first().click(function() {
                Get('phonecall', {
                    action: `call ${$(this).attr('num')}`
                })
            })
        }

        $('.phone_message').contextmenu(function() {
            NewContact($(this).attr('num'))
        })

        $('.phone_recent_call').tooltip({
            tooltipClass: "tooltip"
        })
    }
}