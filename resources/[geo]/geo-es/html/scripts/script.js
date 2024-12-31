let defaultImage = "https://i.imgur.com/3fTnD5Q.png"
let open = false;
let department;
let depimage;
duty = null;

window.addEventListener('message', (event) => {
    let data = event.data
    if (data.type == 'mdt.open') {
        open = true
        duty = data.duty
        $('#mdt').css('display', 'inline')
        if (data.pd == false) {
            $('#sidebar').html(`
                <button class = "mdt_page">Charges</button>
            `)
            OpenCharges();
        } else {
            $('#sidebar').html(`
                <button class = "mdt_page">Profiles</button>
                <button class = "mdt_page">Reports</button>
                <button class = "mdt_page">Charges</button>
                <button class = "mdt_page">Evidence</button>
                <button class = "mdt_page">Charge Editor</button>
                <button class = "mdt_page">Settings</button>
            `)
        }

        $('.mdt_page').click(async function() {
            let page = $(this).html()
            report = null;
    
            switch(page) {
                case 'Profiles':
                    OpenProfiles();
                    break;
                case 'Reports':
                    OpenReports();
                    break;
                case 'Charges':
                    OpenCharges();
                    break;
                case 'Charge Editor':
                    ChargeEditor();
                    break;
                case 'Evidence':
                    OpenEvidence();
                    break;
                case 'Settings':
                    OpenSettings();
                    break;
            }
        })
    }

    if (data.type == 'mdt.image') {
        $('#mdt_image').attr('src', data.data == '' ? "https://i.imgur.com/pfJpfHs.png" : data.data);
        department = data.department;
        depimage = data.data
    } 

    if (data.type == 'mdt.register') {
        OpenProfiles();
    }

    if (data.type == 'mdt.gotcharges') {
        ResetCharges(data.data, data.EMS)
    }
})

document.onkeydown = function(e) {
    if (open || dispatch) {
        switch (e.keyCode) {
            case 9:
                open = false;
                dispatch = false;
                $.post(`http://${GetParentResourceName()}/close`)
                $('#mdt').css('display', 'none');
                $('#dispatch_clear_all').animate({opacity: '0.0'}, 500).css('pointer-events', 'none')
                $('.tooltip').remove()
                $('#dispatch').css('pointer-events', 'none')

                setTimeout(() => {
                    if ((new Date().getTime() - lastCall > 9800) && !dispatch) {
                        $('.dispatch_call').each(function() {
                            if (!(callsign != null && $(this).find('.dispatch_officers').find('.dispatch_info_text').html().match(callsign) != null)) {
                                $(this).slideUp(500)
                            }
                        })
                    }
                }, 10000);

                break;
            case 220:
                $('#mdt').css('opacity', '0.5');
            case 27:

        }
    }
}

document.onkeyup = function(e) {
    if (open) {
        switch (e.keyCode) {
            case 220:
                $('#mdt').css('opacity', '1.0');
        }
    }
}

async function OpenProfiles() {
    let data = await Get('OpenProfile');

    if (!data) return;

    let page = $('#mdt_content');
    $('#profile_active').html('')
    page.html(`
        <div id = "profiles">
            <div class="input_container" id = "profiles_searcher">
                <input type="text" class="input" placeholder="Search Person" id = "profiles_search">
                <img src="img/person.png" id="input_img">
            </div>
        </div>

        <img src="img/newprofile.png" id="profile_new" title = "Create New Profile">
        <div id = "profile_active">
        </div>
    `)

    $('#profile_new').tooltip({
        tooltipClass: "tooltip"
    })

    $('#profile_new').click(function() {
        OpenProflile();
    })

    for(var item of data ) {
        $('#profiles').append(`
            <button class = "profile_option" cid = ${item.cid}>${item.name}</button>
        `)
    }

    $('.profile_option').click(async function() {
        Load()
        OpenProfiles()
        let profile = await Get('LoadProfile', {cid: $(this).attr('cid')})
        OpenProflile(profile)
    })

    let date = new Date().getTime()
    $('#profiles_search').on('input', function() {
        date = new Date().getTime()
        setTimeout(async () => {
            if (new Date().getTime() - date >= 490) {
                let search = await Get('Profiles.Search', {name: $('#profiles_search').val()})
                $('.profile_option').each(function() {
                    $(this).remove()
                });

                for(var item of search ) {
                    $('#profiles').append(`
                        <button class = "profile_option" cid = ${item.cid}>${item.name}</button>
                    `)
                }

                $('.profile_option').click(async function() {
                    Load()
                    OpenProfiles()
                    let profile = await Get('LoadProfile', {cid: $(this).attr('cid')})
                    OpenProflile(profile)
                })
            }
        }, 500);
    })
}

function OpenProflile(pProfile) {
    let page = $('#profile_active')
    page.html(`
        <div class = "mdt_mainbar">
            <img id = "profile_image" src = "${pProfile?.image || defaultImage}" canclick = true>
        
            <div class="input_container" id = "profile_fullname">
                <input type="text" class="input" placeholder="Full Name" id = "profiles_name" value = "${pProfile?.name || ""}">
                <img src="img/person.png" id="input_img">
            </div>

            <div class="input_container" id = "profile_fulldob">
                <input type="text" class="input" placeholder="Date of Birth" id = "profiles_dob" value = "${pProfile?.dob || ""}">
                <img src="img/person.png" id="input_img">
            </div>

            <div class="input_container" id = "profile_fullimage">
                <input type="text" class="input" placeholder="Profile Image" id = "profiles_image" value = "${pProfile?.image || ""}">
                <img src="img/person.png" id="input_img">
            </div>

            <div class="input_container" id = "profile_fullcid">
                <input type="text" class="input" placeholder="CID" id = "profiles_cid" value = "${pProfile?.cid || ""}" ${pProfile != null ? "readonly" : ""}>
                <img src="img/person.png" id="input_img">
            </div>

            <div id = "profile_notes">
                <div id = "profile_notebody" contenteditable = "true" data-placeholder="Enter Notes Here">${pProfile?.notes || ""}</div>
            </div>
        </div>

        <div class = "mdt_sidebar">
            ${pProfile ? 
                `
                <div id = "profile_optionscontainer">
                    ${duty == 'EMS' ? `
                        <div id = "profile_licenses">
                            <p id = "profile_licensesheader">Dead</p>
                            <hr>
                        </div>
                    ` : `
                        <div id = "profile_licenses">
                            <p id = "profile_licensesheader">Licenses</p>
                            <hr>
                        </div>
                    `}
                    

                    ${pProfile.vehicles.length > 0 && duty != 'EMS' ? 
                        `
                        <div id = "profile_Vehicles">
                            <p id = "profile_Vehiclesheader">Vehicles</p>
                            <hr>
                        </div>
                        `: ""}

                    ${pProfile.charges.length > 0 ? 
                        `
                        <div id = "profile_Charges">
                            <p id = "profile_Chargesheader">${duty == 'EMS' ? 'Injuries':'Charges'}</p>
                            <hr>
                        </div>
                        `: ""}
                    ${pProfile.warrants.length > 0 && duty != 'EMS' ? 
                        `
                        <div id = "profile_Warrants">
                            <p id = "profile_Warrantsheader">Warrants</p>
                            <hr>
                        </div>
                        `: ""}
                    ${pProfile.properties.length > 0 && duty != 'EMS' ? 
                        `
                        <div id = "profile_Properties">
                            <p id = "profile_Propertiesheader">Properties</p>
                            <hr>
                        </div>
                        `: ""}
                </div>
                ` 
            : ""}
        </div>

        <img src="img/save.png" id="profile_save" title = "Save Profile">
    `)

    let date = new Date().getTime()
    $('#profiles_image').on('input', function() {
        date = new Date().getTime()
        setTimeout(async () => {
            if (new Date().getTime() - date >= 490) {
                $('#profile_image').attr('src', $(this).val() === "" ? "https://i.imgur.com/3fTnD5Q.png" : $(this).val())
            }
        }, 500);
    })

    $('#profile_save').tooltip({
        tooltipClass: "tooltip"
    })

    $('#profile_save').click(function() {
        Load()
        SaveProfile({
            name: $('#profiles_name').val(),
            dob: $('#profiles_dob').val(),
            image: $('#profiles_image').val(),
            notes: $('#profile_notebody').html(),
            cid: $('#profiles_cid').val(),
            licenses: pProfile?.licenses
        });
    })

    if (pProfile) {
        pProfile.licenses = GetLicenses(pProfile.licenses)
        if (duty != 'EMS') {
            for (var item in pProfile.licenses) {
                $('#profile_licenses').append(`<button class = "profile_licensebutton" id = "${item}" has = "${pProfile.licenses[item]}">${item}</button>`)
            }
        }
       
        if (duty == 'EMS') {
            $('#profile_licenses').append(`<button class = "profile_licensebutton" id = "Dead" has = "${pProfile.licenses['Dead']}">${'Deceased'}</button>`)
        }

        $('.profile_licensebutton').click(function() {
            $(this).attr('has', $(this).attr('has') === 'true' ? 'false' : 'true')
            pProfile.licenses[$(this).attr('id')] = $(this).attr('has') === 'true' ? true : false
        })

        for (var item of pProfile.vehicles) {
            $('#profile_Vehicles').append(`<button class = "profile_vehiclebutton">(${item.id}) ${item.model} - ${item.plate}</button>`)
        }

        for (var item of pProfile.properties) {
            $('#profile_Properties').append(`<button class = "profile_Propertiesbutton">${item.title}</button>`)
        }

        let counts = {};
        let list = duty != 'EMS' ? charges : injuries
        for(var charge of pProfile.charges) {
            let name = list[charge['charge']].title

            if (counts[name] == null) counts[name] = [0, charge['charge']];
            counts[name][0]++
        }

        for (var item in counts) {
            $('#profile_Charges').append(`<button class = "profile_chargesbutton" charge = ${list[counts[item][1]].chargeID}>${list[counts[item][1]].title} x${counts[item][0]}</button>`)
        }

        for (var item of pProfile.warrants) {
            $('#profile_Warrants').append(`<button class = "profile_warrantsbutton" report = ${item.report_id}>${item.title}</button>`)
        }

        $('.profile_chargesbutton').click(async function() {
            Load()
            let data = await Get('GetCharges', {
                cid: pProfile.cid,
                charge: $(this).attr('charge')
            })
            await OpenReports()
            LoadReports(data)
            StopLoad()
        })

        $('.profile_warrantsbutton').click(async function() {
            Load()
            await RefreshReport($(this).attr('report'))
            StopLoad()
        })
    }
    
    ExpandImage()
    StopLoad()
}

async function SaveProfile(data) {
    await Get('SaveProfile', data)
    let profile = await Get('LoadProfile', {cid: data.cid})
    OpenProflile(profile)
}

function GetLicenses(data) {
    data = JSON.parse(data)
    let licenses = {}
    licenses["Drivers License"] = data["Drivers License"] == null ? true : data["Drivers License"];
    licenses["Weapons License"] = data["Weapons License"] == null ? true : data["Weapons License"];
    licenses["Pilots License"] = data["Pilots License"] == null ? false : data["Pilots License"];
    licenses["BAR License"] = data["BAR License"] == null ? false : data["BAR License"];

    if (duty == 'EMS') {
        licenses["Dead"] = data["Dead"] == null ? false : data["Dead"];
    }
    return licenses
}

async function GetPerson() {
    return new Promise(resolve => {
        $('#mdt').css('pointer-events', 'none')
        $('#mdt').append(`
            <div id = "person_search">
                <div class="input_container" id = "person_searcher">
                    <input type="text" class="input" placeholder="Search Person" id = "person_searching">
                    <img src="img/person.png" id="input_img2">
                </div>
            </div>
        `)

        $('#person_search').css('pointer-events', 'all');
        $('#person_searching').focus()
        let date = new Date().getTime()
        $('#person_searching').on('input', function() {
            date = new Date().getTime()
            setTimeout(async () => {
                if (new Date().getTime() - date >= 490) {
                    
                    $('.person_search_container').each(function() {
                        $(this).remove()
                    })
                    
                    Load()
                    let search = await Get('Person.Search', {name: $('#person_searching').val()})
                    StopLoad()
                    for (var item of search) {
                        $('#person_search').append(`
                            <div class = "person_search_container">
                                <img src = "${item.image == "" ? defaultImage : item.image}" id = "person_search_image" canclick = true>
                                <p id = "person_name">${item.name}</p>
                                <p id = "person_cid">CID: ${item.cid}</p>

                                <button class = "person_add" cid = ${item.cid} name = "${item.name}">Add Person</button>
                            </div>
                        `)
                    }

                    $('.person_add').click(function() {
                        $('#mdt').css('pointer-events', 'all')
                        $('#person_search').remove();
                        resolve({
                            cid: Number($(this).attr('cid')),
                            name: $(this).attr('name')
                        })
                    })
                    ExpandImage()
                }
            }, 500);
        })

        $('#person_search').keydown(function(e) {
            if (e.keyCode == 27) {
                $('#mdt').css('pointer-events', 'all')
                $('#person_search').remove();
                resolve(false)
            }
        })
    })
}

function Load() {
   $('#load').css('display', 'inline')
}

function StopLoad() {
    $('#load').css('display', 'none')
}

let bigImg
function ExpandImage(link, elem) {
    if (link) {
        if (bigImg) bigImg.remove();
        $('#imghider').css('display', 'inline')

        bigImg = $(document.createElement('img'))
        bigImg.css('max-width', '50%').css('opacity', '0.0')
        bigImg.attr('src', link)
        $('#imghider').append(bigImg)
        bigImg.css('position', 'fixed')
        .css('top', `${(screen.height / 2) - (parseInt(bigImg.height(), 10) / 2)}px`)
        .css('left', `${(screen.width / 2) - (parseInt(bigImg.width(), 10) / 2)}px`)
        .css('opacity', '1.0')
        setTimeout(() => {
            bigImg.css('position', 'fixed')
                .css('top', `${(screen.height / 2) - (parseInt(bigImg.height(), 10) / 2)}px`)
                .css('left', `${(screen.width / 2) - (parseInt(bigImg.width(), 10) / 2)}px`)
                .css('opacity', '1.0')
        }, 100);
            
        elem.mouseup(function() {
            if (bigImg) bigImg.remove();
            $('#imghider').css('display', 'none')
        }).mouseleave(function() {
            if (bigImg) bigImg.remove();
            $('#imghider').css('display', 'none')
        })
    } else{
        $('img').each(function() {
            if ($(this).attr('canclick')) {
                $(this).mousedown(function() {
                    if (bigImg) bigImg.remove();
                    $('#imghider').css('display', 'inline')
        
                    bigImg = $(document.createElement('img'))
                    bigImg.attr('src', $(this).attr('src'))
                    $('#imghider').append(bigImg)
                        bigImg.css('position', 'fixed')
                            .css('top', `${(screen.height / 2) - (parseInt(bigImg.height(), 10) / 2)}px`)
                            .css('left', `${(screen.width / 2) - (parseInt(bigImg.width(), 10) / 2)}px`)
                  
                }).mouseup(function() {
                    if (bigImg) bigImg.remove();
                    $('#imghider').css('display', 'none')
                }).mouseleave(function() {
                    if (bigImg) bigImg.remove();
                    $('#imghider').css('display', 'none')
                })
            }
        })
    }
}

async function OpenSettings() {
    let page = $('#mdt_content').html('');
    $('#profile_active').html('')

    page.html(`
        <div class="input_container" id = "settings_search">
            <input type="text" class="input" placeholder="Header Image" id = "settings_searcher" value =${depimage}>
            <img src="img/person.png" id="input_img">
        </div>
    `);

    let date = new Date().getTime()
    $('#settings_searcher').on('input', function() {
        date = new Date().getTime()
        setTimeout(async () => {
            if (new Date().getTime() - date >= 490) {
                let head = $(this).val();
                $('#mdt_image').attr('src', head == '' ? "https://i.imgur.com/pfJpfHs.png" : head)
                Get('MDTImage', {
                    department: department,
                    image: head
                })
            }
        }, 500);
    })
}