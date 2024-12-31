let clothingNames = ['Face', 'Mask', 'Hair', 'Torso', 'Pants', 'Parachute', 'Shoes', 'Accessories', 'Undershirt', 'Armor', 'Badge', 'Jacket']
let propNames = ['Hat', 'Glass', 'Ear', null, null, null, 'Watch', 'Bracelt']
let featureNames = ['Nose Width', 'Nose Peak Height', 'Nose Peak Length', 'Nose Bone High', 'Nose Peak Lowering', 'Nose Bone Twist', 'Eyebrow High', 'Eyebrow Forward', 'Cheek Bone High', 'Cheeck Bone Width', 'Cheeks Width', 'Eye Opening', 'Lip Thickness', 'Jaw Bone Width', 'Jaw Bone Back Length', 'Chimp Bone Lowering', 'Chimp Bone Length', 'Chimp Bone Width', 'Chimp Hole', 'Neck Thickness']
let overlayNames = ['Blemishes', 'Facial Hair', 'Eyebrows', 'Age', 'Makeup', 'Blush', 'Complexion', 'Sun Damage', 'Lipstick', 'Moles', 'Chest Hair', 'Body Blemishes', 'Body Blemishes']

let outfits = []
let clothingData = [];

const getBase64StringFromDataURL = (dataURL) =>
    dataURL.replace('data:', '').replace(/^.+,/, '');

window.addEventListener('message', (event) => {
    let data = event.data;
    switch (data.interface) {
        case 'clothing':
            outfits = data.outfits;
            ClothingMenu(data.options, data.showFace, data.char);
            break;
        case 'clothing.outfits':
            outfits = data.outfits;
            break;
        case 'copy':
            Copy(data.data)
        case 'getimage':
            $('body').append(`<img id = "my-image" src="https://nui-img/${data.data2}/${data.data}">`)
            const image = document.getElementById('my-image');
            const toDataURL = () => {
                const canvas = document.createElement('canvas');

                // We use naturalWidth and naturalHeight to get the real image size vs the size at which the image is shown on the page
                canvas.width = 30;
                canvas.height = 30;

                // We get the 2d drawing context and draw the image in the top left
                canvas.getContext('2d').drawImage(image, 0, 0, 30, 30);

                // Convert canvas to DataURL and log to console
                const dataURL = canvas.toDataURL();
                // logs data:image/png;base64,wL2dvYWwgbW9yZ...

                // Convert to Base64 string
                const base64 = getBase64StringFromDataURL(dataURL);
                Get('img64', {data:base64})
                $('#my-image').remove()
                // Logs wL2dvYWwgbW9yZ...
            };

            // If the image has already loaded, let's go!
            if (image.complete) toDataURL(image);
            // Wait for the image to load before converting
            else image.onload = toDataURL;
            }
})

function ClothingMenu(options, showFace, char) {
    interFaceOpen = 'Clothing'
    let elem = $('#clothing');
    clothingData = options
    elem.html(`
        <div id = "clothing_header"></div>
        <img src = "img/shirt.png" id = "clothing_shirt" title = "Clothing">
        <img src = "img/helmet.png" id = "clothing_helmet" title = "Props">

        <div id = "clothing_headcamera">
            <img  src = "img/head.png" id = "clothing_camerapic" Title = "Head Camera">
        </div>
    `)

    $('#clothing_shirt').tooltip({
        tooltipClass: "tooltip2"
    })

    $('#clothing_helmet').tooltip({
        tooltipClass: "tooltip2"
    })

    $('#clothing_camerapic').tooltip({
        tooltipClass: "tooltip2"
    })

    if (options.face) {
        elem.append(`
            <img src = "img/face.png" id = "clothing_overlay" title = "Face Overlay">
        `)
    }

    $('#clothing_overlay').tooltip({
        tooltipClass: "tooltip2"
    })

    if (options.blend) {
        elem.append(`
            <img src = "img/face.png" id = "clothing_blend" title = "Face Structure">
            <img src = "img/face.png" id = "clothing_face" title = "Face Features">
        `)
    }

    $('#clothing_blend').tooltip({
        tooltipClass: "tooltip2"
    })

    $('#clothing_face').tooltip({
        tooltipClass: "tooltip2"
    })

    if (char) {
        elem.append(`
            <img src = "img/outfit.png" id = "clothing_outfits" title = "Outfits">
        `)
    }

    $('#clothing_outfits').tooltip({
        tooltipClass: "tooltip2"
    })

    $('#clothing_shirt').click(function() {
        $('#clothing_container').html('')
        ClothingPage(clothingData.clothing, showFace)
    })

    $('#clothing_helmet').click(function() {
        $('#clothing_container').html('')
        PropPage(clothingData.props, showFace)
    })

    $('#clothing_face').click(function() {
        $('#clothing_container').html('')
        FacePage(clothingData.face, showFace)
    })

    $('#clothing_blend').click(function() {
        $('#clothing_container').html('')
        BlendPage(clothingData.blend, showFace)
    })

    $('#clothing_overlay').click(function() {
        $('#clothing_container').html('')
        OverlayPage(clothingData.overlay, showFace)
    })

    $('#clothing_outfits').click(function() {
        $('#clothing_container').html('')
        Outfits()
    })

    $('#clothing_headcamera').click(function() {
        $.post(`http://${GetParentResourceName()}/Clothing.HeadCam`)
    })

    let container = $(document.createElement('div')).attr('id', 'clothing_container')
    elem.append(container)

    $('#clothing').css('display', 'inline')
    $('#clothing').animate({ opacity: '1.0' }, 500, () => {})
    ClothingPage(options.clothing, showFace);

    /*  ClothingPage(options) */
}

function ClothingPage(options, showFace) {
    let _texture = 0;
    for (var item in options) {
        if (item == 0 && showFace) continue;

        let _item = item
        let range = $(document.createElement('input'))
        range.attr('type', 'range')
        range.attr('id', 'clothing_slider_bar')
        range.attr('min', options[_item].min)
        range.attr('max', options[_item].max)
        range.val(options[_item].current)

        let slider = $(document.createElement('div')).attr('id', 'clothing_slider')
        let drawable = $(document.createElement('input'))
        drawable.attr('type', 'number')
        drawable.attr('id', 'clothing_drawable_input')

        drawable.on('input', function() {
            _texture = 0;
            let val = drawable.val()
            if (val > options[_item].max) val = 0;
            if (val < options[_item].min) val = options[_item].max;
            clothingData.clothing[_item].current = val
            clothingData.clothing[_item].texture = 0
            drawable.val(val)
            range.val(drawable.val());
            _texture = 0;
            texture.val(_texture);

            $.post(`http://${GetParentResourceName()}/Clothing.Change`, JSON.stringify({
                clothing: _item,
                drawable: range.val(),
                texture: _texture,
            }));
        })

        let texture = $(document.createElement('input'))
        texture.attr('type', 'number')
        texture.attr('id', 'clothing_texture_input')

        texture.on('input', function() {
            _texture = texture.val()

            if (_texture > options[_item].maxTex[range.val()]) {
                _texture = 0
            }

            if (_texture < 0) {
                _texture = options[_item].maxTex[range.val()]
            }

            texture.val(_texture);
            clothingData.clothing[_item].texture = _texture

            $.post(`http://${GetParentResourceName()}/Clothing.Change`, JSON.stringify({
                clothing: _item,
                drawable: range.val(),
                texture: _texture,
            }));
        })

        slider.append(range)
        slider.append(`
            <p id = "clothing_name">${clothingNames[_item]}</p>
            <p id = "clothing_drawable">Drawable</p>
            <p id = "clothing_texture">Texture</p>
        `)

        slider.append(drawable)
        slider.append(texture)

        range.on('input', function() {
            drawable.val(range.val())
            _texture = 0;
            texture.val(_texture)
            clothingData.clothing[_item].current = range.val()
            clothingData.clothing[_item].texture = _texture
            $.post(`http://${GetParentResourceName()}/Clothing.Change`, JSON.stringify({
                clothing: _item,
                drawable: range.val(),
                texture: _texture,
            }));
        })

        drawable.val(range.val())
        texture.val(options[_item].texture)

        /* if (options[_item].purchase) {
            let btn = $(document.createElement('button')).addClass('clothing_buy').html('Purchase')
            .click(function() {
                Get('BuyClothing', {
                    id: _item,
                    drawable: range.val(),
                    texture: _texture
                })
            })

            slider.append(btn)
        } */

        $('#clothing_container').append(slider)

        if (_item == 2 && showFace) {
            for (let index = 0; index < 2; index++) {
                let _item = index
                let options = clothingData.overlay
                if (!options[item]) continue;
        
        
                let range = $(document.createElement('input'))
                range.attr('type', 'range')
                range.attr('id', 'clothing_slider_bar')
                range.attr('min', options[_item].min)
                range.attr('max', options[_item].max)
                range.val(round(options[_item].current, 1))
                range.attr('step', (options[_item].step || 1))
        
                let slider = $(document.createElement('div')).attr('id', 'clothing_slider')
                let drawable = $(document.createElement('input'))
                drawable.attr('type', 'number')
                drawable.attr('id', 'clothing_drawable_input')
                drawable.attr('min', options[_item].min)
                drawable.attr('max', options[_item].max)
        
                drawable.on('input', function() {
                    let val = drawable.val()
                    if (val > options[_item].max) val = options[_item].max;
                    if (val < options[_item].min) val = options[_item].min;
                    clothingData.overlay[_item].current = val
                    drawable.val(val)
                    range.val(drawable.val());
                    $.post(`http://${GetParentResourceName()}/Overlay.Change`, JSON.stringify({
                        clothing: _item,
                        drawable: range.val(),
                        data: options[_item]
                    }));
                })
        
                slider.append(range)
                slider.append(`
                    <p id = "clothing_name">${(overlayNames[options[_item].id]) || options[_item].display} ${(options[_item].name || '')}</p>
                    <p id = "clothing_drawable">Drawable</p>
                `)
        
                slider.append(drawable)
        
                range.on('input', function() {
                    drawable.val(range.val())
                    clothingData.overlay[_item].current = range.val()
                    $.post(`http://${GetParentResourceName()}/Overlay.Change`, JSON.stringify({
                        clothing: _item,
                        drawable: range.val(),
                        data: options[_item]
                    }));
                })
        
                drawable.val(range.val())
                $('#clothing_container').append(slider)
            }
        }
    }
}

function PropPage(options) {
    let _texture = 0;
    for (var item in options) {
        let _item = item
        if (!options[item]) continue;


        let range = $(document.createElement('input'))
        range.attr('type', 'range')
        range.attr('id', 'clothing_slider_bar')
        range.attr('min', options[_item].min)
        range.attr('max', options[_item].max)
        range.val(options[_item].current)

        let slider = $(document.createElement('div')).attr('id', 'clothing_slider')
        let drawable = $(document.createElement('input'))
        drawable.attr('type', 'number')
        drawable.attr('id', 'clothing_drawable_input')

        drawable.on('input', function() {
            _texture = 0;
            let val = drawable.val()
            if (val > options[_item].max) val = -1;
            if (val < options[_item].min) val = options[_item].max;

            clothingData.props[_item].current = val
            clothingData.props[_item].texture = 0

            drawable.val(val)
            range.val(drawable.val());
            _texture = 0;
            texture.val(_texture);

            $.post(`http://${GetParentResourceName()}/Prop.Change`, JSON.stringify({
                clothing: _item,
                drawable: range.val(),
                texture: _texture,
            }));
        })

        let texture = $(document.createElement('input'))
        texture.attr('type', 'number')
        texture.attr('id', 'clothing_texture_input')
        texture.attr('min', options[_item].min)
        texture.attr('max', options[_item].max)

        texture.on('input', function() {
            _texture = texture.val()

            if (_texture > options[_item].maxTex[range.val()]) {
                _texture = options[_item].maxTex[range.val()]
            }

            if (_texture < 0) {
                _texture = 0
            }

            clothingData.props[_item].texture = _texture
            texture.val(_texture);

            $.post(`http://${GetParentResourceName()}/Prop.Change`, JSON.stringify({
                clothing: _item,
                drawable: range.val(),
                texture: _texture,
            }));
        })

        slider.append(range)
        slider.append(`
            <p id = "clothing_name">${propNames[_item]}</p>
            <p id = "clothing_drawable">Drawable</p>
            <p id = "clothing_texture">Texture</p>
        `)

        slider.append(drawable)
        slider.append(texture)

        range.on('input', function() {
            drawable.val(range.val())
            _texture = 0;
            texture.val(_texture)
            clothingData.props[_item].current = range.val()
            clothingData.props[_item].texture = _texture
            $.post(`http://${GetParentResourceName()}/Prop.Change`, JSON.stringify({
                clothing: _item,
                drawable: range.val(),
                texture: _texture,
            }));
        })

        drawable.val(range.val())
        texture.val(options[_item].texture)
        $('#clothing_container').append(slider)
    }
}

function FacePage(options) {
    let _texture = 0;
    for (var item in options) {
        let _item = item
        if (!options[item]) continue;


        let range = $(document.createElement('input'))
        range.attr('type', 'range')
        range.attr('id', 'clothing_slider_bar')
        range.attr('min', options[_item].min)
        range.attr('max', options[_item].max)
        range.val(options[_item].current)


        let slider = $(document.createElement('div')).attr('id', 'clothing_slider')
        let drawable = $(document.createElement('input'))
        drawable.attr('type', 'number')
        drawable.attr('id', 'clothing_drawable_input')
        drawable.attr('min', options[_item].min)
        drawable.attr('max', options[_item].max)

        drawable.on('input', function() {
            let val = drawable.val()
            if (val > options[_item].max) val = options[_item].max;
            if (val < options[_item].min) val = options[_item].min;

            clothingData.face[_item].current = val
            drawable.val(val)
            range.val(drawable.val());
            $.post(`http://${GetParentResourceName()}/Face.Change`, JSON.stringify({
                clothing: _item,
                drawable: range.val(),
                data: options[_item].data
            }));
        })

        slider.append(range)
        slider.append(`
            <p id = "clothing_name">${featureNames[_item]}</p>
            <p id = "clothing_drawable">Drawable</p>
        `)

        slider.append(drawable)

        range.on('input', function() {
            drawable.val(range.val())
            clothingData.face[_item].current = range.val()
            $.post(`http://${GetParentResourceName()}/Face.Change`, JSON.stringify({
                clothing: _item,
                drawable: range.val(),
                data: options[_item].data
            }));
        })

        drawable.val(range.val())
        $('#clothing_container').append(slider)
    }
}

function BlendPage(options) {
    let _texture = 0;
    for (var item in options) {
        let _item = item
        if (!options[item]) continue;


        let range = $(document.createElement('input'))
        range.attr('type', 'range')
        range.attr('id', 'clothing_slider_bar')
        range.attr('min', options[_item].min)
        range.attr('max', options[_item].max)
        range.val(options[_item].current)
        range.attr('step', (options[_item].step || 1))


        let slider = $(document.createElement('div')).attr('id', 'clothing_slider')
        let drawable = $(document.createElement('input'))
        drawable.attr('type', 'number')
        drawable.attr('id', 'clothing_drawable_input')
        drawable.attr('min', options[_item].min)
        drawable.attr('max', options[_item].max)

        drawable.on('input', function() {
            let val = drawable.val()
            if (val > options[_item].max) val = options[_item].max;
            if (val < options[_item].min) val = options[_item].min;
            clothingData.blend[_item].current = val
            drawable.val(val)
            range.val(drawable.val());
            $.post(`http://${GetParentResourceName()}/Blend.Change`, JSON.stringify({
                clothing: options[_item].id,
                drawable: range.val(),
                step: options[_item].step
            }));
        })

        slider.append(range)
        slider.append(`
            <p id = "clothing_name">${options[_item].name}</p>
            <p id = "clothing_drawable">Drawable</p>
        `)

        slider.append(drawable)

        range.on('input', function() {
            drawable.val(range.val())
            clothingData.blend[_item].current = range.val()
            $.post(`http://${GetParentResourceName()}/Blend.Change`, JSON.stringify({
                clothing: options[_item].id,
                drawable: range.val(),
                step: options[_item].step
            }));
        })

        drawable.val(range.val())
        $('#clothing_container').append(slider)
    }
}

function OverlayPage(options) {
    let _texture = 0;
    for (var item in options) {
        let _item = item
        if (!options[item]) continue;
        if(_item < 2) continue;

        let range = $(document.createElement('input'))
        range.attr('type', 'range')
        range.attr('id', 'clothing_slider_bar')
        range.attr('min', options[_item].min)
        range.attr('max', options[_item].max)
        range.val(round(options[_item].current, 1))
        range.attr('step', (options[_item].step || 1))

        let slider = $(document.createElement('div')).attr('id', 'clothing_slider')
        let drawable = $(document.createElement('input'))
        drawable.attr('type', 'number')
        drawable.attr('id', 'clothing_drawable_input')
        drawable.attr('min', options[_item].min)
        drawable.attr('max', options[_item].max)

        drawable.on('input', function() {
            let val = drawable.val()
            if (val > options[_item].max) val = options[_item].max;
            if (val < options[_item].min) val = options[_item].min;
            clothingData.overlay[_item].current = val
            drawable.val(val)
            range.val(drawable.val());
            $.post(`http://${GetParentResourceName()}/Overlay.Change`, JSON.stringify({
                clothing: _item,
                drawable: range.val(),
                data: options[_item]
            }));
        })

        slider.append(range)
        slider.append(`
            <p id = "clothing_name">${(overlayNames[options[_item].id]) || options[_item].display} ${(options[_item].name || '')}</p>
            <p id = "clothing_drawable">Drawable</p>
        `)

        slider.append(drawable)

        range.on('input', function() {
            drawable.val(range.val())
            clothingData.overlay[_item].current = range.val()
            $.post(`http://${GetParentResourceName()}/Overlay.Change`, JSON.stringify({
                clothing: _item,
                drawable: range.val(),
                data: options[_item]
            }));
        })

        drawable.val(range.val())
        $('#clothing_container').append(slider)
    }
}

function Outfits() {
    for (var item in outfits) {
        let _item = item
        let clothing = JSON.parse(outfits[_item].clothing)
        let container = $(document.createElement('div')).attr('class', 'clothing_outfit')

        container.html(`
            <p id = "clothing_outfit_name">${clothing.Name}</p>
        `)

        let load = $(document.createElement('button')).attr('id', 'clothing_outfit_load').html('Load Outfit')
        load.click(() => {
            $.post(`http://${GetParentResourceName()}/Clothing.LoadOutfit`, JSON.stringify({
                clothing: JSON.parse(outfits[_item].clothing),
            }));
        })

        let save = $(document.createElement('button')).attr('id', 'clothing_outfit_save').html('Save Outfit')
        save.click(() => {
            $.post(`http://${GetParentResourceName()}/Clothing.SaveOutfit`, JSON.stringify({
                name: clothing.Name
            }));
        })

        container.append(load)
        container.append(save)

        container.append(`
            <img src = "nui://geo-es/html/img/x.png" class = "outfit_delete" title = "Delete Outfit">
        `)

        container.find('.outfit_delete').click(async function() {
            if (await Confirm('Would you like to Delete this outfit?')) {
                outfits = await Get('DeleteOutfit', {
                    outfit: outfits[_item].outfit
                });
                $('#clothing_container').html('')
                Outfits();
            }
        })

        $('.outfit_delete').tooltip({
            tooltipClass: "tooltip2"
        })

        $('#clothing_container').append(container)
    }

    $('#clothing_container').append(`
        <div class = "clothing_outfit">
            <button id = "outfit_new">New Outfit</button>
        </div>
    `)

    $('#clothing_container').append(`
        <div class = "clothing_outfit">
            <button id = "outfit_bag">Bag Current Clothes $1,000</button>
        </div>
    `)

    $('#outfit_new').click(async function() {
        outfits = await Get('CreateOutift');
        $('#clothing_container').html('')
        Outfits();
    })

    $('#outfit_bag').click(async function() {
        outfits = await Get('BagOutfit');
    })
}

$('body').mousedown(function() {
    /* if (interFaceOpen === 'Clothing' && currentHover === undefined) {
        $.post(`http://${GetParentResourceName()}/Clothing.Camera`)
    } */
});

function round(value, decimals) {
    return Number(Math.round(value + 'e' + decimals) + 'e-' + decimals);
}

function ClothesClose() {
    $('#clothing').animate({ opacity: '0.0' }, 500, () => {
        $('#clothing').css('display', 'none')
    })
    $.post(`http://${GetParentResourceName()}/Clothing.Done`)
}