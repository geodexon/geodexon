let currentGuild
let cid, guilds;
let editPage;
let flagsPage;

window.addEventListener('done', function() {
    currentGuild = null;
    editPage = null;
})

window.addEventListener('message', async(event) => {
    let data = event.data
    if (data.interface == 'GuildUpdate') {
        let thisGuild = currentGuild
        let wasEdit = editPage

        if (currentApp == 'guilds') {
            if (flagsPage == true) return;

            await OpenGuilds(true)
            if (wasEdit) {
                await EditGuild(guilds, data.guild, cid)
                return;
            }

            if (thisGuild == data.guild) {
                await OpenGuild(guilds, data.guild, cid);
                return;
            }
        }
    }
})

async function OpenGuilds(bool) {
    flagsPage = false
    currentGuild = null;
    editPage = null;

    let elem = $('#app_container')
    let data = await Get('GetGuilds')
    guilds = data.guilds
    cid = data.cid

    if (bool) return;

    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Guilds</p>
            </div>
        </div>
    `)

    for (var item in guilds) {
        let _item = item;
        let guild = guilds[_item]
        if (!JSON.stringify(guilds[_item].members).includes(`"${cid}"`) && guilds[_item].owner != cid && !JSON.stringify(guilds[_item].temp).includes(`"${cid}"`)) continue;

        $('#phone_message_container').append(`
            <div class = "phone_message">
                <i class="fas fa-briefcase phone_message_icon"></i>
                <p1>${guilds[item].guild}</p1>
                <p2 style = "color:gray;">${guilds[item].ident}</p2>
            </div>
        `)

        $('.phone_message').last().click(function() {
            OpenGuild(guilds, _item, cid)
        })
    }
}

async function OpenGuild(guilds, item, cid) {

    /* $('#phone_apps').append(`
        <div class = "loader" style = "width: 80%; left:10%; height: 10em; top: calc(50% - 5em); position:absolute; background-color:var(--main-bg); border: 0.1em solid var(--main-lighter);">
            <img src = "nui://geo-es/html/img/load.gif" id = "helper_loading">
        </div>
    `) */

    currentGuild = guilds[item].ident
    flagsPage = false
    let firing = false;
    let myAuth = await Get('GuildAuthority', { guild: item })
    let names = await Get('GetNames', { guild: item })
    let elem = $('#app_container')

    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Guilds: ${item}</p>
            </div>

            <div class = "cContainer" style = "overflow-y:scroll;height:28.5em;margin-bottom:5em;">
            </div>
            <div style = "height: 1em;"></div>
        </div>
    `)

    $('#phone_message_header').click(function() {
        OpenGuilds()
    })

    if (guilds[item].owner == cid) {
        $('.cContainer').append(`
            <button class = "editguild" style = "position:relatve;width:70%; margin-bottom:0.5em; margin-left:15%; margin-top:0.5em; height:2em;color:white; background-color:var(--main-content);outline:none;border:none;border-radius:0.5em;">Edit Guild</button>
        `)

        $('.editguild').last().click(function() {
            EditGuild(guilds, item, cid)
        })
    }

    if (myAuth >= 1000) {
        $('.cContainer').append(`
            <button class = "editguild" style = "position:relatve;width:70%; margin-bottom:0.5em; margin-left:15%; margin-top:0.5em; height:2em;color:white; background-color:var(--main-content);outline:none;border:none;border-radius:0.5em;">Add Member</button>
        `)

        $('.editguild').last().click(function() {
            AddMember(null, item)
        })

        $('.cContainer').append(`
            <button class = "editguild" style = "position:relatve;width:70%; margin-bottom:0.5em; margin-left:15%; margin-top:0.5em; height:2em;color:white; background-color:var(--main-content);outline:none;border:none;border-radius:0.5em;">Add Temp Member</button>
        `)

        $('.editguild').last().click(function() {
            AddMember(null, item, true)
        })
    }

    for (var member in guilds[item].fakemembers) {
        let _member = member;
        let guild = guilds[item].fakemembers
        let mCID = guild[_member].cid

        $('.cContainer').append(`
            <div class = "phone_message">
                <i class="fas fa-user-circle phone_message_icon"></i>
                <p1>${names[mCID]}</p1>
                <p2>${guild[_member].title}</p2>
            </div>
        `)

        $('.phone_message').last().contextmenu(async function() {
            if (firing || myAuth < 1000) return;
            let auth = await Get('GuildAuthority', { guild: item, cid: mCID })
            if (myAuth <= auth && guilds[item].owner != cid) return;
            firing = true
            if (await PhoneConfirm('guilds', `Remove ${names[mCID]}?`, null, 30)) {
                setTimeout(() => {
                    Get('Guild.Fire', { guild: item, cid: mCID })
                }, 500);
            }
            firing = false
        })

        if (myAuth >= 1000) {
            $('.phone_message').last().click(async function() {
                //AddMember([mCID, guild[_member].title], item)
                OpenGuildUser(guilds, item, cid, mCID, names[mCID], _member)
            })
        }
    }

    for (var member in guilds[item].temp) {
        let _member = member;
        let guild = guilds[item].temp

        $('.cContainer').append(`
            <div class = "phone_message">
                <i class="fas fa-user-circle phone_message_icon"></i>
                <p1>${_member}</p1>
                <p2>Temp: ${guild[_member].title}</p2>
            </div>
        `)

        $('.phone_message').last().contextmenu(async function() {
            if (firing || myAuth < 1000) return;
            let auth = await Get('GuildAuthority', { guild: item, cid: _member })
            if (myAuth <= auth) return;
            firing = true
            if (await PhoneConfirm('guilds', `Remove ${names[_member]}?`, null, 30)) {
                setTimeout(() => {
                    Get('Guild.FireTemp', { guild: item, cid: _member })
                }, 500);
            }
            firing = false
        })
    }

    $('.loader').remove()
}

function EditGuild(guilds, item, cid) {
    editPage = true

    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Guilds</p>
            </div>

            <div class = "cContainer" style = "overflow-y:scroll;height:28.5em;margin-bottom:5em;">
            </div>
            <div style = "height: 1em;"></div>
        </div>
    `)

    $('#phone_message_header').click(function() {
        OpenGuild(guilds, item, cid)
    })


    $('.cContainer').prepend(`
    <button class = "editguildImage" style = "position:relatve;width:70%; margin-bottom:0.5em; margin-left:15%; margin-top:0.5em; height:2em;color:white; background-color:var(--main-content);outline:none;border:none;border-radius:0.5em;">Add Rank</button>
    `)

    $('.cContainer').prepend(`
    <button class = "editguild" style = "position:relatve;width:70%; margin-bottom:0.5em; margin-left:15%; margin-top:0.5em; height:2em;color:white; background-color:var(--main-content);outline:none;border:none;border-radius:0.5em;">Set Image</button>
    `)

    $('.editguild').click(function() {
        EditGuildImage(null, item, cid)
    })

    $('.editguildImage').click(function() {
        EditGuildRank(null, item, cid)
    })

    let firing = false;
    for (var rank in guilds[item].ranks) {
        let _rank = rank

        $('.cContainer').append(`
            <div class = "phone_message">
                <i class="fas fa-briefcase phone_message_icon"></i>
                <p1>${guilds[item].ranks[rank][0]}</p1>
                <p2 style = "color:gray;">${guilds[item].ranks[rank][1]}</p2>
            </div>
        `)

        $('.phone_message').last().contextmenu(async function() {
            if (firing) return;
            firing = true
            if (await PhoneConfirm('guilds', `Remove Rank: ${guilds[item].ranks[_rank][0]}?`, null, 30)) {
                setTimeout(() => {
                    Get('RemoveRank', { guild: item, rank: guilds[item].ranks[_rank][0] })
                    $(this).remove()
                }, 500);
            }
            firing = false
        })

        $('.phone_message').last().click(async function() {
            LoadRankFlags(guilds, item, _rank, cid)
        })
    }
}

function EditGuildRank(data, item, cid) {
    $('#phone_contacts_new').remove()
    $('#phone_contacts_new').css('height', '11.2em')
    let elem = $('#app_container')

    elem.append(`
        <div id = "phone_contacts_new">
            <p>${data ? 'Edit' : 'Add'} Rank</p>
            <hr>

            <label for="phone_contact_input" class = "phone_contact_container">Name</label>
            <input type = "text" class = "phone_contact_input phone_fullname" placeholder = "Rank Name " maxlength = "46" ${data ? 'readonly' : ''} value = ${data ? data[0] : ''}>

            <label for="phone_contact_input" class = "phone_contact_container">Power</label>
            <input type = "number" maxlength = "4" class = "phone_contact_input phone_fullnumber" placeholder = "Rank Value" value = "${data ? data[1] : ''}" pattern="/^-?\d+\.?\d*$/" onKeyPress="if(this.value.length==4) return false;">
        
            <i class="fas fa-times-circle phone_contact_deny" title = "dick"></i>
            <i class="fas fa-check-circle phone_contact_accept" title = "dick"></i>
        </div>
    `)

    $('#phone_contacts_new').animate({ bottom: '0em' }, 500)
    $('.phone_contact_deny').click(function() {
        $('#phone_contacts_new').animate({ bottom: '-11.2em' }, 500, function() {
            $(this).remove()
        })
    })

    $('.phone_contact_accept').click(async function() {

        if (data) {
            flagsPage = false
            Get('ModifyAuthority', {
                guild: item,
                rank: data[0],
                newAUth: $('.phone_fullnumber').val()
            })
        } else {
            Get('CreateRank', {
                guild: item,
                rank: $('.phone_fullname').val(),
                newAUth: $('.phone_fullnumber').val()
            })
        }

        /* $.post(`http://${GetParentResourceName()}/phone.newcontact`, JSON.stringify({
            rankpower: $('.phone_fullnumber').val(),
            rankname:  $('.phone_fullname').val()
        })); */
        CloseNewContact();
    })
}

function EditGuildImage(data, item) {
    $('#phone_contacts_new').remove()
    $('#phone_contacts_new').css('height', '11.2em')
    let elem = $('#app_container')

    elem.append(`
        <div id = "phone_contacts_new">
            <p>Guild Image</p>
            <hr>

            <label for="phone_contact_input" class = "phone_contact_container">Name</label>
            <input type = "text" class = "phone_contact_input phone_fullname" placeholder = "Image Link" value = ${guilds[item].image ? guilds[item].image : ''}>

            <i class="fas fa-times-circle phone_contact_deny" title = "dick"></i>
            <i class="fas fa-check-circle phone_contact_accept" title = "dick"></i>
        </div>
    `)

    $('#phone_contacts_new').animate({ bottom: '0em' }, 500)
    $('.phone_contact_deny').click(function() {
        $('#phone_contacts_new').animate({ bottom: '-11.2em' }, 500, function() {
            $(this).remove()
        })
    })

    $('.phone_contact_accept').click(async function() {
        Get('SetGuildImage', {
            guild: item,
            image: $('.phone_fullname').val()
        })

        /* $.post(`http://${GetParentResourceName()}/phone.newcontact`, JSON.stringify({
            rankpower: $('.phone_fullnumber').val(),
            rankname:  $('.phone_fullname').val()
        })); */
        CloseNewContact();
    })
}

async function AddMember(data, item, temp) {
    let myAuth = await Get('GuildAuthority', { guild: item })
    $('#phone_contacts_new').remove()
    $('#phone_contacts_new').css('height', '11.2em')
    let elem = $('#app_container')

    elem.append(`
        <div id = "phone_contacts_new">
            <p>${data ? 'Edit' : 'Add'} Member</p>
            <hr>

            <label for="phone_contact_input" class = "phone_contact_container">CID</label>
            <input type = "number" class = "phone_contact_input phone_fullname" placeholder = "Member CID " maxlength = "46" ${data ? 'readonly' : ''} value = ${data ? data[0] : ''}>

            <label for="phone_contact_input" class = "phone_contact_container">Power</label>
            <select name="evidence" class="phone_contact_input phone_fullnumber">
            </select>

            <i class="fas fa-times-circle phone_contact_deny" title = "dick"></i>
            <i class="fas fa-check-circle phone_contact_accept" title = "dick"></i>
        </div>
    `)

    for (var rank of guilds[item].ranks) {
        if (myAuth > rank[1]) {
            $('.phone_contact_input').append(`
                <option value="${rank[0]}">${rank[0]}</option>
            `)
        }
    }

    $('#phone_contacts_new').animate({ bottom: '0em' }, 500)
    $('.phone_contact_deny').click(function() {
        $('#phone_contacts_new').animate({ bottom: '-11.2em' }, 500, function() {
            $(this).remove()
        })
    })

    $('.phone_contact_accept').click(async function() {
        CloseNewContact();
        setTimeout(() => {
            Get('Guild.AddUser', {
                guild: item,
                member: $('.phone_fullname').val(),
                rank: $('.phone_fullnumber').val(),
                temp: temp
            })
        }, 500);

        /* $.post(`http://${GetParentResourceName()}/phone.newcontact`, JSON.stringify({
            rankpower: $('.phone_fullnumber').val(),
            rankname:  $('.phone_fullname').val()
        })); */
    })
}

async function OpenGuildUser(guilds, item, cid, target, name, index) {
    flagsPage = true
    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Guilds: ${item}</p>
            </div>

            <div class = "cContainer" style = "overflow-y:scroll;height:28.5em;margin-bottom:5em;">
            </div>
            <div style = "height: 1em;"></div>
        </div>
    `)

    $('.cContainer').append(`
        <div class = "phone_message">
            <i class="fas fa-user-circle phone_message_icon"></i>
            <p1>${name}</p1>
            <p2>${guilds[item].fakemembers[index].title}</p2>
        </div>
    `)

    $('.cContainer').append(`
        <button class = "property_buy" id = "setguildrank">Set Rank</button>
    `)

    if (guilds[item].owner == cid) {
        $('.cContainer').append(`
            <button class = "property_buy" id = "addguildflag">Add Flag</button>
        `)

        $('#addguildflag').click(async function() {
            let val = await PhoneInput({
                header: 'Guild Flag',
                field: 'text',
                title: 'Flag',
                placeholder: 'Flag'
            })
            if (val) {
                let flag = await Get('Guild.Flag', {
                    flag: val,
                    target: target,
                    guild: item
                })
                guilds[item].fakemembers[index].flags = flag
                LoadFlags(guilds, item, target, index, cid)
            }
        })
    }

    $('#setguildrank').click(async function() {
        AddMember([target, guilds[item].fakemembers[index].title], item)
    })

    $('#phone_message_header').click(async function() {
        let data = await Get('GetGuilds')
        OpenGuild(data.guilds, item, data.cid)
    })

    LoadFlags(guilds, item, target, index, cid)
}

function LoadFlags(guilds, item, target, index, cid) {
    $('.tenants').each(function() {
        $(this).remove()
    })

    if (guilds[item].fakemembers[index].flags) {
        for (var pItem of guilds[item].fakemembers[index].flags) {
            $('.cContainer').append(`
            <p class = "property_price tenants" style = "font-size:1em;">${sanitizeHTML(pItem)}
                <span style="float:right; margin-right:1em;" class = "fas fa-solid fa-ban removetenant" num = "${sanitizeHTML(pItem)}"}>
                </span>
            </p>`)
        }
    }


    $('.removetenant').click(async function() {
        if (!(guilds[item].owner == cid)) return;
        let flag = await Get('Guild.RemoveFlag', {
            flag: $(this).attr('num'),
            target: target,
            guild: item
        })
        guilds[item].fakemembers[index].flags = flag
        LoadFlags(guilds, item, target, index, cid)
    })
}

function LoadRankFlags(guilds, item, rank) {
    flagsPage = true
    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p>Guilds: ${item}</p>
            </div>

            <div class = "cContainer" style = "overflow-y:scroll;height:28.5em;margin-bottom:5em;">
            </div>
            <div style = "height: 1em;"></div>
        </div>
    `)


    $('#phone_message_header').find('p').click(function() {
        EditGuild(guilds, item, cid)
    })

    $('.cContainer').append(`
        <button class = "property_buy" id = "editrankdata">Eidt Rank</button>
        <button class = "property_buy" id = "addguildflag">Add Flag</button>
    `)

    $('#editrankdata').click(function() {
        EditGuildRank(guilds[item].ranks[rank], item, cid)
    })

    $('#addguildflag').click(async function() {
        let val = await PhoneInput({
            header: 'Guild Flag',
            field: 'text',
            title: 'Flag',
            placeholder: 'Flag'
        })
        if (val) {
            let flag = await Get('Guild.RankFlag', {
                flag: val,
                target: rank,
                guild: item
            })
            guilds[item].ranks[rank][2] = flag
            LoadRankFlags(guilds, item, rank, cid)
        }
    })

    let data = guilds[item].ranks[rank]
    if (!data[2]) {
        data[2] = []
    }

    for (var pItem of data[2]) {
        $('.cContainer').append(`
        <p class = "property_price tenants" style = "font-size:1em;">${sanitizeHTML(pItem)}
            <span style="float:right; margin-right:1em;" class = "fas fa-solid fa-ban removetenant" num = "${sanitizeHTML(pItem)}"}>
            </span>
        </p>`)
    }

    $('.removetenant').click(async function() {
        let flag = await Get('Guild.RemoveRankFlag', {
            flag: $(this).attr('num'),
            target: rank,
            guild: item
        })
        guilds[item].ranks[rank][2] = flag
        LoadRankFlags(guilds, item, rank, cid)
    })
}