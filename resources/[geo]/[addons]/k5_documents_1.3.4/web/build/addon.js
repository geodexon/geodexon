window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.interface == 'Guilds') {
        let guilds = data.data
        if (AVAILABLE_JOBS.length == 0) {
            for (var item in guilds) {
                AVAILABLE_JOBS.push({
                    job: guilds[item].ident,
                    templateGrades: [3],
                    logo: (guilds[item].image || '/web/build/mechaniclogo.jpg')
                })
            }
        } 
    }
    if (data.interface == 'GuildsAdjust') {
        let guilds = data.data
        let found = false
        for (var item in AVAILABLE_JOBS) {
            if (AVAILABLE_JOBS[item].job == guilds[0]) {
                AVAILABLE_JOBS[item].logo = guilds[1].image
                found = true;
                break;
            }
        }

        if (!found) {
            AVAILABLE_JOBS.push({
                job: guilds[0],
                templateGrades: [3],
                logo: (guilds[1].image || '/web/build/mechaniclogo.jpg')
            })
        }
    }
})