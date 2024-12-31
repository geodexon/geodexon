$(function() {
    $('body').append(`
        <div id = "broswer">
        <iframe id = "browser_content" src="" title="W3Schools Free Online Web Tutorials"></iframe>
        </div>
    `)
})

window.addEventListener('done', function() {
    $('#browser_content').attr('src', 'about:blank')
    $('#broswer')
        .css('pointer-events', 'none')
        .css('display', 'none')
})

window.addEventListener('message', function(event) {
    if (event.data.interface == 'Browser') {
        interFaceOpen = 'Browser'
        $('#browser_content').attr('src', event.data.link)
        $('#broswer')
            .css('pointer-events', 'all')
            .css('display', 'inline')
    }
})