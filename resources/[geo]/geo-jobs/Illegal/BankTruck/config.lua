Config = {}

Config.Varblocks = 4 --number of blocks

Config.Vartime = 10 --time for the hack

Config.FrontSeatsGun = "WEAPON_COMBATPISTOL"

Config.BackSeatsGun = "WEAPON_SMG"

Config.TimeToBlow = 15 -- Time to explode

Config.PackingTimeLow = 40 -- Progress bar for collect money - time small van

Config.PackingTimeMedium = 50 -- Progress bar for collect money - time medium van

Config.PackingTimeHigh = 60 -- progress bar for collect money - time high van

Config.ActivationCostSmall = 500 -- cost for the small run

Config.ActivationCostMedium = 1000 -- cost for the medium run

Config.ActivationCostLarge = 2000 -- cost for the high run

Config.CooldownTime = 30 -- cooldown in minutos between robberies

Config.CopsSmallJob = 2 -- police for small van

Config.CopsMediumJob = 3 -- police for medium van

Config.CopsLargeJob = 4 -- police for high van
 
Config.Dispatch = 'cd-dispatch' --or cd-dispatch

--------------------if using cd-dispatch --------------------------------

Config.BlipSprite = 431

Config.BlipScale = 1.2

Config.BlipColour = 3

Config.BlipFlashes = true


--------------------Rewards---------------------------------------
Config.UsingMarkedBills = true -- If you use marked bills or not

Config.MoneyItem = "markedbills" -- item that recieve instead of markedbills , if using markedbills just leave ""

Config.PayoutSmall = math.random(6000,10000) -- amount of markedbills/other money you receive small run

Config.PayoutMedium = math.random(10000,15000) -- amount of markedbills/other money you receive medium run

Config.PayoutLarge = math.random(15000,25000) -- amount of markedbills/other money you receive high run

Config.SmallMarkedBillsWorth = math.random(3000,5000) -- worth of markedbills you receive small run

Config.MediumMarkedBillsWorth = math.random(5000,8000) -- worth of markedbills you receive medium run

Config.LargeMarkedBillsWorth = math.random(8000,15000) -- worth of markedbills you receive high run

Config.SmallJobExtraReward = 'security_card_01' --extra reward on small van

Config.SmallJobExtraRewardProb = 55 --probability to drop extra reward from small rob

Config.MediumJobExtraReward = 'security_card_02' --extra reward on medium van

Config.MediumJobExtraRewardProb = 75 --probability to drop extra reward from medium rob

Config.LargeJobExtraReward = 'security_card_05' --extra reward on large van

Config.LargeJobExtraRewardProb = 100 --probability to drop extra reward from large rob

Config.MediumJobRewardProb = 50 --probability to drop rotas UnionDepository

Config.SmallJobRewardProb = 50 --probability to drop rotas MazeBank

Config.TimeToReceiveJob = 1000 * 20 -- Waiting time to receive the banktruck

--Start stuff

Config.debugPoly = false

Config.StartHeistCoord = vector3(1276.1, -1710.14, 54.77) --start heist

Config.StartHeistCoordWidth = 2

Config.StartHeistCoordLength = 2

Config.StartHeistCoordheight = 0.5

Config.StartHeistCoordHeading = 90

Translations = {
    error = {
        ["fail"] = "You failed, try again...",
        ["c4"] = "You dont have a C4..",
        ["broken_van"] = "The strong Van was destroyed, you failed the job!",
        ["guards"] = "Eliminate all guards first!",
        ["c4_boom"] = "The charge will burst go away!",
        ["water"] = "You are in the water!",
        ["stopped_grab"] = "You stopped collecting the money and you missed the job!",
        ["no_police"] = "Not Enough Police",
    },
    success = {
        ["loc_found"] = "I'll send you the location of the van, stay tuned!",
        ["loc_received"] = "You have received a location!",
        ["collect_money"] = "You can collect the money.",
        ["got_money"] = "You have the money, now get the hell out of there!",
    },
    info = {
        ["nomoney"] = "Not enough money!",
        ["already_done"] = "Someone has already done this!",
        ["van_label"] = "Truck With Money",
    },
    menu = {
        ["truckinfo"] = "Information about strong van",
        ["truck"] = "Strong Van",
        ["lite"] = "Slightly Safe",
        ["needs"] = "You need x$ and C4",
        ["needs2"] = "You need x$ and C4",
        ["needs3"] = "You need x$ and C4",
        ["mod"] = "Moderately Safe",
        ["strong"] = "Strongly Safe",
        ["mazehard"] = "You need mazebank harddrive",
        ["unionhard"] = "You need unionbank harddrive",
        ["close"] = "Close",
        ["putc4"] = "Plant C4",
        ["grab"] = "Grab Money",
    },
    progress = {
        ["plant"] = "Planting C4...",
        ["rob"] = "Robbing Money...",
    },
    dispatch = {
        ["title"] = "Possible Bank Truck Robbery",
        ["robprefix"] = "A ",
        ["rob"] = " robbing a van at ",
        ["text"] = "Possible Robbery",
        
    }
}
