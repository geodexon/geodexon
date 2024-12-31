local ActivePoliceSmall = Config.CopsSmallJob 	--policias para small
local ActivePoliceMedium = Config.CopsMediumJob		-- policias para med
local ActivePoliceLarge = Config.CopsLargeJob	-- policias para high
local cashAS = 250 				-- n tou a usar
local cashBS = 500
local cashAM = 750 				--n tou a usar
local cashBM = 1000
local cashAL = 1250 				--n tou a usar
local cashBL = 1500		--n tou a usar
local ActivationCostSmall = Config.ActivationCostSmall --quanto custa comeeçar small
local ActivationCostMedium = Config.ActivationCostMedium --quanto custa começar med
local ActivationCostLarge = Config.ActivationCostLarge	--quanto custa começar high
local ResetTimer = Config.CooldownTime * 60000  --cooldown entre missões
local ActiveMission = 0
local prob = Config.LargeJobExtraRewardProb
local itemLarge = Config.LargeJobExtraReward

local jobs = {}
local payouts = {
	['small'] = {1500, 3000},
	['medium'] = {3000, 4500},
	['large'] = {4500, 6000}
}

RegisterNetEvent('AttackTransport:StartSmall', function()
	local source = source
	local copsOnDuty = 0
	if ActiveMission == 0 then
		if exports['geo-es']:DutyCount('Police') >= 1 and exports['geo-inventory']:RemoveItem('Player', source, 'dollar', ActivationCostSmall) then
			TriggerClientEvent("AttackTransport:Small", source)
			jobs[source] = 'small'
			OdpalTimer()
		else
			TriggerClientEvent('PhoneNotif', source, 'messages', 'Not Currently Available')
		end
	else
		TriggerClientEvent('PhoneNotif', source, 'messages', 'Not Currently Available')
	end
end)

RegisterNetEvent('AttackTransport:StartMedium')
AddEventHandler('AttackTransport:StartMedium', function()
	local source = source
	local copsOnDuty = 0
	if ActiveMission == 0 then
		if exports['geo-es']:DutyCount('Police') >= 1 and exports['geo-inventory']:RemoveItem('Player', source, 'dollar', ActivationCostSmall) then
			jobs[source] = 'medium'
			TriggerClientEvent("AttackTransport:Medium", source)
			OdpalTimer()
		else
			TriggerClientEvent('PhoneNotif', source, 'messages', 'Not Currently Available')
		end
	else
		TriggerClientEvent('PhoneNotif', source, 'messages', 'Not Currently Available')
	end
end)

RegisterNetEvent('AttackTransport:StartLarge')
AddEventHandler('AttackTransport:StartLarge', function()
	local source = source
	if ActiveMission == 0 then
		if exports['geo-es']:DutyCount('Police') >= 1 and exports['geo-inventory']:RemoveItem('Player', source, 'dollar', ActivationCostSmall) then
			jobs[source] = 'large'
			TriggerClientEvent("AttackTransport:Large",source)
			OdpalTimer()
		else
			TriggerClientEvent('PhoneNotif', source, 'messages', 'Not Currently Available')
		end
	else
		TriggerClientEvent('PhoneNotif', source, 'messages', 'Not Currently Available')
	end
end)

function OdpalTimer()
	ActiveMission = 1
	Wait(ResetTimer)
	ActiveMission = 0
	TriggerClientEvent('AttackTransport:CleanUp', -1)
end

RegisterNetEvent('AttackTransport:Reward', function()
	local source = source
	if jobs[source] then
		exports['geo-inventory']:ReceiveItem('Player', source, 'dollar', Random(payouts[jobs[source]][1], payouts[jobs[source]][2]))
		jobs[source] = nil
	end
end)