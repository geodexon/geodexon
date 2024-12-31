let handle;
document.onkeydown = function(e) {
    switch (e.keyCode) {
        case 9:
            fetch(`https://${GetParentResourceName()}/FinishEdit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
            }).then(resp => resp.json()).then();
            break;
        case 81:
            console.log(handle)
            fetch(`https://${GetParentResourceName()}/placeOnGround`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({
                    handle: handle,
                })
            }).then(resp => resp.json()).then();
            break;
    }
}

window.addEventListener('message', function(event) {
    if (event.data.action == 'setGizmoEntity') {
        handle = event.data.data.handle
    }
})