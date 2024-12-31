async function OpenEvidence() {
    let page = $('#mdt_content');
    let reports = await Get('LoadReports');

    $('#profile_active').html('')
    var d = new Date();
    var utc = Math.floor(d.getTime() / 1000);

    page.html(`
        <div id = "reports">
            <div class="input_container" id = "reports_searcher">
                <input type="text" class="input" placeholder="Search Evidence" id = "reports_search">
                <img src="img/person.png" id="input_img">
            </div>
        </div>

        <div id = "profile_active">
            <div class = "mdt_mainbar">
            </div>

            <div class = "mdt_sidebar">
            </div>
        </div>
    `)

    let date = new Date().getTime()
    $('#reports_search').on('input', function() {
        date = new Date().getTime()
        setTimeout(async () => {
            if (new Date().getTime() - date >= 490) {
                let search = await Get('Evidence.Search', {name: $('#reports_search').val()})
                LoadReports(search)
            }
        }, 500);
    })
}