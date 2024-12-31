var helpOpen = false;
known = []
var newPage;

$(function() {
    //CreateHelp(0, 0)

    $('body').append(`
        <div class = "buttonrow">
            <div class = "button_container" menu = "System">
                <div class = "button_system"></div>
            </div>
        </div>
    `)

    $('.button_container').click(function() {
        RowMenu($(this).attr('menu'), $(this))
    })

})

// Crop Images to a 120 / 90 Ratio
let tutortials = {
    0: ["New Character", [
        {
            img: "tutorial_bus",
            description: `You've made a character, great! if you proceed to the area in this picture
                you will recieve a prompt to take the magic school bus, take it to get to the city center
                faster. <br> <br>

                You can click out of the window or press <font color = "gold">TAB</font> to close this message, to enable the UI to interact with these notifications with <font color = "gold">Shift + Left Alt</font>
                and click on "Help Info" from the system try in the bottom right of your screen
            `
        },
    ], "General"],
    1:  ["Starting Out", [
        {
            img: "tutorial_2",
            description: ` So you've taken the bus, now is the time to start your new life, head east and let's get started
            `
        },
        {
            img: "tutorial_3",
            description: `Time to start your first question, interact with this NPC with <font color = "gold">Left Alt</font> and continue forward with this instructions
            `
        },
    ], "General"],
    2:  ["Learning To Shoot", [
        {
            img: "shooting",
            description: `You may have noticed shooting may be a bit difficult, but there are plenty of ways to learn.
            Maybe you like hunting? Maybe a psychopath who likes shooting other people? There are many ways to improve your
            shooing ability but none more efficient than using our range here, we'll get you better in no time
            `
        },
    ], "General"],
    3:  ["Gatherer's Fervor", [
        {
            img: "gathering",
            description: `Congratulations on getting your first gatherer's tool, if you don't have one already you can
            obtain a compass from a hardware store, this will place temporary blips on your map of nodes you can gather from.
            When you reach the nodes use <font color = "gold">Left Alt</font> to interact with them
            `
        },
    ], "Gahtering"],
    4:  ["GoPostal", [
        {
            img: "gopostal",
            description: `Once you start the job a truck will be spawned near you. Take this vehicle and drive it to your 
            delivery destination. Once you get there you can retrieve a box from the trunk of the vehicle. [[Use]] It 
            from your [[inventory]] and bring it to the door of the property to complete the delivery.  
            Repeat this cycle for as many times as you like then bring the vehicle back to the GoPostal depot
            to return the vehicle and collect your pay.

            `
        },
        {
            img: "gopostal2",
            description: `The simplest way to open the back doors of your vehicle would be to use the
            <font color = "gold">Left Alt</font> key to open the back doors.

            `
        },
    ], "Jobs"],
    5:  ["Garbage", [
        {
            img: "garbage",
            description: `Garbage can be done solo or in a group of 2. If you are doing the job solo, 
            drive your garbage truck around the city and find garbage to collect. Once you have found some 
            garbage, walk up to it and use your [[Select Entity]] key (default [[Left Alt]]) to pick up the garbage,
            bring it to the rear of the vehicle, open the trunk and follow the prompt to place it in the truck.
            Repeat this task as much as you like then go back to the start point to return your truck and get 
            paid. 
            `
        },
        {
            img: "garbage",
            description: `If you are doing this as a group everything above still applies, except the person who 
            started the group cannot pick up trash, they are the driver, only the person who joined the group 
            can pick up the trash and put it into the truck.

            `
        },
        {
            img: "garbage2",
            description: `Find trash cans like the ones you may occasionaly rummage through to collect garbage from them through
            [[Left Alt]]

            `
        },
    ], "Jobs"],
    6:  ["Dock Work", [
        {
            img: "dockwork",
            description: `Dock Work involves moving crates around the port of Buccaneer Way. Once you 
            start the job a dock handler will be brought out for you to bring crates to their destinations. 
            `
        },
        {
            img: "dockwork2",
            description: `When you get close to the crate you need to move you can press [[Left Shift]] to raise your grabber 
            and [[Left Control]] to lower it. When the grabber is close enough to the crate it will attach and you
            can move it to the destination. 

            `
        },
        {
            img: "dockwork3",
            description: `Lower the crate onto the target and go on the next crate. 
            Repeat this process as much as you like then return to the start point to return the handler and 
            collect your money.

            `
        },
    ], "Jobs"],
    7:  ["Trucking", [
        {
            img: "trucking",
            description: `When you begin the job you will be charged $100 + tax for a trunk rental. 
            Go out to your truck and connect it to the trailer provided, then you are off to your deliveries. 
            `
        },
        {
            img: "trucking2",
            description: ` Once near a delivery point head to the rear of your trailer, open the back doors and open the 
            [[Inventory]] to retrieve a dolly. Use It from your [[inventory]] and wheel it to the destination to 
            complete the delivery. Repeat this cycle for as many times as you like then bring the vehicle back 
            to the Trucking depot to return the vehicle and collect your pay.
            `
        },
    ], "Jobs"],
    8:  ["Winery", [
        {
            img: "winery",
            description: `Simple but honest work. Head here between the hours of [[5AM]] and [[7PM]] to begin this job.
             Go out in the field and you will be prompted to pick up grapes. Once you have collected the 
             amount asked for and bring them back to the start point. They may want more or you will be asked 
             to deliver them to the vat for processing. Do so to get your payment. Perhaps bring a friend so 
             you don’t have to suffer alone.

            `
        },
    ], "Jobs"],
    9:  ["Hunting", [
        {
            img: "hunting",
            description: `A small job to do in your offtime. Go out into the wild and kill some wild animals, 
            once they’re out take out a [[knife]] and approach the animal, you will be prompted to 
            collect materials from it. You can bring those materials to the hunting lodge for a small sum.


            `
        },
    ], "Jobs"],
    11:  ["Taxi", [
        {
            img: "taxi",
            description: `Once you have started the job, drive around until a fare pops up on your GPS. 
            Pull up to your customer and let them enter the vehicle. Unlike most people you know, 
            the citizens of Los Santos aren’t a fan of batshit insane driving, so maybe try to give them a 
            more calm experience, or they may very well flee your vehicle.


            `
        },
    ], "Jobs"],
    12:  ["Tow", [
        {
            img: "tow",
            description: `Some vehicles need moving, and you are that mover.  To tow a vehicle position your 
            tow capable vehicle in front of the vehicle, go up to your target and open your 
            [[Radial Menu]] (default [[F1]]) and select [[“Tow”]], you will then be prompted with further instructions on 
            how to proceed. 
            `
        },
        {
            img: "tow2",
            description: ` If you are called to a scene by the police and they need you to impound a 
            vehicle, bring it to the impound lot in Roy Lowenstein and drop the vehicle in the “No Parking” 
            zone and use your [[Radial Menu]] on the vehicle to deliver the vehicle and get paid.
            `
        },
    ], "Jobs"],
    13:  ["Repo", [
        {
            img: "repo",
            description: `Add addon to the tow job, while you’re on duty as a tow driver you can accept repo 
            jobs. You’ll be provided with the location of someone who lost the rights to have a vehicle, 
            head to their location and talk to them, some of them might be angry, in these cases it might be 
            best to call a police officer to handle the situation or continue at your own risk. Once this is 
            handled tow the vehicle back to the yard and proceed just like a normal impound.
            `
        },
    ], "Jobs"],
}

function CreateHelp() {
    helpOpen = true
    UISound('open')
    $('.help').remove()
    $('body').append(`
        <div class = "window help">
            <div class = "helpheader">
                <p class = "title">Help</p>
                <div class="img"></div>
            </div>

            <br>
            <div class = "container">
            </div>
        </div>
    `)

    let elem = $('.help')
    zIndex += 1
    elem.css('z-index', zIndex)
    let containers = {}

    for (var item in tutortials) {
        let _item = item
        if (known[String(_item)] || _item < 2) {
            if (!containers[tutortials[item][2]]) {
                elem.find('.container').append(`
                    <div class = "tutcategory Help${tutortials[item][2]}">
                        <div class = "tutheader">
                            <p class = "tut">${tutortials[item][2]}</p>
                        </div>
                    </div>
                    <span style = "margin-bottom:1vh;display:block;"></span>
                `)
                containers[tutortials[item][2]] = true;
            }
            $(`.Help${tutortials[item][2]}`).append(`
            <div class = "tutcontainer">
                 <p class = "tut">${tutortials[item][0]}</p>
            </div>
         `)

         $('.tutcontainer').last().click(function() {
            newPage = true;
            OpenHelp(_item, 0)
         })
        }
    }

    elem.find('.container').css('overflow-y', 'scroll')
    elem.find('.container').css('height', '90%')
    MoveableWindow(elem, '.helpheader')
}

function OpenHelp(id, page) {
    helpOpen = true;

    if (newPage) {
        UISound('open')
        newPage = false;
    }

    let desc = tutortials[id][1][page].description
    desc = desc.replaceAll('[[', '<font color = "gold">')
    desc = desc.replaceAll(']]', '</font>')

    $('.helpcontainer').remove()
    $('body').append(`
        <div class = "window helpcontainer">
            <div class = "help2header">
                <p>${tutortials[id][0]}</p>
                <div class="img"></div>
            </div>
            <div class = "containerbody">
                <div class = "block" style = "width:47%;left:2%">
                    <img src = "nui://geo-interface/html/Help/img/${tutortials[id][1][page].img}.jpg"> 
                </div>

                <div class = "block" style = "width:47%;left:4%">
                    <p class = "helpdesc">${desc}</p>
                </div>
            </div>

            <div class = "helpbottomwarning" style = "width:60%;">
                <p>You can disable these notifications through <br> F1 > Glboal > Settings > Server Help. <br>
                 Shift + Left Alt to Interact with this dialogue
                </p>
            </div>
            <div class = "helppages" style = "left:4%;width:34%;"></div>
        </div>
    `)

    let elem = $('.helpcontainer')

    zIndex += 1
    elem.css('z-index', zIndex)

    for (var item in tutortials[id][1]) {
        elem.find('.helppages').append(`
            <button class = "helppage" page = ${item} ${page == item ? 'selected = true' : ''}>${Number(item) + 1}</button>
        `)
    }

    $('.helppage').click(function() {
        OpenHelp(id, $(this).attr('page'))
    })

    MoveableWindow(elem, '.help2header')
}

$('body').mousedown(function(evt) {
    if ($(evt.target).prop('nodeName') == 'BODY') {
        CloseRowMenu()
        if (helpOpen) {
            CloseMenu()
        }
    }
})

window.addEventListener('done', function() {
    $('.helpcontainer').fadeOut(500, function() {
        $('.helpcontainer').remove()
    })

    $('.help').fadeOut(500, function() {
        $('.help').remove()
    })
    CloseRowMenu()
    $('.buttonrow').css('bottom', '-5vh')
    $('.buttonrow').css('pointer-events', 'none')
    helpOpen = false;
})


let menus = {
    System: [
        ["Help Info", 'CreateHelp()'],
        ["My Referral Code", `Referral()`],
        ["Submit Referral Code", `Referral2()`],
        ["Settings", `CloseMenu();RunCommand('settings')`],
    ]
}

function RowMenu(menu, elem) {
    let data = menus[menu]

    let left = elem.offset().left
    let top = elem.offset().top
    let width = elem.width()

    $('body').append(`
        <div class = "helpselection" style = "bottom:${screen.height - top + 20};right:${screen.width - left - width};">
            <p>${menu}</p>
            <hr>
        </div>
    `)

    for (var item of data) {
        $('.helpselection').append(`
            <div class = "helpoption" onclick = "CloseRowMenu();${item[1]};">
                <p>${item[0]}</p
            </div>
        `)
    }
}

function CloseRowMenu() {
    $('.helpselection').remove()
}

function RunCommand(command) {
    $.post('https://geo-interface/Help.Command', JSON.stringify({command:command}))
}

function Referral() {
    UISound('open')
    $('.Referral').remove()
    let elem = CreateWindow('Referral', 'Referral Code', {remove:true})
    elem.append(`
        <div class = "container">
            <p class = "helper">${user.data.ref}</p>

            <div class = "helpbottomwarning" style = "width:90%; top: 0vh;">
                <p> Provide this code to people you get to join, when they play for 5 hours both you and them will get rewards
                </p>
            </div>
        </div>
    `)
}

function Referral2() {
    UISound('open')
    $('.Referral2').remove()
    let elem = CreateWindow('Referral2', 'Referral Code', {remove:true})
    console.log(JSON.stringify(user))

    if (!user.data.myref) {
        elem.append(`
            <div class = "container">
                <input type = "text" placeholder = "Ref Code"></input>
            </div>
        `)

        elem.find('input').focus().on('keydown', async function(e) {
            if (e.which == 13) {
                let val = $(this).val()
                let complete = await Get(['geo-interface', 'Ref'], {code: val})
                if (complete) elem.remove();
            }
        })

        elem.append(`
            <br>
            <div class = "helpbottomwarning" style = "width:90%;">
                <p>Enter the code given to you, when you have played for 5 hours, on your next login you will recieve your rewards
                </p>
            </div>
        `)
    }


    elem.on('remove', function() {
        UISound('close')
    })
}