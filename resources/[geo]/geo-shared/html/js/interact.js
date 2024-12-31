$(() => {
    $('body').append(`
        <div class = "alert_container">
            <img src = "alert.png" class = "alert_icon">
            <h class = "alert_text">[E] Lock That Shit</h>
        </div>
    `)
})

let shown = false;
let items = []
window.addEventListener("message", (e) => {
    switch(e.data.interface) {
        case 'interact':
            Queue(Add, e, e.data.allowed);
            break;
        case 'closeInteract':
            Queue(Remove, e);
            break;
        case 'updateInteract':
            Queue(Update, e);
            break;
    }
})

let _queue = []
async function Queue(ev, data, allowed) {
    _queue.push([ev, data])
    if (_queue.length == 1) {
        while (_queue[0] != null) {
            _queue[0][0](_queue[0][1], allowed);
            await sleep(500);
            _queue.shift()
        }
    }
}

async function sleep(ms) {
    return new Promise(resolve => {
        setTimeout(() => {
            resolve(true)
        }, ms);
    })
}

function Update(e) {
    let id = e.data.id
    if (e.data.id) {
        items[id].find('.alert_text').html(e.data.message);
        items[id].css('display', 'inline');
        items[id].css('width', `auto`);
        items[id].css('left', `calc(50% - ${Math.floor(items[id].width() / 2)}px)`);
    }
}

function Add(e, allowed) {
    let id = e.data.id
    if (!items[id]) items[id] = $(document.createElement('div')).addClass('alert_container');
    items[id].html(`
        <img src = "alert.png" class = "alert_icon">
        <h class = "alert_text">[E] Lock That Shit</h>
    `)
    items[id].find('.alert_text').html(e.data.message);
    $('body').append(items[id])
    items[id].css('display', 'inline');
    items[id].find('.alert_text').animate({opacity: '1.0'}, 0)
    items[id].css('width', `auto`);
    items[id].css('left', `calc(50% - ${Math.floor(items[id].width() / 2)}px)`);

    if (allowed == false && allowed != null) {
        items[id].css('background-color', `rgb(133, 76, 76)`);
    }

    items[id].animate({opacity: '1.0'}, 500);
}

function Remove(e) {
    let id = e.data.id
    if (e.data.id) {
        items[id].find('.alert_text').animate({opacity: '0.0', }, 250);
        items[id].animate({width: '5vh', left: 50 - ((5/2) * 9/16)+'%'}, 500, () => {
            setTimeout(() => {
                items[id].animate({opacity: '0.0'}, 250, () => {
                    items[id].remove()
                })
            }, 250);
        });
        shown = false;
    }
}