selectorOpen = false;
let menuLayer = 0;
let menuList = [];
let menu;
let cHover = -1
let availableOptions = []

/*
    Valid Types:
    ----------------------------------------------------------------------------------------------
    title: the main text name *string*
    params: values triggered from the event *array*
    description: text the describes what happens *sting*
    event: the event that is triggered *string*
    disabled: whether the element can be clicked on or not *bool*
    submenu: menu in a menu *array*
    hidden: show the element or not *bool*
    image: show an image on hover *string*
*/

window.addEventListener('message', (evt) => {
    if (evt.data.interface == 'OptionSelector') {
        menu = evt.data.menu;
        menuLayer = 0;
        menuList = [];
        interFaceOpen = 'OptionSelector'
        $('#selector').css('pointer-events', 'all')
        OpenMenu(evt.data.menu)
    }
})

window.addEventListener('done', function() {
    $('body').find('.selector_image').remove();
})

function _optionSelector(e) {
    if (availableOptions.length == 0) return;
    if (e == 40) {
        if (availableOptions[cHover + 1]) {
            if (cHover != -1) {
                availableOptions[cHover].removeClass('selector_hover')
            }
            cHover++
            availableOptions[cHover].addClass('selector_hover')
        }
    } else if (e == 13 && cHover != -1) {
        availableOptions[cHover].trigger('click')
    } else if (e == 38) {
        if (cHover - 1 != -1) {
            availableOptions[cHover].removeClass('selector_hover')
            cHover--
            availableOptions[cHover].addClass('selector_hover')
        }
    } else if (e == 39 && availableOptions[cHover].hasClass('selector_hasSub')) {
        availableOptions[cHover].trigger('click')
    } else if (e == 37 && menuLayer > 0 && cHover == 0) {
        availableOptions[cHover].trigger('click')
    }
}

function OpenMenu(menuData) {
    cHover = -1
    availableOptions = [];
    selectorOpen = true;
    $('#selector').html('')

    if (menuLayer > 0) {
        let elem = $(document.createElement('div')).addClass('selector_option')
        elem.html(`
            <div class = "selector_title_text">${'← Go Back'}</div>
        `)

        elem.click(() => {
            menuLayer--
            OpenMenu(menuList[menuLayer])
            menuList.pop()
        })
        $('#selector').append(elem)
        availableOptions.push(elem)
    }

    for (var item of menuData) {
        let _item = item
        _item.title = _item.title || ''
        if (_item.hidden) continue;

        let elem = $(document.createElement('div')).addClass('selector_option')
        elem.html(`
            <div class = "selector_title_text">${_item.title} 
                ${_item.right ? '<span style="float:right; margin-right:1em;">'+_item.right+'</font></span>' : ''}
                ${_item.sub ? '<br>  <p class = "selector_desc">'+_item.sub+'</p>' : ''}
            </div>
        `)

        if (_item.description) {
            elem.find('.selector_title_text').append(`
                <p class = "selector_desc">
                    ${_item.description}
                </p>
            `)
        }
        

        if (_item.submenu) {
            elem.find('span').css('margin-right', '3.5em')
            elem.addClass('selector_hasSub')
            elem.append(`
                <h class = "selector_sub">→</h>
            `)
        }

        if (!_item.disabled) {
            availableOptions.push(elem)
            if (_item.title != '') {
                elem.click(() => {
                    if (_item.submenu) {
                        menuLayer++
                        menuList.push(menuData)
                        OpenMenu(_item.submenu)
                    } else {
                        if (_item.close == null || _item.close == true) {
                            CloseMenu();
                        }
                        if (_item.event == null && _item.serverevent == null && _item.func == null) return;
                        Get('OptionSelector.Trigger', {
                            event: _item.event,
                            serverevent: _item.serverevent,
                            params: _item.params,
                            func: _item.func,
                            close: _item.close
                        })
                    }
                })
            }
        } else {
            elem.css('background-color', ' rgb(88, 88, 88)')
            elem.css('border-color', 'white')
            elem.find('.selector_desc').css('color', 'white')
        }

        if (_item.title == '') {
            elem.find('.selector_desc').css('margin-bottom', '1vh')
        }

        if (_item.image) {
            elem.mouseenter(() => {
                $('body').append(`<img class = "selector_image" src = "${_item.image}">`)
                var rt = ($(window).width() - (elem.offset().left));
                $('body').find('.selector_image').css('right', `calc(1em + ${rt}px)`)
                $('body').find('.selector_image').css('top', elem.offset().top)

            }).mouseleave(() => {
                $('body').find('.selector_image').slideUp(500, function() {
                    $(this).remove()
                })
            })
        }

        if (_item.hover) {
            elem.mouseenter(() => {
                Get('OptionSelector.Hover', {
                    hover: _item.hover[0],
                    params: _item.hoverparams
                })
            }).mouseleave(() => {
                Get('OptionSelector.Hover', {
                    hover: _item.hover[1],
                    params: _item.hoverparams
                })
            })
        }

        $('#selector').append(elem)
    }
}