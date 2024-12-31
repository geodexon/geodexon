let ads

window.addEventListener('message', function(e) {
    let data = e.data;
    if (e.data.interface == 'UpdateAds') {
        ads = data.data;
    }
})

async function OpenBusiness() {
    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Advertisments</p>
                <i class="fas fa-external-link-alt phone_message_new"></i>
            </div>

            <div class = "cContainer" style = "overflow-y:scroll;height:28.5em;margin-bottom:5em;">
        </div>
    `)

    if (!ads) {
        ads = await Get('Phone.GetAds')
    }

    for (var index in ads) {
        let item = ads[index]
        if (!item) continue;

        let img
        let args = item.message.split(/(\s+)/)
        for (var pItem in args) {
            if (args[pItem].includes('.png') || args[pItem].includes('.jpg')) {
                img = args[pItem];
                args.splice(pItem, 1)
            }
        }

        item.newmessage = args.join(' ')
        $('.cContainer').prepend(`
            <div class = "phone_ad">
                <p style = "padding:0.5em; font-size:0.9em;">${sanitizeHTML(item.newmessage)}</p>

                ${img == null ? '' : `
                    <img src = "${img}" class = "phone_image spoiler">
                `}

                <div class = "phone_ad_bottom">
                    <p style = "text-align:center;position:relative;bottom:0.5em;">${item.name}</p>
                </div>
                <div class = "phone_ad_bottom call_me" number = "${item.num}" title = "Call">
                    <p style = "text-align:center;position:relative;bottom:0.5em;">${formatPhoneNumber(String(item.num))}</p>
                </div>
            </div>
        `)

        if (img) {
            $('.phone_image').last()
                .mousedown(function(e) {
                    if (e.which == 1) {
                        ExpandImage($(this).attr('src'), $(this))
                    } else {
                        Copy($(this).attr('src'))
                    }
                }).click(function(e) {
                    $(this).removeClass('spoiler')
                    e.stopPropagation();
                })
        }
    }

    $('.call_me').click(function() {
        Get('phonecall', {
            action: `call ${Number($(this).attr('number'))}`
        })
    }).tooltip({
        tooltipClass: "tooltip"
    })

    $('.phone_message_new').click(function() {
        NewAd()
    })
}

function NewAd() {
    $('#phone_contacts_new').remove()
    $('#phone_contacts_new').css('height', '11.2em')
    let elem = $('#app_container')

    elem.append(`
        <div id = "phone_contacts_new">
            <p>New Ad</p>
            <hr>

            <span contenteditable="true" role = "textbox" type = "text" class = "phone_ad_inut phone_fullname"></span>

            <i class="fas fa-times-circle phone_contact_deny" title = "dick"></i>
            <i class="fas fa-check-circle phone_contact_accept" title = "dick"></i>
        </div>
    `)

    $('#phone_contacts_new').animate({bottom: '0em'}, 500)
    $('.phone_contact_deny').click(function() {
        $('#phone_contacts_new').animate({bottom: '-11.2em'}, 500, function() {
            $(this).remove()
        })
    })

    $('.phone_contact_accept').click(async function() {
        let text = $('.phone_ad_inut').text();
        $('#phone_contacts_new').animate({bottom: '-11.2em'}, 500, function() {
            $(this).remove()
        })
        let data = await Get('Phone.SendAd', {text: text});
        UpdateAds(data)
    })
}

function UpdateAds(data) {
    ads = data
    $('.cContainer').html('')
    if (currentApp == 'business') {
        for (var index in data) {
            let item = ads[index]
            if (!item) continue;

            let img
            let args = item.message.split(/(\s+)/)
            for (var pItem in args) {
                if (args[pItem].includes('.png') || args[pItem].includes('.jpg')) {
                    img = args[pItem];
                    args.splice(pItem, 1)
                }
            }

            item.newmessage = args.join(' ')
            $('.cContainer').prepend(`
                <div class = "phone_ad">
                    <p style = "padding:0.5em; font-size:0.9em;">${sanitizeHTML(item.newmessage)}</p>

                    ${img == null ? '' : `
                        <img src = "${img}" class = "phone_image spoiler">
                    `}
                    <div class = "phone_ad_bottom">
                        <p style = "text-align:center;position:relative;bottom:0.5em;">${item.name}</p>
                    </div>

                    <div class = "phone_ad_bottom call_me" number = "${item.num}" title = "Call">
                        <p style = "text-align:center;position:relative;bottom:0.5em;">${formatPhoneNumber(String(item.num))}</p>
                    </div>
                </div>
            `)

            if (img) {
                $('.phone_image').last()
                    .mousedown(function(e) {
                        if (e.which == 1) {
                            ExpandImage($(this).attr('src'), $(this))
                        } else {
                            Copy($(this).attr('src'))
                        }
                    }).click(function(e) {
                        $(this).removeClass('spoiler')
                        e.stopPropagation();
                    })
            }
        }


        $('.call_me').click(function() {
            Get('phonecall', {
                action: `call ${Number($(this).attr('number'))}`
            })
        }).tooltip({
            tooltipClass: "tooltip"
        })
    }
}