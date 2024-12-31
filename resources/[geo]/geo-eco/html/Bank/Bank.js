let accounts = []
let bankopen = false
let activeAccunt = 0;
let defAccount = 0;
let creating = false;
let atAtm = false;

window.addEventListener('message', (event) => {
    let data = event.data
    switch(data.interface) {
        case 'bankdata':
            accounts = data.data
            SetAccounts();
            break;
        case 'bank.open':
            bankopen = true;
            atAtm = data.ATM || false
            defAccount = data.account
            activeAccunt = 0
            $('#bank-sidebar').html('<button id = "bank-create" class = "bank-button" >Create Account</button>')
            console.log($('#bank-info').css('font-size'))
            $('#bank').css('display', 'inline');
            setTimeout(() => {
                $('#bank').css('height', '80%');
            }, 100);
            break;
        case 'bank.transactions':
            UpdateTransactions(data.data);
            break;
        case 'bank.finishcreation':
            CreateAccount();
            break;
        case 'bank.finishtransfer':
            SetAccounts(activeAccunt)
            break;
        case 'bank.alert':
            BankAlert(data.text)
            break;
    }
})

async function SetAccounts(forceID) {
    let index = 0;
    if (!bankopen) {
        while (true) {
            await Wait(100)
            index++

            if (bankopen) break;
            if (index > 5) {
                return;
            }
        }
    }

    let elem = $('#bank-sidebar')
    elem.html('<button id = "bank-create" class = "bank-button" >Create Account</button>')
    if (atAtm) elem.html('');

    $('#bank-create').click(() => {
        CreateAccount();
        return;
    })

    let found = false
    for (var item in accounts) {
        if (accounts[item].id === activeAccunt) {
            found = true; 
            break;
        }
    }

    if (!found && !creating) {
        activeAccunt = 0;
        $('#bank-info').html('');
    }

    for (var item in accounts) {
        let _item  = accounts[item]
        let doc = $(document.createElement('button')).addClass('bank-button')
        doc.html(`${_item.name || _item.id}`)

        if (activeAccunt === _item.id) {
            $('#bank-account-balance').html(`$${numberWithCommas(_item.amount)}`);
            LoadUsers(doc, _item)
        }

        doc.click(() => {
            creating = false;
            activeAccunt = _item.id
            let container = $('#bank-info')
            container.html(`
                <div id = "bank-account-info">
                    <p id ="bank-account-name">Account: ${_item.name || _item.id} (${_item.id})</p>
                    <p id ="bank-account-type">Account Type: ${_item.account_type}</p>
                    <p id ="bank-account-balance">$${numberWithCommas(_item.amount)}</p>
                    <button id ="bank-account-delete">Delete Account</p>
                </div>

                ${!atAtm ? `
                    <div id = "bank-account-deposit">
                        <input type = "number" id="bank-account-deposit-field" rows="1" cols="1" placeholder = "Deposit Money">
                    </div>
                ` : '' }

                <div id = "bank-account-withdraw">
                    <input type = "number" id="bank-account-withdraw-field" rows="1" cols="1" placeholder = "Withdraw Money">
                </div>


                ${!atAtm ? `
                    <button id = "bank-account-transfer-button">Transfer Money</button>
                    <div id = "bank-account-namebox">
                        <input type = "text" id="bank-account-namechoice" rows="1" cols="1" placeholder = "Account Name" value = "${_item.name  || ''}">
                    </div>

                    <div id = "bank-account-clients">
                    </div>
                ` : '' }

                
                <div id = "bank-account-transactions">
                    <div class = "loader" id = "bank-transaction-loader"></div>
                </div>

                <input type="checkbox" id="bank-default" ${activeAccunt === defAccount ? "checked" : "unchecked"}>
            `);

            $('#bank-account-withdraw').css('width', atAtm ? '80%' : '35%')

            $('#bank-default').on('input', async function(e) {
                if ($(this).prop('checked')) {
                    let val = await Get('bank.default', {account: _item.id})
                    if (val) {
                        defAccount = _item.id
                    } else {
                        $(this).prop('checked', false)
                    }
                } else {
                    $(this).prop('checked', true)
                }
            })

            LoadUsers(doc, _item)

            $('#bank-account-deposit').keypress(function (e) {
                if(e.which == 13) {
                    e.preventDefault();
                    $.post(`http://${GetParentResourceName()}/bank.deposit`, JSON.stringify({
                        account: _item.id,
                        amount:  $('#bank-account-deposit-field').val()
                    }));
                    $('#bank-account-deposit-field').val('')
                }
            });

            $('#bank-account-withdraw').keypress(function (e) {
                if(e.which == 13) {
                    e.preventDefault();
                    $.post(`http://${GetParentResourceName()}/bank.withdraw`, JSON.stringify({
                        account: _item.id,
                        amount:  $('#bank-account-withdraw-field').val()
                    }));
                    $('#bank-account-withdraw-field').val('')
                }
            });

            $('#bank-account-namechoice').keypress(function (e) {
                if(e.which == 13) {
                    e.preventDefault();
                    $.post(`http://${GetParentResourceName()}/bank.name`, JSON.stringify({
                        account: _item.id,
                        text:  $('#bank-account-namechoice').val()
                    }));
                }
            });

            $('#bank-account-delete').click(function() {
                $.post(`http://${GetParentResourceName()}/bank.delete`, JSON.stringify({
                    account: _item.id,
                })); 
            });

            $('#bank-account-transfer-button').click(function() {
                TransferMoney(_item);
            })

            $.post(`http://${GetParentResourceName()}/bank.gettransactions`, JSON.stringify({
                account: _item.id,
            }));
        })

        if (forceID === _item.id) {
            doc.trigger('click')
        }

        elem.append(doc)
    }
}

function Wait(ms) { return new Promise(res => setTimeout(res, ms)); }

function LoadUsers(doc, _item) {

    if ($('#bank-account-clients-add').is(':focus')) {
        return;
    }

    $('#bank-account-clients').html('')
    let acc = JSON.parse(_item.access)

    let _add = $(document.createElement('div'))
        .attr('type', 'number')
        .attr('id', 'bank-account-clients-item')
        .html(`
            <input type = "number" id = "bank-account-clients-add" placeholder = "Add Person To Account">
        `)

        _add.find('#bank-account-clients-add').keypress(function (e) {
        if(e.which == 13) {
            e.preventDefault();
            _add.find('#bank-account-clients-add').blur()
            $.post(`http://${GetParentResourceName()}/bank.addtoaccount`, JSON.stringify({
                account: _item.id,
                person:  _add.find('#bank-account-clients-add').val()
            }));
            _add.find('#bank-account-clients-add').val('')
        }
    });

    $('#bank-account-clients').append(_add)

    for (var data in acc) {
        let name = acc[data]
        let num = data
        let _nb = $(document.createElement('div')).attr('id', 'bank-account-clients-item') 
        _nb.html(`
            <input type = "text" readonly id = "bank-account-clients-item-name" value = "${name}">
        `)

        _nb.append($(document.createElement('button')).attr('id', 'bank-account-clients-item-remove').html('Remove Client')
            .click(function() {
                $.post(`http://${GetParentResourceName()}/bank.removefromaccount`, JSON.stringify({
                    account: _item.id,
                    person:  num
            }));
        }))

        $('#bank-account-clients').append(_nb)
    }
}

function UpdateTransactions(actions) {
    let elem = $('#bank-account-transactions')
    let container = $(document.createElement('div')).attr('id', 'bank-account-transactions')

    for (var index of actions) {
        let item = index
        let data = JSON.parse(item.data)
        let box = $(document.createElement('div')).attr('id', 'bank-account-transaction-container')

        if (data.type === 'deposit') {
            box.append(`
                <p id = "bank-transaction-type">Deposit</p>
                <p id = "bank-transaction-name">Name: ${item.first} ${item.last}</p>
                <p id = "bank-transaction-deposit">$${numberWithCommas(data.amount)}</p>
                <p id = "bank-transaction-reason">${data.reason}</p>
            `)
        }
        
        if (data.type === 'withdraw') {
            box.append(`
                <p id = "bank-transaction-type">Withdraw</p>
                <p id = "bank-transaction-name">Name: ${item.first} ${item.last}</p>
                <p id = "bank-transaction-withdraw">$${numberWithCommas(data.amount)}</p>
                <p id = "bank-transaction-reason">${data.reason}</p>
            `)
        }

        if (data.type === 'debit') {
            box.append(`
                <p id = "bank-transaction-type">Debit</p>
                <p id = "bank-transaction-name">Name: ${item.first} ${item.last}</p>
                <p id = "bank-transaction-withdraw">$${numberWithCommas(data.amount)}</p>
                <p id = "bank-transaction-reason">${data.reason}</p>
            `)
        }

        container.append(box)
    }

    elem.replaceWith(container)
}

function CreateAccount() {
    creating = true
    let elem = $('#bank-info')
    elem.html(`
        <div id = "bank-createaccount">
            <input type = "text" id = "bank-guild" placeholder = "Guild Name"> 
            <button id = "bank-personal">Personal</button>
            <button id = "bank-business">Business</button>
        </div>
    `)

    $('#bank-personal').click(function() {
        $.post(`http://${GetParentResourceName()}/bank.create`);
        elem.html(`
            <div class = "loader" id = "bank-transaction-loader"></div>
        `)
    })

    $('#bank-business').click(function() {
        $.post(`http://${GetParentResourceName()}/bank.create`, JSON.stringify({
            business: true,
            businessName: $('#bank-guild').val()
        }));

        elem.html(`
            <div class = "loader" id = "bank-transaction-loader"></div>
        `)
    })
}

function TransferMoney(item) {
    let container = $('#bank-info')
    container.html(`
        <div id = "bank-account-info">
            <p id ="bank-account-name">Account: ${item.name || item.id} (${item.id})</p>
            <p id ="bank-account-type">Account Type: ${item.account_type}</p>
            <p id ="bank-account-balance">$${numberWithCommas(item.amount)}</p>
            <button id ="bank-account-delete">Delete Account</p>
        </div>

        <div id = "bank-account-transfer">
            <input type = "number" id="bank-account-transfer-field" rows="1" cols="1" placeholder = "Transfer Amount">
        </div>

        <div id = "bank-account-transferTo">
            <input type = "number" id="bank-account-transferTo-field" rows="1" cols="1" placeholder = "Transfer To Account">
        </div>

        <button id = "bank-transfer-submit">Transfer Money</button>
    `);

    $('#bank-transfer-submit').click(function() {
        $.post(`http://${GetParentResourceName()}/bank.transfer`, JSON.stringify({
            fromAccount: item.id,
            toAccount: $('#bank-account-transferTo-field').val(),
            amount: $('#bank-account-transfer-field').val()
        }));

        container.html(`
            <div class = "loader" id = "bank-transaction-loader"></div>
        `)
    });
}

function BankAlert(text) {
    let elem = $(document.createElement('div')).attr('id', 'bank-alert')
    elem.html(text)

    $('#bank-events').append(elem)
    elem.fadeIn(500);
    setTimeout(() => {
        elem.fadeOut(500)
    }, 2500);
}

document.onkeydown = function(e) {
    if (bankopen) {
        switch (e.keyCode) {
            case 9:
                CloseMenu()
        }
    }
}

function CloseMenu() {
    bankopen = false
    $.post(`http://${GetParentResourceName()}/close`)
    $('#bank').css('height', '0%');
    setTimeout(() => {
        $('#bank').css('display', 'none');
    }, 500);
}

function numberWithCommas(x) {
    x = x.toString();
    var pattern = /(-?\d+)(\d{3})/;
    while (pattern.test(x))
        x = x.replace(pattern, "$1,$2");
    return x;
}