let currentHover
let phoneNumber
let messages
let contacts;
let openMessage = false;
currentApp = null;
let appList
let interFaceOpen
let tentacMessages = [];
let replyingTo = null;
let notifsActive = 0
let callElem;
let notifs = [];
cid = null;
user = {}
let closingApp = false

let minimize = {}

window.addEventListener('message', (event) => {
    let data = event.data
    switch (data.interface) {
        case 'phone.open':
            $('#phone').css('display', 'inline')
            $('#phone').animate({ bottom: '20%' }, 300, () => {})
            interFaceOpen = 'phone';
            cid = data.id
            LoadApps(data.apps, data.messages, data.number, data.contacts, data.time);
            break;
        case 'phone.messages':
            UpdateMessages(data.messages);
            break;
        case 'phone.contacts':
            UpdateContacts(data.contacts);
            break;
        case 'phone.time':
            $('#phone_time').html(data.time)
            break;
        case 'phone.echat':
            UpdateEchat(data.chat);
            if (data.msg && currentApp != 'echat') {
                PhoneNotif('echat', data.msg)
            }
            break;
        case 'phone.fleeca':
            UpdateFleeca(data.data);
            break;
        case 'phone.close':
            CloseMenu();
            break;
        case 'phone.error':
            PhoneError(data.error);
            break;
        case 'phone.vehicles':
            UpdateVehicles(data.data);
            break;
        case 'phone.tentac':
            NewTentac(data.message);
            break;
        case 'phone.newmessage':
            if (currentApp != 'messages') {
                PhoneNotif('messages', typeof GetName(data.num) == 'string' ? GetName(data.num) + ': ' + data.text : formatPhoneNumber(GetName(data.num)) + ': ' + data.text)
            }
            break;
        case 'phone_call':
            PhoneCall('contacts', 'Call: ' + data.num, data.ident, data.num)
            break;
        case 'call_end':
            callElem.fadeOut(500, function() {
                callElem.remove()
                callElem = null;
                notifsActive--
                if (notifsActive == 0 && interFaceOpen != 'phone') {
                    $('#phone').animate({ bottom: '-40%' }, 250, () => {
                        $('#phone').css('display', 'none')
                    })
                }
            })
            break;
        case 'phone_start':
            StartPhoneCall(typeof GetName(data.num) == 'string' ? GetName(data.num) : formatPhoneNumber(GetName(data.num)))
            break;
        case 'phone_calling':
            StartCalling(typeof GetName(data.num) == 'string' ? GetName(data.num) : formatPhoneNumber(GetName(data.num)));
            break;
        case 'phone_confirm':
            PhoneConfirm(data.icon || 'contacts', data.text, data.ident, data.timer);
            break;
        case 'phone_notif':
            PhoneNotif(data.icon, data.message, data.time);
            break;
        case 'phone_image':
            var img = crop(data.data, 16 / 9).then((canvas) => {
                //$('body').css('background', `url(${canvas.toDataURL()})`).css('background-repeat', 'no-repeat').css('background-size', '576px 1080px')
                $('.camera').css('background', `url(${canvas.toDataURL()})`).css('background-repeat', 'no-repeat').css('background-size', '100% 100%')
                    //$('body').css('background', `url(${canvas.toDataURL()})`).css('background-repeat', 'no-repeat')

            })
            break;
        case 'GetPicture':
            var img = crop(data.data, 16 / 9).then((canvas) => {
                Get('GetPicture', { data: canvas.toDataURL() })
            })
            break;
        case 'Help':
            newPage = true
            OpenHelp(data.id, 0)
            break;
        case 'uicursor':
            interFaceOpen = 'uicursor'
            $('.buttonrow').css('bottom', '2vh')
            $('.buttonrow').css('pointer-events', 'all')
            known = data.known
            helpOpen = true
            user = data.user
            break;

    }
})

function crop(url, aspectRatio) {
    // we return a Promise that gets resolved with our canvas element
    return new Promise((resolve) => {
        // this image will hold our source image data
        const inputImage = new Image();

        // we want to wait for our image to load
        inputImage.onload = () => {
            // let's store the width and height of our image
            // create a canvas that will present the output image
            const outputImage = document.createElement('canvas');

            // set it to the same size as the image
            //outputImage.width = screen.width * 0.3;
            //outputImage.height = outputHeight;

            outputImage.width = screen.width * (640 / screen.width)
            outputImage.height = screen.height * (360 / screen.height)

            // draw our image at position 0, 0 on the canvas
            const ctx = outputImage.getContext('2d');
            //ctx.drawImage(inputImage, outputImage.width * 0.342, 0, outputImage.width * 0.7, outputImage.height);
            ctx.drawImage(inputImage, outputImage.width * 0.5, 0, outputImage.width * 0.6458, outputImage.height);
            //ctx.drawImage(inputImage, screen.width * 0.4, 0, screen.width * 0.3, screen.height * 3, 0, 0, screen.width * 0.3, screen.height);

            resolve(trim(outputImage));
        };

        // start loading our image
        inputImage.src = url;
    });
}

function trim(c) {
    var ctx = c.getContext('2d'),
        copy = document.createElement('canvas').getContext('2d'),
        pixels = ctx.getImageData(0, 0, c.width, c.height),
        l = pixels.data.length,
        i,
        bound = {
            top: null,
            left: null,
            right: null,
            bottom: null
        },
        x, y;

    for (i = 0; i < l; i += 4) {
        if (pixels.data[i + 3] !== 0) {
            x = (i / 4) % c.width;
            y = ~~((i / 4) / c.width);

            if (bound.top === null) {
                bound.top = y;
            }

            if (bound.left === null) {
                bound.left = x;
            } else if (x < bound.left) {
                bound.left = x;
            }

            if (bound.right === null) {
                bound.right = x;
            } else if (bound.right < x) {
                bound.right = x;
            }

            if (bound.bottom === null) {
                bound.bottom = y;
            } else if (bound.bottom < y) {
                bound.bottom = y;
            }
        }
    }

    var trimHeight = bound.bottom - bound.top,
        trimWidth = bound.right - bound.left,
        trimmed = ctx.getImageData(bound.left, bound.top, trimWidth, trimHeight);

    copy.canvas.width = trimWidth;
    copy.canvas.height = trimHeight;
    copy.putImageData(trimmed, 0, 0);

    // open new window with trimmed image:
    return copy.canvas;
}

document.onkeydown = function(e) {
    if (interFaceOpen || helpOpen) {
        _menuInput(e)
        _optionSelector(e.keyCode)
        switch (e.keyCode) {
            case 9:
                if (newContact || newText || interFaceOpen === 'CharacterSelect') break;
                CloseMenu()
                break;
            case 27:
                if (interFaceOpen == 'phone') {
                    openMessage = null;
                    LoadApps(appList, messages, phoneNumber, contacts);
                }
                break;
        }
    }
}

$(function() {
    $('#home_button').click(function() {
        LoadApps(appList, messages, phoneNumber, contacts);
    }).tooltip({
        tooltipClass: "tooltip"
    })

    $('#phone_notifications').tooltip({
        tooltipClass: "tooltip"
    }).click(function() {
        if ($('#notif_history').css('opacity') == '1') {
            $('#notif_history').css('opacity', '0.0').css('pointer-events', 'none')
        } else {
            $('#notif_history').css('opacity', '1.0').css('pointer-events', 'all')
        }
    })
})

async function CloseMenu() {
    $('.menuHolder').remove()
    $('#radio_int').css('display', 'none')
    $('#radio_info').remove()
    $('#EntitySelect').css('display', 'none')
    $('#EntitySelect2').css('display', 'none')
    $('#settings').css('display', 'none').css('pointer-events', 'none')
    $('#notif_history').css('opacity', '0.0').css('pointer-events', 'none').scrollTop(0)
    window.dispatchEvent(new Event('done'));
    $.post(`http://${GetParentResourceName()}/Focus`, JSON.stringify({}));

    if (interFaceOpen == 'radio') {
        $.post(`http://${GetParentResourceName()}/radio.close`, JSON.stringify({}));
    }

    if (interFaceOpen == 'SelectOption') {
        $('#Selector-Options').html('');
        $.post(`http://${GetParentResourceName()}/SelectOption.Close`, JSON.stringify({}));
    }

    EntityClose();
    if (interFaceOpen === 'Clothing') {
        ClothesClose();
    }

    if (interFaceOpen == 'Setings') {
        $.post(`http://${GetParentResourceName()}/Settings.Close`, JSON.stringify({}));
    }

    if (selectorOpen) {
        selectorOpen = false;
        $('#selector').css('pointer-events', 'none')
        $('#selector').html('')
    }

    if (interFaceOpen == 'phone') {
        if (notifsActive != 0) {
            $('#phone').css('display', 'inline')
            $('#phone').animate({ bottom: '-27%' }, 250, () => {
                LoadApps(appList, messages, phoneNumber, contacts);
            })
        } else {
            $('#phone').animate({ bottom: '-40%' }, 250, async () => {
                LoadApps(appList, messages, phoneNumber, contacts);
                $('#phone').css('display', 'none')
            })
        }
    }

    interFaceOpen = null;
    currentApp = null;
}

function LoadApps(apps, _messages, number, contact, time) {
    let img = localStorage[`phone.${cid}`]
    if (img) {
        $('#phone_container').css('background', `url(${img})`)
    } else {
        $('#phone_container').css('background', `url('https://media.istockphoto.com/photos/blue-abstract-background-or-texture-picture-id1138395421?k=6&m=1138395421&s=612x612&w=0&h=bJ1SRWujCgg3QWzkGPgaRiArNYohPl7-Wc4p_Fa_cyA=')`)
    }
    $('#phone_container').css('background-size', '100% 100%')
    Get('Phone.WentHome')

    messages = _messages
    phoneNumber = number
    appList = apps
    contacts = contact
    EndApp()
    currentApp = null;
    let elem = $('#phone_apps').html('')
    $('#phone_time').html(time)

    newText = false;
    newContact = false;

    $('#phone_shadow').css('background-color', 'rgba(0, 0, 0, 0.0)')
    for (var item in apps) {
        let ind = apps[item]
        let app = $(document.createElement('div'))
        app.attr('id', 'phone_app')
        app.html(`<img src = "img/${ind}.png" id = "phone_app_image">`)
        app.click(function() {
            OpenApp(ind)

            setTimeout(() => {
                let con = $('#app_containerx')
                con.css('width', app.css('width'))
                con.css('height', app.css('height'))
                con.css('left', `calc(${app.position().left}px + 6%)`)
                con.css('top', `calc(${app.position().top}px + 7.6%)`)
                con.css('opacity', '1.0')

                minimize = {width: con.css('width'), height: con.css('height'), left: con.position().left, top: con.position().top}
                con.animate({left: '0%', top: '0%', width: "100%", height: '100%'}, 250, 'swing')

                $('#app_containerx').css('bottom', '0%')
                $('#app_containerx').css('pointer-events', 'all')
            }, 0);
        }).attr('title', ind)

        elem.append(app)
            /*  app.tooltip({
                 tooltipClass: "phonetool"
             }) */
    }

    $('#phone').css('display', 'inline')
}

function OpenApp(app) {
    currentApp = app;
    switch (app) {
        case 'messages':
            OpenMessages();
            break;
        case 'contacts':
            OpenContacts();
            break;
        case 'echat':
            OpenEChat();
            break;
        case 'fleeca':
            OpenFleeca();
            break;
        case 'vehicles':
            OpenVehicles();
            break;
        case 'tentac':
            OpenTentac();
            break;
        case 'guilds':
            OpenGuilds();
            break;
        case 'location':
            OpenLocation();
            break;
        case 'business':
            OpenBusiness();
            break;
        case 'calls':
            OpenCalls();
            break;
        case 'housing':
            OpenHousing();
            break;
        case 'camera':
            OpenCamera();
            break;
        case 'photos':
            OpenPhotos();
            break;
        case 'settings':
            OpenSettingsApp();
            break;
    }
}

function OpenMessages() {

    $('.messageIcon').remove();
    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Messages</p>
                <i class="fas fa-external-link-alt phone_message_new"></i>
            </div>
        </div>
    `)

    $('.phone_message_new').click(function() {
        NewText()
    })

    let msgList = []
    for (var item of messages) {
        if (phoneNumber != item.from_number) {
            if (msgList[item.from_number] == null) {
                msgList[item.from_number] = []
            }
        }

        if (phoneNumber != item.to_number) {
            if (msgList[item.to_number] == null) {
                msgList[item.to_number] = []
            }
        }

        if (msgList[item.from_number] != null) {
            msgList[item.from_number].push(item)
            continue;
        }

        if (msgList[item.to_number] != null) {
            msgList[item.to_number].push(item)
            continue;
        }
    }

    for (var item in msgList) {
        $('#phone_message_container').append(`
            <div class = "phone_message" number = "${String(item)}">
                <i class="fas fa-user-circle phone_message_icon"></i>
                <p1>${formatPhoneNumber(String(GetName(item)))}</p1>
                <p2>${msgList[item][msgList[item].length - 1].message}</p2>
            </div>
        `)
    }

    $('.phone_message').click(function() {
        OpenTexts(Number($(this).attr('number')))
    }).contextmenu(async function() {
        let val = await Confirm("Would you like to delete the message history?")
        if (val) {
            $(this).remove();
            await Get('Phone.DeleteHistory', {
                number: Number($(this).attr('number'))
            })
            return;
        }
    })

    let found = [];
    let arr = [];
    for (var item in messages) {

        let number = messages[item].to_number
        if (number == phoneNumber) number = messages[item].from_number;
        if (!found[number] && number != phoneNumber) {
            found[number] = true;
            let val = GetLastestTime(number)
            arr.push([val, number])
        }
    }

    arr.sort(function(a, b) {
        return b[0] - a[0]
    })

    for (var item of arr) {
        let number = item[1]
        let msgContainer = $(document.createElement('div'))
        msgContainer.addClass('phone_message_selector')
        msgContainer.html(`
            <img src = "img/person.png" id = "phone_message_image">
            <p id = "phone_message_name">${GetName(number)}</p>
            <img src = "img/call.png" id = "phone_message_call">
        `)
    }
}

function OpenContacts() {

    $('.messageIcon').remove();
    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Contacts</p>
                <i class="fas fa-external-link-alt phone_message_new"></i>
            </div>
        </div>
    `)

    $('.phone_message_new').click(function() {
        NewContact()
    })

    for (var item of contacts) {
        $('#phone_message_container').append(`
            <div class = "phone_message" number = "${String(item.number)}">
                <i class="fas fa-user-circle phone_message_icon"></i>
                <p1>${item.name}</p1>
                <p2>${formatPhoneNumber(String(item.number))}</p2>
                <img src = "img/call.png" class = "contacts_call" style = "
                    width:1.5em; position:absolute; right:1em;top:0.75em;
                    ">
            </div>
        `)
    }

    $('.contacts_call').click(function(e) {
        e.stopPropagation();
        Get('phonecall', {
            action: 'call ' + $(this).parent().attr('number')
        })
    })

    $('.phone_message_icon').click(function() {
        OpenTexts(Number($(this).parent().attr('number')))
    })

    $('.phone_message').click(function() {
        for (var item of contacts) {
            if (item.number == $(this).attr('number')) {
                EditContact(item);
                break;
            }
        }
    })

    $('.phone_message').contextmenu(function() {
        for (var item of contacts) {
            if (item.number == $(this).attr('number')) {
                DeleteContact(item);
                break;
            }
        }
    })
}

function OpenEChat() {
    let elem = $('#app_container')
    elem.html('')
    $.post(`http://${GetParentResourceName()}/phone.getechat`, JSON.stringify({}));
}

function OpenFleeca() {
    let elem = $('#app_container')

    elem.html('')
    $.post(`http://${GetParentResourceName()}/phone.fleeca`, JSON.stringify({}));
}

function OpenVehicles() {
    let elem = $('#app_container')

    elem.html('')
    $.post(`http://${GetParentResourceName()}/phone.vehicles`, JSON.stringify({}));
}

let newContact = false;

function NewContact(number) {
    $('#phone_contacts_new').remove()
    $('#phone_contacts_new').css('height', '11.2em')
    let elem = $('#app_container')

    elem.append(`
        <div id = "phone_contacts_new">
            <p>New Contact</p>
            <hr>

            <label for="phone_contact_input" class = "phone_contact_container">Name</label>
            <input type = "text" class = "phone_contact_input phone_fullname" placeholder = "Full Name ">

            <label for="phone_contact_input" class = "phone_contact_container">Number</label>
            <input type = "text" maxlength = "30" class = "phone_contact_input phone_fullnumber" placeholder = "Phone Number" value = "${number}">
        
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

    $('.phone_contact_accept').click(function() {
        $.post(`http://${GetParentResourceName()}/phone.newcontact`, JSON.stringify({
            number: $('.phone_fullnumber').val().replace('-', ''),
            name: $('.phone_fullname').val()
        }));
        CloseNewContact();
        if (number && currentApp == 'messages') {
            setTimeout(() => {
                OpenMessages();
            }, 500);
        }
    })
}

function EditContact(contact) {
    $('#phone_contacts_new').remove()
    $('#phone_contacts_new').css('height', '11.2em')

    let elem = $('#app_container')

    elem.append(`
        <div id = "phone_contacts_new">
            <p>New Contact</p>
            <hr>

            <label for="phone_contact_input" class = "phone_contact_container">Name</label>
            <input type = "text" class = "phone_contact_input phone_fullname" placeholder = "Full Name " value = "${contact.name}">

            <label for="phone_contact_input" class = "phone_contact_container">Number</label>
            <input type = "text" maxlength = "30" class = "phone_contact_input phone_fullnumber" placeholder = "Phone Number" value = "${contact.number}">
        
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

    $('.phone_contact_accept').click(function() {
        $.post(`http://${GetParentResourceName()}/phone.editcontact`, JSON.stringify({
            number: $('.phone_fullnumber').val(),
            name: $('.phone_fullname').val()
        }));
        CloseNewContact();
        if (number && currentApp == 'messages') {
            setTimeout(() => {
                OpenMessages();
            }, 500);
        }
    })
}

function DeleteContact(item) {
    $('#phone_contacts_new').remove()
    $('#phone_contacts_new').css('height', '11.2em')
    let elem = $('#app_container')

    elem.append(`
        <div id = "phone_contacts_new" style = "height:0.5em;">
            <p>Delete ${item.name}?</p>
            <hr>
        
            <i class="fas fa-times-circle phone_contact_deny shorter" title = "dick"></i>
            <i class="fas fa-check-circle phone_contact_accept shorter" title = "dick"></i>
        </div>
    `)

    $('#phone_contacts_new').css('bottom', '0em')
    $('#phone_contacts_new').animate({ bottom: '6.2em' }, 500)
    $('.phone_contact_deny').click(function() {
        $('#phone_contacts_new').animate({ bottom: '-11.2em' }, 500, function() {
            $(this).remove()
        })
    })

    $('.phone_contact_accept').click(function() {
        $.post(`http://${GetParentResourceName()}/phone.deletecontact`, JSON.stringify({
            number: item.number,
        }));
        CloseNewContact();
    })
}


let newText = false;

function NewText() {
    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_newmessage_header">
            <p>New Text</p>
        </div>
        <input type = "number" class = "phone_newmessage_to" placeholder = "To" pattern="/^-?\d+\.?\d*$/" onKeyPress="if(this.value.length==10) return false;">
    
        <span contenteditable="true" class = "phone_messagebar" role = "textbox"></span>
    `)

    $('.phone_messagebar').on('keydown', function(e) {
        if (e.which == 13) {
            e.preventDefault();
            let num = $('.phone_newmessage_to').val()
            let text = $('.phone_messagebar').text()
            if (num != '' && text != '') {
                Get('phone.text', {
                    number: num,
                    text: text
                })
            }
        }
    })
}

function OpenTexts(number) {
    openMessage = number;
    let value = $('#phone_message_input').val()

    let elem = $('#app_container')
    elem.html('')

    let whoIs = $(document.createElement('div'))
    whoIs.attr('id', 'phone_messages_who')
    whoIs.html(`
        <i class="fas fa-user-circle phone_message_head"></i>
        <p id = "phone_message_whoname"> ${GetName(number)} </p>
    `)

    elem.append(whoIs)

    $('.phone_message_head').click(function() {
        if (!isNaN(Number(GetName(number)))) {
            NewContact(number)
        } else {
            OpenContacts()
        }
    })

    let msgContainer = $(document.createElement('div'))
    msgContainer.attr('id', 'phone_messages_container')
    for (var item in messages) {
        let doc = $(document.createElement('div'))
        doc.attr('id', 'phone_messages_message')
        let msg = messages[item]

        let img
        let args = msg.message.split(/(\s+)/)
        for (var item in args) {
            if (args[item].includes('.png') || args[item].includes('.jpg')) {
                img = args[item];
                args.splice(item, 1)
            }
        }

        let newmessage = args.join(' ')
        let msgBox = $(document.createElement('div'))
        if ((msg.from_number === number && msg.to_number === phoneNumber) || (msg.to_number === number && msg.from_number === phoneNumber)) {
            if (msg.from_number === phoneNumber) {
                msgBox.addClass('phone_message_me')
            } else {
                msgBox.addClass('phone_message_other')
            }

            msgBox.html(sanitizeHTML(newmessage))

            if (img) {
                msgBox.append(`<img src = "${img}" class = "phone_image spoiler">`)
                    .find('.phone_image').mousedown(function(e) {
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

            doc.append(msgBox)
            msgContainer.append(doc)
        }
    }

    let input = $(document.createElement('spawn')).attr('contenteditable', 'true').attr('role', 'textbox')
    input.addClass('phone_messagebar')
    input.keypress(function(e) {
        if (e.which == 13) {
            e.preventDefault();
            $.post(`http://${GetParentResourceName()}/phone.text`, JSON.stringify({
                number: number,
                text: $('.phone_messagebar').text()
            }));
            $(this).val("");
        }
    });

    input.on('DOMSubtreeModified', function(e) {
        $('#phone_messages_container').css('max-height', `calc(25.5em - ${$(this).height()}px`)
        msgContainer.scrollTop(9999999999999999999999999)
    });

    $('#phone_message_whoname').click(() => {
        OpenMessages();
        openMessage = null
    })

    elem.append(msgContainer)
    msgContainer.scrollTop(9999999999999999999999999)
    elem.append(input)
    input.focus();
}

function CloseNewText(elem) {
    newText = false;
    elem.find('#phone_newtext').remove()
    $('#phone_shadow').css('background-color', 'rgba(0, 0, 0, 0.0)')
}

function CloseNewContact(elem) {
    $('#phone_contacts_new').animate({ bottom: '-11.2em' }, 500, function() {
        $(this).remove()
    })
}

function UpdateMessages(_messages) {
    messages = _messages

    if (openMessage) {
        OpenTexts(openMessage);
        return;
    }

    if (currentApp === 'messages') {
        OpenMessages();
        return;
    }
}

function UpdateContacts(_contacts) {
    contacts = _contacts

    if (currentApp === 'contacts') {
        OpenApp('contacts')
    }
}

function UpdateEchat(data) {
    if (currentApp != 'echat') return;


    let val = $('#phone_echat_input').html()

    let elem = $('#app_container')
    elem.html('')

    let container = $(document.createElement('div'))
    container.attr('id', 'phone_echat_container')
    elem.append(container)
    for (var element of data) {

        let img
        let args = element[1].split(/(\s+)/)
        for (var item in args) {
            if (args[item].includes('.png') || args[item].includes('.jpg')) {
                img = args[item];
                args.splice(item, 1);
                break;
            }
        }

        element[2] = args.join(' ')
        $('#phone_echat_container').append(`
            <div style = "min-height:3em;height:auto;max-height:5em;" class = "phone_message" msg = "${element[2]}">
                <i class="fas fa-user-circle phone_message_icon"></i>
                <p1 style = "font-weight:bold;"> ${element[0]}</p1>
                <div style = "position:relative;left:3em;width:12em; height:auto;padding-bottom:1em;">
                    <p2 style = "position:relative;left:0em;top:0em;word-wrap:break-word;font-size:0.75em;"> ${truncate(element[2], 80)}</p1>
                </div>

                ${img == null ? '' : `
                    <img src = "${img}" class = "phone_image spoiler">
                `}
            </div>
        `);

        if (img) {
            $('.phone_message')
                .last()
                .css('max-height', 'none')
                .addClass('expanded')
                .find('p2')
                .html($('.phone_message')
                .last()
                .attr('msg'), 80)
            $('.phone_message')
                .find('.phone_image').mousedown(function(e) {
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
    };

    $('.phone_message').click(function() {
        let item = $(this)
        item.toggleClass('expanded')
        if (item.hasClass('expanded')) {
            item.css('max-height', 'none')
            item.find('p2').html(item.attr('msg'))
        } else {
            item.css('max-height', '5em')
            item.find('p2').html(truncate(item.attr('msg'), 80))
        }
    })


    let textbox = $(document.createElement('span'))
    textbox.attr('contentEditable', 'true')
    textbox.attr('role', 'textbox').addClass('phone_messagebar')

    textbox.keypress(function (e) {
        if(e.which == 13) {
            e.preventDefault();
            $.post(`http://${GetParentResourceName()}/phone.echat`, JSON.stringify({
                text:  textbox.text()
            }));
            $(this).html("");
        }
    });

    elem.append(textbox)
    textbox.on('DOMSubtreeModified', function (e) {
        $('#phone_echat_container').css('max-height', `calc(30.25em - ${$(this).height()}px`)
        container.scrollTop(9999999999999999999999999)
    });

    container.scrollTop(9999999999999999999999999)

    setTimeout(() => {
        if (currentApp != 'echat') return;
        textbox.focus()
    }, 500);
}

function UpdateFleeca(data) {

    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Banking</p>
            </div>
        </div>
    `)

    $('.phone_message_new').click(function() {
        NewContact()
    })

    for (var item of data) {
        $('#phone_message_container').append(`
            <div class = "phone_message" money = ${item.amount}>
                <i class="fas fa-university phone_message_icon"></i>
                <p1 style = "top:0.9em;font-size:1.1em;left:3em;" title = "${item.name || item.id}">${truncate(item.name || item.id, 9)}</p1>
                <p2 style = "top:0.9em;font-size:1.1em;right:0.5em;text-align:right;">$${numberWithCommas(item.amount)}</p2>
            </div>
        `)
    }

    $('p1').tooltip({
        tooltipClass: "tooltip"
    })
}

function UpdateVehicles(data) {

    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Vehicles</p>
            </div>
            <div class = "cContainer" style = "overflow-y:scroll;height:28.5em;margin-bottom:5em;">
            </div>
        </div>
    `)

    $('.phone_message_new').click(function() {
        NewContact()
    })

    for (var item in data) {
        $('.cContainer').append(`
            <div class = "phone_message" index = "${item}">
                <i class="fas fa-car phone_message_icon"></i>
                <p1 style = "top:0.9em;font-size:1.1em;left:3em;" title = "${data[item].plate}">${data[item].plate}</p1>
            </div>
        `)
    }

    $('.phone_message').click(function() {
        let item = $(this)
        let value = data[Number(item.attr('index'))]

        item.toggleClass('expanded')
        item.css('transition', 'height 0.5s')
        if (item.hasClass('expanded')) {
            item.css('height', '7em')
            item.append(`
                <br>
                <br>
                <p4>Garage: ${value.garage}</p4>
                <br>
                <p4>Parked: ${value.parked == 0 ? 'Out' : 'Parked'}</p4>
                <br>
                <p4>Model: ${value.model}</p4>
            `)

            if (value.parked == 0 && JSON.parse(value.flags)?.gps) {
                item.append(`
                    <br>
                    <button class = "vehicles_lojack">Track Vehicle</button>
                `)
                item.css('height', '8em')

                $('.vehicles_lojack').click(function(e) {
                    e.stopPropagation()
                    Get('LoJack', {plate: $(this).parent().find('p1').attr('title')})
                })
            }
        } else {
            item.css('height', '3em')
            item.find('p4').remove()
            item.find('br').remove()
            item.find('.vehicles_lojack').remove()
        }
    })

    $('p1').tooltip({
        tooltipClass: "tooltip"
    })
}

$('body').mousemove(function(evt){
    currentHover = $(evt.target).attr('id')
});

function sanitizeHTML(text) {
    var element = document.createElement('div');
    element.innerText = text;
    return element.innerHTML;
}

function GetName(number) {
    for (var item in contacts) {
        if (contacts[item].number == number) {
            return contacts[item].name
        }
    }

    return number
}

function numberWithCommas(x) {
    x = x.toString();
    var pattern = /(-?\d+)(\d{3})/;
    while (pattern.test(x))
        x = x.replace(pattern, "$1,$2");
    return x;
}

function GetLastestTime(num) {
    let time = 0
    for (var item of messages) {
        if ((num === item.from_number || (phoneNumber == item.from_number && num === item.to_number)) && item.time > time) time = item.time
    }

    return time;
}

function PhoneError(txt) {
    let err = $(document.createElement('div'))
    err.attr('id', 'phone_error')
    err.html(`
        <img src = "img/error.png"> 
        <p>${txt}</p>
    `)
    $('#phone_apps').append(err)
    setTimeout(() => {
        err.fadeOut(1000)
    }, 1000);
}

function OpenTentac() {
    replyingTo = null
    $('#tentac_iconimg').remove()
    $.post(`http://${GetParentResourceName()}/Phone.TentacName`).then(function(data) {
        let name = data
    
        let elem = $('#app_container')
        if (!name) {
            elem.html(`
                <div id = "phone-tentac-create">
                    <p id = "phone-tentac-title">Create Account</p>
                    <p id = "phone-tentac-warning">Spaces will be trimmed from username</p>
                    <span contenteditable="true" class = "phone_messagebar" role = "textbox"></span>
                    <button id = "phone-tentac-newuser">Submit Username</button>
                </div>
            `)

            $('#phone-tentac-newuser').click(function() {
                $.post(`http://${GetParentResourceName()}/Phone.RegisterTentac`, JSON.stringify({
                    name: $('.phone_messagebar').text()
                })).then(function(data) {
                    if (data) {
                        OpenTentac()
                    } else {
                        PhoneError('Could not Create User')
                    }
                })
            })
        } else {
            elem.html(`
                <div id = "phone-tentac-container"></div>
                <span contenteditable="true" class = "phone_messagebar" role = "textbox"></span>
            `);

            $('.phone_messagebar').on('DOMSubtreeModified', function() {
                if ($(this).html() === "") replyingTo = null;
                $('#phone-tentac-container').css('max-height', `calc(30.25em - ${$(this).height()}px`).scrollTop(0)
            })

            $('.phone_messagebar').keypress(function (e) {
                if(e.which == 13) {
                    e.preventDefault();
                    $.post(`http://${GetParentResourceName()}/phone.tentac`, JSON.stringify({
                        text:  $('.phone_messagebar').text(),
                        reply: replyingTo
                    }));
                    replyingTo = null;
                    $(this).html("");
                }
            });

            tentacMessages.forEach(element => {
                element = element

                let img
                let args = element.message.split(/(\s+)/)
                for (var item in args) {
                    if (args[item].includes('.png') || args[item].includes('.jpg')) {
                        img = args[item];
                        args.splice(item, 1)
                    }
                }

                element.newmessage = args.join(' ')
                $('#phone-tentac-container').append(`
                    <div style = "min-height:3em;height:auto;max-height:5em;" author = "${element.author}" class = "phone_message" id = "phone-tentac-new" msg = "${element.newmessage}">
                        <i class="fas fa-user-circle phone_message_icon"></i>
                        <p1 style = "font-weight:bold;"> ${element.author}</p1>
                        <div style = "position:relative;left:3em;width:12em; height:auto;padding-bottom:1em;">
                            <p2 style = "position:relative;left:0em;top:0em;word-wrap:break-word;font-size:0.75em;"> ${truncate(element.newmessage, 80)}</p1>
                        </div>
                        <i class="fas fa-reply phone_tentac_reply"></i>

                        ${img == null ? '' : `
                            <img src = "${img}" class = "phone_image spoiler">
                        `}
                    </div>
                `);

                if (img) {
                    $('.phone_message')
                        .last()
                        .css('max-height', 'none')
                        .addClass('expanded')
                        .find('p2')
                        .html($('.phone_message')
                        .last()
                        .attr('msg'), 80)
                    $('.phone_message')
                        .find('.phone_image').mousedown(function(e) {
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
            });

            $('.phone_message').click(function() {
                let item = $(this)
                item.toggleClass('expanded')
                if (item.hasClass('expanded')) {
                    item.css('max-height', 'none')
                    item.find('p2').html(item.attr('msg'))
                } else {
                    item.css('max-height', '5em')
                    item.find('p2').html(truncate(item.attr('msg'), 80))
                }
            })
    
            $('.phone_tentac_reply').click(function() {
                replyingTo = $(this).parent().attr('author')
                $(".phone_messagebar").focus().text(`@${replyingTo} `)
                document.getElementById('phone-tentac-new').focus();
                document.execCommand('selectAll', false, null);
                document.getSelection().collapseToEnd();
            })
        }
    })
}

function NewTentac(message) {
    tentacMessages.unshift(message)
    if (currentApp === 'tentac') {

        let img
        let args = message.message.split(/(\s+)/)
        for (var item in args) {
            if (args[item].includes('.png') || args[item].includes('.jpg')) {
                img = args[item];
                args.splice(item, 1)
            }
        }

        message.newmessage = args.join(' ')
        $('#phone-tentac-container').prepend(`
            <div style = "min-height:3em;height:auto;max-height:5em;" author = "${message.author}" class = "phone_message" id = "phone-tentac-new" msg = "${message.newmessage}">
                <i class="fas fa-user-circle phone_message_icon"></i>
                <p1 style = "font-weight:bold;"> ${message.author}</p1>
                <div style = "position:relative;left:3em;width:12em; height:auto;padding-bottom:1em;">
                    <p2 style = "position:relative;left:0em;top:0em;word-wrap:break-word;font-size:0.75em;"> ${truncate(message.newmessage, 80)}</p1>
                </div>
                <i class="fas fa-reply phone_tentac_reply"></i>

                ${img == null ? '' : `
                    <img src = "${img}" class = "phone_image spoiler">
                `}
            </div>
        `)


        if (img) {
            $('.phone_message')
                .first()
                .css('max-height', 'none')
                .addClass('expanded')
                .find('p2')
                .html($('.phone_message')
                .first()
                .attr('msg'), 80)
            $('.phone_message')
                .find('.phone_image').mousedown(function(e) {
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

        $('.phone_message').click(function() {
            let item = $(this)
            item.toggleClass('expanded')
            if (item.hasClass('expanded')) {
                item.css('max-height', 'none')
                item.find('p2').html(item.attr('msg'))
            } else {
                item.css('max-height', '5em')
                item.find('p2').html(truncate(item.attr('msg'), 80))
            }
        })

        $('.phone_tentac_reply').click(function() {
            replyingTo = $(this).parent().attr('author')
            $(".phone_messagebar").focus().text(`@${replyingTo} `)
            document.getElementById('phone-tentac-new').focus();
            document.execCommand('selectAll', false, null);
            document.getSelection().collapseToEnd();
        })
    } else {
        PhoneNotif('tentac', message.author + ': '+ message.message)
    }
}

function moveCursorToEnd(el){
    if(el.innerText && document.createRange)
    {
      window.setTimeout(() =>
        {
          let selection = document.getSelection();
          let range = document.createRange();

          range.setStart(el.childNodes[0],el.innerText.length);
          range.collapse(true);
          selection.removeAllRanges();
          selection.addRange(range);
        }
      ,1);
    }
  }

async function PhoneNotif(icon, message, time) {
    if (!await Get('HasPhone')) return;
    notifsActive++
    let elem = $(document.createElement('div')).addClass('phone_notif')
    elem.html(`
        <img src = "img/${icon}.png" class = "phone_notif_icon">
        <p>${message}</p>
    `)

    elem.fadeOut(0)
    $('#phone_notif').prepend(elem);

    let newElem = $(document.createElement('div')).addClass('phone_notif').css('pointer-events', 'none')
    newElem.html(`
        <img src = "img/${icon}.png" class = "phone_notif_icon">
        <p>${message}</p>
    `)

    $('#notif_history').prepend(newElem)
        newElem.fadeIn(500, function() {
    })

    setTimeout(() => {
        elem.fadeIn(500, function() {
        })
    }, 500);

    setTimeout(() => {
        if (elem) {
            elem.fadeOut(500, function() {
                elem.remove()
                elem = null;
                notifsActive--
                if (notifsActive == 0 && interFaceOpen != 'phone') {
                    $('#phone').animate({bottom: '-40%'}, 250, () => {
                        $('#phone').css('display', 'none')
                    })
                }
            })
        }
    }, time || 10000);

    elem.click(function() {
        if (elem) {
            elem.fadeOut(500, function() {
                elem.remove()
                elem = null;
                notifsActive--
                if (notifsActive == 0 && interFaceOpen != 'phone') {
                    $('#phone').animate({bottom: '-40%'}, 250, () => {
                        $('#phone').css('display', 'none')
                    })
                }
            })
        }
    })
   
    if (interFaceOpen != 'phone') {
        $('#phone').css('display', 'inline')
        $('#phone').animate({bottom: '-27%'}, 250, () => {
        })
    }
}

async function PhoneCall(icon, message, id, num) {
    if (!await Get('HasPhone')) return;
    if (callElem) return;
    notifsActive++
    callElem = $(document.createElement('div')).addClass('phone_notif')
    callElem.html(`
        <img src = "img/${icon}.png" class = "phone_notif_icon" ident = "${id}">
        <p>${message}</p>
        <i class="fas fa-times-circle phone_deny" title = "dick"></i>
        <i class="fas fa-check-circle phone_accept" title = "dick"></i>
    `)

    calls.unshift([num, 'Incoming'])
    UpdateCalls()

    callElem.fadeOut(0)
    $('#phone_notif').prepend(callElem)

    callElem.find('.phone_deny').click(function() {
        callElem.fadeOut(500, function() {
            callElem.remove()
            callElem = null;
            notifsActive--
            Get('phonecall', {
                action: 'h'
            })
            if (notifsActive == 0 && interFaceOpen != 'phone') {
                $('#phone').animate({bottom: '-40%'}, 250, () => {
                    $('#phone').css('display', 'none')
                })
            }
        })
    })

    callElem.find('.phone_accept').click(function() {
        callElem.fadeOut(500, function() {
            callElem.remove()
            callElem = null;
            notifsActive--
            Get('phonecall', {
                action: 'a'
            })
            if (notifsActive == 0 && interFaceOpen != 'phone') {
                $('#phone').animate({bottom: '-40%'}, 250, () => {
                    $('#phone').css('display', 'none')
                })
            }
        })
    })

    setTimeout(() => {
        callElem.fadeIn(500, function() {
        })
    }, 500);

    if (interFaceOpen != 'phone') {
        $('#phone').css('display', 'inline')
        $('#phone').animate({bottom: '-27%'}, 250, () => {
        })
    }
}
async function PhoneConfirm(icon, message, id, timer) {
    if (!await Get('HasPhone')) return;
    return new Promise(resolve => {
        notifsActive++
        let seconds = timer;
        let thisElem = $(document.createElement('div')).addClass('phone_notif')
        let minutes = Math.floor(seconds / 60)
        let secs = String(seconds - (minutes * 60))
        if (secs.length == 1) secs = '0'+secs
        thisElem.html(`
            <img src = "img/${icon}.png" class = "phone_notif_icon" ident = "${id}">
            <p>${message} <font color = "lightgray"> - ${minutes}:${secs}</font></p>
            <i class="fas fa-times-circle phone_deny" title = "dick"></i>
            <i class="fas fa-check-circle phone_accept" title = "dick"></i>
        `)

        thisElem.fadeOut(0)
        $('#phone_notif').prepend(thisElem)

        thisElem.find('.phone_deny').click(function() {
            if (id) {
                Get('phoneaction', {
                    ident: id,
                    bool: false
                })
            }
            thisElem.fadeOut(500, function() {
                thisElem.remove()
                thisElem = null;
                notifsActive--
                if (notifsActive == 0 && interFaceOpen != 'phone') {
                    $('#phone').animate({bottom: '-40%'}, 250, () => {
                        $('#phone').css('display', 'none')
                    })
                }
            })
            resolve(false)
        })

        thisElem.find('.phone_accept').click(function() {
            if (id) {
                Get('phoneaction', {
                    ident: id,
                    bool: true
                })
            }
            thisElem.fadeOut(500, function() {
                thisElem.remove()
                thisElem = null;
                notifsActive--
                if (notifsActive == 0 && interFaceOpen != 'phone') {
                    $('#phone').animate({bottom: '-40%'}, 250, () => {
                        $('#phone').css('display', 'none')
                    })
                }
            })
            resolve(true)
        })

        thisElem.fadeIn(500, function() {
        })

        if (interFaceOpen != 'phone') {
            $('#phone').css('display', 'inline')
            $('#phone').animate({bottom: '-27%'}, 250, () => {
            })
        }

        if (timer) {
            let seconds = timer;
            let interval = setInterval(() => {
                if (!thisElem) {
                    clearInterval(interval) 
                    return;
                } 
                seconds--

                if (seconds == 0) {
                    thisElem.find('.phone_deny').trigger('click')
                }

                let minutes = Math.floor(seconds / 60)
                let secs = String(seconds - (minutes * 60))
                if (secs.length == 1) secs = '0'+secs
                thisElem.find('p').html(`${message} <font color = "lightgray"> - ${minutes}:${secs}</font>`)
            }, 1000);
        }
    })
}

async function StartPhoneCall(num) {
    if (!await Get('HasPhone')) return;
    if (callElem)  {
        if (callElem.attr('calling') == 'true')  {
            notifsActive--
            let _item = callElem
            _item.fadeIn(500, function() {
                _item.remove();
            })
            callElem = null;
        } else {
            return;
        }
    }
    notifsActive++
    callElem = $(document.createElement('div')).addClass('phone_notif')
    callElem.html(`
        <img src = "img/${'contacts'}.png" class = "phone_notif_icon">
        <p style = "transform: scale(1.25, 1.25);left:5em;">${num} <font color = "gray"> - 0:00</font></p>
        <i class="fas fa-times-circle phone_deny" title = "dick"></i>
    `)

    let seconds = 0;
    let interval = setInterval(() => {
        if (!callElem) {
            clearInterval(interval) 
            return;
        } 
        seconds++
        let minutes = Math.floor(seconds / 60)
        let secs = String(seconds - (minutes * 60))
        if (secs.length == 1) secs = '0'+secs
        callElem.find('p').html(`${num} <font color = "gray"> - ${minutes}:${secs}</font>`)
    }, 1000);

    callElem.fadeOut(0)
    $('#phone_notif').prepend(callElem)

    $('.phone_deny').click(function() {
        Get('phonecall', {
            action: 'h'
        })
    })

    setTimeout(() => {
        callElem.fadeIn(500, function() {
        })
    }, 500);

    if (interFaceOpen != 'phone') {
        $('#phone').css('display', 'inline')
        $('#phone').animate({bottom: '-27%'}, 250, () => {
        })
    } 
}

async function StartCalling(num) {
    if (!await Get('HasPhone')) return;
    if (callElem) return;
    notifsActive++
    callElem = $(document.createElement('div')).addClass('phone_notif').attr('calling', 'true')
    callElem.html(`
        <div><img src = "img/contacts.png" class = "phone_notif_icon"></div>
        <p>${num}<font color = "gray"> - Calling</font></p>
        <i class="fas fa-times-circle phone_deny" title = "dick"></i>
    `)

    callElem.fadeOut(0)
    $('#phone_notif').prepend(callElem)

    $('.phone_deny').click(function() {
        Get('phonecall', {
            action: 'h'
        })
    })

    setTimeout(() => {
        callElem.fadeIn(500, function() {
        })
    }, 500);

    if (interFaceOpen != 'phone') {
        $('#phone').css('display', 'inline')
        $('#phone').animate({bottom: '-27%'}, 250, () => {
        })
    } 
}

function truncate(str, n){
    return (str.length > n) ? str.substr(0, n-1) + '&hellip;' : str;
};

let bigImg;
function ExpandImage(link, elem) {
    if (link) {
        if (elem.hasClass('spoiler')) return;
        if (bigImg) bigImg.remove();
        $('#imghider').css('display', 'inline')

        bigImg = $(document.createElement('img'))
        bigImg.attr('src', link)
        bigImg.attr('width', '50%')
        $('#imghider').append(bigImg)
            bigImg.css('position', 'fixed')
                .css('top', `${(screen.height / 2) - (parseInt(bigImg.height(), 10) / 2)}px`)
                .css('left', `${(screen.width / 2) - (parseInt(bigImg.width(), 10) / 2)}px`)
        elem.mouseup(function() {
            if (bigImg) bigImg.remove();
            $('#imghider').css('display', 'none')
        }).mouseleave(function() {
            if (bigImg) bigImg.remove();
            $('#imghider').css('display', 'none')
        })
    }
}

function Copy(id) {
    var dummy = document.createElement("textarea");
    document.body.appendChild(dummy);
    dummy.value = id;
    dummy.select();
    document.execCommand("copy");
    document.body.removeChild(dummy);
}

function OpenCamera() {
    let elem = $('#app_container')
    elem.html(`
        <div class = "camera">
        </div>
    `)
    Get('Phone.Camera')
}

async function OpenPhotos() {
    let elem = $('#app_container')

    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Photos</p>
            </div>
            <div class = "phone_photos">
            </div>
        </div>
    `)

    let photos = await Get('Phone.Photos')
    for(var item of photos) {
        $('.phone_photos').append(`
            <div class = "photo">
                <img src = "${item.photo}" pid = ${item.pid}>

                <div class = "footer" id = "photofooter">
                    <div class="fas fa-trash-alt trashing" id = "null"></div>
                    <div class="fas fa-copy copying" id = "null"></div>
                </div>
            </div>
        `)
    }

    $('.photo').each(function() {
        $(this).mousedown(function(e) {
            if (e.which == 1 && currentHover == null) {
                ExpandImage($(this).find('img').attr('src'), $(this))
            } 
        })

        $(this).mouseenter(function() {
            $(this).find('.footer').css('opacity', '0.75')
        }).mouseleave(function() {
            $(this).find('.footer').css('opacity', '0.0')
        })
    })

    $('.trashing').click(async function(e) {
        if (await PhoneConfirm('photos', 'Would you like to delete this picture?', null, 15)) {
            let photos = await Get('Phone.DeletePhoto', {pid: $(this).parent().parent().find('img').attr('pid')})
            $(this).parent().parent().remove();
        }
    })

    $('.copying').click(function(e) {
        Copy($(this).parent().parent().find('img').attr('src'))
        PhoneNotif('photos', "Copied URL to clipboard")
    })
}

async function PhoneInput(obj) {
    return new Promise((resolve) => {
        $('#phone_contacts_new').remove()
        $('#phone_contacts_new').css('height', '11.2em')
        let elem = $('#app_container')
    
        elem.append(`
            <div id = "phone_contacts_new">
                <p>${obj.header}</p>
                <hr>
    
                <label for="phone_contact_input" class = "phone_contact_container">${obj.title}</label>
                <input type = "${obj.field}" maxlength = "30" class = "phone_contact_input phone_fullnumber" placeholder = "${obj.placeholder}" value = "${obj.value || ''}">
            
                <i class="fas fa-times-circle phone_contact_deny" title = "dick"></i>
                <i class="fas fa-check-circle phone_contact_accept" title = "dick"></i>
            </div>
        `)
    
        $('#phone_contacts_new').animate({bottom: '0em'}, 500)
        $('.phone_contact_deny').click(function() {
            $('#phone_contacts_new').animate({bottom: '-11.2em'}, 500, function() {
                resolve()
                $(this).remove()
            })
        })
    
        $('.phone_contact_accept').click(function() {
            resolve($('.phone_fullnumber').val())
            CloseNewContact();
        })
    })
}

async function EndApp() {
    $('#app_containerx').animate({left: minimize.left, top: minimize.top, width: minimize.height, height: minimize.height}, 250, 'swing')

    setTimeout(() => {
        $('#app_containerx').css('opacity', '0.0')
    }, 50);

    $('#app_containerx').css('pointer-events', 'none')
    setTimeout(() => {
        $('#app_container').html('')
    }, 500);
}