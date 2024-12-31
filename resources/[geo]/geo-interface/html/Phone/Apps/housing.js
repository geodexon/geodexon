function OpenHousing() {
    let elem = $('#app_container')
    elem.html(`
        <div id = "phone_message_container">
            <div id = "phone_message_header">
                <p id = "restarthousing">Housing</p>
            </div>

            <button class = "housing_toggle">Show Housing</button>
            <button class = "housing_find">Closest Property</button>
            <div class = "cContainer" style = "overflow-y:scroll;height:29.5em;margin-bottom:5em;">
                
            </div>
        </div>
    `)

    $('#restarthousing').click(function() {
        OpenHousing()
    })

    $('.housing_toggle').click(function() {
        Get('ToggleHousing')
    })

    $('.housing_find').click(async function() {
        SearchHomes(elem)
    })
}
async function SearchHomes(elem) {
    let data = await Get('FindHousing')
    if (data) {
        const date = new Date();
        date.toLocaleString('en-US', {
            timeZone: 'America/New_York',
        })

        const date2 = new Date(data.lastpay + (60 * 60 * 24 * 14 * 1000));
        date2.toLocaleString('en-US', {
            timeZone: 'America/New_York',
        })

        let remainingTime = ((date2 - date) / 60 / 60 / 1000 / 24)
        let remainStr = remainingTime.toFixed(2) + ' Days'
        if (remainingTime < 0) {
            remainStr = '<font color = "red">IMPENDING</font>'
        }

        let hours = Math.floor((date - data.lastpay) / 60 / 60 / 1000)
        let days = Math.floor((date - data.lastpay) / 60 / 60 / 1000 / 24)

        if (data.cid != data.owner) {
            $('.housing_find').css('margin-bottom', '0.2em')
            $('.cContainer').html(`

                ${data.buyable ? `
                    <p class = "property_title">${data.title}</p>
                    <p class = "property_price">Price: <font color = "#67e354">
                        <span style="float:right; margin-right:1em;">
                            $${numberWithCommas(data.taxprice)}</font>
                        </span>
                    </p>

                    <p class = "property_price">Down Payment: <font color = "#67e354">
                    <span style="float:right; margin-right:1em;">
                        $${numberWithCommas(Math.floor(data.taxprice) * 0.6)}</font>
                    </span>

                    <p class = "property_price"> Weekly: <font color = "#67e354">
                        <span style="float:right; margin-right:1em;">
                            $${numberWithCommas(Math.floor(data.price) * 0.05)}</font>
                        </span>
                    </p>
                ` : `
                    <p class = "property_price"> Weekly: <font color = "#67e354">
                        <span style="float:right; margin-right:1em;">
                            $${numberWithCommas(data.price)}</font>
                        </span>
                    </p>
                `}
               
            `)

            if (data.owner == 0 && data.renter == 0) {
                if (data.buyable) {
                    if(data.realtor) {
                        $('.cContainer').append(`
                            <button class = "property_buy">Buy Property</button>
                        `)
                            
                        $('.property_buy').click(async function() {
                            let val = await PhoneInput({
                                header: 'House Sale',
                                field: 'number',
                                title: 'CID',
                                placeholder: 'State ID'
                            })
                            if (val) {
                                Get('BuyProperty', {
                                    pid: data.pid,
                                    cid: val
                                })
                            }
                        })
                    }
                    
                } else {
                    $('.cContainer').append(`
                        <button class = "property_buy">Rent Property</button>
                    `)
                    
                    $('.property_buy').click(async function() {
                        await Get('Property.Rent', {
                            pid: data.pid
                        })
                        SearchHomes()
                    })
                }
            }

            if (data.renter == data.cid) {
                $('.housing_toggle').remove()
                $('.housing_find').remove()
                $('.cContainer').html(`
                    <div class = "property_container">
                        <p class = "property_title">${data.title}</p>
                            <p class = "property_price">Weekly: <font color = "#67e354">
                            <span style="float:right; margin-right:1em;">
                                $${numberWithCommas(data.price)}</font>
                            </span>
                        </p>

                        <p class = "property_price">Last Payment:
                            <span style="float:right; margin-right:1em;">
                                ${(hours < 24 ? hours+' Hours Ago':days+ ' Days Ago')}</font>
                            </span>
                        </p>

                        <p class = "property_price">Property Seizure:
                            <span style="float:right; margin-right:1em;">
                                ${(remainStr)}</font>
                            </span>
                        </p>
                    </div>
                `)

                $('.property_container').append(`
                    <button class = "property_buy" id = "buyproperty">Make Payment</button>
                    <button class = "property_buy" id = "quitproperty">Forfeit Home</button>
                `)
                $('#buyproperty').click(async function() {
                    await Get('Housing.Payment', {
                        property: data.pid
                    })
                    SearchHomes()
                })

                $('#quitproperty').click(async function() {
                    await Get('Housing.Sell', {
                        property: data.pid
                    })
                    SearchHomes()
                })
            }

        } else {
            $('.housing_toggle').remove()
            $('.housing_find').remove()
            $('.cContainer').html(`
                <div class = "property_container">
                    <p class = "property_title">${data.title}</p>
                        <p class = "property_price">Value: <font color = "#67e354">
                        <span style="float:right; margin-right:1em;">
                            $${numberWithCommas(data.price)}</font>
                        </span>
                    </p>


                    ${data.owed <= 0 ? '': `
                        <p class = "property_price">Owed: <font color = "#67e354">
                            <span style="float:right; margin-right:1em;">
                                $${numberWithCommas(data.owed)}</font>
                            </span>
                        </p>

                        <p class = "property_price"> Minmum Payment: <font color = "#67e354">
                            <span style="float:right; margin-right:1em;">
                                $${numberWithCommas(Math.floor(data.price) * 0.05)}</font>
                            </span>
                        </p>
                    `}

                    ${data.owed > 0 ? '': `
                        <p class = "property_price"> Tax Payment: <font color = "#67e354">
                            <span style="float:right; margin-right:1em;">
                                $${numberWithCommas(Math.floor(data.price) * 0.01)}</font>
                            </span>
                        </p>
                    `}
                   
                    <p class = "property_price">ID:
                        <span style="float:right; margin-right:1em;">
                            ${data.pid}</font>
                        </span>
                    </p>

                    <p class = "property_price">Last Payment:
                        <span style="float:right; margin-right:1em;">
                            ${(hours < 24 ? hours+' Hours Ago':days+ ' Days Ago')}</font>
                        </span>
                    </p>

                    <p class = "property_price">Property Seizure:
                        <span style="float:right; margin-right:1em;">
                            ${(remainStr)}</font>
                        </span>
                    </p>
                </div>
            `)

            $('.property_container').append(`
                <button class = "property_buy" id = "buyproperty">Make Payment</button>
                <button class = "property_buy" id = "modproperty">Modify Property</button>
                <button class = "property_buy" id = "addtenant">Add Tenant</button>
                <button class = "property_buy" id = "removetenant">Remove Tenant</button>
                <button class = "property_buy" id = "quitproperty">Forfeit Home</button>
            `)
            
            $('#buyproperty').click(async function() {
                await Get('Housing.Payment', {
                    property: data.pid
                })
                SearchHomes()
            })

            $('#modproperty').click(async function() {
                CloseMenu()
                await Get('Housing.Modify', {
                    property: data.pid
                })
            })

            $('#quitproperty').click(async function() {
                await Get('Housing.Sell', {
                    property: data.pid
                })
                SearchHomes()
            })

            $('#addtenant').click(async function() {
                $('#phone_contacts_new').remove()
                $('#phone_contacts_new').css('height', '11.2em')
                let elem = $('#app_container')

                elem.append(`
                    <div id = "phone_contacts_new">
                        <p>Guild Image</p>
                        <hr>

                        <label for="phone_contact_input" class = "phone_contact_container">CID </label>
                        <input type = "text" class = "phone_contact_input phone_fullname" placeholder = "Persons State ID" value = ''}>

                        <i class="fas fa-times-circle phone_contact_deny" title = "dick"></i>
                        <i class="fas fa-check-circle phone_contact_accept" title = "dick"></i>
                    </div>
                `)

                $('#phone_contacts_new').animate({bottom: '0em'}, 500)
                $('.phone_contact_deny').click(function() {
                    $('#phone_contacts_new').animate({bottom: '-11.2em'}, 500, function() {
                        $(this).remove()
                    })
                })

                $('.phone_contact_accept').click(async function() {
                    Get('Property.AddTentant', {
                        id: $('.phone_fullname').val(),
                        property: data.pid
                    })
                    CloseNewContact();
                })
            })

            $('#removetenant').click(async function() {
                let tenants = await  Get('Property.GetTenants', {
                    property: data.pid
                })

                $('.tenants').each(function() {
                    $(this).remove()
                })

                for (var item of tenants) {
                    let pItem = item;
                    $('.property_container').append(`
                    <p class = "property_price tenants" style = "font-size:1em;">${item[1]}:
                        <span style="float:right; margin-right:1em;" class = "fas fa-solid fa-ban removetenant" pid = ${item[0]}>
                        </span>
                    </p>
                    `)
                }

                $('.removetenant').click(async function() {
                    if (await PhoneConfirm('housing', 'Would you like to remove this tenant?', null, 15)) {
                        await Get('Property.RemoveTenant', {
                            property: data.pid,
                            tenant: $(this).attr('pid')
                        })
                        $(this).parent().remove()
                    }
                })
            })
        }

        if (data.owner > 0 && data.realtor) {
            $('.property_container').append(`
                <button class = "property_buy" id = "releaseproperty">Request Release</button>
            `)
                
            $('#releaseproperty').click(async function() {
                Get('ReleaseProprety', {
                    pid: data.pid,
                })
            })
        }

    } else {
        PhoneNotif('housing', 'No properties found')
    }
}