local CurrentCops = 0 
local lasersActive = true
local lasersObjActive = true
local canHack = true

VangelicoHeist = {
    ['painting'] = {},
    ['globalObject'] = nil,
    ['globalItem'] = nil,
}

Vitrine = {
	{ coords = vector3(-626.85, -235.34, 38.06), Heading = 38.38, looted = false, oldModel = 'des_jewel_cab3_start', newModel = 'des_jewel_cab3_end', objPos = vector3(-627.35, -234.947, 37.8531), coordsAnim = vector3(-626.51, -235.8, 38.06)},
	{ coords = vector3(-625.69, -234.52, 38.06), Heading = 38.38, looted = false, oldModel = 'des_jewel_cab4_start', newModel = 'des_jewel_cab4_end', objPos = vector3(-626.298, -234.193, 37.8492), coordsAnim = vector3(-625.59, -234.9, 38.06)},
	{ coords = vector3(-627.98, -233.94, 38.06), Heading = 214.82, looted = false, oldModel = 'des_jewel_cab_start', newModel = 'des_jewel_cab_end', objPos = vector3(-627.735, -234.439, 37.875), coordsAnim = vector3(-628.09, -233.65, 38.06)},
	{ coords = vector3(-626.84, -233.11, 38.06), Heading = 214.82, looted = false, oldModel = 'des_jewel_cab_start', newModel = 'des_jewel_cab_end', objPos = vector3(-626.716, -233.685, 37.8583), coordsAnim = vector3(-627.05, -232.9, 38.06)},
	{ coords = vector3(-625.63, -237.83, 38.06), Heading = 214.82, looted = false, oldModel = 'des_jewel_cab3_start', newModel = 'des_jewel_cab3_end', objPos = vector3(-625.376, -238.358, 37.8687), coordsAnim = vector3(-625.867, -237.458, 38.06)},
	{ coords = vector3(-626.7, -238.55, 38.06), Heading = 214.82, looted = false, oldModel = 'des_jewel_cab2_start', newModel = 'des_jewel_cab2_end', objPos = vector3(-626.399, -239.132, 37.8616), coordsAnim = vector3(-626.894, -238.2, 38.06)},
	{ coords = vector3(-620.28, -234.49, 38.06), Heading = 214.82, looted = false, oldModel = 'des_jewel_cab_start', newModel = 'des_jewel_cab_end', objPos = vector3(-619.978, -234.93, 37.8537), coordsAnim = vector3(-620.44, -234.084, 38.06)},
	{ coords = vector3(-619.15, -233.69, 38.06), Heading = 214.82, looted = false, oldModel = 'des_jewel_cab3_start', newModel = 'des_jewel_cab3_end', objPos = vector3(-618.937, -234.16, 37.8425), coordsAnim = vector3(-619.39, -233.32, 38.06)},
	{ coords = vector3(-624.98, -227.84, 38.06), Heading = 38.38, looted = false, oldModel = 'des_jewel_cab3_start', newModel = 'des_jewel_cab3_end', objPos = vector3(-625.517, -227.421, 37.86), coordsAnim = vector3(-624.738, -228.2, 38.06)},
	{ coords = vector3(-623.89, -227.04, 38.06), Heading = 38.38, looted = false, oldModel = 'des_jewel_cab4_start', newModel = 'des_jewel_cab4_end', objPos = vector3(-624.467, -226.653, 37.861), coordsAnim = vector3(-623.688, -227.437, 38.06)},
	{ coords = vector3(-620.44, -226.52, 38.06), Heading = 307.11, looted = false, oldModel = 'des_jewel_cab_start', newModel = 'des_jewel_cab_end', objPos = vector3(-620.163, -226.212, 37.8266), coordsAnim = vector3(-620.797, -226.79, 38.06)},
	{ coords = vector3(-619.63, -227.64, 38.06), Heading = 307.11, looted = false, oldModel = 'des_jewel_cab2_start', newModel = 'des_jewel_cab2_end', objPos = vector3(-619.384, -227.259, 37.8342), coordsAnim = vector3(-620.055, -227.817, 38.06)},
	{ coords = vector3(-618.32, -229.48, 38.06), Heading = 307.11, looted = false, oldModel = 'des_jewel_cab3_start', newModel = 'des_jewel_cab3_end', objPos = vector3(-618.019, -229.115, 37.8302), coordsAnim = vector3(-618.679, -229.704, 38.06)},
	{ coords = vector3(-617.53, -230.55, 38.06), Heading = 307.11, looted = false, oldModel = 'des_jewel_cab2_start', newModel = 'des_jewel_cab2_end', objPos = vector3(-617.249, -230.156, 37.8201), coordsAnim = vector3(-617.937, -230.731, 38.06)},
	{ coords = vector3(-620.13, -233.31, 38.06), Heading = 39.12, looted = false, oldModel = 'des_jewel_cab4_start', newModel = 'des_jewel_cab4_end', objPos = vector3(-620.6465, -232.9308, 37.8407), coordsAnim = vector3(-620.184, -233.729, 38.06)},
	{ coords = vector3(-619.79, -230.34, 38.06), Heading = 131.18, looted = false, oldModel = 'des_jewel_cab_start', newModel = 'des_jewel_cab_end', objPos = vector3(-620.3262, -230.829, 37.8578), coordsAnim = vector3(-619.408, -230.1969, 38.06)},
	{ coords = vector3(-623.08, -232.93, 38.06), Heading = 307.11, looted = false, oldModel = 'des_jewel_cab_start', newModel = 'des_jewel_cab_end', objPos = vector3(-622.7541, -232.614, 37.8638), coordsAnim = vector3(-623.3596, -233.2296, 38.06)},
	{ coords = vector3(-621.04, -228.59, 38.06), Heading = 131.18, looted = false, oldModel = 'des_jewel_cab3_start', newModel = 'des_jewel_cab3_end', objPos = vector3(-621.7181, -228.9636, 37.8425), coordsAnim = vector3(-620.864, -228.481, 38.06)},
	{ coords = vector3(-624.44, -231.04, 38.06), Heading = 307.11, looted = false, oldModel = 'des_jewel_cab4_start', newModel = 'des_jewel_cab4_end', objPos = vector3(-624.1267, -230.7476, 37.8618), coordsAnim = vector3(-624.939, -231.247, 38.06)},
	{ coords = vector3(-624.03, -228.11, 38.06), Heading = 214.82, looted = false, oldModel = 'des_jewel_cab2_start', newModel = 'des_jewel_cab2_end', objPos = vector3(-623.8118, -228.6336, 37.8522), coordsAnim = vector3(-624.293, -227.83, 38.06)},


}

-- clear everything
RegisterNetEvent('mv-vangelico:client:clear')
AddEventHandler('mv-vangelico:client:clear', function()
   
	for k, v in pairs(Vitrine) do
		Vitrine[k].looted = false
		TriggerEvent('RemoveZone', "vitrinevangelico" .. k)
		CreateModelSwap(Vitrine[k].objPos.x,Vitrine[k].objPos.y,Vitrine[k].objPos.z, 0.3, GetHashKey(Vitrine[k].newModel), GetHashKey(Vitrine[k].oldModel), 1)
	end


	for k, v in pairs(VangConfig['VangelicoInside']['painting']) do
        v['looted'] = false
        object = GetClosestObjectOfType(v['objectPos'], 1.0, GetHashKey(v['object']), 0, 0, 0)
        DeleteObject(object)
		TriggerEvent('RemoveZone', "paintvangelico" .. k)
    end

	Config['VangelicoInside']['glassCutting']['looted'] = false
    
    glassObjectDel = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_glass_disp_01a'), 0, 0, 0)
    glassObjectDel2 = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_glass_disp_01b'), 0, 0, 0)
    DeleteObject(glassObjectDel)
    DeleteObject(glassObjectDel2)

	diamondObjectDel = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_diamond_01a'), 0, 0, 0)
	diamondObjectDel2 = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_diamond_disp_01a'), 0, 0, 0)
	DeleteObject(diamondObjectDel)
    DeleteObject(diamondObjectDel2)

	diamondObjectDel3 = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_art_pant_01a'), 0, 0, 0)
	DeleteObject(diamondObjectDel3)

	necklaceObjectDel = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_necklace_01a'), 0, 0, 0)
	necklaceObjectDel2 = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_neck_disp_01a'), 0, 0, 0)
	DeleteObject(necklaceObjectDel)
	DeleteObject(necklaceObjectDel2)

	bottleObjectDel = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_t_bottle_02b'), 0, 0, 0)
	DeleteObject(bottleObjectDel)
	
end)

CreateThread(function() 

    AddBoxZone(vector4(-628.2, -235.17, 38.06, 120.41), 20.0, 35.0, {
		name = "vangelico-zone",
        debugPoly = false,
        heading = 35,
        minZ =38.06 - 3,
        maxZ = 38.06 + 5,
    })

	AddCircleZone(vector3(-596.1, -283.82, 50.72), 0.5, {
		name ="startvangelico",
		useZ = true,
		debugPoly=false
		}, {
			options = {
				{
					event = "mv-vangelico:client:começar",
					icon = "fas fa-user-secret",
					label = 'Disable security system',
				},
			 },
	
			distance = 2.1
	})
	exports['geo-interface']:AddTargetZone('startvangelico', 'Disable Security System', 'mv-vangelico:client:começar', nil, 5.0, 'fas fa-user-secret')

	lasersVangelico1 = Laser.new(
		vector3(-622.158, -235.901, 41.046),
		{vector3(-625.716, -230.125, 37.057), vector3(-631.682, -233.77, 37.057), vector3(-628.212, -233.587, 37.057), vector3(-620.451, -236.097, 37.057), vector3(-617.267, -232.82, 37.057), vector3(-616.224, -235.566, 37.057), vector3(-623.9, -235.294, 37.057), vector3(-627.887, -238.428, 37.057), vector3(-628.27, -234.794, 37.057), vector3(-628.694, -230.641, 37.057), vector3(-623.634, -232.243, 37.057), vector3(-625.033, -237.254, 37.057), vector3(-627.593, -235.515, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "lasersvangelicofdd"}
	  )

	lasersVangelico2 = Laser.new(
		vector3(-622.158, -235.901, 41.046),
		{vector3(-625.716, -230.125, 37.057), vector3(-631.682, -233.77, 37.057), vector3(-628.212, -233.587, 37.057), vector3(-620.451, -236.097, 37.057), vector3(-617.267, -232.82, 37.057), vector3(-616.224, -235.566, 37.057), vector3(-623.9, -235.294, 37.057), vector3(-627.887, -238.428, 37.057), vector3(-628.27, -234.794, 37.057), vector3(-628.694, -230.641, 37.057), vector3(-623.634, -232.243, 37.057), vector3(-625.033, -237.254, 37.057), vector3(-627.593, -235.515, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "lasersvangelicofdd"}
	  )

	  lasersVangelico3 = Laser.new(
		vector3(-622.158, -235.901, 41.046),
		{vector3(-625.716, -230.125, 37.057), vector3(-631.682, -233.77, 37.057), vector3(-628.212, -233.587, 37.057), vector3(-620.451, -236.097, 37.057), vector3(-617.267, -232.82, 37.057), vector3(-616.224, -235.566, 37.057), vector3(-623.9, -235.294, 37.057), vector3(-627.887, -238.428, 37.057), vector3(-628.27, -234.794, 37.057), vector3(-628.694, -230.641, 37.057), vector3(-623.634, -232.243, 37.057), vector3(-625.033, -237.254, 37.057), vector3(-627.593, -235.515, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "lasersvangelicofdd"}
	  )

	  lasersVangelico4 = Laser.new(
		vector3(-622.158, -235.901, 41.046),
		{vector3(-625.716, -230.125, 37.057), vector3(-631.682, -233.77, 37.057), vector3(-628.212, -233.587, 37.057), vector3(-620.451, -236.097, 37.057), vector3(-617.267, -232.82, 37.057), vector3(-616.224, -235.566, 37.057), vector3(-623.9, -235.294, 37.057), vector3(-627.887, -238.428, 37.057), vector3(-628.27, -234.794, 37.057), vector3(-628.694, -230.641, 37.057), vector3(-623.634, -232.243, 37.057), vector3(-625.033, -237.254, 37.057), vector3(-627.593, -235.515, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "lasersvangelicofdd"}
	  )

	  lasersVangelico5 = Laser.new(
		vector3(-622.158, -235.901, 41.046),
		{vector3(-625.716, -230.125, 37.057), vector3(-631.682, -233.77, 37.057), vector3(-628.212, -233.587, 37.057), vector3(-620.451, -236.097, 37.057), vector3(-617.267, -232.82, 37.057), vector3(-616.224, -235.566, 37.057), vector3(-623.9, -235.294, 37.057), vector3(-627.887, -238.428, 37.057), vector3(-628.27, -234.794, 37.057), vector3(-628.694, -230.641, 37.057), vector3(-623.634, -232.243, 37.057), vector3(-625.033, -237.254, 37.057), vector3(-627.593, -235.515, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "lasersvangelicofdd"}
	  )



	  lasersVangelico6 = Laser.new(
		vector3(-627.07, -229.15, 41.02),
		{vector3(-625.716, -230.125, 37.057), vector3(-631.682, -233.77, 37.057), vector3(-628.212, -233.587, 37.057), vector3(-620.451, -236.097, 37.057), vector3(-617.267, -232.82, 37.057), vector3(-616.224, -235.566, 37.057), vector3(-623.9, -235.294, 37.057), vector3(-627.887, -238.428, 37.057), vector3(-628.27, -234.794, 37.057), vector3(-628.694, -230.641, 37.057), vector3(-623.634, -232.243, 37.057), vector3(-625.033, -237.254, 37.057), vector3(-627.593, -235.515, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "lasersvangelicofdd"}
	  )

	lasersVangelico7 = Laser.new(
		vector3(-627.07, -229.15, 41.02),
		{vector3(-625.716, -230.125, 37.057), vector3(-631.682, -233.77, 37.057), vector3(-628.212, -233.587, 37.057), vector3(-620.451, -236.097, 37.057), vector3(-617.267, -232.82, 37.057), vector3(-616.224, -235.566, 37.057), vector3(-623.9, -235.294, 37.057), vector3(-627.887, -238.428, 37.057), vector3(-628.27, -234.794, 37.057), vector3(-628.694, -230.641, 37.057), vector3(-623.634, -232.243, 37.057), vector3(-625.033, -237.254, 37.057), vector3(-627.593, -235.515, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "lasersvangelicofdd"}
	  )

	  lasersVangelico8 = Laser.new(
		vector3(-627.07, -229.15, 41.02),
		{vector3(-625.716, -230.125, 37.057), vector3(-631.682, -233.77, 37.057), vector3(-628.212, -233.587, 37.057), vector3(-620.451, -236.097, 37.057), vector3(-617.267, -232.82, 37.057), vector3(-616.224, -235.566, 37.057), vector3(-623.9, -235.294, 37.057), vector3(-627.887, -238.428, 37.057), vector3(-628.27, -234.794, 37.057), vector3(-628.694, -230.641, 37.057), vector3(-623.634, -232.243, 37.057), vector3(-625.033, -237.254, 37.057), vector3(-627.593, -235.515, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "lasersvangelicofdd"}
	  )

	  lasersVangelico9 = Laser.new(
		vector3(-627.07, -229.15, 41.02),
		{vector3(-625.716, -230.125, 37.057), vector3(-631.682, -233.77, 37.057), vector3(-628.212, -233.587, 37.057), vector3(-620.451, -236.097, 37.057), vector3(-617.267, -232.82, 37.057), vector3(-616.224, -235.566, 37.057), vector3(-623.9, -235.294, 37.057), vector3(-627.887, -238.428, 37.057), vector3(-628.27, -234.794, 37.057), vector3(-628.694, -230.641, 37.057), vector3(-623.634, -232.243, 37.057), vector3(-625.033, -237.254, 37.057), vector3(-627.593, -235.515, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "lasersvangelicofdd"}
	  )

	  lasersVangelico10 = Laser.new(
		vector3(-627.07, -229.15, 41.02),
		{vector3(-625.716, -230.125, 37.057), vector3(-631.682, -233.77, 37.057), vector3(-628.212, -233.587, 37.057), vector3(-620.451, -236.097, 37.057), vector3(-617.267, -232.82, 37.057), vector3(-616.224, -235.566, 37.057), vector3(-623.9, -235.294, 37.057), vector3(-627.887, -238.428, 37.057), vector3(-628.27, -234.794, 37.057), vector3(-628.694, -230.641, 37.057), vector3(-623.634, -232.243, 37.057), vector3(-625.033, -237.254, 37.057), vector3(-627.593, -235.515, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "lasersvangelicofdd"}
	  )


	  --lasers objeto

	  laserObj = Laser.new(
		{vector3(-617.662, -226.87, 41.912), vector3(-618.014, -227.122, 41.911), vector3(-618.299, -227.324, 41.911)},
		{vector3(-617.662, -226.87, 37.057), vector3(-618.014, -227.122, 37.057), vector3(-618.299, -227.324, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "objetofdd"}
	  )

	  laserObj2 = Laser.new(
		{vector3(-618.299, -227.324, 41.911), vector3(-618.014, -227.122, 41.911), vector3(-617.662, -226.87, 41.912)},
		{vector3(-618.299, -227.324, 37.057), vector3(-618.014, -227.122, 37.057), vector3(-617.662, -226.87, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, randomTargetSelection = true, name = "objetofdd"}
	  )

	  laserObj3 = Laser.new(
		{vector3(-616.939, -227.734, 41.889), vector3(-617.346, -228.013, 41.889), vector3(-617.769, -228.334, 41.889)},
		{vector3(-616.939, -227.734, 37.057), vector3(-617.346, -228.013, 37.057), vector3(-617.769, -228.334, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, name = "aewqewq"}
	  )

	  laserObj4 = Laser.new(
		{vector3(-617.769, -228.334, 41.889), vector3(-617.346, -228.013, 41.889), vector3(-616.939, -227.734, 41.889)},
		{vector3(-617.769, -228.334, 37.057), vector3(-617.346, -228.013, 37.057), vector3(-616.939, -227.734, 37.057)},
		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, name = "aewqewq"}
	  )

	  laserObj5 = Laser.new(
  		{vector3(-617.802, -228.314, 41.941), vector3(-618.414, -227.454, 41.922)},
  		{vector3(-617.802, -228.314, 37.057), vector3(-618.414, -227.454, 37.057)},
  		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, name = "frenteaydwq"}
	  )

	  laserObj6 = Laser.new(
  		{vector3(-618.414, -227.454, 41.922), vector3(-617.802, -228.314, 41.941)},
  		{vector3(-618.414, -227.454, 37.057), vector3(-617.802, -228.314, 37.057)},
  		{travelTimeBetweenTargets = {3.0, 3.0}, waitTimeAtTargets = {0.0, 0.0}, name = "frenteaydwq"}
	  )

end)

RegisterNetEvent("Poly.Zone", function(ZoneName, inZone)
    if ZoneName == 'vangelico-zone' and inZone then
        lasersVangelico1.setActive(lasersActive)
        lasersVangelico2.setActive(lasersActive)
		lasersVangelico3.setActive(lasersActive)
		lasersVangelico4.setActive(lasersActive)
		lasersVangelico5.setActive(lasersActive)
		lasersVangelico6.setActive(lasersActive)
		lasersVangelico7.setActive(lasersActive)
		lasersVangelico8.setActive(lasersActive)
		lasersVangelico9.setActive(lasersActive)
		lasersVangelico10.setActive(lasersActive)

		laserObj.setActive(lasersObjActive)
		laserObj2.setActive(lasersObjActive)
		laserObj3.setActive(lasersObjActive)
		laserObj4.setActive(lasersObjActive)
		laserObj5.setActive(lasersObjActive)
		laserObj6.setActive(lasersObjActive)

	elseif ZoneName == 'vangelico-zone' and not inZone then
		lasersVangelico1.setActive(false)
		lasersVangelico2.setActive(false)
		lasersVangelico3.setActive(false)
		lasersVangelico4.setActive(false)
		lasersVangelico5.setActive(false)
		lasersVangelico6.setActive(false)
		lasersVangelico7.setActive(false)
		lasersVangelico8.setActive(false)
		lasersVangelico9.setActive(false)
		lasersVangelico10.setActive(false)
		
		laserObj.setActive(false)
		laserObj2.setActive(false)
		laserObj3.setActive(false)
		laserObj4.setActive(false)
		laserObj5.setActive(false)
		laserObj6.setActive(false)
    end
end)

RegisterNetEvent('mv-vangelico:client:começar')
AddEventHandler('mv-vangelico:client:começar', function()
    --if CurrentCops >= VangConfig.MinimumJobPolice then
        if Task.Run('Vangelico.Cooldown', Shared.GetLocation()) then
			thermiteAnim()
			TriggerServerEvent('mv-vangelico:server:coolout')
			TriggerServerEvent('mv-vangelico:server:lasertimeout')
			TriggerServerEvent("mv-vangelico:server:synctargets")
			VangelicoSetup()
			TriggerServerEvent("mv-vangelico:server:syncAlarm")
		end
        --end)
    --else
		--lib.notify({ description = Lang:t('error.no_police'), type = 'error' })
    --end
end)

RegisterNetEvent('mv-vangelico:client:synctargets')
AddEventHandler('mv-vangelico:client:synctargets', function()

	for k, v in pairs(Vitrine) do
		AddBoxZone(v.coords, 0.85, 0.85, {
		  name = "vitrinevangelico" .. k,
		  debugPoly = false,
		  minZ = v.coords.z - 1.99,
		  maxZ = v.coords.z + 0.99,
		}, true)
		exports['geo-interface']:AddTargetZone("vitrinevangelico" .. k, 'Break', 'mv-vangelico:client:lootVitrine', {v.Heading, v.coords, k}, 10.0, 'fas fa-solid fa-ring')
	end



	for k, v in pairs(VangConfig['VangelicoInside']['painting']) do
		AddBoxZone(v['objectPos'], 0.85, 0.85, {
			name = "paintvangelico" .. k,
			debugPoly = false,
			minZ = v['objectPos'].z - 1.99,
			maxZ = v['objectPos'].z + 0.99,
		}, true)
		exports['geo-interface']:AddTargetZone("paintvangelico" .. k, 'Cut Painting', 'Vangelico:Painting', {k}, 5.0, 'fas fa-user-secret')
	end

	AddBoxZone(vector3(VangConfig['VangelicoInside']['glassCutting']['displayPos'].x, VangConfig['VangelicoInside']['glassCutting']['displayPos'].y, VangConfig['VangelicoInside']['glassCutting']['displayPos'].z + 1), 0.85, 0.85, {
		name = "overheat",
		debugPoly = false,
		minZ = VangConfig['VangelicoInside']['glassCutting']['displayPos'].z - 0.99,
		maxZ = VangConfig['VangelicoInside']['glassCutting']['displayPos'].z + 1.99,
	})
	exports['geo-interface']:AddTargetZone('overheat', 'Cut Glass', 'Vangelico:Overheat', nil, 5.0, 'fas fa-user-secret')

	AddBoxZone(vector3(VangConfig['VangelicoInside']['glassCutting']['displayPos'].x, VangConfig['VangelicoInside']['glassCutting']['displayPos'].y, VangConfig['VangelicoInside']['glassCutting']['displayPos'].z + 1), 0.85, 0.85, {
		name = "overheat",
		debugPoly = false,
		minZ = VangConfig['VangelicoInside']['glassCutting']['displayPos'].z - 0.99,
		maxZ = VangConfig['VangelicoInside']['glassCutting']['displayPos'].z + 1.99,
	}, true)
	exports['geo-interface']:AddTargetZone('overheat', 'Cut Glass', 'Vangelico:Overheat', nil, 5.0, 'fas fa-user-secret')

	--[[ exports['qb-target']:AddBoxZone("overheat", vector3(VangConfig['VangelicoInside']['glassCutting']['displayPos'].x, VangConfig['VangelicoInside']['glassCutting']['displayPos'].y, VangConfig['VangelicoInside']['glassCutting']['displayPos'].z + 1), 0.85, 0.85, {
		name = "overheat",
		debugPoly = false,
		minZ = VangConfig['VangelicoInside']['glassCutting']['displayPos'].z - 0.99,
		maxZ = VangConfig['VangelicoInside']['glassCutting']['displayPos'].z + 1.99,
	  }, {
		options = {
		  {
			icon = "fas fa-user-secret",
			label = Lang:t('target.glass'),
			action = function()
			  
			    if not VangConfig['VangelicoInside']['glassCutting']['looted'] then
					if not lasersObjActive then
						if QBCore.Functions.HasItem(VangConfig.RequiredItemCutGlass) then
							OverheatScene()
						else
							QBCore.Functions.Notify(Lang:t('error.cutter'), "error")
						end
					else
						QBCore.Functions.Notify(Lang:t('error.lasers'), "error")
					end
				
				else
					QBCore.Functions.Notify(Lang:t('error.alreadyStole'), "error")
			    end

		  
			end
		  },
		},
		distance = 1.0
	  })


	  exports['qb-target']:AddBoxZone("hacklasers", vector3(-631.01, -230.75, 38.06), 0.85, 0.85, {
		name = "hacklasers",
		debugPoly = false,
		minZ = 38.06 - 0.99,
		maxZ = 38.06 + 1.99,
	  }, {
		options = {
		  {
			icon = "fas fa-user-secret",
			label = Lang:t('target.system'),
			action = function()
				if canHack then
					HackLasers()
				else
					QBCore.Functions.Notify(Lang:t('error.lasers_off'), "error")
				end
		  
			end
		  },
		},
		distance = 1.0
	  }) ]]
    
end)

AddEventHandler('Vangelico:Painting', function(id)
	PaintingScene(id)
end)

--sync de loot vitrines

RegisterNetEvent('mv-vangelico:client:syncloot')
AddEventHandler('mv-vangelico:client:syncloot', function(i)
    Vitrine[i].looted = true
end)

--sync de loot painting

RegisterNetEvent('mv-vangelico:client:synclootPainting')
AddEventHandler('mv-vangelico:client:synclootPainting', function(i)
    VangConfig['VangelicoInside']['painting'][i]['looted'] = true
end)

--sync de loot overhear

RegisterNetEvent('mv-vangelico:client:synclootOverheat')
AddEventHandler('mv-vangelico:client:synclootOverheat', function(i)
    VangConfig['VangelicoInside']['glassCutting']['looted'] = true
end)

-- sync de vitrines partidas
RegisterNetEvent('mv-vangelico:client:smashSync')
AddEventHandler('mv-vangelico:client:smashSync', function(index)
    CreateModelSwap(Vitrine[index].objPos.x,Vitrine[index].objPos.y,Vitrine[index].objPos.z, 0.3, GetHashKey(Vitrine[index].oldModel), GetHashKey(Vitrine[index].newModel), 1)
end)

RegisterNetEvent('mv-vangelico:client:lootVitrine', function(heading, coords, i)

	local weapon2 = GetSelectedPedWeapon(Shared.Ped)

	local weapon = false
	weapon = true

	if weapon then

		TriggerServerEvent("mv-vangelico:server:syncloot", i)

		local ped = Shared.Ped
	
		local pedCo = GetEntityCoords(ped)
		local pedRotation = GetEntityRotation(ped)
		local animDict = 'missheist_jewel'
		local ptfxAsset = "scr_jewelheist"
		local particleFx = "scr_jewel_cab_smash"
		loadAnimDict(animDict)
		loadPtfxAsset(ptfxAsset)
	
		SetEntityCoords(ped, Vitrine[i].coordsAnim)
		SetEntityHeading(ped, Vitrine[i].Heading)
	
		local rot = GetEntityRotation(ped)
		local anims = {
			'smash_case_necklace', 
			'smash_case_d',
			'smash_case_e',
			'smash_case_f',
		}
		
		local selected = anims[math.random(1, #anims)]
	
		scene = NetworkCreateSynchronisedScene(Vitrine[i].coordsAnim.x, Vitrine[i].coordsAnim.y, Vitrine[i].coordsAnim.z-1, rot, 2, true, false, 1065353216, 0, 1.3)
		NetworkAddPedToSynchronisedScene(ped, scene, animDict, selected, 2.0, 4.0, 1, 0, 1148846080, 0)
		NetworkStartSynchronisedScene(scene)
		TriggerServerEvent("mv-vangelico:server:smashSync", i)
		PlaySoundFromCoord(-1, "Glass_Smash", Vitrine[i].coordsAnim, 0, 1, 0)
		
		SetPtfxAssetNextCall(ptfxAsset)
        StartNetworkedParticleFxNonLoopedAtCoord(particleFx, Vitrine[i].objPos.x, Vitrine[i].objPos.y, Vitrine[i].objPos.z + 0.3, 0.0, 0.0, 0.0, 2.0, 0, 0, 0)
	
		Wait(GetAnimDuration(animDict, selected) * 1000 - 1000)
	
		ClearPedTasks(Shared.Ped)

		TriggerServerEvent("mv-vangelico:server:lootVitrine", i)
		TriggerEvent('RemoveZone', "vitrinevangelico" .. i)
		local coords = GetEntityCoords(Shared.Ped)
	end
	
                
            
end)

function PaintingScene(sceneId)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(Shared.Ped)
 

        if exports['geo-inventory']:HasItemKey('switchblade') then
            TriggerServerEvent("mv-vangelico:server:synclootPainting", sceneId)

            local pedCo, pedRotation = GetEntityCoords(ped), vector3(0.0, 0.0, 0.0)
            local animDict = "anim_heist@hs3f@ig11_steal_painting@male@"
            scene = VangConfig['VangelicoInside']['painting'][sceneId]
            sceneObject = GetClosestObjectOfType(scene['objectPos'], 1.0, GetHashKey(scene['object']), 0, 0, 0)
            scenePos = scene['scenePos']
            sceneRot = scene['sceneRot']
            loadAnimDict(animDict)
            
            for k, v in pairs(ArtHeist['objects']) do
                loadModel(v)
                ArtHeist['sceneObjects'][k] = CreateObject(GetHashKey(v), pedCo, 1, 1, 0)
            end
            
            for i = 1, 10 do
                ArtHeist['scenes'][i] = NetworkCreateSynchronisedScene(scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 2, true, false, 1065353216, 0, 1065353216)
                NetworkAddPedToSynchronisedScene(ped, ArtHeist['scenes'][i], animDict, 'ver_01_' .. ArtHeist['animations'][i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
                NetworkAddEntityToSynchronisedScene(sceneObject, ArtHeist['scenes'][i], animDict, 'ver_01_' .. ArtHeist['animations'][i][3], 1.0, -1.0, 1148846080)
                NetworkAddEntityToSynchronisedScene(ArtHeist['sceneObjects'][1], ArtHeist['scenes'][i], animDict, 'ver_01_' .. ArtHeist['animations'][i][4], 1.0, -1.0, 1148846080)
                NetworkAddEntityToSynchronisedScene(ArtHeist['sceneObjects'][2], ArtHeist['scenes'][i], animDict, 'ver_01_' .. ArtHeist['animations'][i][5], 1.0, -1.0, 1148846080)
            end

            cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
            SetCamActive(cam, true)
            RenderScriptCams(true, 0, 3000, 1, 0)
            
            FreezeEntityPosition(ped, true)
            NetworkStartSynchronisedScene(ArtHeist['scenes'][1])
            PlayCamAnim(cam, 'ver_01_top_left_enter_cam_ble', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
            Wait(3000)
            NetworkStartSynchronisedScene(ArtHeist['scenes'][2])
            PlayCamAnim(cam, 'ver_01_cutting_top_left_idle_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)

            NetworkStartSynchronisedScene(ArtHeist['scenes'][3])
            PlayCamAnim(cam, 'ver_01_cutting_top_left_to_right_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
            Wait(3000)
            NetworkStartSynchronisedScene(ArtHeist['scenes'][4])
            PlayCamAnim(cam, 'ver_01_cutting_top_right_idle_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)

            NetworkStartSynchronisedScene(ArtHeist['scenes'][5])
            PlayCamAnim(cam, 'ver_01_cutting_right_top_to_bottom_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
            Wait(3000)
            NetworkStartSynchronisedScene(ArtHeist['scenes'][6])
            PlayCamAnim(cam, 'ver_01_cutting_bottom_right_idle_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)

            NetworkStartSynchronisedScene(ArtHeist['scenes'][7])
            PlayCamAnim(cam, 'ver_01_cutting_bottom_right_to_left_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
            Wait(3000)

        	NetworkStartSynchronisedScene(ArtHeist['scenes'][9])
       		PlayCamAnim(cam, 'ver_01_cutting_left_top_to_bottom_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
       		Wait(1500)
        	NetworkStartSynchronisedScene(ArtHeist['scenes'][10])
        	RenderScriptCams(false, false, 0, 1, 0)
        	DestroyCam(cam, false)
        	Wait(7500)
        
        	ClearPedTasks(ped)
			FreezeEntityPosition(ped, false)
			RemoveAnimDict(animDict)
			for k, v in pairs(ArtHeist['sceneObjects']) do
				DeleteObject(v)
			end
			DeleteObject(sceneObject)
			DeleteEntity(sceneObject)
			ArtHeist['sceneObjects'] = {}
			ArtHeist['scenes'] = {}

			local coords = GetEntityCoords(Shared.Ped)

			TriggerEvent('RemoveZone', "paintvangelico" .. sceneId)
			TriggerServerEvent("mv-vangelico:server:lootPainting", sceneId)
		else
			TriggerEvent('You need a switchblade')
		end


end

function OverheatScene()
	TriggerServerEvent("mv-vangelico:server:synclootOverheat")

	local ped = Shared.Ped
	local pedCo, pedRotation = GetEntityCoords(ped), GetEntityRotation(ped)
	local animDict = 'anim@scripted@heist@ig16_glass_cut@male@'
	sceneObject = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_glass_disp_01a'), 0, 0, 0)
	scenePos = GetEntityCoords(sceneObject)
	sceneRot = GetEntityRotation(sceneObject)
	globalObj = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 5.0, GetHashKey(VangelicoHeist['globalObject']), 0, 0, 0)
	loadAnimDict(animDict)
	RequestScriptAudioBank('DLC_HEI4/DLCHEI4_GENERIC_01', -1)

	cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
	SetCamActive(cam, true)
	RenderScriptCams(true, 0, 3000, 1, 0)

	for k, v in pairs(Overheat['objects']) do
		loadModel(v)
		Overheat['sceneObjects'][k] = CreateObject(GetHashKey(v), pedCo, 1, 1, 0)
	end

	local newObj = CreateObject(GetHashKey('h4_prop_h4_glass_disp_01b'), GetEntityCoords(sceneObject), 1, 1, 0)
	SetEntityHeading(newObj, GetEntityHeading(sceneObject))

	for i = 1, #Overheat['animations'] do
		Overheat['scenes'][i] = NetworkCreateSynchronisedScene(scenePos, sceneRot, 2, true, false, 1065353216, 0, 1.3)
		NetworkAddPedToSynchronisedScene(ped, Overheat['scenes'][i], animDict, Overheat['animations'][i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
		NetworkAddEntityToSynchronisedScene(Overheat['sceneObjects'][1], Overheat['scenes'][i], animDict, Overheat['animations'][i][2], 1.0, -1.0, 1148846080)
		NetworkAddEntityToSynchronisedScene(Overheat['sceneObjects'][2], Overheat['scenes'][i], animDict, Overheat['animations'][i][3], 1.0, -1.0, 1148846080)
		if i ~= 5 then
			NetworkAddEntityToSynchronisedScene(sceneObject, Overheat['scenes'][i], animDict, Overheat['animations'][i][4], 1.0, -1.0, 1148846080)
		else
			NetworkAddEntityToSynchronisedScene(newObj, Overheat['scenes'][i], animDict, Overheat['animations'][i][4], 1.0, -1.0, 1148846080)
		end
	end

	local sound1 = GetSoundId()
	local sound2 = GetSoundId()

	NetworkStartSynchronisedScene(Overheat['scenes'][1])
	PlayCamAnim(cam, 'enter_cam', animDict, scenePos, sceneRot, 0, 2)
	Wait(GetAnimDuration(animDict, 'enter') * 1000)

	NetworkStartSynchronisedScene(Overheat['scenes'][2])
	PlayCamAnim(cam, 'idle_cam', animDict, scenePos, sceneRot, 0, 2)
	Wait(GetAnimDuration(animDict, 'idle') * 1000)

	NetworkStartSynchronisedScene(Overheat['scenes'][3])
	PlaySoundFromEntity(sound1, "StartCutting", Overheat['sceneObjects'][2], 'DLC_H4_anims_glass_cutter_Sounds', true, 80)
	loadPtfxAsset('scr_ih_fin')
	UseParticleFxAssetNextCall('scr_ih_fin')
	fire1 = StartParticleFxLoopedOnEntity('scr_ih_fin_glass_cutter_cut', Overheat['sceneObjects'][2], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1065353216, 0.0, 0.0, 0.0, 1065353216, 1065353216, 1065353216, 0)
	PlayCamAnim(cam, 'cutting_loop_cam', animDict, scenePos, sceneRot, 0, 2)
	Wait(GetAnimDuration(animDict, 'cutting_loop') * 1000)
	StopSound(sound1)
	StopParticleFxLooped(fire1)

	NetworkStartSynchronisedScene(Overheat['scenes'][4])
	PlaySoundFromEntity(sound2, "Overheated", Overheat['sceneObjects'][2], 'DLC_H4_anims_glass_cutter_Sounds', true, 80)
	UseParticleFxAssetNextCall('scr_ih_fin')
	fire2 = StartParticleFxLoopedOnEntity('scr_ih_fin_glass_cutter_overheat', Overheat['sceneObjects'][2], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1065353216, 0.0, 0.0, 0.0)
	PlayCamAnim(cam, 'overheat_react_01_cam', animDict, scenePos, sceneRot, 0, 2)
	Wait(GetAnimDuration(animDict, 'overheat_react_01') * 1000)
	StopSound(sound2)
	StopParticleFxLooped(fire2)

	DeleteObject(sceneObject)
	NetworkStartSynchronisedScene(Overheat['scenes'][5])
	Wait(2000)
	DeleteObject(globalObj)
	
	PlayCamAnim(cam, 'success_cam', animDict, scenePos, sceneRot, 0, 2)
	Wait(GetAnimDuration(animDict, 'success') * 1000 - 2000)
	DeleteObject(Overheat['sceneObjects'][1])
	DeleteObject(Overheat['sceneObjects'][2])
	ClearPedTasks(ped)
	RenderScriptCams(false, false, 0, 1, 0)
	DestroyCam(cam, false)

	local coords = GetEntityCoords(Shared.Ped)

	--[[ if math.random(1, 100) <= 25 then
		TriggerServerEvent("evidence:server:CreateBloodDrop", playerData.citizenid, playerData.metadata.bloodtype, coords)
		lib.notify({ title = 'Burned', description = 'You bujrned yourself while using the cutter', type = 'info' })
	end ]]

	TriggerEvent('RemoveZone', 'overheat')
	TriggerServerEvent("mv-vangelico:server:lootOverHeat", VangGlobalIndex)
end



function HackLasers()
	exports['ps-ui']:VarHack(function(success)
		if success then

			TriggerServerEvent("mv-vangelico:server:syncLasersobj")

		else
			QBCore.Functions.Notify(Lang:t('error.fail'), 'error')
		end
	end, VangConfig.NumberOfBlocksInMinigameVar, 10) -- Number of Blocks, Time (seconds)
	local coords = GetEntityCoords(Shared.Ped)
	TriggerServerEvent("evidence:server:CreateLockTampering", coords)
end



function VangelicoSetup()

    local random = math.random(1, 4)
    local glassConfig = VangConfig['VangelicoInside']['glassCutting']
    loadModel(glassConfig['rewards'][random]['object']['model'])
    loadModel(glassConfig['rewards'][random]['displayObj']['model'])
    loadModel('h4_prop_h4_glass_disp_01a')
    local glass = CreateObject(GetHashKey('h4_prop_h4_glass_disp_01a'), -617.4622, -227.4347, 37.057, 1, 1, 0)
    SetEntityHeading(glass, -53.06)
    local reward = CreateObject(GetHashKey(glassConfig['rewards'][random]['object']['model']), glassConfig['rewardPos'].xy, glassConfig['rewardPos'].z + 0.195, 1, 1, 0)
    SetEntityHeading(reward, glassConfig['rewards'][random]['object']['rot'])
    local rewardDisp = CreateObject(GetHashKey(glassConfig['rewards'][random]['displayObj']['model']), glassConfig['rewardPos'], 1, 1, 0)
    SetEntityRotation(rewardDisp, glassConfig['rewards'][random]['displayObj']['rot'])
    TriggerServerEvent('mv-vangelico:server:globalObject', glassConfig['rewards'][random]['object']['model'], random)

    for k, v in pairs(VangConfig['VangelicoInside']['painting']) do
        loadModel(v['object'])
        VangelicoHeist['painting'][k] = CreateObjectNoOffset(GetHashKey(v['object']), v['objectPos'], 1, 0, 0)
        SetEntityRotation(VangelicoHeist['painting'][k], 0, 0, v['objHeading'], 2, true)
    end

end



function thermiteAnim()
	local thermiteCoords = vector4(-595.97, -283.88, 50.32, 300.85)
	local particleCoords = vector3(-595.92, -282.88, 50.32)

	TriggerServerEvent("mv-vangelico:server:removethermite")
	RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end
    local ped = Shared.Ped
	
	SetEntityHeading(ped, thermiteCoords.w)

    Citizen.Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(Shared.Ped)))
    local bagscene = NetworkCreateSynchronisedScene(vector3(thermiteCoords.x, thermiteCoords.y, thermiteCoords.z), rotx, roty, rotz + 1.1, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), vector3(thermiteCoords.x, thermiteCoords.y, thermiteCoords.z),  true,  true, false)
	

    SetEntityCollision(bag, false, true)
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.2, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(bagscene)
	--[[ QBCore.Functions.Progressbar('Changeme', Lang:t('progress.start'), 3500, false, false, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true
		}, {}, {}, {}, function()
			-- This code runs if the progress bar completes successfully
		end, function()
			-- This code runs if the progress bar gets cancelled
	end) ]]
    Citizen.Wait(1500)
    local x, y, z = table.unpack(GetEntityCoords(ped))
	
    local bomba = CreateObject(GetHashKey("hei_prop_heist_thermite"), x-1, y, z + 0.3,  true,  true, true)

    SetEntityCollision(bomba, false, true)
    AttachEntityToEntity(bomba, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    Citizen.Wait(2000)
    DeleteObject(bag)

    DetachEntity(bomba, 1, 1)
    FreezeEntityPosition(bomba, true)
    TriggerServerEvent("mv-vangelico:server:particleserver", particleCoords)
	
    NetworkStopSynchronisedScene(bagscene)
    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)
    Citizen.Wait(5000)
    ClearPedTasks(ped)
    DeleteObject(bomba)
    
	TriggerServerEvent('mv-vangelico:server:setDoorStatus', 'vangelico-1', 0)
	--TriggerServerEvent('qb-doorlock:server:updateState', 23, false, false, false, true, false, false)
end


RegisterNetEvent("mv-vangelico:client:ptfxparticle")
AddEventHandler("mv-vangelico:client:ptfxparticle", function(particleCoords)
    local ptfx

    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(1)
    end
        ptfx = particleCoords
    SetPtfxAssetNextCall("scr_ornate_heist")
    local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfx, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    Citizen.Wait(4000)
    
    StopParticleFxLooped(effect, 0)
	
end)


RegisterNetEvent('mv-vangelico:client:LasersCoolout', function()
    lasersActive = false
	lasersVangelico1.setActive(false)
	lasersVangelico2.setActive(false)
	lasersVangelico3.setActive(false)
	lasersVangelico4.setActive(false)
	lasersVangelico5.setActive(false)
	lasersVangelico6.setActive(false)
	lasersVangelico7.setActive(false)
	lasersVangelico8.setActive(false)
	lasersVangelico9.setActive(false)
	lasersVangelico10.setActive(false)


    local timer = VangConfig.Cooldown * 60000
    while timer > 0 do
        Wait(1000)
        timer = timer - 1000
        if timer == 0 then
            lasersActive = true
			lasersObjActive = true
			canHack = true
			TriggerServerEvent('mv-vangelico:server:setDoorStatus', 'vangelico-1', 1)
			-- TriggerServerEvent('ox_doorlock:setState', 23, 1)
			TriggerEvent("mv-vangelico:client:clear")

        end
    end
end)

--sync lasers obj

RegisterNetEvent('mv-vangelico:client:LasersObjDisable', function()
    lasersObjActive = false
	canHack = false
	laserObj.setActive(false)
	laserObj2.setActive(false)
	laserObj3.setActive(false)
	laserObj4.setActive(false)
	laserObj5.setActive(false)
	laserObj6.setActive(false)

end)




function loadPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        RequestNamedPtfxAsset(dict)
        Citizen.Wait(50)
	end
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(50)
    end
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

RegisterNetEvent('mv-vangelico:client:globalObject')
AddEventHandler('mv-vangelico:client:globalObject', function(obj, index)
    VangelicoHeist['globalObject'] = obj
    VangelicoHeist['globalItem'] = VangConfig['VangelicoInside']['glassCutting']['rewards'][index]['item']
	VangGlobalIndex = index
end)


RegisterNetEvent('mv-vangelico:client:alarmsync')
AddEventHandler('mv-vangelico:client:alarmsync', function(data)
	
	while not PrepareAlarm("JEWEL_STORE_HEIST_ALARMS") do
		Citizen.Wait(100)
	end
	StartAlarm("JEWEL_STORE_HEIST_ALARMS", 1)

	Wait(VangConfig.AlarmTime)

	StopAlarm("JEWEL_STORE_HEIST_ALARMS", -1)
										
	
end)

CreateThread(function()
	local blip = AddBlipForCoord(-617.4622, -227.4347, 37.057)
	SetBlipSprite(blip, 617)
	SetBlipAsShortRange(blip, true)
	SetBlipScale(blip, 1.0)
	SetBlipColour(blip, 42)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Vangelicos")
	EndTextCommandSetBlipName(blip)
end)

AddEventHandler('Vangelico:Overheat', function()
	OverheatScene()
end)