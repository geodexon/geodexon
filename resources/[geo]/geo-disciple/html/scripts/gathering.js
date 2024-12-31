let Gathering = {}
interfaceOpen = null;
let gatheringLog

$(function() {
    let elem = CreateWindow('Gathering', 'Gathering')
    elem.append(` 
    <br> <br>
    <div class = "gathering_container">
    </div>`)

    elem.find('.img').click(function() {
        CloseMenu()
    })
})

window.addEventListener('message', (event) => {
    let data = event.data;
    if (data.type == 'Gathering') {
        gatheringLog = data.gatheringLog
        Gathering = data.items
    }
    switch (data.interface) {
        case 'Gather':
            Gather(data.data);
            break;
        case 'UpdateNode':
            UpdateNode(data.data);
            break;
    }
})

document.onkeydown = function(e) {
    switch (e.keyCode) {
        case 9:
            if (interfaceOpen) {
                CloseMenu()
            }
            break;
    }
}

function CloseMenu() {

    if ($('.crafting_window').length > 0) {
        return;
    }

    $('.Gathering')
        .css('pointer-events', 'none')
        .css('opacity', '0.0')
    $('#crafting')
        .css('pointer-events', 'none')
        .css('opacity', '0.0')
    $('#repair')
        .css('pointer-events', 'none')
        .css('opacity', '0.0')
    interfaceOpen = null;
    window.dispatchEvent( new Event('done') );
    Get('CloseMenu');
}

let canGather = true;
function Gather(data) {
    interfaceOpen = 'Gathering'
    UISound('open')
    CreateWindow('Gathering', 'Gathering')
    let elem = $('.gathering_container').html('')
    for (var item in data.Items) {
        if (data.Items[item]) {
            elem.append(`
                <div class = "gathering_item" item = ${item} skill = "${Gathering[data.Items[item]].Skill}" type = ${Gathering[data.Items[item]]["Main Hand"]}>
                    <div class = "gathering_item_image">
                        <img src = "nui://geo-inventory/html/img/${data.Items[item]}.png">
                    </div>

                    <p class = "gathering_item_name">${gatheringLog[data.Items[item]] ? Gathering[data.Items[item]].Name : "???"}</p>
                    <p class = "gathering_item_level">Lv. ${Gathering[data.Items[item]].MinLevel}</p>
                    <p class = "gathering_item_chance">${data.Chances[item]}%   /   ${data.HQChance[item]}%</p>
                </div>
            `)
        } else {
            elem.append(`
                <div class = "gathering_item">
                    <div class = "gathering_item_image">
                    </div>
                </div>
            `)
        }
    }

    elem.append(`
        <br><br><br><br><br>
        <div class = "gathering_quick_container">
            <input type="checkbox" class="gathering_quick" name="default" value="default">
            <label for="gathering_quick" class="gathering_quick_text">Quick Gather</label><br>
        </div>
        
        <div class = "gathering_node_health" style = "width: ${(data.Health * 0.9)+'%'};background-color:${perc2color(data.Health)};"></div>
    
        <div class="meter">
            <span style="width: 100%"></span>
        </div>
    `)

    $('.gathering_quick_container').click(function() {
        let option = $(this).find('.gathering_quick').prop('checked')
        $(this).find('.gathering_quick').prop('checked', !option)
    })

    $('.gathering_quick').click(function() {
        let option = $(this).prop('checked')
        $(this).prop('checked', !option)
    })

    $('.gathering_item').click(async function() {
        if ($(this).attr('item') == null) return;
        if (canGather) {
            canGather = false;
            setTimeout(() => {
                canGather = true;
            }, 1000);
        } else {
            return;
        }

        if ($('.gathering_quick').prop('checked')) {
            $('.gathering_quick').css('display', 'none')
            $('.gathering_quick_text').css('display', 'none')
            $('.gathering_node_health').css('display', 'none')
            $('.meter').css('display', 'inline')
        }

        let val = await Get('Gathering.Harvest', {
            item: $(this).attr('item'),
            skill: $(this).attr('skill'),
            quick: $('.gathering_quick').prop('checked'),
            mainHand: $(this).attr('type')
        })

        gatheringLog = val.log

        if (val.data) {
            $('.gathering_node_health').css('width', (val.data.Health * 0.9)+'%').css('background-color', perc2color(val.data.Health))
        
            $('.gathering_item').each(function() {
                $(this).find('.gathering_item_name').html(gatheringLog[data.Items[$(this).attr('item')]] ? Gathering[data.Items[$(this).attr('item')]].Name : "???")
            }) 
        } else {
            $('.gathering_node_health').css('width', '0%').css('background-color', perc2color(0))
            setTimeout(() => {
                CloseMenu()                
            }, 500);
        }
    })

    $('.Gathering')
        .css('pointer-events', 'all')
        .css('opacity', '1.0')

}

function UpdateNode(data) {
    if (data) {
        $('.gathering_node_health').css('width', (data.Health * 0.9)+'%').css('background-color', perc2color(data.Health))
        $('.gathering_item').each(function() {
            $(this).find('.gathering_item_name').html(gatheringLog[data.Items[$(this).attr('item')]] ? Gathering[data.Items[$(this).attr('item')]].Name : "???")
        }) 
    } else {
        $('.gathering_node_health').css('width', '0%').css('background-color', perc2color(0))
        setTimeout(() => {
            CloseMenu()                
        }, 500);
    }
}

function perc2color(perc) {
	var r, g, b = 0;
	if(perc < 50) {
		r = 255;
		g = Math.round(5.1 * perc);
	}
	else {
		g = 255;
		r = Math.round(510 - 5.10 * perc);
	}
	var h = r * 0x10000 + g * 0x100 + b * 0x1;
	return '#' + ('000000' + h.toString(16)).slice(-6);
}