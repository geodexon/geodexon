window.addEventListener('message', function(evt) {
    let data = evt.data

    if (data.interface == 'Store') {
        interFaceOpen = 'Store'
        let elem = CreateWindow('Store', 'Store', {remove: true, sound: 'open'})

        elem.append(`
            <table>
                <tr>
                    <th class = style = "width:5%;"></th>
                    <th class = style = "width:25%;">Item</th>
                    <th style = "width:40%;">Amount</th>
                    <th style = "width:30%;">Cost</th>
                </tr>
            </table>
        `)

        for (var item in data.data) {
            let Pitem = data.data[item]
            let _ind = item

            elem.find('table').append(`
                <tr>
                    <th><img src = "nui://geo-inventory/html/img/${Pitem[0]}.png" style = "position:relative;height:2.5vh;float:left;left:1vh;"></th>
                    <th> ${Pitem[2] || data.inv[Pitem[0]].Name} ${Pitem[3] ? 'x'+Pitem[3] : ''}</th>
                    <th><input
                        type="number"
                        inputmode="numeric"
                        maxlength="19"
                        value=1
                        min = 1
                        max = 1000
                        class = "storenum"
                        item = "${Pitem[2] || data.inv[Pitem[0]].Name}"
                        onkeypress="return (event.charCode == 8 || event.charCode == 0 || event.charCode == 13) ? null : event.charCode >= 48 && event.charCode <= 57"
                        /></th>
                    <th class = "pname" style = "text-align:left;">${Pitem[1][1]}x ${data.inv[Pitem[1][0]].Name}</th>
                </tr>
            `)

            elem.find('table').find('input').last().on('input', function() {
                if ($(this).val() <= 0) $(this).val(1)
                if ($(this).val() > 1000) $(this).val(1000)
                $(this).parent().parent().find('.pname').html(`
                    ${Pitem[1][1] * $(this).val()}x ${data.inv[Pitem[1][0]].Name}
                `)
            })

            elem.find('table').find('tr').last().click(function() {
                let wind = CreateWindow('ConfirmWindow', 'Confirm', {remove:true, sound: 'open'})
                let parent = $(this)

                wind.append(`
                    <h1>Would you like to purchase ${$(this).find('input').val() * (Pitem[3] || 1)}x ${$(this).find('input').attr('item')}(s)
                    for ${Pitem[1][1] * $(this).find('input').val()}x ${data.inv[Pitem[1][0]].Name}(s)
                    </h1>
                
                    <button class = "confirmdia denya">Deny</button>
                    <button class = "confirmdia confirma">Confirm</button>
                `)

                $('.denya').click(function() {
                    wind.find('.img').trigger('click')
                })

                $('.confirma').click(function() {
                    Get('Store.Buy', {
                        Store: data.Store,
                        Item: Number(_ind) + 1,
                        Amount: parent.find('input').val()
                    })
                    wind.find('.img').trigger('click')
                })
            })
        }

        $('.storenum').click(function(e) {
            e.stopPropagation()
        })
    }
})