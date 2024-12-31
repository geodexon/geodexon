//////////////////////////////////////////
//           Discord Whitelist          //
//////////////////////////////////////////

/// Config Area ///

var guild = "839829039191556116";
var botToken = "Nzg0NTUxMjkyMjM1Njc3NzE3.X8q8VA.mJPCE39k_AsebwpHUkxX8ryRMz0";

var whitelistRoles = [ // Roles by ID that are whitelisted.
    ""
]

var blacklistRoles = [ // Roles by Id that are blacklisted.
    ""
]

var notWhitelistedMessage = "You're Not Whitelisted. This sever is whitelisted and requires access to join."
var noGuildMessage = "Guild Not Detected. It seems you're not in the guild for this community."
var blacklistMessage = "You're blacklisted from this server."
var debugMode = true

/// Code ///
const axios = require('axios').default;
axios.defaults.baseURL = 'https://discord.com/api/v8';
axios.defaults.headers = {
    'Content-Type': 'application/json',
    Authorization: `Bot ${botToken}`
};
function getUserDiscord(source) {
    if(typeof source === 'string') return source;
    if(!GetPlayerName(source)) return false;
    for(let index = 0; index <= GetNumPlayerIdentifiers(source); index ++) {
        let ident = GetPlayerIdentifier(source, index)
        if (!ident) return false;
        if (ident.indexOf('discord:') !== -1) {
            return GetPlayerIdentifier(source, index).replace('discord:', '');
        }
    }
    return false;
}

function Check(pSource, cb) {
    let user = getUserDiscord(pSource);
    axios(`/guilds/${guild}/members/${user}`).then((resDis) => {
        if(!resDis.data) {
            cb(false);
        } else {
            cb(true);
        }
    }).catch((err) => {
        cb(false)
    });
}

exports('Check', Check)