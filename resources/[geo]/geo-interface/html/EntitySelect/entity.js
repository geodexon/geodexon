let x, y
let SubNav
let isConfirming = false;

window.addEventListener('message', (evt) => {
    let data = evt.data
    switch (data.interface) {
        case 'CharacterSelect':
            interFaceOpen = 'CharacterSelect';
            $('#changelog').css('display', 'inline').css('pointer-events', 'all')
            break;
        case 'Character.Found':
            CharInput(data.data, data.name);
            break;
        case 'Entity.Select':
            SubNav = data.SubMenus
            $('#EntityCont').css('display', 'inline')
            EntityOptions($('#EntitySelect2'), data.options, 0.01, 0.3)
            interFaceOpen = 'EntitySelect';
            break;
        case 'Entity.Selected':
            $('.menuHolder').remove()
            var svgMenu = new RadialMenu({
                parent: document.body,
                size: 400,
                closeOnClick: true,
                menuItems: data.l,
                onClick: function(item) {
                    $.post(`http://${GetParentResourceName()}/Entity.ItemClick`, JSON.stringify({
                        item: item.id,
                        ent: true
                    }));
                    CloseMenu();
                }
            }).open();

            SubNav = data.SubMenus
                /*  EntityOptions(null, data.Options, data.x, data.y) */
        case 'Selector':
            $('.supercenter').css('opacity', data.mode === 'open' ? '1.0' : '0.0');
            if (data.mode === 'close') $('#Selector-Options').html('');
            break;
        case 'SelectorUpdate':
            let obj = $('#Selector-Options');
            obj.html('');

            if (data.options.length > 0) {
                $('.supercenter').css('animation', 'none')
            } else {
                $('.supercenter').css('animation', 'rotation 2s infinite linear')
            }

            for (var item of data.options) {
                let div = $(document.createElement('div')).addClass('dicksout')
                let _item = item
                let elem = $(document.createElement('i'))
                    .attr('id', 'Selector-Option')
                    .html(_item.title.toUpperCase())

                div.append(`<i class="${_item.icon || ""}"></i>`).append(elem)
                obj.append(div)
                div.click(function() {
                    $.post(`https://${GetParentResourceName()}/OptionSelected`, JSON.stringify({
                        option: _item.id
                    }));

                    $('#Selector-Options').html('');
                    $.post(`http://${GetParentResourceName()}/SelectOption.Close`, JSON.stringify({}));
                });
            }
            break;
        case 'SelectOption':
            interFaceOpen = 'SelectOption';
            break;
        case 'Discord':
            Discord();
            break;
        case 'SpeechBubble':
            SpeechBubble(data.txd, data.msg, data.key);
            break;
        case 'SpeechBubbleLocation':
            SpeechBubbleUpdate(data.pos);
            break;
    }
})


$('body').mousemove(function(evt) {
        if (interFaceOpen === 'CharacterSelect') {
            $.post(`http://${GetParentResourceName()}/SelectChar`, JSON.stringify({
                x: evt.clientX / screen.width,
                y: evt.clientY / screen.height
            }));
        }

        if (interFaceOpen === 'EntitySelect') {
            x = evt.clientX / screen.width;
            y = evt.clientY / screen.height;
        }
    })
    /* 
    $('body').click(function(evt) {
        if (interFaceOpen ==='EntitySelect' && currentHover != 'entity_option_name') {
            $.post(`http://${GetParentResourceName()}/EntitySelect`, JSON.stringify({
                x: x,
                y: y
            }));
        }
    }) */

function CharInput(data, name) {
    if (isConfirming) return;
    let elem = $('#char_field')

    let addon1 = data.job != null ? `<p id = "char_info">Job: ${data.job}</p>` : ''


    if (data === 'none') {
        elem.html(`
            <p id = "char_name">New Character</p>
            <button id = "char_create" onclick = Create()>
                Create Character
            </button>
        `).css('height', 'auto')
    } else {
        elem.html(`
            <p id = "char_name">${name}</p>
            <hr>

            <p id = "char_info">Date of Birth: ${data.dob}</p>
            <p id = "char_info">Sex: ${data.sex === 0 ? 'Male' : 'Female'}</p>
            <p id = "char_info">Phone Number: ${formatPhoneNumber(data.phone_number)}</p>
            ${addon1}
            <br>
            <br>
            <br>
            <button id = "char_select" onclick = Login(${data.id})>
                Login
            </button>

            <button id = "char_delete" onclick = DeleteChar(${data.id})>
                Delete Character
            </button>

            <button id = "char_work" onclick = Work(${data.id})>
                Send to Work
            </button>
        `).css('height', '20%')
    }
    elem.css('display', 'inline')
}

async function DeleteChar(id) {
    isConfirming = true;
    if (await Confirm('Would you like to Delete this character?')) {
        $.post(`http://${GetParentResourceName()}/Delete`, JSON.stringify({
            id: id
        }));
    }
    isConfirming = false;
}

async function Work(id) {
    isConfirming = true;
    if (await Confirm('Would you like to send this character to work? they will be unavailable for 16 hours and will earn some cash. It will be deposited into their primary bank account')) {
        let val = await Get('Work', {
            id: id
        });

        if (val) {
            $('#char_field').html('')
        }
    }
    isConfirming = false;
}

function Login(id) {
    $.post(`http://${GetParentResourceName()}/Login`, JSON.stringify({
        id: id
    }));

    $('#changelog').css('display', 'none').css('pointer-events', 'none')
    $('#char_field').css('display', 'none')
    interFaceOpen = null;
}

function Create() {
    $('#char_field').css('display', 'none')
    $('#changelog').css('display', 'none').css('pointer-events', 'none')
    $.post(`http://${GetParentResourceName()}/Create`, JSON.stringify({}));
    interFaceOpen = null;
}

let formatPhoneNumber = (str) => {
    if (str.length != 10) return str;
    let cleaned = ('' + str).replace(/\D/g, '');

    let match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);

    if (match) {
        return '(' + match[1] + ') ' + match[2] + '-' + match[3]
    };

    return null
};

let _items = [];
let _subitems = [];
let _hover = -1;
let _inSub = false
let _parentID

let _upDown = false;
let _downDown = false;
let _leftDown = false;
let _rightDown = false;

function _menuInput(e) {
    let toCheck = _items

    if (_inSub) toCheck = _subitems

    if (e.keyCode == '40' && !_downDown) {
        _downDown = true
        if (toCheck[_hover + 1]) {
            _hover++
            if (toCheck[_hover]) {
                if (toCheck[_hover - 1]) {
                    if (!_inSub) _subitems = [];
                    toCheck[_hover - 1].removeClass('hover')
                }
                toCheck[_hover].trigger('mouseenter')
                toCheck[_hover].addClass('hover')
            }
        }
    }

    if (e.keyCode == '38' && !_upDown) {
        _upDown = true
        if (toCheck[_hover - 1]) {
            _hover--
            if (toCheck[_hover]) {
                if (toCheck[_hover + 1]) {
                    if (!_inSub) _subitems = [];
                    toCheck[_hover + 1].removeClass('hover')
                }
                toCheck[_hover].trigger('mouseenter')
                toCheck[_hover].addClass('hover')
            }
        }
    }

    if (e.keyCode == '39' && !_rightDown) {
        _rightDown = true
        if (_subitems.length > 0) {
            _parentID = _hover
            _hover = 0
            _inSub = true

            if (_subitems[0]) {
                if (_subitems[0 - 1]) {
                    if (!_inSub) _subitems = [];
                    _subitems[0 - 1].removeClass('hover')
                }
                _subitems[0].trigger('mouseenter')
                _subitems[0].addClass('hover')
            }
        }
    }

    if (e.keyCode == '37' && !_leftDown) {
        _leftDown = true
        if (_inSub) {
            _subitems[_hover].removeClass('hover')
            _hover = _parentID
        }
        _inSub = false;
    }

    if (e.keyCode == '13' && interFaceOpen == 'EntitySelect') {
        toCheck[_hover].trigger('click')
        _hover = 0
        _inSub = false;
    }
}

document.onkeyup = function(e) {
    if (interFaceOpen) {
        if (e.keyCode == '40') {
            _downDown = false;
        }

        if (e.keyCode == '38') {
            _upDown = false;
        }

        if (e.keyCode == '39') {
            _rightDown = false;
        }

        if (e.keyCode == '37') {
            _leftDown = false;
        }
    }
}

function EntityOptions(elem, data, x, y) {
    let _sub = false;
    x -= 0.01

    if (!elem) {
        _sub = true
        elem = $('#EntitySelect')
    } else {
        _hover = -1;
        _inSub = false;
        _items = [];
        _subitems = [];
    }

    elem.html('')
    elem.css('top', 'auto')
    elem.css('bottom', 'auto')
    let math = (x * screen.width) + (10 * (screen.width / 1920))
    let math2 = y * screen.height
    let overFlowX = false;
    let overFlowY = false;
    elem.css('right', 'auto')
    elem.css('bottom', 'auto')
    elem.css('left', math + 'px')
    elem.css('top', math2)

    let _nav = SubNav
    let _index = 0;
    for (var item of data) {
        let ind = item
        let name = item[1] == null ? item[0] : item[1]

        let _item = $(document.createElement('div'))
        _item.addClass('entity_option')
        _item.html(`
            <p id = "entity_option_name">${item[1] == null ? item[0] : item[1]}</p>
        `)

        _item.click(() => {
            CloseMenu();
            $.post(`http://${GetParentResourceName()}/Entity.ItemClick`, JSON.stringify({
                item: ind[0],
                ent: _sub
            }));
        })

        elem.append(_item)
        if (!_sub) {
            _items[_index] = _item
        }

        if (!overFlowX && math + parseInt(_item.css('width')) > screen.width) {
            overFlowX = true;
            elem.css('left', 'auto')
            elem.css('right', Math.abs(1920 - screen.width - ((1.0 - x) * screen.width)) + (10 * (screen.width / 1920)) + 'px')
        }

        if (!overFlowY && math2 + parseInt(elem.css('height')) > screen.height) {
            overFlowY = true;
            elem.css('top', 'auto')
            elem.css('bottom', Math.abs(screen.height - screen.height - ((1.0 - y) * screen.height)) + (10 * (screen.height / 1920)) + 'px')
        }

        if (_nav && _nav[ind[0]]) {
            /*             _item.append($(document.createElement('p')).html('>').attr('id', 'entity_option_expand').css('top', 0 - (_item.height()))) */
            _item.append('<p id = "entity_option_expand">></p>')
            _item.mouseenter(() => {

                if (ind[2]) {
                    $.post(`http://${GetParentResourceName()}/Entity.ItemHover`, JSON.stringify({
                        item: ind[0],
                        ent: _sub
                    }));
                }

                $('.entity_submenu').each(function() {
                    $(this).remove();
                })

                let index = 0;
                for (var subItem of _nav[ind[0]]) {
                    let _ind = index
                    let _subItem = $(document.createElement('div'))
                    _subItem.addClass('entity_option')
                    _subItem.addClass('entity_submenu')
                    _subItem.html(`
                        <p id = "entity_option_name">${subItem[0]}</p>
                    `)


                    elem.append(_subItem)

                    if (!_sub) {
                        _subitems[index] = _subItem
                    }

                    if (overFlowX) {
                        _subItem.css('left', parseInt(elem.css('left')) - _item.width() + 2 - (screen.width * 0.011))
                    } else {
                        _subItem.css('left', parseInt(elem.css('left')) + _item.width() + 2 + (screen.width * 0.011))
                    }

                    _subItem.css('top', parseInt(_item.offset().top) + (index * _item.height()))

                    _subItem.click(() => {
                        CloseMenu()
                        $.post(`http://${GetParentResourceName()}/Entity.SubItem`, JSON.stringify({
                            command: _nav[ind[0]][_ind][0],
                            ent: _sub,
                            name: ind[0]
                        }));

                    })

                    index++
                }
            }).mouseleave(function() {
                if (ind[2]) {
                    $.post(`http://${GetParentResourceName()}/Entity.ItemHoverEnd`, JSON.stringify({
                        item: ind[0],
                        ent: _sub
                    }));
                }
            })
        } else {
            _item.mouseenter(() => {
                $('.entity_submenu').each(function() {
                    $(this).remove();
                })

                if (ind[2]) {
                    $.post(`http://${GetParentResourceName()}/Entity.ItemHover`, JSON.stringify({
                        item: ind[0],
                        ent: _sub
                    }));
                }
            }).mouseleave(function() {
                if (ind[2]) {
                    $.post(`http://${GetParentResourceName()}/Entity.ItemHoverEnd`, JSON.stringify({
                        item: ind[0],
                        ent: _sub
                    }));
                }
            })
        }
        _index++
    }

    elem.css('display', 'inline')
}

function EntityClose() {
    if (interFaceOpen === 'EntitySelect') {
        $('#EntityCont').css('display', 'none')
        $.post(`http://${GetParentResourceName()}/Entity.Finish`, JSON.stringify({}));
    }
}

function Discord() {
    $('#discord').css('display', 'inline')

    $('#dcordbutton').click(() => {
        window.invokeNative('openUrl', 'https://discord.com/invite/gh276yeyMz')
        $('#discord').css('display', 'none')
        $.post(`https://${GetParentResourceName()}/Discord`)
    })

    $('#dcordbutton2').click(() => {
        $('#discord').css('display', 'none')
        $.post(`https://${GetParentResourceName()}/Discord`)
    })
}

$(() => {
    ChangelogInfo(changelog[changelog.length - 1])
})

function ChangelogInfo(data) {
    $('#changelog').html('')
    $('#changelog').append(`
        <p id = "changelog_title">${data[0]}</p>
        <hr>
        <ul>
        </ul>
    `)

    for (var item of data[1]) {
        $('#changelog').find('ul').append(`
            <li class = "changelog_item">${item}</li>
        `)
    }

    $('#changelog').append(`
        <select name="Date" id="changelog_date_selector">
        </select>
    `)

    for (var item of changelog.reverse()) {
        $('#changelog_date_selector').append(`
            <option value="${item[0]}">${item[0]}</option>
        `)
    }

    $('#changelog_date_selector').val(data[0])
    $('#changelog_date_selector').on('input', function() {
        for (var item of changelog) {
            if (item[0] == $(this).val()) ChangelogInfo(item);
        }
    })
}

function SpeechBubble(txd, msg, key) {
    console.log(key)
    $('.dialogue-text').html(key)
    $('.dialogue-headshot').attr('src', `https://nui-img/${txd}/${msg}`)
}

function SpeechBubbleUpdate(pos) {
    let elem = $('.dialogue')

    if (pos[3] == -1) {
        elem.css('opacity', '0.0')
    } else {
        elem.css('opacity', '1.0')
    }

    elem.css('left', ((pos[0] * 100) - (pos[3] / 2)) + '%')
    elem.css('top', ((pos[1] * 100) - (pos[3] / 4)) + '%')
    elem.css('transform', `rotateY(${pos[2]}deg) scale(${1.0 - (pos[3] / 20)}, ${1.0 - (pos[3] / 20)})`)
}

function HashString(command) {
    let hash = 0;
    let string = command.toLowerCase();
    for(i=0; i < string.length; i++) {
      let letter = string[i].charCodeAt();
      hash = hash + letter;
      hash += (hash << 10 >>> 0);
      hash ^= (hash >>> 6);
      hash = hash >>> 0
    }

    hash += (hash << 3);
    if (hash < 0) {
      hash = hash >>> 0
    }
    hash ^= (hash >>> 11);
    hash += (hash << 15);
    if (hash < 0) {
      hash = hash >>> 0
    }
    return hash.toString(16).toUpperCase();
  }