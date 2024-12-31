function OpenLocation() {
    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Location Services</p>
            </div>

            <p style = "top:2em;color:white;position:relative;text-align:center;font-size:1.25em">Target ID</p>
            <input class = "phone_ping" type = "number" placeholder = "CID" style = 
                "position:relative;background:none;border:none;outline:none;top:2em;width: 60%;left:20%;
                background-color:var(--main-content); border-radius:0.25em;font-size: 1.5em; padding:0.25em;
                color:white;text-align:center;
            ">

            <button class = "phone_ping_button" style = "position:relative;background:none;border:none;outline:none;top:2em;width: 60%;left:20%;
            background-color:var(--main-content); border-radius:0.25em;font-size: 1.25em; padding:0.25em;
            color:white;top:6em;">Send Ping</button>
        </div>
    `)

    $('.phone_ping_button').click(function() {
        if ($('.phone_ping').val()) {
            Get('SendPing', {
                id: $('.phone_ping').val()
            })
            $('.phone_ping').val('')
        }
    })
}