let inventoryOpen = false;
let items = [];
let descr = [];
let Slots = [];
let inventory = [];
let otherInv = [];
let Sizes = [];
let Whitelists = {}
let revealed = {}
let beingDragged;
let currentHover;
let cache;
let otherID;
let myMax = 0;
let otherMax = 0;
let otherName;
let cacheNum = 0;
let ctrPressed = false;
let duty;
let otherWeight;
let otherRealName;
let cid;
let opening = false;
invs = {}
user = {}

let cNum = 1

let equipSlots = ["Armor", "Main Hand", "Off Hand"]

$(document).ready(function() {
    $("#hud").mouseup(function() {
        //MoveItems();
        $('.menu').css('display', 'none');
    });

    $("#use").mouseup(function() {
        if (beingDragged) {
            $.post("https://geo-inventory/Use", JSON.stringify({
                origin: `plyr${beingDragged.attr('Item')}`,
            }));
            beingDragged = null;
            currentHover = null;
        }
    });

    for (var item of equipSlots) {
        $('#Player_equipment').append(`
            <div class = "Equipment-Container" slot = "${item}">
                <div class = "Equipment-Item">
                </div>
                <p class = "Equipment-Title">Slot: ${item}</p>
                <p class = "Equipment-Title">Fill: Empty</p>
            </div>
        `)
    }

    $(".targetinv").each(function() {
        $(this).find('.img').click()
    })

    invs = {}

   /*  let window2 = CreateWindow('Other', 'Other')
    window2.append('<div id = "Other"></div>') */

    $('.inv_menu_item').tooltip({
        tooltipClass: "tooltip"
    }).click(function() {
        let title = $(this).attr('name')
        $('#Player').css('pointer-events', title == 'Inventory' ? 'all' : 'none')
            .css('opacity', title == 'Inventory' ? '1.0' : '0.0')

        $('#Player_equipment').css('pointer-events', title == 'Inventory' ? 'none' : 'all')
            .css('opacity', title == 'Inventory' ? '0.0' : '1.0')
    })
});

document.onkeydown = function(e) {
    if (inventoryOpen) {
        switch (e.keyCode) {
            case 9:
                CloseMenu()
                break;
            case 16:
                let thisnum = $('#amount').val();

                if (thisnum != 0) {
                    cacheNum = thisnum;
                    cNum = 0
                    $('#amount').val(0)
                } else {
                    $('#amount').val(cacheNum)
                    cNum = cacheNum
                    cacheNum = 0
                }
                break;
            case 17:
                if (!ctrPressed) {
                    ctrPressed = true;
                }
                break;
        }
    }
}

document.onkeyup = function(e) {
    if (inventoryOpen) {
        switch (e.keyCode) {
            case 17:
                if (ctrPressed) {
                    ctrPressed = false;;
                }
                break;
        }
    }
}

let date
window, addEventListener("message", function(event) {
    let dataset = event.data
    switch (dataset.type) {
        case 'updateList':
            items = dataset.list;
            descr = dataset.desc;
            Slots = dataset.slots;
            Sizes = dataset.Sizes
            Whitelists = dataset.Whitelists
            break;
        case 'inventoryUpdate':
            date = new Date().getTime()
            cid = dataset.cid
            if (dataset.othersize) otherWeight = dataset.othersize
            UpdateInventory(dataset.invType, dataset.inventory, dataset.id, dataset.max, dataset.name, dataset.realname, dataset.open)
            break;
        case 'inventoryUI':
            duty = dataset.Duty
            otherData = dataset.data
            if (dataset.open) {
                $('.Player').fadeIn(0)
                ctrPressed = false;
                setTimeout(() => {
                    inventoryOpen = true;
                    interFaceOpen = 'uicursor'
                    $('.buttonrow').css('bottom', '2vh')
                    $('.buttonrow').css('pointer-events', 'all')
                    known = dataset.known
                    helpOpen = true
                    user = dataset.user
                }, 0);
                $('#hud').css('opacity', '1.0')
            } else {
                inventoryOpen = false;
                $('#hud').css('opacity', '0.0')
            }
            break;
        case 'UpdateAmount':
            UpdateAmount(dataset.Key, dataset.Amount);
            break;
        case 'txt':
            let elem = $(document.createElement('p')).attr('id', 'textNotif');
            elem.html(dataset.val);
            $('#textUpdates').append(elem);
            $('#textUpdates').scrollTop($('#textUpdates')[0].scrollHeight);
            break;
        case 'InventoryDisplay':
            DisplayInventory(dataset.open);
            break;
        case 'GetDurability':
            let val = GetDurability(dataset.item)
            Get('GetDurability', {
                val: val,
                id: dataset.id
            })
    }
})

function CloseMenu() {
    $('.description').remove()
    $.post("https://geo-inventory/Focus", JSON.stringify({}));
    $('.menu').css('display', 'none');

    $(".targetinv").each(function() {
        $(this).find('.img').click()
    })
    $('.Player').remove()

    window.dispatchEvent( new Event('done') );
    invs = {}
    revealed = {};
}

function UpdateInventory(who, inv, invType, max, name, realname, doOpen) {
    if (who == 'Player') {
        inventory = inv
        let match = JSON.stringify(inv) == JSON.stringify(invs['Player_undefined'])
        invs['Player_undefined'] = inv
        if (max) {
            myMax = max
        }

        DoEquipment(invType, inv)

        //if (!match) {
            FillInventory('Player', invType, inventory, 'Player')
    
            $('#player_capcity').html(GetWeight(inv, Slots['Player']) / 100 + ' / ' + Sizes['Player'] / 100)
        //}
    } else {
        otherInv = inv
        otherID = invType
        let match = JSON.stringify(inv) == JSON.stringify(invs[`${invType}_${realname}`])
        invs[`${invType}_${realname}`] = inv


        if (!revealed[String(realname.hashCode())]) {
            revealed[String(realname.hashCode())] = {};
        }

        if (max) {
            otherMax = max
        }

        if (name) {
            otherName = name
            otherRealName = realname
        }
        
        if (doOpen == false) return;
        FillInventory('Other', invType, otherInv, realname, name)

       /*  var bottom = $('#Other').offset().top + $('#Other').outerHeight()
        $('#other_capcity').css('top', `calc(${bottom + 'px'} + 1.5vh)`)
        $('#other_capcity').find('.capacity').css('width', (((GetWeight(inv, Slots[otherID])) / otherWeight) * 100) + '%')
        $('#other_capcity').find('.capacity-percent').html(GetWeight(inv, Slots[otherID]) / 100 + ' / ' + otherWeight / 100) */
    
        $(`.${(String(realname.hashCode()))}weight`).html(GetWeight(inv, Slots[invType]) / 100 + ' / ' + Sizes[invType] / 100)
    }

    $('.Item-Container').droppable({
        drop: function() {
            MoveItems();
        },
    })

    $('.Item-Container').hover(function() {
        if (beingDragged && currentHover) {
            if (!ItemAllowed(currentHover.parent().parent().attr('invtype'), invs[`${beingDragged.attr('invtype')}_${beingDragged.attr('invname')}`][beingDragged.attr('Item')], inv)) {
                $(this).addClass('ui-state-hover-bad')
            }
        }
    }, function() {
        $(this).removeClass('ui-state-hover-bad')
    })
}

async function RefreshInv(str) {
    for (var item in invs) {
        if (str && item != str) continue;
        let list = item.split('_')
        if (item == 'Player_undefined') {
            FillInventory('Player', 'Player', invs[item], 'Player')
        } else {
            FillInventory('Other', list[0], invs[item], list[1])
        }
    }

    $(`#Player`).find('.Item-Container').hover(function() {
        if (beingDragged && currentHover) {
            let startType = beingDragged.attr('invtype')
            let startinvID = beingDragged.attr('invname')
            let startString = `${startType}_${startinvID}`
            let endType = currentHover.parent().parent().attr('invtype')
            let endinvID = currentHover.parent().parent().attr('invname')
            let endString = `${endType}_${endinvID}`
            if (!ItemAllowed(currentHover.parent().parent().attr('invtype'), invs[startString][beingDragged.attr('Item')], invs[endString])) {
                $(this).addClass('ui-state-hover-bad')
            }
        }
    }, function() {
        $(this).removeClass('ui-state-hover-bad')
    })


    $(`.oinv`).each(function() {
        $(this).find('.Item-Container').hover(function() {
            if (beingDragged && currentHover) {
                let startType = beingDragged.attr('invtype')
                let startinvID = beingDragged.attr('invname')
                let startString = `${startType}_${startinvID}`
                let endType = currentHover.parent().parent().attr('invtype')
                let endinvID = currentHover.parent().parent().attr('invname')
                let endString = `${endType}_${endinvID}`
                let str = $(this).parent().attr('invtype')+'_'+$(this).parent().attr('invname')
                if (!ItemAllowed(currentHover.parent().parent().attr('invtype'), invs[startString][beingDragged.attr('Item')], invs[endString])) {
                    $(this).addClass('ui-state-hover-bad')
                }
            }
        }, function() {
            $(this).removeClass('ui-state-hover-bad')
        })
    })

    beingDragged = null;
    currentHover = null;
}

function MoveItems(pElem) {
    if (pElem) currentHover = pElem;

    if (!beingDragged) {
        RefreshInv()
        return;
    }

    let startType = beingDragged.attr('invtype')
    let startinvID = beingDragged.attr('invname')
    let startString = `${startType}_${startinvID}`


    if (!currentHover) {
        RefreshInv(startString)
        return;
    }

    if (currentHover != null && beingDragged != null) {
        let startID = beingDragged.attr('Item')
        let endID = currentHover.attr('Item')
        let num = Number($('#amount').val());
        num = Math.floor(num)
        let allowed = false;

       
        let endType = currentHover.parent().parent().attr('invtype')
        let endinvID = currentHover.parent().parent().attr('invname')
        let endString = `${endType}_${endinvID}`

        let startInv = invs[`${startType}_${startinvID}`]
        let endInv = invs[`${endType}_${endinvID}`]

        if (!endInv) {
            RefreshInv(startString);
            return;
        }

        let str1 = beingDragged.attr('Inventory') == 'Player' ? 'plyr' : 'othr'
        let str2 = currentHover.attr('Inventory') == 'Player' ? 'plyr' : 'othr'

        if (!startInv[startID]) return;

        if ((num == 0 || (num > startInv[startID].Amount)) && otherID != 'StoreUI') {
            num = Number(beingDragged.attr('Amount'))
        }

        let thisMax = otherMax;

        if (str1 == 'othr') {
            slotCount = Slots['Player']
            thisMax = myMax;
        }

        if (otherID == 'Credit') {
            if (ctrPressed && str1 == 'plyr') return;
            if (str2 == 'othr') {
                RefreshInv(startString)
                return;
            }
        }

       /*  if (ctrPressed) {

            if ((otherID == 'StoreUI') && str1 == 'plyr') return;

            if (startInv[startID] == null) {
                return;
            }

            num = num == 0 ? startInv[startID].Amount : num
            let slotCount = str1 == 'plyr' ? Slots[otherID] : Slots['Player']

            if (str1 == 'othr' && otherID == 'Player') {
                if (items[startInv[startID].Key].Soulbound) {
                    beingDragged = null
                    currentHover = null;
                    RefreshInv()
                    return;
                } 
            }

            if (CanFit(endInv, Slots[str1 == 'plyr' ? otherID : 'Player'], startInv[startID].Key, num, endInv, str2, true)) {
                let toAdd = num;
                let slotID = 0;

                for (let index = 1; index < slotCount + 1; index++) {

                    if (toAdd == 0) break;

                    if (!startInv[startID] || !endInv[index]) continue;
                    let cl = clone(startInv[startID])
                    if (endInv[index].ID == startInv[startID].ID && endInv[index].Amount < GetMax(startInv[startID].Key)) {
                        let math = GetMax(startInv[startID].ID) - endInv[index].Amount
                        if (math >= toAdd) {
                            cl.Amount = toAdd + endInv[index].Amount
                            endInv[index] = cl
                            startInv[startID].Amount -= toAdd
                            if (startInv[startID].Amount <= 0) {
                                startInv[startID] = null;
                            }
                            toAdd = 0;
                            slotID = index
                        } else {
                            cl.Amount = math + endInv[index].Amount
                            endInv[index] = cl
                            startInv[startID].Amount -= toAdd
                            if (startInv[startID].Amount <= 0) {
                                startInv[startID] = null;
                            }
                            toAdd -= math
                            slotID = index
                        }
                    }
                }


                for (let index = 1; index < slotCount + 1; index++) {

                    if (toAdd == 0) break;

                    if (!startInv[startID]) continue;
                    let cl = clone(startInv[startID])
                    if (endInv[index] == null) {
                        if (toAdd <= GetMax(startInv[startID].Key)) {
                            cl.Amount = toAdd
                            endInv[index] = cl
                            startInv[startID].Amount -= toAdd
                            if (startInv[startID].Amount <= 0) {
                                startInv[startID] = null;
                            }
                            toAdd -= toAdd;
                            slotID = index
                        } else {
                            cl.Amount = toAdd
                            endInv[index] = cl
                            startInv[startID].Amount -= toAdd
                            if (startInv[startID].Amount <= 0) {
                                startInv[startID] = null;
                            }
                            toAdd -= GetMax(startInv[startID].Key)
                            slotID = index
                        }
                    } else {
                        if (endInv[index].ID == startInv[startID].ID && endInv[index].Amount < GetMax(startInv[startID].Key)) {
                            let math = GetMax(startInv[startID].ID) - endInv[index].Amount
                            if (math >= toAdd) {
                                cl.Amount = toAdd + endInv[index].Amount
                                endInv[index] = cl
                                startInv[startID].Amount -= toAdd
                                if (startInv[startID].Amount <= 0) {
                                    startInv[startID] = null;
                                }
                                toAdd = 0;
                                slotID = index
                            } else {
                                cl.Amount = math + endInv[index].Amount
                                endInv[index] = cl
                                startInv[startID].Amount -= toAdd
                                if (startInv[startID].Amount <= 0) {
                                    startInv[startID] = null;
                                }
                                toAdd -= math
                                slotID = index
                            }
                        }
                    }
                }

                if (otherID != 'StoreUI') {
                    $.post("https://geo-inventory/Transfer2", JSON.stringify({
                        target: `${str2}${endID}`,
                        amount: num,
                        startType: startType,
                        startinvID: startinvID,
                        endType: endType,
                        endinvID: endinvID
                    }));
                } else {
                    $.post("https://geo-inventory/Transfer", JSON.stringify({
                        origin: `${str1}${startID}`,
                        target: `plyr${slotID}`,
                        amount: num,
                        startType: startType,
                        startinvID: startinvID,
                        endType: endType,
                        endinvID: endinvID
                    }));
                }
            }

            beingDragged = null
            currentHover = null;
            RefreshInv()
            return;
        } */

        if (`${startString}${startID}` == `${endString}${endID}`) {
            return;
        }

        if (!ItemAllowed(endType, startInv[beingDragged.attr('Item')], endInv)) {
            RefreshInv(startString)
            return;
        }
       
        if (items[startInv[startID].Key].size) {
            if (9 - (endID % 8) < items[startInv[startID].Key].size[0] || (Number(endID) % 8) == 0) {
                RefreshInv(startString)
                return;
            }

            if (Slots[endType] < Number(endID) + ( (8 * items[startInv[startID].Key].size[1]) - 8 )) {
                RefreshInv(startString)
                return;
            }
            
            for (let heightIndex = 1; heightIndex <= items[startInv[startID].Key].size[1]; heightIndex++) {
                for (let pIndex = 1; pIndex <= items[startInv[startID].Key].size[0]; pIndex++) {
                    if (pIndex == 1 && heightIndex == 1) continue
                    let num = (heightIndex * 8) + pIndex - 8 - 1
                    if (endInv[Number(endID) + num] && endInv[Number(endID) + num].ID != startInv[startID].ID) {
                        RefreshInv(startString)
                        return;
                    }

                    if (endInv[endID] && endInv[Number(endID) + num]) {
                        RefreshInv(startString)
                        return;
                    }
                }
            }
        } 

        if (endInv[endID] && items[endInv[endID].Key].size) {
            if (9 - (startID % 8) < items[endInv[endID].Key].size[0] || (Number(startID) % 8) == 0) {
                RefreshInv(startString)
                return;
            }

            if (Slots[endType] < Number(startID) + ( (8 * items[endInv[endID].Key].size[1]) - 8 )) {
                RefreshInv(startString)
                return;
            }

            for (let heightIndex = 1; heightIndex <= items[endInv[endID].Key].size[1]; heightIndex++) {
                for (let pIndex = 1; pIndex <= items[endInv[endID].Key].size[0]; pIndex++) {
                    if (pIndex == 1 && heightIndex == 1) continue
                    let num = (heightIndex * 8) + pIndex - 8 - 1
                    if (endInv[Number(startID) + num] && endInv[Number(startID) + num].ID != startInv[startID].ID) {
                        RefreshInv(startString)
                        return;
                    }

                    if (endInv[endID] && endInv[Number(endID) + num]) {
                        RefreshInv(startString)
                        return;
                    }
                }
            }
        } 

        let skip = false;
        if (otherID == 'StoreUI') {
            if (str1 == 'othr' && str2 == 'plyr') {
                if (inventory[endID] == null) {
                    let origin = clone(startInv[startID]);
                    inventory[endID] = origin
                    inventory[endID].Amount = num
                    allowed = true;
                    skip = true;
                } else {
                    if (inventory[endID].ID == startInv[startID].ID) {
                        inventory[endID].Amount += num;
                        allowed = true;
                        skip = true;
                    }
                }
            }
        }

        if (!skip) {
            if ((beingDragged.attr('Inventory') == 'Other' && otherID == 'Player') && currentHover.attr('Inventory') == 'Player') {
                if (items[startInv[startID].Key].Soulbound) {
                    beingDragged = null
                    currentHover = null;
                    RefreshInv(startString)
                    return;
                } 
            }

            if (otherID == 'StoreUI' && (str1 != 'plyr' || str2 != 'plyr')) {
                beingDragged = null
                currentHover = null;
                RefreshInv(startString)
                return;
            }

            if (`${startType}_${startinvID}` == `${endType}_${endinvID}`) {
                if (startInv[endID] == null) {
                    let origin = clone(startInv[startID]);
                    if (startInv[startID].Amount - num >= 0) {
                        startInv[startID].Amount -= num;
                        startInv[endID] = origin
                        startInv[endID].Amount = num
                        allowed = true;
                    }

                    if (startInv[startID].Data.Life) {
                        let count = startInv[startID].Data.Life.length - num - 1
                        for (let index = startInv[startID].Data.Life.length - 1; index > count; index--) {
                            startInv[startID].Data.Life.pop()
                        }
                    }

                    if (startInv[startID].Amount == 0) {
                        startInv[startID] = null;
                    }
                } else {
                    if (startInv[startID].ID == startInv[endID].ID && (startInv[endID].Amount + num <= GetMax(startInv[endID].Key))) {
                        if (startInv[startID].Amount - num >= 0) {
                            startInv[startID].Amount -= num;
                            startInv[endID].Amount += num
                            allowed = true;
                        }

                        if (startInv[startID].Data.Life) {
                            startInv[endID].Data.Life.push(startInv[startID].Data.Life[startInv[startID].Data.Life.length - 1])
                            startInv[startID].Data.Life.pop()
                        }

                        if (startInv[startID].Amount == 0) {
                            startInv[startID] = null;
                        }
                    } else {
                        let origin = clone(startInv[startID]);
                        let othr = clone(startInv[endID])

                        startInv[startID] = othr;
                        startInv[endID] = origin;
                        allowed = true;
                    }
                }
            } else {
                if (CanFit(endInv, Slots[str1 == 'plyr' ? otherID : 'Player'], startInv[startID].Key, num, endInv, str2)) {
                    if (endInv[endID] == null) {
                        let origin = clone(startInv[startID]);
                        if (startInv[startID].Amount - num >= 0) {
                            startInv[startID].Amount -= num;
                            endInv[endID] = origin
                            endInv[endID].Amount = num
                            allowed = true;
                        }

                        if (startInv[startID].Data.Life) {
                            let count = startInv[startID].Data.Life.length - num - 1
                            for (let index = startInv[startID].Data.Life.length - 1; index > count; index--) {
                                startInv[startID].Data.Life.pop()
                            }
                        }

                        if (startInv[startID].Amount == 0) {
                            startInv[startID] = null;
                        }
                    } else {
                        if (startInv[startID].ID == endInv[endID].ID && (endInv[endID].Amount + num <= GetMax(endInv[endID].Key))) {
                            if (startInv[startID].Amount - num >= 0) {
                                startInv[startID].Amount -= num;
                                endInv[endID].Amount += num
                                allowed = true;
                            }

                            if (startInv[startID].Data.Life) {
                                endInv[endID].Data.Life.push(startInv[startID].Data.Life[startInv[startID].Data.Life.length - 1])
                                startInv[startID].Data.Life.pop()
                            }

                            if (startInv[startID].Amount == 0) {
                                startInv[startID] = null;
                            }
                        } else {
                            let origin = clone(startInv[startID]);
                            let othr = clone(endInv[endID])

                            startInv[startID] = othr;
                            endInv[endID] = origin;
                            allowed = true;
                        }
                    }
                }
            }
        }

        beingDragged = null
        currentHover = null;
        if (allowed) {
            invs[`${startType}_${startinvID}`] = startInv
            invs[`${endType}_${endinvID}`] = endInv
            RefreshInv(startString)
            RefreshInv(endString)
            $.post("https://geo-inventory/Transfer", JSON.stringify({
                origin: `${str1}${startID}`,
                target: `${str2}${endID}`,
                amount: num,
                startType: startType,
                startinvID: startinvID,
                endType: endType,
                endinvID: endinvID
            }));
           
            return;
        }

        RefreshInv()
    }
}

function clone(obj) {
    if (null == obj || "object" != typeof obj) return obj;
    return JSON.parse(JSON.stringify(obj));
}

function UpdateAmount(key, amount) {
    let elem = CreateItem(key, amount);
    elem.find('#Item-Name').css('font-size', '1.2vh')
    elem.addClass('right')

    elem.find('#Item-Amount').css('display', 'block').html(amount)
    if (amount == 'Equipped') elem.find('#Item-Amount').css('color', 'white');
    if (amount == 'Unequipped') elem.find('#Item-Amount').css('color', 'white');
    if (typeof amount == 'number' && amount > 0) elem.find('#Item-Amount').css('color', 'white').css('font-size', '1.5vh').css('top', '50%');
    if (typeof amount == 'number' && amount < 0) elem.find('#Item-Amount').css('color', 'white').css('font-size', '1.5vh').css('top', '50%');


    /*     if (amount == 'Equipped') elem.css('background', 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)').find('#Item-Amount').css('color', 'white');
        if (amount == 'Unequipped') elem.css('background', 'linear-gradient(to right, #fa709a 0%, #fee140 100%)').find('#Item-Amount').css('color', 'black');
        if (typeof amount == 'number' && amount > 0) elem.css('background', 'linear-gradient(120deg, #d4fc79 0%, #96e6a1 100%)').find('#Item-Amount').css('color', 'black').css('font-size', '1.5vh').css('top', '50%');
        if (typeof amount == 'number' && amount < 0) elem.css('background', 'linear-gradient(120deg, #fccb90 0%, #d57eeb 100%)').find('#Item-Amount').css('color', 'black').css('font-size', '1.5vh').css('top', '50%'); */

    elem.find('#Item-Picture').css('width', '100%')
    elem.find('#Item-Picture').css('height', '100%')
    elem.css('height', '6vh')

    $('#Update').append(elem)
    elem.fadeOut(2500, function() {
        elem.remove()
    })
}

function Copy(id) {
    var dummy = document.createElement("textarea");
    document.body.appendChild(dummy);
    dummy.value = id;
    dummy.select();
    document.execCommand("copy");
    document.body.removeChild(dummy);
}

function Context(ev, inv, ind, t, name, skip) {
    $('.description').remove()
    ev.preventDefault();
    $('.menu').css('top', `${ev.clientY + 10}px`);
    $('.menu').css('left', `${ev.clientX + 10}px`);
    $('.menu').css('display', 'block');
    $('.menu').css('z-index', '9999999999999999');

    $('.menu').html('')

    if (t == 'Player') {
        CreaetButton('Use', function() {
            $.post("https://geo-inventory/Use", JSON.stringify({
                origin: `plyr${ind}`,
            }));
        })
    }

    if (items[inv[ind].Key].Weapon || inv[ind].Key == 'evidence_bullet' || inv[ind].Key == 'evidence_blood') {
        CreaetButton('Copy Serial Number', function() {
            Copy(inv[ind].Data.UniqueID || inv[ind].Data.Serial)
        })
    }

    if (inv[ind].Amount > 1) {
        let spltr = t == "Player" ? "plyr" : "othr";
        CreaetButton('Split Half', function() {
            let hashName = String(name.hashCode())

            let startType = t == 'Player' ? 'Player' : $(`#${hashName}`).parent().attr('invtype')
            let startinvID = t == 'Player' ? 'undefined' :  $(`#${hashName}`).parent().attr('invname')
            let startString = `${startType}_${startinvID}`
            let endType = t == 'Player' ? 'Player' : $(`#${hashName}`).parent().attr('invtype')
            let endinvID = t == 'Player' ? 'undefined' :  $(`#${hashName}`).parent().attr('invname')

            for (let index = 1; index <= (spltr == 'plyr' ? Slots['Player'] : Slots[otherID]); index++) {
                if (skip[index]) continue;
                if (inv[index] == null) {
                    $.post("https://geo-inventory/Transfer", JSON.stringify({
                        origin: `${spltr}${ind}`,
                        target: `${spltr}${index}`,
                        amount: Math.floor(inv[ind].Amount / 2),
                        startType: startType,
                        startinvID: startinvID,
                        endType: endType,
                        endinvID: endinvID
                    }));

                    let amount = Math.floor(inv[ind].Amount / 2)
                    inv[ind].Amount -= amount
                    inv[index] = clone(inv[ind])
                    inv[index].Amount = amount

                    if (spltr == 'plyr') {
                        inventory = inv
                    } else {
                        otherInv = inv
                    }

                   /*  UpdateInventory('Player', inventory, 'Player')
                    UpdateInventory('Other', otherInv, otherID) */
                    break;
                }
            }
        });
    }

    if (t == "Player" && items[inv[ind].Key].Weapon && inv[ind].Data.Ammo && HasItem(inv, inv[ind].Data.Ammo)) {
        CreaetButton('Reload', function() {
            $.post("https://geo-inventory/Use", JSON.stringify({
                origin: `plyr${HasItem(inv, inv[ind].Data.Ammo)}`,
            }));
        })
    }

    if (t == "Player" && items[inv[ind].Key].Weapon && inv[ind].Data.Ammo) {
        CreaetButton('Unload', function() {
            $.post("https://geo-inventory/Unload", JSON.stringify({}));
        })
    }

    if (duty == 'Police' && items[inv[ind].Key].Weapon) {
        CreaetButton('Run Serial', function() {
            $.post("https://geo-inventory/RunSerial", JSON.stringify({
                serial: inv[ind].Data.UniqueID
            }));
        })
    }

    if (t == "Player" && inv[ind].Key == 'outfit') {
        CreaetButton('Change Outfit Name', function() {
            $.post("https://geo-inventory/OutfitName", JSON.stringify({
                id: inv[ind].ID
            }));
        })
    }

    if (t == "Player" && items[inv[ind].Key].Equippable && !inv[ind].Data.Equipped) {
        CreaetButton('Equip', function() {
            $.post("https://geo-inventory/Equip", JSON.stringify({
                id: inv[ind].ID,
                bool: true
            }));
        })
    }

    if (t == "Player" && items[inv[ind].Key].Equippable && inv[ind].Data.Equipped) {
        CreaetButton('Unequip', function() {
            $.post("https://geo-inventory/Equip", JSON.stringify({
                id: inv[ind].ID,
                bool: false
            }));
        })
    }

    if (t == "Player" && items[inv[ind].Key].Repair) {
        CreaetButton('Repair', function() {
            $.post("https://geo-inventory/Repair", JSON.stringify({
                id: inv[ind].ID,
                key: inv[ind].Key
            }));
            CloseMenu()
        })
    }

    if (t == 'Other' && otherRealName.includes('Store') && otherData.owner) {
        CreaetButton('Set Price', function() {
            $.post("https://geo-inventory/SetPrice", JSON.stringify({
                id: inv[ind].ID,
                key: inv[ind].Key
            }));
        })
    }

    if (t != "Player" && duty == 'Police' && items[inv[ind].Key].Soulbound) {
        CreaetButton('Take As Evidence', function() {
            $.post("https://geo-inventory/TakeEvidence", JSON.stringify({item: inv[ind].ID, key: inv[ind].Key, slot: ind}));
        })
    }

    if (t == 'Player' && inv[ind].Key == 'evidencebag') {
        CreaetButton('Name Evidence Bag', function() {
            $.post("https://geo-inventory/NameBag", JSON.stringify({
                id: inv[ind].ID,
                key: inv[ind].Key
            }));
        })
    }
}

async function FillInventory(who, invType, inv, name, displayname) {
    if(name == 'Drops') return;
    let hashName = String(name.hashCode())
    $(`${who == "Player" ? "#Player" : `#${hashName}`}`).html('')
    $('#amount').remove()
    if ($('#Player').length != 1) {
        let window = CreateWindow('Player', 'Player')
        window.css('width', '50vh').css('height', '40vh').css('min-width', '40vh')
        window.append('<div id = "Player"></div>')
        window.attr('invtype', 'Player')
        window.append(`<div id = "player_capcity"></div>`)
        window.appendTo('#hud')
    }
  
    $('#Player').parent().append(`
        <input type = "number"  id = "amount"  min = "0" maxlength = "4" value = ${cNum} pattern="/^-?\d+\.?\d*$/" onKeyPress="if(this.value.length==4) return false;">
    `)


    $('#amount').on('input', function() {
        cNum = $(this).val()
    })

   /*  window.resizable({
        aspectRatio: 50 / 40 //(in your case it should be 2/1)
    }); */

    /* window.on('resize', function() {
        window.find('.Item-Container').css('height', window.find('.Item-Container').css('width'))
    }) */

    if (who == 'Other' && typeof displayname != 'undefined'  && name != 'Drops') {
        if ($('.'+hashName).length != 1) {
            let win = CreateWindow(hashName, displayname, {remove:true}).addClass('targetinv')

            win.css('width', '50vh').css('height', 'auto')
            win.addClass('invsize')
            win.append(`<div class = "oInv pinv" id = "${hashName}"></div>`)
            win.attr('invtype', invType).attr('invname', name)
            win.find('.title').css('overflow', 'hidden')
           /*  win.resizable({
                aspectRatio: 50 / 40 //(in your case it should be 2/1)
            }); */
            win.append(`<div class = "other_capcity ${hashName}weight">10/250</div>`)
            win.appendTo('#hud')

            $('[invtype ="Drops"').css('top', `calc(${$('.Player').css('top')} - 15vh)`)
            $('[invtype ="Drops"').css('left', `${$('.Player').css('left')}`)
        
         /*    win.on('resize', function() {
                win.find('.Item-Container').css('height', win.find('.Item-Container').css('width'))
            }) */
        }
    }

    let skip = {}
    for (let index = 1; index < Slots[invType] + 1; index++) {
        let elem = CreateItem((inv[index] || {}).Key, (inv[index] && invType != 'StoreUI' ? (inv[index] || {}).Amount : ((inv[index] || {}).Price)), inv[index])
        elem.attr('Inventory', who)
        elem.attr('Item', index)

        if (inv[index]) {
            if (GetDurability(inv[index]) <= 0) {
                elem.css('background', 'radial-gradient(circle, rgba(224, 110, 110, 0.459) 0%, rgba(235, 129, 129, 0.397) 50%, rgba(224, 110, 110, 0.377) 100%)')
            }

            elem.attr('Amount', inv[index].Amount)
            $(elem).draggable({
                scroll: false,
                appendTo: 'body',
                helper: function() {
                   /*  if ($(this).find('#Item-Picture').css('filter').match('blur')) {
                        return;
                    }
 */
                    beingDragged = elem;
                    beingDragged.attr('invtype', elem.parent().parent().attr('invtype')).attr('invname', elem.parent().parent().attr('invname'))
                    if (ctrPressed) {
                        MoveItems();
                    }

                    $('.description').remove()
                    var helper = $(this).clone();
                    helper.css('zIndex', '999');
                    helper.css('width', elem.css('width'));
                    helper.css('height', elem.css('height'));
                    helper.css('left', elem.css('left'));
                    helper.css('top', elem.css('top'));
                    helper.css('box-shadow', 'none');
                    helper.css('pointer-events', 'none')

                    let num = Number($('#amount').val())
                    if (num == 0 || num > inv[index].Amount) {
                        num = Number(inv[index].Amount)
                    }

                    helper.find('#Item-Amount').html(num == 0 ? inv[index].Amount : num)

                    if (inv[index].Amount - (num == 0 ? inv[index].Amount : num) > 0) {
                        elem.find('#Item-Amount').html(num == 0 ? inv[index].Amount : inv[index].Amount - num)
                        elem.find('.item_health')
                            .css('width', (GetDurability(inv[index], num) * 100) + '%')
                            .css('background-color', perc2color(GetDurability(inv[index], num) * 100))
                    } else {
                        setTimeout(() => {
                            let item = CreateItem()
                            item.css('width', elem.css('width'));
                            item.css('height', elem.css('height'));

                            if (inv[index] && items[inv[index].Key].size && (invType != 'StoreUI')) {
                                item.css('grid-column', `span ${items[inv[index].Key].size[0]}`)
                                item.css('grid-row', `span ${items[inv[index].Key].size[1]}`)
                                item.css('height', '98%')
                            } else {
                                item.css('height', item.css('width'))
                            }
                            elem.replaceWith(item)
                            if (inv[index] && items[inv[index].Key].size) {
                                item.parent().find('.hidden'+index).css('display', 'inline')

                                item.css('grid-column', `span ${items[inv[index].Key].size[0]}`)
                                .css('grid-row', `span ${items[inv[index].Key].size[1]}`)
                                .css('width', '100%')
                                .css('height', '98%')

                                helper.css('width', item.css('width'))
                                helper.css('height', item.css('height'))

                                item.css('grid-column', `span 1`)
                                    .css('grid-row', `span 1`)
                                    .css('width', item.css('height'))
                            }
                          
                        }, 0);
                    }

                    return helper;
                },

                stop: function(e) {
                    setTimeout(() => {
                        MoveItems()
                    }, 0);
                }
            });

            if (who == "Player") {
                elem.dblclick(function() {
                    $.post("https://geo-inventory/Use", JSON.stringify({
                        origin: `plyr${elem.attr('Item')}`,
                    }));
                    beingDragged = null;
                    currentHover = null;

                    if (items[inv[index].Key].Close == false) {
                        return;
                    }

                    CloseMenu();
                })
            }

            elem.contextmenu(function(ev) {
                Context(ev, inv, index, who, name, skip)
            })

        }

        elem.mouseenter(function() {
            currentHover = elem;
            $('.description').remove()
            /* if ($(this).find('#Item-Picture').css('filter').match('blur')) {
                return;
            } */

            UpdateInfo(inv[index], elem, inv, who)
        }).mouseleave(function() {
            currentHover = null;
            $('.description').remove()
        })

        if (who == 'Other' && inv[index] && !revealed[hashName][inv[index].ID] && invType == 'Player') {
           /*  elem.find('#Item-Picture').css('filter', 'blur(1vh)')
            $(elem).draggable('disable') */
        }
        $(`${who == "Player" ? "#Player" : `#${hashName}`}`).append(elem)

        
        elem.css('width', `100%`)

        if (invType != 'StoreUI') {
            if (inv[index] && items[inv[index].Key].size) {
                elem.css('grid-column', `span ${items[inv[index].Key].size[0]}`)
                elem.css('grid-row', `span ${items[inv[index].Key].size[1]}`)
    
                for (let heightIndex = 1; heightIndex <= items[inv[index].Key].size[1]; heightIndex++) {
                    for (let pIndex = 1; pIndex <= items[inv[index].Key].size[0]; pIndex++) {
                        if (pIndex == 1 && heightIndex == 1) continue
                        let num = (heightIndex * 8) + pIndex - 8 - 1
                        skip[index + num] = index
                    }
                }
                elem.css('height', '98%')
                elem.find('#Item-Picture').css('width', `${100 / (items[inv[index].Key].size[0] / items[inv[index].Key].size[1])}%`).css('left', `calc(50% - ${elem.find('#Item-Picture').width() / 2}px)`)
            } else {
                elem.css('height', elem.css('width'))
            }
        } else {
            elem.css('height', elem.css('width'))
        }
        

        elem.mousedown(function() {
            if (opening) return;
            if (inv[index] && who == 'Other' && revealed[hashName]) {
                opening = true;
                elem.find('#Item-Picture').css('filter', 'none')
                revealed[hashName][inv[index].ID] = true;
                setTimeout(() => {
                    $(elem).draggable('enable')
                    if (currentHover == elem) {
                        UpdateInfo(inv[index], elem, inv, who)
                    }
                    opening = false
                }, 1500);
            }
        })

        if (skip[index]) {
            elem.css('display', 'none').addClass('hidden'+skip[index])
        };
    }
}

function CreateItem(key, amount, item) {
    let elem = $(document.createElement('div'))
    elem.addClass('Item-Container')
    if (key) {

        let img = key
        let splitted = img.split('_hq')


        if (splitted[1] != null) {
            img = splitted[0];
            elem.addClass('hq')
        }

        elem.html(`
            <img src = "img/${img}.png" id = "Item-Picture">
            <p id = "Item-Amount">${amount}</p>
        `);

        if (item && item.Data.Image) {
            elem.find('#Item-Picture').attr('src', 'data:image/png;base64,'+item.Data.Image).css('width', '100%').css('height', '100%')
        }

        if (!items[key].Stackable && typeof amount != 'string') {
            elem.find('#Item-Amount').css('display', 'none')
        }

        if (items[key].Rarity) {
            elem.addClass(items[key].Rarity.toLowerCase())
        }

        if (item && item.Data.Equipped) {
            elem.append(`<i class="fas fa-star equipped"></i>`)
        }

    } else {
        elem.html(`
            <img src = "img/empty.png" id = "Item-Picture">
        `);
        elem.addClass('emptySlot')
    }

    if ((item && items[key].Decay) || item && item.Data.Durability) {
        elem.append(`
            <div style = "width:${GetDurability(item) * 100}%; background-color:${perc2color(GetDurability(item) * 100)}"class = "item_health"></div>
        `)
    }

   /*  elem.droppable({
        hoverClass: "ui-state-hover",
        drop: function() {
            RefreshInv()
        },
    }) */

    elem.css('height', $('.Item-Container').css('width'))
    return elem
}

function GetMax(itemID) {
    return (items[itemID].max || 1000)
}

function CanFit(inv, slots, itemID, amount, endInv, str1, ctrClick) {
    let toAdd = amount;
    if (ctrClick) str1 = str1 == 'plyr' ? 'other' : 'plyr';
    let weight = GetWeight(endInv, slots);
    let nMax = Sizes[str1 == 'plyr' ? 'Player' : otherID];
    if (str1 != 'plyr') nMax = otherWeight;
    if (weight + ((items[itemID].Weight || 0) * amount) > nMax) return false;

    for (let index = 1; index < slots + 1; index++) {
        if (inv[index] == null) {
            if (toAdd <= GetMax(itemID)) {
                return true;
            } else {
                toAdd -= GetMax(itemID)
            }
        } else {
            if (inv[index].ID == itemID) {
                let math = GetMax(itemID) - inv[index].Amount
                if (math >= toAdd) {
                    toAdd = 0;
                } else {
                    toAdd -= math
                }
            }
        }
    }

    return toAdd == 0
}

function HasItem(inv, itemID) {
    for (const key in inv) {
        if (inv[key].ID == itemID) return key;
    }
}

function Amount(inv, itemID) {
    let total = 0;
    for (const key in inv) {
        if (inv[key] && inv[key].ID == itemID) total += inv[key].Amount;
    }

    return total;
}

function CreaetButton(text, func) {
    let tVar = $(document.createElement('div'))
    tVar.addClass('menu-item')
    tVar.click(func)
    tVar.html(text)

    $('.menu').append(tVar)
}

async function UpdateInfo(data, start, inv, invType) {
    if (data != null) {
        let elem = $(document.createElement('div')).addClass('description')
        let first = $('.description').length == 0
        if (first) {
            $('#hud').append(elem)
        } else {
            elem = $('.description').first()
            elem.find('.inv-amounter').html(`
                ${data.Amount} / ${items[data.Key].Stackable ? GetMax(data.Key) : 1} (Total: ${Amount(inv, data.ID)})
            `)
            return;
        }
        elem.html('')
        elem.css('width', '20%')
        let pic = CreateItem(data.Key, '')

        let lr = start.offset().left + elem.width() > screen.width  ? 'right' : 'left'
        let pos = start.offset().left + elem.width() < screen.width ? start.offset().left + start.width() + 20 : 1920 - start.offset().left + start.width() + 20
        if (pos == 100) return;
        elem.css(lr, pos+'px')

        elem.css('top', start.offset().top)
        elem.append(pic)
        pic.css('left', '3%')
        pic.css('top', '4%')
        pic.css('width', '15%')
        pic.css('margin-top', '3%')
        pic.css('height', pic.css('width'))

        let durab = $(document.createElement('div'))
        durab.css('left', '0%')
        let math = GetDurability(data)

        durab.css('top', math < 1 ? 0 + (pic.height() - (math * pic.height())) + 'px' : '0px')
        durab.css('width', '2%')
        durab.css('position', 'absolute')
        durab.css('margin-top', '3%')
        durab.css('max-height', pic.css('width'))
        durab.css('height', (math * Number(pic.height()) + 'px'))
        durab.css('background-color', math == 1 ? 'rgb(48, 120, 171)' : 'green')
        durab.css('border-radius', '5vh')

        let durab2 = $(document.createElement('div'))
        durab2.css('left', '0%')
        durab2.css('top', '0px')
        durab2.css('width', '2%')
        durab2.css('position', 'absolute')
        durab2.css('margin-top', '3%')
        durab2.css('max-height', pic.css('width'))
        durab2.css('height', Number(pic.height()) + 'px')
        durab2.css('background-color', 'rgb(69, 15, 8')
        durab2.css('box-shadow', '0 0 2px rgb(0, 0, 0),  0 0 2px rgb(0, 0, 0),  0 0 2px rgb(0, 0, 0)')
        durab2.css('border-radius', '5vh')

        elem.append(durab2)
        elem.append(durab)

        elem.append(`
            <p id = "desc-name">${sanitizeHTML((data.Data.DisplayName) || items[data.Key].Name)}</p>
        `)

        elem.append(`
            <div id = "desc-cont">
                <p class = "inv-amounter" id = "desc-amount">${data.Amount} / ${items[data.Key].Stackable ? GetMax(data.Key) : 1} (Total: ${Amount(inv, data.ID)})</p>
            </div>
        `)

        elem.append('<hr>')
        elem.append('<br>')
        elem.append('<br>')
        elem.append('<br>')
        elem.append('<br>')
        elem.append('<br>')
        elem.append('<br>')

        if (otherID == 'StoreUI' && invType == 'Other') {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Price:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${data.Price}</p>
                </div>
            `)

            if (items[data.Key].Decay) {
                elem.append(`
                    <div id = "desc-cont">
                        <p id = "desc-items">Shelf Life:</p>
                        <p id = "desc-items" style = "left:40%; position:absolute;">${Math.floor(items[data.Key].Decay / 86400)} Days</p>
                    </div>
                `)
            }
        }

        elem.append(`
            <div id = "desc-cont">
                <p id = "desc-items">Condition:</p>
                <p id = "desc-items" style = "left:40%; position:absolute;">${Math.ceil(math * 100)}%</p>
            </div>
        `)

        if (items[data.Key].Weapon) {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Familiarity:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${(data.Data.Familiarity?.[String(cid)] || 0) / 25}%</p>
                </div>
            `)
        }


        if (data.Data.Life) {
            let d = new Date();
            let utc = Math.floor(d.getTime());
            let useby = new Date(utc + (items[data.Key].Decay * 1000 * math)).toDateString()
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Expiration:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${useby}</p>
                </div>
            `)
        }

        var num = 2
        if (items[data.Key].Weapon) {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Serial Number:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${(data.Data.UniqueID).substring(0, 20) +' ...'}</p>
                </div>
            `)

            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Ammo:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${data.Data.CurrentAmmo || 0}</p>
                </div>
            `)
        }
        if (data.Key == 'radio') {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Channel:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${data.Data.Channel}</p>
                </div>
            `)
        }

        if (data.Key == 'keycard') {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Guild:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${ data.Data.Guild}</p>
                </div>
            `)


            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Card Identifier:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${data.Data.Keycard}</p>
                </div>
            `)
        }
        if (data.Key == 'armor' || data.Key == 'lightarmor') {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Armor:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${data.Data.Armor}%</p>
                </div>
            `)
        }

        if (data.Key == 'trophy_bronze') {
            if (data.Data.firstname) {
                elem.append(`
                    <div id = "desc-cont">
                        <p id = "desc-items">First Name:</p>
                        <p id = "desc-items" style = "left:40%; position:absolute;">${data.Data.firstname}</p>
                    </div>
                `)
            }

            if (data.Data.lastname) {
                elem.append(`
                    <div id = "desc-cont">
                        <p id = "desc-items">Last Name:</p>
                        <p id = "desc-items" style = "left:40%; position:absolute;">${data.Data.lastname}</p>
                    </div>
                `)
            }

            if (data.Data.reason) {
                elem.append(`
                    <div id = "desc-cont">
                        <p id = "desc-items">Reason:</p>
                        <p id = "desc-items" style = "left:40%; position:absolute;">${data.Data.reason}</p>
                    </div>
                `)
            }

        }

        if (data.Key == 'id') {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Person:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${data.Data.first} ${data.Data.last}</p>
                </div>
            `)
        }

        if (items[data.Key].Weight) {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Weight:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${items[data.Key].Weight / 100} units</p>
                </div>
            `)
        }

        if (items[data.Key].Skill) {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Profession:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${items[data.Key].Skill}</p>
                </div>
            `)
        }

        if (descr[data.Key]) {
            elem.append('<br>')
            elem.append('<br>')
            elem.append('<br>')

            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-desc">${descr[data.Key]}</p>
                </div>
            `)
        }

        if (data.Key == 'mask') {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">ID:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${ data.Data.Drawable}</p>
                </div>

                <div id = "desc-cont">
                    <p id = "desc-items">Fit:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${ CheckModel(data.Data.Model)}</p>
                </div>
            `)
        }

        if (data.Key == 'outfit') {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Name:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${ data.Data.Name}</p>
                </div>
            `)
        }

        if (data.Key == 'evidence_bullet' || data.Key == 'evidence_blood') {
            elem.append(`
                <div id = "desc-cont">
                    <p id = "desc-items">Serial:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${data.Data.Serial.length > 20 ? data.Data.Serial.substring(0, 20) +' ...' : data.Data.Serial}</p>
                </div>

                <div id = "desc-cont">
                    <p id = "desc-items">Count:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${data.Data.Count}</p>
                </div>
            `)
        }

        if (items[data.Key].Soulbound) {
            elem.append(`
            <br>
            <div id = "desc-cont">
                <p id = "desc-items">This Can not be stolen</p>
            </div>
            `)
        }

        if (items[data.Key].Description) {
            elem.append(`
                <br><br><br><br>
                <div id = "desc-cont">
                    <p id = "desc-desc">${items[data.Key].Description}</p>
                </div>
            `)
        }

        if (data.Stock  ) {
            elem.append(`
                <br><br><br><br>
                <div id = "desc-cont">
                    <p id = "desc-items">Current Stock:</p>
                    <p id = "desc-items" style = "left:40%; position:absolute;">${data.Amount}</p>
                </div>
            `)
        }

        $('.description').css('opacity', '1.0')
    } else {
        $('.description').remove()
    }
}

function GetWeight(inv, slots) {
    if (inv == null) return 0;
    let weight = 0;

    for (let index = 1; index < slots + 1; index++) {
        if (inv[index] != null) {
            weight += ((items[inv[index].Key].Weight || 0) * inv[index].Amount)
        }
    }

    return weight
}

function CheckModel(id) {
    if (id == 1885233650) return "Male";
    if (id == -1667301416) return "Female";
    return 'Unknown'
}

function DisplayInventory(bool) {
    if (bool) {
        for (let index = 1; index < 6; index++) {
            let elem = CreateItem((inventory[index] || {}).Key, (inventory[index] || {}).Amount)
            elem.css('width', '5vh')
            elem.css('height', '5vh')
            $('#hotbar').append(elem)
        }

        $('#hotbar').animate({ opacity: '1.0' }, 500)
    } else {
        $('#hotbar').animate({ opacity: '0.0' }, 500, function() {
            $('#hotbar').html('')
        })
    }
}

function GetDurability(data, num) {
    let math = (data.Data.Durability || 100) / 100
    if (data.Data.Durability == 0) math = 0;
    var d = new Date();
    var utc = Math.floor(d.getTime() / 1000);

    if (data.Data.Life) {
        math -= (utc - data.Data.Life[data.Data.Life.length - 1 - (num || 0)]) / items[data.Key].Decay
    }

    if (math < 0) math = 0;
    return math;
}

function perc2color(perc) {
    var r, g, b = 0;
    if (perc < 50) {
        r = 255;
        g = Math.round(5.1 * perc);
    } else {
        g = 255;
        r = Math.round(510 - 5.10 * perc);
    }
    var h = r * 0x10000 + g * 0x100 + b * 0x1;
    return '#' + ('000000' + h.toString(16)).slice(-6);
}

function DoEquipment(invType, inv) {
    let found = {}
    for (var item of equipSlots) {
        for (let index = 1; index < Slots[invType] + 1; index++) {
            if (inv[index] && items[inv[index].Key].Equippable == item && inv[index].Data.Equipped) {
                let img = inv[index].Key
                let splitted = img.split('_hq')
                found[item] = [splitted[0], splitted[1]]
                if (items[inv[index].Key].Rarity) {
                    found[item].push(items[inv[index].Key].Rarity)
                }
                break;
            }
        }
    }

    $('#Player_equipment').html('')
    for (var item of equipSlots) {
        found[item] = found[item] || {}
        $('#Player_equipment').append(`
            <div class = "Equipment-Container" slot = "${item}">
                <div class = "Equipment-Item">
                    <img src = "img/${found[item][0] ||'empty'}.png" class = "${found[item][1] != null ? 'hq': ''} ${found[item][2] != null ? found[item][2]: ''}" style = "position:relatvie;width:100%;">
                </div>
                <p class = "Equipment-Title">Slot: ${item}</p>
                <p class = "Equipment-Title">Fill: ${found[item][0] == null ? 'Empty': 'Filled'}</p>
            </div>
        `)
    }
}

String.prototype.hashCode = function() {
  var hash = 0,
    i, chr;
  if (this.length === 0) return hash;
  for (i = 0; i < this.length; i++) {
    chr = this.charCodeAt(i);
    hash = ((hash << 5) - hash) + chr;
    hash |= 0; // Convert to 32bit integer
  }
  return hash;
}

function ItemAllowed(endType, pItem, inv) {
    if (Whitelists[endType]) {
        if (Whitelists[endType].Weapon) {
            if (items[pItem.Key].Weapon) return true;
        }

        if (Whitelists[endType].items) {
            for (var item of Whitelists[endType].items) {
                //console.log(item, pItem.Key)
                if (item == pItem.Key) {
                    return true;
                }
            }
        }

        return false;
    }
        let foundIndex ;

    let nItem = currentHover.attr('Item')
    if (items[pItem.Key].size) {
        if (9 - (nItem % 8) < items[pItem.Key].size[0] || (Number(nItem) % 8) == 0) {
            return;
        }

        if (Slots[endType] < Number(nItem) + ( (8 * items[pItem.Key].size[1]) - 8 )) {
            return;
        }
        

        let skip = {}
        if (!inv[nItem]) {
            for (let index = 1; index < Slots[endType] + 1; index++) {
                if (inv[index] && items[inv[index].Key].size && inv[index]['ID'] != pItem.ID) {
                    for (let heightIndex = 1; heightIndex <= items[inv[index].Key].size[1]; heightIndex++) {
                        for (let pIndex = 1; pIndex <= items[inv[index].Key].size[0]; pIndex++) {
                            if (pIndex == 1 && heightIndex == 1) continue
                            let num = (heightIndex * 8) + pIndex - 8 - 1
                            skip[index + num] = index
                        }
                    }
                }
            }
        }

        for (let heightIndex = 1; heightIndex <= items[pItem.Key].size[1]; heightIndex++) {
            for (let pIndex = 1; pIndex <= items[pItem.Key].size[0]; pIndex++) {
                if (pIndex == 1 && heightIndex == 1) continue
                let num = (heightIndex * 8) + pIndex - 8 - 1
                if (skip[Number(nItem) + num]) return;
                if (inv[Number(nItem) + num] && inv[Number(nItem) + num].ID != pItem.ID) {
                    return;
                }

                if (inv[nItem] && inv[Number(nItem) + num]) {
                    return;
                }
            }
        }
    } 

    return true;
}

function sanitizeHTML(text) {
    var element = document.createElement('div');
    element.innerText = text;
    return element.innerHTML;
}