window.addEventListener('message', function(e) {
    let data = e.data;

    if (e.data.interface == 'houserob') {
        $('#houserob').animate({opacity: data.active ? '1.0' : '0.0'}, 1000)
    }

    if (e.data.interface == 'houserob-progress') {
        $('.houserob_percent').css('width', data.percent+'%')
    }
})