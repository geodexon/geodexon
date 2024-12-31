let textbox = false;
let choice = false;
let logg = false;
let willWin = false;
let game = false;
let gameInterval
let gameInterval2;
let diag = false
let elems = [];


let sounds = []

$(function(){
    window.addEventListener('message', function (event) {
        if (event.data.type == 'Inform') {
            Notification(event.data.text, event.data.time, event.data.center)
        }
        else if (event.data.type == 'Sound') {
            var audio = new Audio('sounds/'+event.data.sound)
            audio.volume = event.data.volume;
            audio.play()
            sounds.push(audio)
        }
    
        else if (event.data.type == 'progress') {
            ProgressBar(event.data.time, event.data.id, event.data.title)
        }
    
        else if (event.data.type == 'terminate') {
            Terminate(event.data.id)
        }

        else if (event.data.type == 'minigame') {
            $('body').append(`
                <div id = "minigame">
                    <div id = "minigame-bg"></div>
                    <div id = "minigame-win"></div>
                </div>
            `)
            
            let timeAmount = event.data.speed || 5000;
            willWin = false;
            game = true;
            let num =  (100 - event.data.challenge - (Math.random() * 100))
            num = num < 30 ? 30 : num;
            $('#minigame-win').css('left', `${num}%`)
            $('#minigame-win').css('width', `${event.data.challenge}%`)
            $('#minigame').css('opacity', `1.0`);
            $('#minigame-bg').css('transition', `all ${timeAmount / 1000}s linear`).css('width', '100%');

            let range = [$('#minigame-win').css('left'), $('#minigame-win').css('width')]
            let elem =  $('#minigame-bg')
            let match = 0;
            let last = 0;
            gameInterval = setInterval(() => {
                let num1 = Number(elem.css('width').split('px')[0])
                let num2 = Number(range[0].split('px')[0])
                let num3 = Number(range[1].split('px')[0])


                if (num1 > num2 && num1 < (num2 + num3)) {
                    $('#minigame-win').css('background-color', 'green');
                    willWin = true;
                } else {
                    willWin = false;
                    $('#minigame-win').css('background-color', 'rgba(200, 70, 70)')
                }
            }, 0);

            gameInterval2 = setInterval(() => {
                let num1 = Number(elem.css('width').split('px')[0])
                if (last == num1) {
                    match++
                    if (match == 5) {
                        EndGame();
                    }
                } else {
                    match = 0;
                }

                last = num1
            }, 100);
        }

        else if (event.data.type === 'Sound.Stop') {
            for (var item of sounds) {
                item.pause();
            }
        }

        if (event.data.interface === 'dialogue') {
            Dialogue(event.data.data)
        }

        if (event.data.type === 'Confirm2') {
            Confirm2(event.data.message, event.data.id)
        }
    });
})

let tInputData =''

$(function() {
    tInputData = $('#tin').html();
})

let tInputData2 = '<p id = "nText"> Input Text </p><p id = "nDesc"> Input Text </p><div id = "gField"><p id = "tInput2"> </p>    <img src = "Yes.png" id = "yes">    <img src = "No.png" id = "no"></div>'

window.addEventListener('message', function (event) {
    if (event.data.type == 'textinput') {
        if (event.data.notif) {
            $('#tin').html(tInputData2);
            $('#nText').html('System Notification');
            $('#tInput2').html(event.data.blob);
            choice = true;
        } else {
            $('#tin').html(tInputData);
            $('#nText').html('Input Text');
            $('#tInput').focus();
            $('#tInput').attr('maxlength', event.data.len)
        }
        $.post("http://geo-shared/OpenSound", JSON.stringify({}));
        $('#nDesc').html((event.data.desc || ''));

        $('#tin').css('opacity', '1.0')
        $('#tin').css('height', '35%')
        $('#gField').css('scale', '1 1')
        $('#yes').css('opacity', '1.0')
        $('#no').css('opacity', '1.0')
        textbox = true;

        document.getElementById('yes').addEventListener('click', function (e) {
            $('#tin').css('opacity', '0.0');
            $('#tin').css('height', '16.625%')
            $('#gField').css('scale', '1 1')
            let val = ($('#tInput').val())
            $('#tInput').val("")
            val = returnEscapedHtml(val);

            if (choice) {
                val = true;
                choice = false;
                $('#tInput2').val("")
            }
            
            $.post("http://geo-shared/Result", JSON.stringify({val}));
            $.post("http://geo-shared/SelectSound", JSON.stringify({}));
            textbox = false;
            $('#nDesc').html('');
            CloseMenu();
        });
        
        document.getElementById('no').addEventListener('click', function (e) {
            $('#tin').css('opacity', '0.0');
            $('#tin').css('height', '16.625%')
            $('#gField').css('scale', '1 0')
            $('#yes').css('opacity', '0.0')
            $('#no').css('opacity', '0.0')
            let val = ""
            $('#tInput').val("")
            val = returnEscapedHtml(val);

            if (choice) {
                val = false;
                choice = false;
                $('#tInput2').val("")
            }

            $.post("http://geo-shared/Result", JSON.stringify({val
            }));
            $.post("http://geo-shared/SelectSound", JSON.stringify({}));

            textbox = false;
            $('#nDesc').html('');
            CloseMenu();
        });
    }
});

window.addEventListener('message', function (event) {
    if (event.data.type == 'log') {
        var today = new Date();
        var id = document.getElementById('log');
        id.innerHTML = id.innerHTML + "<p id = \"logElement\">["+today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds()+"] "+event.data.text+"</p>"
        id.scrollTop = id.scrollHeight;
    }
    if (event.data.type == 'logHUD') {
        if (event.data.log) {
            document.getElementById('log').style.opacity = "1.0";
            logg = true;
        }
        else {
            document.getElementById('log').style.opacity = "0.0";
            logg = false;
        }
    }
});

function Notification(text, time, center) {
    if (!center) {
        let elem = $(document.createElement('div'))
        elem.addClass('notif')
        elem.html(text)
        elem.css('opacity', '0.0')
        $('#notif').append(elem)
        elem.animate({opacity: 1.0}, 500)
        setTimeout(() => {
            elem.animate({opacity: 0.0}, 500, () => {
                elem.remove();
            })
        }, (time || 2500));
    } else {
        let elem = $(document.createElement('div'))
        elem.addClass('notif')
        elem.html(text)
        elem.css('opacity', '0.0')
        elem.css('text-align', 'center')
        elem.css('display', 'block')
        elem.css('font-size', '1.75vh')
        elem.css('width', 'auto')
        $('#notif2').append(elem)
        elem.animate({opacity: 1.0}, 500)
        setTimeout(() => {
            elem.animate({opacity: 0.0}, 500, () => {
                elem.remove();
            })
        }, (time || 2500));
    }
}

var allowed = true;
document.onkeydown = checkKey;
document.onkeyup = allowKey;

function allowKey(e) {
	if (e.keyCode == '16' && allowed == false) {
		allowed = true;
	}
}

function checkKey(e) {
    e = e || window.event;

    if (textbox) {
        if (e.keyCode == '13') {
            $('#tin').css('opacity', '0.0');
            let val = ($('#tInput').val())
            $('#tin').css('height', '16.625%')
            $('#gField').css('scale', '1 0')
            $('#yes').css('opacity', '0.0')
            $('#no').css('opacity', '0.0')
            $('#tInput').val("")
            val = returnEscapedHtml(val);

            if (choice) {
                val = true;
                choice = false;
                $('#tInput2').val("")
            }

            $.post("http://geo-shared/Result", JSON.stringify({val
            }));
            $.post("http://geo-shared/SelectSound", JSON.stringify({}));

            CloseMenu();
            $('#nDesc').html('');
            textbox = false;
        }

        if (e.keyCode == '27') {
            $('#tin').css('opacity', '0.0');
            $('#tin').css('height', '16.625%')
            $('#gField').css('scale', '1 0')
            $('#yes').css('opacity', '0.0')
            $('#no').css('opacity', '0.0')
            let val = ""
            $('#tInput').val("")
            val = returnEscapedHtml(val);

            if (choice) {
                val = false;
                choice = false;
                $('#tInput2').val("")
            }

            $.post("http://geo-shared/Result", JSON.stringify({val
            }));
            $.post("http://geo-shared/SelectSound", JSON.stringify({}));

            CloseMenu();
            $('#nDesc').html('');
            textbox = false;
        }
    } else {
    }

    if (logg) {
        if (e.keyCode == 9) {
            CloseMenu();
            logg = false;
        }
    }

    if (game) {
        if (e.keyCode == 69) {
            EndGame()
        }
    }

    if (diag && e.keyCode == '27') {
        $.post("http://geo-shared/Dialogue", JSON.stringify({}));
        $('#dialogue').css('display', 'none');
        diag = false;
    }

    if (diag && e.keyCode == '13') {
        let list = []
        for(var item of elems) {
            list.push(item.find('.input').val())
        }

        $.post("http://geo-shared/Dialogue", JSON.stringify({data: list}));
        $('#dialogue').css('display', 'none');
        diag = false;
    }
}

function EndGame() {

    if (!game) return;

    clearInterval(gameInterval)
    clearInterval(gameInterval2)
    $('#minigame').remove();
    game = false;
    $.post("http://geo-shared/minigame", JSON.stringify({
        win: willWin
    }));
}

function CloseMenu() {
    $.post("http://geo-shared/Focus", JSON.stringify({
    }));
}

function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
      if ((new Date().getTime() - start) > milliseconds){
        break;
      }
    }
  }

function returnEscapedHtml(string) {
    // This function returns the HTML entity escaped version of a string
    // Do NOT depend on this for security, you must always perform the same procedure in the backend!

    if (string === "") {
        return "";
    }

    var entityMap = {
        "<": "",
        ">": "",
        /* "&": "&amp;",
        '"': '&quot;',
        "'": '&#39;',
        "/": '&#x2F;' */
    };

    if (typeof string === "undefined") {
        return "";
    } else {
        return String(string).replace(/[<>]/g, function (s) {
            return entityMap[s];
        });
    }
}

let lst = []
let $active = null;
async function ProgressBar(time, id, title) {
    let derp =  $(document.createElement('div'));
    derp.addClass('progressbar')
    derp.html("<p id = txt>"+title+"</p><div id = ex"+id+" </div>")
    lst[id] = derp;
    $('#merp').append(derp);
    derp.animate({opacity: '1.0'}, 0)
    $('#ex'+id).css('transition', `all ${time / 1000}s linear`).css('width', '100%');
    $(derp).animate({left: '0%'}, 500)
    setTimeout(() => {
        if (lst[id]) {
            lst[id].animate({left: '-55%'}, 500)
            lst[id].fadeOut(500, function() {
                lst[id].remove()
                lst[id] = null;
            })
        }
    }, time);
}

async function Terminate(id) {
    if (lst[id]) {
        lst[id].animate({left: '-55%'}, 500)
        lst[id].fadeOut(500, function() {
            lst[id].remove()
            lst[id] = null;
        })
    }
}

var players = {};
window.addEventListener('message', function(event) {
    if (event.data.submissionType == "sendSound") {
        var i = event.data.soundIndex;
        players[i] = new Howl({src: ["./sounds/" + event.data.submissionFile]});
        //Howler.pos(event.data.playerPos.x,event.data.playerPos.y,event.data.playerPos.z);
        //Howler.orientation(event.data.camDir.x,event.data.camDir.y,event.data.camDir.z,0,0,1);
        //players[i].pos(event.data.pos.x,event.data.pos.y,event.data.pos.z);
        players[i].volume(event.data.volume);
        players[i].pannerAttr({
            panningModel: 'HRTF',
            rolloffFactor: 1,
            distanceModel: 'linear',
            maxDistance:100
        });

        setTimeout(() => {
            players[i].play();
            players[i].on('end',function(){
                $.post(`http://${GetParentResourceName()}/discardSound`,JSON.stringify({index:i}));
            });
        }, 100);
       
    }
    else if(event.data.submissionType == "updateVolume"){
        var i = event.data.soundIndex;
        //Howler.pos(event.data.playerPos.x,event.data.playerPos.y,event.data.playerPos.z);
        //Howler.orientation(event.data.camDir.x,event.data.camDir.y,event.data.camDir.z,0,0,1);
        //players[i].pos(event.data.lpos.x,event.data.lpos.y,event.data.lpos.z);
        players[i].volume(event.data.volume);
       
    }
});

function Dialogue(data) {
    elems = [];
    diag = true;

    $('.input_container').each(function() {
        $(this).remove()
    })

    $('#dialogue').html(`
        <p id = "dialogue_title">${data[0].title}</h>
        <hr>
        <br>
    `)

    let count = 0;
    for(var item of data) {
        let element = $(document.createElement('div'))
        element.addClass('input_container')
        .html(`
            <input type="${item.type || 'text'}" class="input" placeholder="${item.placeholder}" value = "${item.value || ""}">
            <img src="${item.image}.png" id="input_img">
        `)

        $('#dialogue').append(element)
        elems.push(element)

        element.attr('id', `inputID${count}`)
        count++
    }

    $('#dialogue').append(`
        <button id = "confirm">Confirm</button>
        <button id = "deny">Cancel</button>
    `)

    $('#confirm').click(function() {
        let list = []
        for(var item of elems) {
            list.push(item.find('.input').val())
        }

        $.post("http://geo-shared/Dialogue", JSON.stringify({data: list}));
        $('#dialogue').css('display', 'none');
        diag = false;
    })

    $('#deny').click(function() {
        $.post("http://geo-shared/Dialogue", JSON.stringify({data: []}));
        $('#dialogue').css('display', 'none');
        diag = false;
    })

    $('#dialogue').css('height', `auto`)
    let height = $('#dialogue').height()
    $('#dialogue').css('top', `calc(50% - ${$('#dialogue').height() / 2}px)`)
    $('#dialogue').css('height', `0`)
    $('#dialogue').css('display', 'inline')
    $('#dialogue').animate({height: height}, 250, function() {
        elems[0].find('.input').focus();
    })
}

async function Confirm2(message, id) {
    $.post("http://geo-shared/Confirm2", JSON.stringify({bool: await Confirm(message), id: id}));
}