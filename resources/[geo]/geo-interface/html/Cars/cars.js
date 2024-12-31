let cars = []

window.addEventListener('message', function(data) {
    data = data.data
    if (data.interface == 'cars') {
        $('#car_data').html(``)
        $('#cars')
            .css('display', 'inline')
            .css('pointer-events', 'all')
        cars = data.data
        interfaceOpem = 'cars'
        $('#cars_sidebar').html('<input type = "text" class = "car_search" placeholder = "Search Vehicles"> <div class = "car_list"></div>')
        LoadCars('')

        $('.car_search').on('input', function() {
            $('.car_list').html('')
            LoadCars($(this).val())
        })
    }
})

window.addEventListener('done', function() {
    $('#cars')
        .css('display', 'none')
        .css('pointer-events', 'none')
})

function LoadCars(str) {
    for(var item in cars) {
        if (cars[item][0].toLowerCase().match(str.toLowerCase())) {
            $('.car_list').append(`
                <button class = "cars_view" name = "${cars[item][0]}" carid = ${item}>${cars[item][0]}</button>
            `)
        }
    }

    $('.cars_view').click(async function() {
        Loading()
        let data = await GetCarData('https://gta.now.sh/api/vehicles/'+$(this).attr('name').toLowerCase())
        if (data != 'not found') {
            data = JSON.parse(data)
            data = data.images.frontQuarter.split('/revision/latest/scale-to-width-down/210')[0]
        }

        $('#car_data').html(`
            <img id = "car_img" src = "${data}"></div>
            <p id = "car_price">$${numberWithCommas(cars[$(this).attr('carid')][1])}</p>
            <button id = "car_locate" name = "${$(this).attr('name')}">Locate Car</button>
        `)

        StopLoading()

        $('#car_locate').click(function() {
            Get('FindCar', {
                name: $(this).attr('name')
            })
        }) 
    })

}

async function GetCarData(theUrl)
{
    return new Promise(resolve => {
        var xmlHttp = new XMLHttpRequest();
        xmlHttp.onreadystatechange = function() { 
            if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
                resolve(xmlHttp.responseText);
        }
        xmlHttp.open("GET", theUrl, true); // true for asynchronous 
        xmlHttp.send(null);
    })
}