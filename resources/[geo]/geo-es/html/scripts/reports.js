let report = null;

async function OpenReports() {
    let page = $('#mdt_content');

    let reports = await Get('LoadReports');

    $('#profile_active').html('')
    var d = new Date();
    var utc = Math.floor(d.getTime() / 1000);

    page.html(`
        <div id = "reports">
            <div class="input_container" id = "reports_searcher">
                <input type="text" class="input" placeholder="Search Reports" id = "reports_search">
                <img src="img/person.png" id="input_img">
            </div>
        </div>

        <div id = "profile_active">
            <div class = "mdt_mainbar">
                <div class="input_container" id = "reports_title">
                    <input type="text" class="input" placeholder="Report Title" id = "reports_titler">
                    <img src="img/person.png" id="input_img2">
                </div>

                <div id = "report_body">
                    <textarea id = "report_body_content" contenteditable = true>${
                        `${department} Report \n\nDate: ${d.toLocaleString('en-US', { timeZone: 'America/New_York' })} EST\n\nReport:\n`
                    }</textarea>
                </div>
            </div>

            <div class = "mdt_sidebar">
                <div id = "report_info">
                    <div id = "report_data">
                        <p id = "report_number">Case #:</p>
                        <img src="img/save.png" id="report_save" title = "Save Report">
                        <hr>
                    </div>
                </div>
            </div>
        </div>
    `)

    $('#report_save').tooltip({
        tooltipClass: "tooltip"
    })

    $('#report_save').click(async function() {
        Load()
        let data = await Get('NewReport', {
            title: $('#reports_titler').val(),
            body: $('#report_body_content').val()
        })

        if (data != false) {
            OpenReport(data)
        } else {
            OpenReports()
        }
    })

    for(var item of reports ) {
        $('#reports').append(`
            <div class = "report_option" reportid = "${item.report_id}">
                <p id = "report_option_title">${item.title}</p>
                <p id = "report_option_id">Case #:${item.report_id}</p>
                ${item.locked == 1 ? '<i class="fas fa-lock report_lockicon"></i>' : ''}
            </div>
        `)
    }

    $('.report_option').click(async function() {
        RefreshReport($(this).attr('reportid'))
    })

    let date = new Date().getTime()
    $('#reports_search').on('input', function() {
        date = new Date().getTime()
        setTimeout(async () => {
            if (new Date().getTime() - date >= 490) {
                let search = await Get('Reports.Search', {name: $('#reports_search').val()})
                LoadReports(search)
            }
        }, 500);
    })

    StopLoad()
}

function OpenReport(pReport) {
    report = pReport
    let page = $('#profile_active');
    report.people = JSON.parse(report.people)
    report.officers = JSON.parse(report.officers)
    report.evidence = JSON.parse(report.evidence)

    page.css('pointer-events', pReport.locked == 1 ? 'none' : ' all')

    $('#profile_active').html('')
    page.html(`
        <div class = "mdt_mainbar">
            <div class="input_container" id = "reports_title">
                <input type="text" class="input" placeholder="Report Title" id = "reports_titler" value = "${report.title}" maxlength = 50>
                <img src="img/person.png" id="input_img2">
            </div>

            <div id = "report_body">
                <textarea id = "report_body_content" ${pReport.locked == 1 ? 'readonly' : ''}>${report.body}</textarea>
            </div>
        </div>

        <div class = "mdt_sidebar">
            <div id = "report_info">
                <div id = "report_data">
                    <p id = "report_number" reportid = "${report.report_id}">Case #: ${report.report_id}</p>
                    <img src="img/save.png" id="report_save" title = "Save Report">
                    <img src="img/lock.png" id="report_lock" title = "Lock Report">
                    <img src="img/evidence.png" id="report_evidenceopen" title = "Open Evidence">
                    <hr>

                    <div id = "report_persons">
                        <p id = "report_add">Add Person</p>
                        <img src="img/newprofile.png" id="report_addperson" title = "Add Person">
                    </div>
                    <br>
                </div>
            </div>
        </div>
    `)

    $('#report_save').tooltip({
        tooltipClass: "tooltip"
    })

    $('#report_lock').tooltip({
        tooltipClass: "tooltip"
    })

    $('#report_evidenceopen').tooltip({
        tooltipClass: "tooltip"
    })

    $('#report_addperson').tooltip({
        tooltipClass: "tooltip"
    })


    $('#report_evidenceopen').click(function() {
        document.dispatchEvent(new KeyboardEvent('keypress',{'key':'TAB'}));
        Get('OpenEvidence', {evidence: report.report_id})
    })


    $('#report_addperson').click(async function() {
        let person = await GetPerson();
        if (!person) return;
        for(var item of report.people) {
            if (item.cid == person.cid) return;
        }

        report.people.push({
            cid: person.cid,
            charges: {},
            name: person.name
        })

        Load()
        let data = await Get('SaveReport', {
            title: $('#reports_titler').val(),
            body: $('#report_body_content').val(),
            id: $('#report_number').attr('reportid'),
            people: report.people,
            officers : report.officers,
            evidence : report.evidence,
        })
        StopLoad()

        if (data != false) {
            OpenReport(data)
        }
    })

    $('#report_save').click(async function() {
        Load()
        let data = await Get('SaveReport', {
            title: $('#reports_titler').val(),
            body: $('#report_body_content').val(),
            id: $('#report_number').attr('reportid'),
            people: report.people,
            officers : report.officers,
            evidence : report.evidence,
        })

        if (data != false) {
            OpenReport(data)
        }
    })

    $('#report_lock').click(async function() {
        let val = await Confirm('Are you sure you would like to lock this report? Once done, this report cannot be edited again')
        if (val) {
            await Get('LockReport', {
                report: report.report_id
            })
            RefreshReport(report.report_id)
        } 
    })

    ReformPeople(report)

    $('#report_data').append(`
        <div id = "report_officers">
            <p>${duty != 'EMS' ? 'Officers' : 'Medics'} Involved</p>
            <hr>
            <button id = "report_addofficer">Add ${duty != 'EMS' ? 'Officer' : 'Medic'}</button>
        </div>
    `)

    if (duty != 'EMS') {
        $('#report_data').append(`
            <div id = "report_evidence">
                <p>Evidence</p>
                <hr>
                <button id = "report_addevidence">Add Evidence</button>
            </div>
        `)
    }
    

    LoadOfficers()
    LoadEvidence()

    $('#report_addofficer').click(async function() {
        let person = await GetPerson();
        if (!person) return;
        for(var item of report.officers) {
            if (item.cid == person.cid) return;
        }

        report.officers.push({
            cid: person.cid,
            name: person.name
        })

        Load()
        let data = await Get('SaveReport', {
            title: $('#reports_titler').val(),
            body: $('#report_body_content').val(),
            id: $('#report_number').attr('reportid'),
            people: report.people,
            officers: report.officers,
            evidence: report.evidence,
        })
        StopLoad()
        if (data != false) {
            OpenReport(data)
        }
    })

    $('#report_addevidence').click(async function() {
        let evidence = await GetEvidence();
        if (!evidence) return;
        if (evidence.ident != "" && evidence.name != "") {
            if (evidence.type == 'Vehicle') evidence.ident = 'VIN: '+evidence.ident
            for(var item of report.evidence) {
                if (item.ident == evidence.ident) return;
            }
    
            report.evidence.push(evidence)

            Load()
            let data = await Get('SaveReport', {
                title: $('#reports_titler').val(),
                body: $('#report_body_content').val(),
                id: $('#report_number').attr('reportid'),
                people: report.people,
                officers: report.officers,
                evidence: report.evidence,
            })
            StopLoad()
            if (data != false) {
                OpenReport(data)
            }
        }
    })

    if (pReport.locked) {
        $('.report_addevidence').css('pointer-events', 'all')
        $('#report_body_content').css('pointer-events', 'all')
    }

    StopLoad()
}


async function ReformPeople() {
    $('.report_person_cont').each(function() {
        $(this).remove()
    })

    for (var item of report.people) {
        let pItem = item;
        let elem = $(document.createElement('div')).addClass('report_person_cont');
        let counts = {};

        elem.append(`
            <p id = "report_person_name">${pItem.name} #${pItem.cid}</p>
            <img src = "img/x.png" class = "report_person_remove" title = "Remove Person">
            <img src="img/newprofile.png" class="report_person_op" title = "Open Profile">
            <hr>
            <button class = "report_addcharge" cid = ${pItem.cid}>Add ${duty != 'EMS' ? 'Charge' : 'Injury'}</button>
        `)

        elem.find('.report_person_op').click(async function() {
            if (await Confirm('Would you like to open their profile?')) {
                Load()
                OpenProfiles()
                let profile = await Get('LoadProfile', {cid: pItem.cid})
                OpenProflile(profile)
            }
        })

        if (report.charges) {
            let list = duty != 'EMS' ? charges : injuries
            for(var charge of report.charges) {
                if (charge.cid == pItem.cid) {
                    console.log(charge.charge)
                    let name = list[charge['charge']].title
    
                    if (counts[name] == null) counts[name] = [0, charge['charge']];
                    counts[name][0]++
                }
            }
        }

        for (var name in counts) {
            elem.append(`
                <button class = "report_addcharge" cid = ${pItem.cid} charge = ${counts[name][1]} remove = true>${name} x${counts[name][0]}</button>
            `)
        }

        elem.append(`
            <br>
            ${report.charges.length > 0 && duty != 'EMS' ? `
                <input type = "checkbox" class = "report_iswarrant" ${GetWarrant(report.charges, pItem.cid) == 1 ? "checked" : ""}>
                <p class = "report_warrantlabel">Warrant</p>
            ` : ""}
            <p class = "charge_info">${numberWithCommas(GetMonths(report.charges, pItem.cid))} Months | $${numberWithCommas(GetFine(report.charges, pItem.cid))} Fine</p>
        `)

        if (duty == 'EMS') {
            elem.find('.charge_info').remove()
            elem.css('margin-bottom', '3vh')
        }

        $('#report_data').append(elem)

        $('.report_person_remove').tooltip({
            tooltipClass: "tooltip"
        })

        $('.report_person_op').tooltip({
            tooltipClass: "tooltip"
        })

        elem.find('.report_iswarrant').click(async function() {
            await Get('SetWarrant', {
                warrant: $(this).prop('checked'),
                report: report.report_id,
                cid: pItem.cid,
            })
            RefreshReport(report.report_id)
        })
    }

    $('.report_person_remove').click(async function() {
        let id = Number($(this).parent().find('.report_addcharge').attr('cid'))
        for (var option in report.people) {
            if (report.people[option].cid == id) {
                report.people.splice(option, 1);

                Load()
                let data = await Get('SaveReport', {
                    title: $('#reports_titler').val(),
                    body: $('#report_body_content').val(),
                    id: $('#report_number').attr('reportid'),
                    people: report.people,
                    officers : report.officers,
                    person: id,
                    evidence: report.evidence,
                })
                if (data != false) {
                    OpenReport(data)
                }
                StopLoad()

                break;
            }
        }
    })

    $('.report_addcharge').click(async function() {
        if ($(this).attr('remove') != "true") {
            OpenCharges(report.report_id, $(this).attr('cid'))
        } else {
            let rem = await Get('RemoveCharge', {
                charge: $(this).attr('charge'),
                report: report.report_id,
                cid : $(this).attr('cid'),
            });

            RefreshReport(report.report_id)
        }
    })
}

async function LoadOfficers() {
    $('.report_addofficer').each(function() {
        $(this).remove()
    })

    for (var item of report.officers) {
        $('#report_officers').append(`
            <button class = "report_addofficer" cid = ${item.cid}>${item.name}</button>
        `)
    }

    $('.report_addofficer').click(async function() {
        let id = Number($(this).attr('cid'))
        for (var option in report.officers) {
            if (report.officers[option].cid == id) {
                report.officers.splice(option, 1);

                Load()
                let data = await Get('SaveReport', {
                    title: $('#reports_titler').val(),
                    body: $('#report_body_content').val(),
                    id: $('#report_number').attr('reportid'),
                    people: report.people,
                    officers : report.officers,
                    person: id,
                    evidence: report.evidence,
                })
                if (data != false) {
                    OpenReport(data)
                }
                StopLoad()

                break;
            }
        }
    })
}

function GetTitle(item) {
    switch(item.type) {
        case 'DNA':
            return 'DNA: '+item.ident;
        case 'Bullet':
            return 'Serial: '+item.ident;
        case 'Vehicle':
            return item.ident;
        default:
            return ''
    }
}

async function LoadEvidence() {
    $('.report_addevidence').each(function() {
        $(this).remove()
    })

    for (var item of report.evidence) {
        $('#report_evidence').append(`
            <button class = "report_addevidence" type = ${item.type} ident = "${item.ident}" title = "${GetTitle(item)}">${item.type} - ${item.name != null ? item.name : item.ident}</button>
            <i class="fas fa-trash-alt report_removeevidence" ident = "${item.ident}" title = "Remove Evidence"></i>
        `)
    }

    $('.report_removeevidence').tooltip({
        tooltipClass: "tooltip"
    })

    $('.report_addevidence').tooltip({
        tooltipClass: "tooltip"
    })

    $('.report_addevidence').mousedown(async function(e) {
        if ($(this).attr('type') == 'Picture') {
            ExpandImage($(this).attr('ident'), $(this))
        } else if ($(this).attr('type') == 'DNA') {
            Load()
            let id = await Get("SearchDNA", {
                DNA: $(this).attr('ident')
            })
            StopLoad()

            if (id) {
                if (await Confirm('Would you like to open their profile?')) {
                    Load()
                    OpenProfiles()
                    let profile = await Get('LoadProfile', {cid: id.cid})
                    OpenProflile(profile)
                }
            } else {
                Confirm('No match found For this DNA')
            }
        } else if ($(this).attr('type') == 'Bullet') {
            if (e.which == 3) {
                Copy($(this).attr('ident'))
                return;
            }
            if (await Confirm('Would you like to load reports matching this casing?')) {
                Load()
                let reports = await Get('FindReportsFprCasing', {
                    casing : $(this).attr('ident')
                })
                LoadReports(reports)
                StopLoad()
            }
        }  else if ($(this).attr('type') == 'Vehicle') {
            if (await Confirm('Would you like to load reports matching this Vehicle?')) {
                Load()
                let reports = await Get('FindReportsFprCasing', {
                    casing : $(this).attr('ident')
                })
                LoadReports(reports)
                StopLoad()
            }
        }
    })

    $('.report_removeevidence').click(async function() {
        let id = ($(this).attr('ident'))
        for (var option in report.evidence) {
            if (report.evidence[option].ident == id && await Confirm("Would you like to remove this evidence?")) {
                report.evidence.splice(option, 1);

                Load()
                let data = await Get('SaveReport', {
                    title: $('#reports_titler').val(),
                    body: $('#report_body_content').val(),
                    id: $('#report_number').attr('reportid'),
                    people: report.people,
                    officers : report.officers,
                    person: id,
                    evidence: report.evidence,
                })
                if (data != false) {
                    OpenReport(data)
                }
                StopLoad()

                break;
            }
        }
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

async function RefreshReport(reportid, open) {
    Load()
    let data = await Get('OpenReport', {
        id: reportid
    })

    if (data != false) {
        OpenReport(data)
    } else {
        OpenReports()
    }
}

function LoadReports(data) {
    $('.report_option').each(function() {
        $(this).remove()
    });

    for(var item of data ) {
        $('#reports').append(`
            <div class = "report_option" reportid = "${item.report_id}">
                <p id = "report_option_title">${item.title}</p>
                <p id = "report_option_id">Case #:${item.report_id}</p>
                ${item.locked == 1 ? '<i class="fas fa-lock report_lockicon"></i>' : ''}
            </div>
        `)
    }

    $('.report_option').click(async function() {
        RefreshReport($(this).attr('reportid'))
    })
}

function GetMonths(pCharges, cid) {
    let count = 0;
    for(var charge of pCharges) {
        if (charge.cid == cid) count+= charges[charge['charge']].time
    }

    return count;
}

function GetFine(pCharges, cid) {
    let count = 0;
    for(var charge of pCharges) {
        if (charge.cid == cid) count+= charges[charge['charge']].fine;
    }

    return count;
}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

$(function() {
    $('#mdt_content').keydown(function(e) {
        if ( e.ctrlKey && ( e.which == 83 ) ) {
            $('#report_save').trigger('click')
        }
    })
})

function GetWarrant(data, cid) {
    for (var item of data) {
        if (item.cid == cid) {
            return item.warrant
        }
    }
}

async function GetEvidence() {
    return new Promise(resolve => {
        $('#mdt').css('pointer-events', 'none')
        $('#mdt').append(`
            <div id = "person_search" class = "Evidence">
                <p>Add Evidence</p>
                <hr>
                <label for="evidence_type" class = "evidence_label">Evidence Type</label>
                <select name="evidence" id="evidence_type">
                    <option value="Picture">Picture</option>
                    <option value="Bullet">Bullet Casing</option>
                    <option value="DNA">DNA</option>
                    <option value="Vehicle">Vehicle</option>
                </select>
                <br>
                <label for="evidence_field" class = "evidence_label">Evidence Indentifier</label>
                <input type = "text" class = "evidence_field evidence_ident" placeholder = "Evidence Indentifier">

                <label for="evidence_field" class = "evidence_label">Evidence Name</label>
                <input type = "text" maxlength = "30" class = "evidence_field evidence_name" placeholder = "Evidence Name">

                <button id = "helper_confirm_yes" style = "margin-bottom:2em;">Confirm</button>
                <button id = "helper_confirm_no" style = "margin-bottom:2em;">Deny</button>
            </div>
        `)

        $('#helper_confirm_yes').click(function() {
            resolve({
                type: $('#evidence_type').val(),
                ident: $('.evidence_ident').val(),
                name: $('.evidence_name').val(),
            })
            $('#mdt').css('pointer-events', 'all')
            $('#person_search').remove();
        })

        $('#helper_confirm_no').click(function() {
            resolve()
            $('#mdt').css('pointer-events', 'all')
            $('#person_search').remove();
        })

        $('.evidence_label').focus()
        $('#evidence_type').on('input', function() {
            $(this).nextAll().remove();
            if ($(this).val() == 'Picture') {
                $('#person_search').append(`
                    <label for="evidence_field" class = "evidence_label">Evidence Indentifier</label>
                    <input type = "text" class = "evidence_field evidence_ident" placeholder = "Evidence Indentifier">

                    <label for="evidence_field" class = "evidence_label">Evidence Name</label>
                    <input type = "text" class = "evidence_field evidence_name" placeholder = "Evidence Name">
                `)
            } else if ($(this).val() == 'DNA') {
                $('#person_search').append(`
                    <label for="evidence_field" class = "evidence_label">Evidence Indentifier</label>
                    <input type = "text" class = "evidence_field evidence_ident" placeholder = "Evidence Indentifier">
                `)
            } else if ($(this).val() == 'Bullet') {
                $('#person_search').append(`
                    <label for="evidence_field" class = "evidence_label">Evidence Indentifier</label>
                    <input type = "text" class = "evidence_field evidence_ident" placeholder = "Evidence Indentifier">

                    <label for="evidence_field" class = "evidence_label">Evidence Name</label>
                    <input type = "text" class = "evidence_field evidence_name" placeholder = "Evidence Name">
                `)
            } else if ($(this).val() == 'Vehicle') {
                $('#person_search').append(`
                    <label for="evidence_field" class = "evidence_label">Evidence Indentifier</label>
                    <input type = "text" class = "evidence_field evidence_ident" placeholder = "Evidence Indentifier">

                    <label for="evidence_field" class = "evidence_label">Evidence Name</label>
                    <input type = "text" class = "evidence_field evidence_name" placeholder = "Evidence Name">
                `)
            }

            $('#person_search').append(`
                <button id = "helper_confirm_yes" style = "margin-bottom:2em;">Confirm</button>
                <button id = "helper_confirm_no" style = "margin-bottom:2em;">Deny</button>
            `)

            $('#helper_confirm_yes').click(function() {
                resolve({
                    type: $('#evidence_type').val(),
                    ident: $('.evidence_ident').val(),
                    name: $('.evidence_name').val(),
                })
                $('#mdt').css('pointer-events', 'all')
                $('#person_search').remove();
            })
    
            $('#helper_confirm_no').click(function() {
                $('#mdt').css('pointer-events', 'all')
                $('#person_search').remove();
                resolve()
            })
        })

        $('#person_search').css('pointer-events', 'all');
        $('#person_search').keydown(function(e) {
            if (e.keyCode == 27) {
                $('#mdt').css('pointer-events', 'all')
                $('#person_search').remove();
                resolve(false)
            }
        })
    })
}