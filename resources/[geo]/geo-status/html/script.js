let statuses = [];
let statusTimers = {};

window.addEventListener('message', function(event) {
    let data = event.data
    switch(data.job) {
        case 'SetStatus':
            SetStatus(data.status, data.time);
            break;
        case 'Register':
            RegisterStatus(data.status, data.time);
            break;
        case 'Clear':
            ClearStatus();
            break;
    }
})

function SetStatus(statusID, time) {
    if (statusTimers[statusID] == null) {
        console.error(`^1[Status]^0 ${statusID} is not a valid status type`);
    }

    if (typeof time == 'undefined') return;

    if (statuses[statusID] == null) {
        if (time <= 0) return;

        let elem = $(document.createElement('div'));
        elem.addClass('status_container')
        elem.html(`
            <img src = "img/${statusID}.png" id = "status_image">
            <p id = "remaining_time">${GetTimeString(time)}</p>
        `)

        statuses[statusID] = {
            element : elem,
            time : time,
            increment : 0
        }

        $('#status').append(elem);
    } else {
        statuses[statusID].time = time;
    }
}

function RegisterStatus(statusID, timeInc) {
    statusTimers[statusID] = timeInc;
    console.log(`^1[Status]^0 ${statusID} is now registered`)
}

function ClearStatus() {
    for (const key in statuses) {
        statuses[key].element.remove();
        delete statuses[key]
    }
}

function GetTimeString(time) {
    if (time > 10000) return '‏‏‎ ';
    if (time > 3600) return (Math.floor(time / 3600) + 'h');
    if (time >= 60) return (Math.floor(time / 60) + 'm');
    if (time < 60) return time;
}

setInterval(() => {
    for (const key in statuses) {
        statuses[key].time -= 1;
        statuses[key].increment += 1;
        statuses[key].element.find('#remaining_time').html(GetTimeString(statuses[key].time))

        if (statusTimers[key] != null && statuses[key].increment == statusTimers[key]) {
            $.post(`http://${GetParentResourceName()}/status`, JSON.stringify({
                status: key
            })); 
            statuses[key].increment = 0;
        }

        if (statuses[key].time <= 0) {
            $.post(`http://${GetParentResourceName()}/status.done`, JSON.stringify({
                status: key
            })); 
            statuses[key].element.remove();
            delete statuses[key]
        }
    }
}, 1000);