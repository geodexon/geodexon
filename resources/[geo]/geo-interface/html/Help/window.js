let zIndex = 0;
function UISound(name) {
    var audio = new Audio(`nui://geo-interface/html/Help/sounds/${name}.mp3`)
    audio.volume = 0.05 * (localStorage["UISound"] || 1)
    audio.play()
}

function MoveableWindow(elem, dragger) {
    let width = (elem.width()) / 2
    let height = (elem.height()) / 2
    if (localStorage[dragger]) {
        let pos = JSON.parse(localStorage[dragger])
        elem.css('left', (pos[0] * screen.width)+'px')
        elem.css('top', (pos[1] * screen.height)+'px')
    }


    $(dragger).mousedown(function() {
        elem.draggable({containment: [0 - width, 0 - height, screen.width - width, screen.height - height]})
       
    })

    elem.mousedown(function() {
        zIndex += 1
        elem.css('z-index', zIndex)
    })

    $(dragger).mouseup(function() {
        elem.draggable('destroy')
        localStorage[dragger] = JSON.stringify([elem.position().left / screen.width, elem.position().top / screen.height])
    })

    elem.find('.img').click(function() {
        if (elem.attr('remove')) {
            UISound('close')
            elem.remove()
            return;
        }

        elem.css('display', 'none')
        UISound('close')
    })
}

function CreateWindow(pClass, title, attr) {
    zIndex += 1
    if ($('.'+pClass).html()) {
        $('.'+pClass).css('display', 'inline')
        $('.'+pClass).css('pointer-events', 'all')
        $('.'+pClass).css('pointer-events', '1.0')
        $('.'+pClass).css('z-index', zIndex)
        return $('.'+pClass);
    }
    $('body').append(`
        <div class = "window ${pClass}">
            <div class = "header ${pClass}drag">
                <p>${title}</p>
                <div class="img"></div>
            </div>
        </div>
    `)

    let elem = $('.'+pClass)
    MoveableWindow(elem, `.${pClass}drag`)
    elem.css('z-index', zIndex)

    if (attr) {

        if (attr.sound) {
            UISound(attr.sound)
        }

        for(var item in attr) {
            elem.attr(item, attr[item])
        }
    }

    return elem
}

window.addEventListener('done', function() {
    $('.window').each(function() {
        if ($(this).attr('sound')) {
            UISound('close')
        }

        if ($(this).attr('remove')) {
            $(this).remove()
            return;
        }

        let transition = $(this).css('transition')
        $(this).css('transition', 'none')
        $(this).animate({opacity: '0.0'}, 500, function() {
            $(this).css('transition', transition)
            $(this).css('pointer-events', 'none')
        })
    })
})