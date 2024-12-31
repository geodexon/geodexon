function OpenSettingsApp() {
    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p id = "restarthousing">Settings</p>
            </div>

            <div class = "input_containerx" id = "phonebgimage">
                <input type = "text" class = "input_field" placeholder = "Phone Background URL" id = "phoneimgsetter" value = "${localStorage[`phone.${cid}`] ? localStorage[`phone.${cid}`] : ''}">
                <img src = "img/person.png" class = "input_img">
            </div>
        </div>
    `)

    $('#phoneimgsetter').on('input', function() {
        localStorage[`phone.${cid}`] = $(this).val()
        if (localStorage[`phone.${cid}`] == '') {
            delete localStorage[`phone.${cid}`]
        }
        $('#phone_container').css('background', `url(${localStorage[`phone.${cid}`] || 'https://media.istockphoto.com/photos/blue-abstract-background-or-texture-picture-id1138395421?k=6&m=1138395421&s=612x612&w=0&h=bJ1SRWujCgg3QWzkGPgaRiArNYohPl7-Wc4p_Fa_cyA='})`)
    })
}