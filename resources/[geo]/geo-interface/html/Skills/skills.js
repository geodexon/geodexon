let skillsOpen = false;
let skillData = {}

window.addEventListener('message', (e) => {
    if (e.data.interface == 'Skills') {
        skillData = e.data.info
        ToggleSkills(e.data.data)
    }

    if (e.data.interface == 'SkillBar') {
        if (e.data.info) {
            skillData = e.data.info
        }
        Skillbar(e.data.data, e.data.boss)
    }
    
})

function ToggleSkills(skills) {
    $('.skill').each(function() {
        $(this).remove();
    })

    for (var item in skills) {
        let skill = skillData[skills[item][0]]
        let maxLevel = skill ? skill.MaxLevel : 2
        let currentXP = skills[item][1]
        let myLevel = GetLevel(skills[item][1])
        let visibleXP = currentXP - (skillData.Levels[myLevel - 1])

        let elem = $(document.createElement('div')).addClass('skill')
        elem.html(`
            <h class = "skill_name">${skills[item][0]}</h>
            <div class = "skill_container">
                <div class = "skill_amount"></div>
            </div>
            <h class = "skill_level">${myLevel}</h>
        `)

        elem.find('.skill_amount').css('width', (visibleXP / (skillData.Levels[myLevel + 1] ? (skillData.Levels[myLevel + 1] - skillData.Levels[myLevel]) : visibleXP) * 100 +'%')).css('background-color', 'var(--main-lighter)')
        if (myLevel >= (skillData.MaxLevels[skills[item][0]]? skillData.MaxLevels[skills[item][0]] : 30)) {
            elem.find('.skill_amount').css('width', '100%').css('background-color', 'white')
        }
        
        
        $('#skills').append(elem)
    }

    skillsOpen = !skillsOpen
    $('#skills').animate({opacity: skillsOpen ? '1.0' : '0.0'}, 1000)
}

function GetLevel(xp) {
    let level = 1;
    for (var item in skillData.Levels) {
        if (xp >= skillData.Levels[item]) level = Number(item) + 1;
    }

    return level
}

function Skillbar(data, boss) {
    let elem = $('.skillbarcontainer')
    if (!data) {
        elem.css('bottom', '-5vh')
        return;
    }

    elem.css('bottom', '1.2vh')
    elem.find('.title').html(data[0])

    let level = !boss ? GetLevel(data[1]) : 0
    let currentXP = !boss ? ((data[1] || 0) - skillData.Levels[level - 1]) : data[1]
    let maxXp = !boss ? (skillData.Levels[level] - skillData.Levels[level - 1]) : data[2]

    elem.find('.xp').html(currentXP +'/' + maxXp)
    elem.find('.xpbar').css('width', ((currentXP / maxXp) * 100)+'%')
}

$(function() {
    $('#skillbar').find('.xpbar').css('width', '10%')
})