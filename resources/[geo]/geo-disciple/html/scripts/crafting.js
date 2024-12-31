let Crafting;
let craftingTab
let craftingIndex;
let inventory;
let firstLoad = true
let craftingLog;
let gatherItems;
let minLevel = 0
let maxLevel = 100

window.addEventListener('message', (event) => {
    let data = event.data;
    if (data.inv) {
        UpdateInventory(data.inv)
    }

    if (data.craftingLog) {
        craftingLog = data.craftingLog
        gatheringLog = data.gatheringLog
        gatherItems = data.gatheringItems
    }

    Crafting = data.data
    switch (data.interface) {
        case 'Craft':
            Craft(data.inv);
            break;
        case 'Repair':
            Repair(data.key, data.id, data.items)
    }
})

window.addEventListener('done', () => {
    $('.crafting_requirements').html('<br>')
})

$(function() {
    let elem = CreateWindow('Crafting2', 'Crafting Log')
    elem.attr('nofade', true)
    elem.append(`
        <div class = "crafting_search">
            <input type = "text" class = "crafting_search_input" placeholder = "Item Name">
            <br>
            <li min = 0 max = 100 class = "isActive">0 - ? </li>
            <li min = 0 max = 5>1 - 5 </li>
            <li min = 6 max = 10>6 - 10 </li>
            <li min = 11 max = 15>11 - 15 </li>
            <li min = 16 max = 20>16 - 20 </li>
            <li min = 21 max = 25>21 - 25 </li>
        </div>

        <div class = "crafting_itemlist">
            <br>
        </div>

        <div class = "crafting_requirements">
        </div>
    `)

    elem.find('.header').css('height', '7vh')
    elem.find('.header').append(`
        <div class = "jobs">
        </div>
    `)

    $('.crafting_search_input').on('input', function() {
        LoadRecipes(craftingTab, $(this).val(), true)
    })

    $('.crafting_search').find('li').click(function() {
        $('.crafting_search').find('li').each(function() {
            $(this).removeClass('isActive')
        })
        $(this).addClass('isActive')
        maxLevel = $(this).attr('max');
        minLevel = $(this).attr('min');
        LoadRecipes(craftingTab, null, null, maxLevel)
    })

    elem.find('.img').click(function() {
        CloseMenu()
    })

    let celem = CreateWindow('Repair', 'Repair')
    celem.css('display', 'none')
    celem.attr('id', 'repair')
    celem.append(`
        <div class = "repair_container">
        </div>
    `)
    setTimeout(() => {
        celem.css('display', 'inline')
    }, 1000);

    celem.find('.img').click(function(e) {
        CloseMenu()
    })
})

function Craft(inv) {
    inventory = inv

    if(!interfaceOpen) {
        UISound('open')
        CreateWindow('Crafting2', 'Crafting Log')
        $('.Crafting2').css('opacity', '1.0')
    }

    interfaceOpen = 'Craft'

    if (firstLoad) {
        LoadRecipes(Crafting.Jobs[0], null, null, maxLevel)
        firstLoad = false;
    }

    $('.jobs').html('')
    for (var item of Crafting.Jobs) {
        $('.jobs').append(`
            <img class = "crafting_job" src = "img/${item}.png" job = "${item}">
        `)
    }

    $('.crafting_job').click(function() {
        $('.crafting_search').find('li').each(function() {
            $(this).removeClass('isActive')
        })
        minLevel = 0;
        maxLevel = 100
        LoadRecipes($(this).attr('job'))
    })

    $('.Crafting2')
        .css('pointer-events', 'all')
        .css('opacity', '1.0')
}

async function LoadRecipes(id, str, bool) {
    craftingTab = id;
    let myLevel = await Get('MyLevel', {job: craftingTab})
    myLevel = Math.ceil(myLevel / 5) * 5

    $('.crafting_search').find('li').each(function() {
        if ($(this).attr('min') > myLevel) {
            $(this).css('display', 'none')
        } else {
            $(this).css('display', 'inline')
        }
    })

    str = str || ''
    let elem = $('.crafting_itemlist').html('<br>')
    if (!bool) $('.crafting_requirements').html('<br>');
    for (var item in Crafting.Lists[id]) {
        if (!Crafting.Lists[id][item].Name.toLowerCase().match(str.toLowerCase())) continue;
        if (Crafting.Lists[id][item].Level > (maxLevel)) continue;
        if (Crafting.Lists[id][item].Level < (minLevel)) continue;
        if (Crafting.Lists[id][item].Level > (myLevel)) continue;
        elem.append(`
            <div class = "crafting_item" index = ${item}>
                <div class = "crafting_item_image">
                    <img src = "nui://geo-inventory/html/img/${Crafting.Lists[id][item].Item}.png">
                </div>

                <p1>${Crafting.Lists[id][item].Name}</p1>
                <p2>Lv. ${Crafting.Lists[id][item].Level}</p2>
            </div>
        `)
    }

    $('.crafting_item').click(function() {
        craftingIndex = $(this).attr('index')
        $('.crafting_requirements').html('<br>')
        /* for (var item of Crafting.Lists[id][$(this).attr('index')].Requirements) {
            $('.crafting_requirements').append(`
                <div class = "crafting_item" index = ${item}>
                    <div class = "crafting_item_image">
                        <img src = "nui://geo-inventory/html/img/${item[0]}.png">
                    </div>

                    <p1>${item[2]}</p1>
                    <p2>Need: x${item[1]}</p2>
                    <p3 style = "${inventory[item[0]] >= item[1] ? "" : "color:lightcoral;"}">Have: x${inventory[item[0]] || 0}</p3>
                    <p99>*Preproduction environment meant to set up API, recipes and crafting difficulty will be more involved later</p99>
                </div>
            `)
        } */

        let crafting = Crafting.Lists[id][$(this).attr('index')]
        $('.crafting_requirements').append(`
            <div class = "crafting_item_header">
                <div class = "crafting_item" index = ${item}>
                    <div class = "pAmounter">
                        <pAmount>${crafting.Amount}</pAmount>
                    </div>
                    <div class = "crafting_item_image" style = "margin-left:2em;">
                        <img src = "nui://geo-inventory/html/img/${crafting.Item}.png">
                    </div>

                    <p1 style = "margin-left:2em;">${crafting.Name}</p1>
                </div>

                <p10 style = "margin-left:2em;">Difficulty</p10>
                <p11 style = "margin-left:2em;">${crafting.Craftsmanship}</p11>
                <br>
                <p10 style = "margin-left:2em;">Durability</p10>
                <p11 style = "margin-left:2em;">${crafting.Durability}</p11>
            </div>
        `)

        $('.crafting_requirements').append(`<h1>NQ</h1>`)
        $('.crafting_requirements').append(`<h2>HQ</h2>`)

        for (var item of Crafting.Lists[id][$(this).attr('index')].Requirements) {
            $('.crafting_requirements').append(`
                <div class = "crafting_item craftingelement" total = ${item[1]} item = "${item[0]}">
                    <div class = "pAmounter">
                        <pAmount>${item[1]}</pAmount>
                    </div>
                    <div class = "crafting_item_image" style = "margin-left:2em;">
                        <img src = "nui://geo-inventory/html/img/${item[0]}.png" class = "getitemhover" item = "${item[2]}" itemID = "${item[0]}">
                    </div>

                    <div class = "NQ">
                        <p max =${inventory[item[0]] || 0}>${inventory[item[0]] > item[1] ? item[1] : 0}</p>
                    </div>
                    <div class = "HQ">
                        <p max = ${inventory[item[0]+'_hq'] || 0}>0</p>
                    </div>
                    <hr>
                    <div class = "MyNQ">
                        <p>${inventory[item[0]] || 0}</p>
                    </div>
                    <div class = "MyHQ">
                        <p>${inventory[item[0]+'_hq'] || 0}</p>
                    </div>
                    <hr>
                </div>
            `)
        }

        $('.getitemhover').hover(function() {
            let item = $(this).attr('itemID')
            let string = $(this).attr('item')
            if (gatherItems[item]) {
                if (!gatheringLog[item]) {
                    string = '???'
                }
            }

            if (CanBeCrafted(item)) {
                if (!craftingLog[item]) {
                    string = '???'
                }
            }
            $(this).attr('title', string)
        })

        $('.getitemhover').tooltip({
            tooltipClass: "tooltip"
        })

        $('.NQ').click(function() {
            AdjustTotals('NQ', $(this))
        })

        $('.HQ').click(function() {
            AdjustTotals('HQ', $(this))
        })

        $('.crafting_requirements').append(`
            <button class = "crafting_start">Craft</button>
            <button class = "crafting_quick">Quick Craft</button>
        `)

        $('.crafting_quick').mouseenter(function() {
            if (craftingLog[Crafting.Lists[craftingTab][craftingIndex].Item]) {
                $(this).attr('title', '')
            } else {
                $(this).attr('title', 'You need to make one first')
            }
        }).click(function() {
            if (!craftingLog[Crafting.Lists[craftingTab][craftingIndex].Item]) return;
            QuickCraft(craftingTab, craftingIndex)
        })

        $('.crafting_quick').tooltip({
            tooltipClass: "tooltip"
        })

        $('.crafting_start').click(async function() {
            if (!CanCraft()) return;
            CraftItem(craftingTab, craftingIndex)

           /*  inventory = await Get('Craft', {
                job: craftingTab,
                item: craftingIndex,
                items: GetCraftingItems()
            }) */
            
            //UpdateInventory(inventory)
            //$('p3').html(`Have: x${inventory[item[0]] || 0}`).attr('style', `${inventory[item[0]] >= item[1] ? "" : "color:lightcoral;"}`)
        })

        $('.crafting_quick').click(async function() {
            if (!CanCraft()) return;
        })

        if (!CanCraft()) {
            $('.crafting_quick').css('opacity', '0.5')
            $('.crafting_start').css('opacity', '0.5')
        } else {
            $('.crafting_quick').css('opacity', '1.0')
            $('.crafting_start').css('opacity', '1.0')
        }
    })
}

function AdjustTotals(bar, element) {
    let str = bar == 'NQ' ? '.HQ' : '.NQ'
    let currentAmount = Number(element.find('p').html())
    let totalOther = Number(element.parent().find(str).find('p').html())
    let max = element.find('p').attr('max')

    if (currentAmount + 1 > max) return;
    if (currentAmount + 1 + totalOther > element.parent().attr('total')) {
        if (totalOther > 0) {
            element.parent().find(str).find('p').html(totalOther - 1)
        } else {
            return;
        }
    }
    element.find('p').html(currentAmount + 1)

    if (!CanCraft()) {
        $('.crafting_quick').css('opacity', '0.5')
        $('.crafting_start').css('opacity', '0.5')
    } else {
        $('.crafting_quick').css('opacity', '1.0')
        $('.crafting_start').css('opacity', '1.0')
    }
}

function CanCraft() {
    let canContinue = true;


    $('.craftingelement').each(function() {
        let totalNQ = Number($(this).find('.NQ').find('p').html())
        let totalHQ = Number($(this).find('.HQ').find('p').html())

        if (totalNQ + totalHQ != $(this).attr('total')) canContinue = false;
    })

    return canContinue;
}

function Repair(key, id, items) {
    CreateWindow('Repair', 'Repair')
    interfaceOpen = 'Repair'
    let elem = $('.repair_container').html('')
    
    for (var item of items) {
        elem.append(`
            <div class = "crafting_item" index = ${item}">
                <div class = "crafting_item_image">
                    <img src = "nui://geo-inventory/html/img/${item[0]}.png">
                </div>

                <p1>${item[2]}</p1>
                <p2>Need: x${item[1]}</p2>
                <p3 style = "${inventory[item[0]] >= item[1] ? "" : "color:lightcoral;"}">Have: x${inventory[item[0]] || 0}</p3>
            </div>
        `)
    }

    elem.append(`
        <button class = "repair_start">Repair</button>
    `)

    $('.repair_start').click(async function() {
        let data = await Get('Repair', {
            item: id,
        })

        if (data) CloseMenu();
    })

    $('#repair')
        .css('pointer-events', 'all')
        .css('opacity', '1.0')
}

function UpdateInventory(inv) {
    inventory = inv
    $('.craftingelement').each(function() {
        let totalNQ = Number($(this).find('.MyNQ').find('p').html(inv[$(this).attr('item')] || 0).html())
        let totalHQ = Number($(this).find('.MyHQ').find('p').html(inv[$(this).attr('item')+'_hq'] || 0).html())

        if (Number($(this).find('.HQ').find('p').html()) > totalHQ) {
            $(this).find('.HQ').find('p').html(totalHQ).attr('max', inv[$(this).attr('item')+'_hq'] || 0)
        }
        $(this).find('.HQ').find('p').attr('max', inv[$(this).attr('item')+'_hq'] || 0)


        if (Number($(this).find('.NQ').find('p').html()) > totalNQ) {
            $(this).find('.NQ').find('p').html(totalNQ).attr('max', inv[$(this).attr('item')] || 0)
        }
        $(this).find('.HQ').find('p').attr('max', inv[$(this).attr('item')+'_hq'] || 0)
    })
}

function GetCraftingItems() {
    let list = [];
    $('.craftingelement').each(function() {
        let totalNQ = Number($(this).find('.NQ').find('p').html())
        let totalHQ = Number($(this).find('.HQ').find('p').html())

        list.push([totalNQ, totalHQ])
    })

    return list
}

let canClick = false;
async function CraftItem(job, index) {
    canClick = true
    let item = Crafting.Lists[job][index]
    let canCraft = await Get('CraftingItem', {
        job: job,
        index: index,
        items: GetCraftingItems()
    })

    if (!canCraft) return;

    $('.Crafting2').css('opacity', '0.0').css('pointer-events', 'none')

    $('body').append(`
        <div class = "crafting_window">
            <div class = "crafting_item" index = ${item}>
                <div class = "crafting_item_image">
                    <img src = "nui://geo-inventory/html/img/${item.Item}.png">
                </div>

                <p1>${item.Name}</p1>
            </div>
            <p2>${item.Durability} / ${item.Durability}</p2>
            <hr>
            <div class = "progress">
                <p>Progress</p>
                <div class = "progress_bar">
                    <div class = "progress"></div>
                </div>
                <p1>0 / ${item.Craftsmanship}</p1>
            </div>
            <div class = "quality">
                <p>Quality</p>
                <div class = "progress_bar">
                    <div class = "progress"  style = "width:${(canCraft.Quality / item.Control) * 100}%;"></div>
                </div>
                <p1>${canCraft.Quality} / ${item.Control}</p1>
            </div>
            <p3>HQ: ${canCraft.HQChance}%</p3>

            <button class = "crafting_progress">Increase Progress</button>
            <button class = "crafting_quality">Increase Quality</button>
        </div>
    `)

    $('.crafting_progress').click(async function() {
        UseSkill(item, 1)
    })

    $('.crafting_quality').click(async function() {
        UseSkill(item, 2)
    })
}

async function UseSkill(item, skill) {
    if (!canClick) return;
        let elem = $('.crafting_window')
        canClick = false
        $('.crafting_progress').css('opacity', '0.5')
        $('.crafting_quality').css('opacity', '0.5')
        setTimeout(() => {
            canClick = true
            $('.crafting_progress').css('opacity', '1.0')
            $('.crafting_quality').css('opacity', '1.0')
        }, 1000);
        let data = await Get('Crafting.Skill', {
            skill: skill
        });

        if (data.inv) {
            inventory = data.inv
            UpdateInventory(inventory)
        }

        if (data.fail || data.completed) { 
            setTimeout(() => {
                elem.fadeOut(250, function() {
                    elem.remove()
                    $('.Crafting2').css('opacity', '1.0').css('pointer-events', 'all')
                })
                return;
            }, 500);
        }

        elem.find('p2').html(`${data.Durability} / ${item.Durability}`)
        elem.find('p3').html(`HQ: ${data.HQChance}%`)
        elem.find('.progress')
            .find('p1').html(`${data.Progress} / ${item.Craftsmanship}`).parent()
            .find('.progress_bar').find('.progress').css('width', ((data.Progress / item.Craftsmanship) * 100) +'%')

        elem.find('.quality')
            .find('p1').html(`${data.Quality} / ${item.Control}`).parent()
            .find('.progress_bar').find('.progress').css('width', ((data.Quality / item.Control) * 100) +'%')
}

function QuickMax(job, index) {
    let totalMax = 999
    let item = Crafting.Lists[job][index]
    for (var items of item.Requirements) {
        let amount = inventory[items[0]] || 0
        if (amount < items[1]) {
            return 0;
        } else {
            let calc = Math.floor(amount / items[1])
            if (calc < totalMax) {
                totalMax = calc
            }
        }
    }

    return totalMax
}

async function QuickCraft(job, index) {
    let item = Crafting.Lists[job][index]
    let canMake = QuickMax(job, index)
    if (canMake <= 0) return;
    $('.Crafting2').css('opacity', '0.0').css('pointer-events', 'none')

    $('body').append(`
        <div class = "crafting_window">
            <div class = "crafting_item" index = ${item}>
                <div class = "crafting_item_image">
                    <img src = "nui://geo-inventory/html/img/${item.Item}.png">
                </div>

                <p1>${item.Name}</p1>
            </div>
            <p2>60%</p2>
            <hr>
            <div class = "quick_craft">
                <input type = "number" id = "quick_make" placeholder = "Amount" max = ${canMake} min = 1 value = 1>
                <label for="quick_make" class = "quick_make_text">Max : ${canMake}</label>
            </div>

            <button class = "quick_craft_go">Craft</button>
            <button class = "quick_craft_cancel" id = "cancel">Cancel</button>
        </div>
    `)

    $('#quick_make').on('input', function() {
        if (Number($(this).val()) > Number($(this).attr('max'))) {
            $(this).val($(this).attr('max'))
        }

        if (Number($(this).val()) < Number($(this).attr('min'))) {
            $(this).val($(this).attr('min'))
        }
    })

    $('.quick_craft_go').click(async function() {
        let amount = Number($('#quick_make').val())
        $('.crafting_window').html(`
            <div class = "crafting_item" index = ${item}>
                <div class = "crafting_item_image">
                    <img src = "nui://geo-inventory/html/img/${item.Item}.png">
                </div>

                <p1>${item.Name}</p1>
            </div>
            <p2>60%</p2>
            <hr>
            <button class = "quick_craft_cancel">Cancel</button>
        `).css('top', '10%')

        $('.quick_craft_cancel').click(function() {
            Get('CancelQuick', {
            });
            $(this).html('Cancelling...')
        })

        await Get('QuickCraft', {
            job: job,
            index: index,
            amount : amount
        });

        $('.crafting_window').remove()
    })

    $('#cancel').click(function() {
        $('.crafting_window').remove()
        Craft(inventory)
    })
}

function CanBeCrafted(item) {
    for (var profession in Crafting.Lists) {
        for (var pItem of Crafting.Lists[profession]) {
            if (pItem.Item == item) return true;
        }
    }

    return false;
}