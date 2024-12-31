local Translations = {
    error = {
        ["fail"] = "Canceled..",
        ["cooldown"] = "Someone already did it!",
        ["no_police"] = "You cant do that!",
        ["noitem"] = "You dont have a thermite!",
        ["alreadyStole"] = "Someone already stole that!",
        ["lasers"] = "I need to turn of the lasers first!",
        ["cutter"] = "I need a cutter!",
        ["lasers_off"] = "The lasers are off!",
        ["weapon"] = "You need something to break it!",
        ["weapon2"] = "You need a switchblade to cut it!",
    },
    target = {
        ["start"] = "Disable security system",
        ["vitrine"] = "Break",
        ["painting"] = "Rob Painting",
        ["glass"] = "Cut Glass",
        ["system"] = "Enter System",
    },
    progress = {
        ["start"] = "Applying Thermite..",

    },


}
Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
