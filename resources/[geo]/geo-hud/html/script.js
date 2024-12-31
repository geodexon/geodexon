let objList = [];
$(function() {
    objList.health = $('.container').find('#health').parent().find('.clr')
    objList.armor = $('.container').find('#armor').parent().find('.clr')
    objList.weight = $('.container').find('#weight').parent().find('.clr')
    objList.hunger = $('.container').find('#hunger').parent().find('.clr')
    objList.thirst = $('.container').find('#thirst').parent().find('.clr')
    objList.stamina = $('.container').find('#stamina').parent().find('.clr')
    objList.nos = $('.container').find('#nos').parent().find('.clr')
    objList.fuel = $('.container').find('#fuel').parent().find('.clr')

    for (var item in objList) {
        objList[item].html(`
            <div class="barOverflow">
                <div class="bar"></div>
            </div>
            <span>10</span>
        `)
    }

   /*  $(".clr").each(function(){
        var $bar = $(this).find(".bar");
        var $val = $(this).find("span");
        var perc = parseInt( $val.text(), 10);
       
        $({p:0}).animate({p:perc}, {
          duration: 3000,
          easing: "swing",
          step: function(p) {
            $bar.css({
              transform: "rotate("+ (45+(p*1.8)) +"deg)", // 100%=180° so: ° = % * 1.8
              // 45 is to add the needed rotation to have the green borders at the bottom
            });
            $val.text(p|0);
          }
        });
      });  */

    objList.health.find('.bar').css('border-bottom-color', 'rgb(26, 122, 31)').css('border-right-color', 'rgb(26, 122, 31)')
    objList.armor.find('.bar').css('border-bottom-color', 'rgb(54, 89, 204)').css('border-right-color', 'rgb(54, 89, 204)')
    objList.weight.find('.bar').css('border-bottom-color', 'rgb(194, 194, 16)').css('border-right-color', 'rgb(194, 194, 16)')
    objList.hunger.find('.bar').css('border-bottom-color', 'rgb(10, 136, 17)').css('border-right-color', 'rgb(10, 136, 17)')
    objList.thirst.find('.bar').css('border-bottom-color', 'rgb(9, 138, 170)').css('border-right-color', 'rgb(9, 138, 170)')
    objList.stamina.find('.bar').css('border-bottom-color', '#75c1ff').css('border-right-color', '#75c1ff')
    objList.nos.find('.bar').css('border-bottom-color', 'rgb(54, 89, 204)').css('border-right-color', 'rgb(54, 89, 204)')
    objList.fuel = $('.container').find('#fuel').parent().find('.clr')
})

window.addEventListener('message', function (event) {
    let vals = event.data
    switch (event.data.type) {
        case 'baropac':
            $('#plyrHud').css('opacity', event.data.amount)
            $('#txt').css('display', event.data.amount == 0 ? 'none' : 'inline')
            break;
        case 'hud:update':
            for (const key in vals) {
                UpdateBar(key, vals[key])
            }
            break;
        case 'hud:speed':
            $('#speed').html(event.data.val);
            if (event.data.gps) {
                $('#speed').css('top', '87%');
                $('#mph').css('top', '91%');
            } else {
                $('#speed').css('top', '79%');
                $('#mph').css('top', '83%');
            }
            break;
        case 'hud:location':
            $('#location').html(event.data.val);
            $('#location2').html(event.data.val);
            if (event.data.gps) {
                $('#location').css('opacity', '0.0')
                $('#location2').css('opacity', '1.0')
            } else {
                $('#location').css('opacity', '1.0')
                $('#location2').css('opacity', '0.0')
            }
            break;
        case 'hud:time':
            $('#time').html(event.data.val);
            break;
        case 'textHUD':
            $('#txt').css('opacity', event.data.val);
            $('#txtBar').css('opacity', event.data.val);
            $('#rect').css('opacity', event.data.val)
            $('.lock').css('opacity', event.data.val)
            $('.belt').css('opacity', event.data.val)
            break;
        case "hud:locked":
            if (event.data.val) {
                $('#lock').css('color', 'rgb(138, 235, 134)')
            } else {
                $('#lock').css('color', 'rgb(255, 146, 146)')
            }
            break;
        case "hud:belt":
            if (event.data.val) {
                $('#belt').css('color', 'rgb(138, 235, 134)')
            } else {
                $('#belt').css('color', 'rgb(255, 146, 146)')
            }
            break;
        case 'hud:rect':
            $('#rect').css('left', event.data.data[0] + 'px')
            $('#rect').css('top', event.data.data[1] + 'px')
            break;
        case 'RemoveFuelBar':
            objList.fuel.parent().css('display', 'none')
            objList.nos.parent().css('display', 'none')
            break;
    }
});

let status = []
function UpdateBar(bar, width) {
    if (objList[bar]) {
        let obj = objList[bar].parent()
        status[bar] = width
        if (DoHide(bar, width)) {
            obj.css('display', 'none')
        } else {
            obj.css('display', 'inline-block')
        }

        if (bar == 'fuel') {
            if (width < 15) {
                objList['fuel'].find('.bar').css('border-bottom-color', 'rgb(255, 0, 0)').css('border-right-color', 'rgb(255, 0, 0)')
            } else {
                objList['fuel'].find('.bar').css('border-bottom-color', 'rgb(206, 122, 25)').css('border-right-color', 'rgb(206, 122, 25)')
            }
        }

        objList[bar].css('width', width + '%');
        objList[bar].find('span').text(width);

        var $bar = objList[bar].find(".bar");
        var $val = objList[bar].find("span");
        var perc = parseInt( $val.text(), 10);
        
        $bar.css({
            transform: "rotate("+ (45+(perc*1.8)) +"deg)", // 100%=180° so: ° = % * 1.8
        });

    }
}

function DoHide(bar, width) {
    let hide = false;

    if (width === 100 || width <= 0) {
        hide = true
    }
    
    if (bar === 'armor' && width > 0) {
        hide = false
    }

    if (bar == 'nos' && width > 0) {
        hide = false
    }

    return hide
}

function CreateHudObject(elemName, bgcolor) {
    let thisElem = $('#plyrHud').append(`
        <div class = "container" >
            <div id = "clr"></div>
            <div id = "${elemName}" >
            </div>
        </div>
    `)

    thisElem = $('.container').find(`#${elemName}`).parent()
    thisElem.find(`#${elemName}`).css('position', 'relative')
    thisElem.find(`#${elemName}`).css('width', '100%')
    thisElem.find(`#${elemName}`).css('content', `url('pics/${elemName}.png')`)

    thisElem = thisElem.find('#clr')
    thisElem.css('background-color', (bgcolor || 'rgb(255, 255, 255'))
    thisElem.killme = function() {
        thisElem.parent().remove();
        objList[elemName] = null;
    }

    objList[elemName] = thisElem
}