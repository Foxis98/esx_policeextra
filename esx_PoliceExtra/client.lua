local insideMarker = false
local job = nil
local lastInteractionTime = 0

Citizen.CreateThread(function()
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	job = ESX.GetPlayerData().job
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	job = xPlayer.job
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(newJob)
	job = newJob
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		local coords = GetEntityCoords(PlayerPedId())
		local veh = GetVehiclePedIsIn(PlayerPedId(), false)
		local pedInVeh = IsPedInAnyVehicle(PlayerPedId(), true)

		if job and job.name == Config.PoliceDatabaseName then
			for k, v in pairs(Config.ExtraZones) do
				for i = 1, #v.Pos, 1 do
					local distance = Vdist(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z)

					if distance < 4.5 and insideMarker == false and pedInVeh then
						if GetVehicleClass(veh) == 18 then
							lib.showTextUI('[E] - Atidaryti EXTRA')
							if IsControlJustPressed(0, 38) and (GetGameTimer() - lastInteractionTime) > 1000 then
								OpenMainMenu()
								insideMarker = true
								lastInteractionTime = GetGameTimer()
							end
						end
					else
						lib.hideTextUI()
					end
				end
			end
		end
	end
end)


-- Police Extra Menu:
function OpenExtraMenu()
	local elements = {}
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
	for id=0, 12 do
		if DoesExtraExist(vehicle, id) then
			local state = IsVehicleExtraTurnedOn(vehicle, id) 

			if state then
				table.insert(elements, {
					label = "Ekstra: "..id.." | "..('<span style="color:green;">%s</span>'):format("Įjungta"),
					value = id,
					state = not state
				})
			else
				table.insert(elements, {
					label = "Ekstra: "..id.." | "..('<span style="color:red;">%s</span>'):format("Išjungta"),
					value = id,
					state = not state
				})
			end
		end
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'extra_actions', {
		title    = Config.TitlePoliceExtra,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		SetVehicleExtra(vehicle, data.current.value, not data.current.state)
		local newData = data.current
		if data.current.state then
			newData.label = "Ekstra: "..data.current.value.." | "..('<span style="color:green;">%s</span>'):format("Įjungta")
		else
			newData.label = "Ekstra: "..data.current.value.." | "..('<span style="color:red;">%s</span>'):format("Išjungta")
		end
		newData.state = not data.current.state

		menu.update({value = data.current.value}, newData)
		menu.refresh()
	end, function(data, menu)
		menu.close()
	end)
end

-- Police Livery Menu:
function OpenLiveryMenu()
	local elements = {}
	
	local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
	local liveryCount = GetVehicleLiveryCount(vehicle)
			
	for i = 1, liveryCount do
		local state = GetVehicleLivery(vehicle) 
		local text
		
		if state == i then
			text = "Lipdukai: "..i.." | "..('<span style="color:green;">%s</span>'):format("Įjungta")
		else
			text = "Lipdukai: "..i.." | "..('<span style="color:red;">%s</span>'):format("Išjungta")
		end
		
		table.insert(elements, {
			label = text,
			value = i,
			state = not state
		}) 
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'livery_menu', {
		title    = Config.TitlePoliceLivery,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		SetVehicleLivery(vehicle, data.current.value, not data.current.state)
		local newData = data.current
		if data.current.state then
			newData.label = "Lipdukai: "..data.current.value.." | "..('<span style="color:green;">%s</span>'):format("Įjungta")
		else
			newData.label = "Lipdukai: "..data.current.value.." | "..('<span style="color:red;">%s</span>'):format("Išjungta")
		end
		newData.state = not data.current.state
		menu.update({value = data.current.value}, newData)
		menu.refresh()
		menu.close()	
	end, function(data, menu)
		menu.close()		
	end)
end

-- Police Extra Main Menu:
function OpenMainMenu()
	local elements = {
		{label = Config.LabelPrimaryCol,value = 'primary'},
		{label = Config.LabelSecondaryCol,value = 'secondary'},
		{label = Config.LabelExtra,value = 'extra'},
		{label = Config.LabelLivery,value = 'livery'}
	}
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'color_menu', {
		title    = Config.TitlePoliceExtra,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'extra' then
			OpenExtraMenu()
		elseif data.current.value == 'livery' then
			OpenLiveryMenu()
		elseif data.current.value == 'primary' then
			OpenMainColorMenu('primary')
		elseif data.current.value == 'secondary' then
			OpenMainColorMenu('secondary')
		end
	end, function(data, menu)
		menu.close()
		insideMarker = false
	end)
end

-- Police Color Main Menu:
function OpenMainColorMenu(colortype)
	local elements = {}
	for k,v in pairs(Config.Colors) do
		table.insert(elements, {
			label = v.label,
			value = v.value
		})
	end
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main_color_menu', {
		title    = Config.TitleColorType,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		OpenColorMenu(data.current.type, data.current.value, colortype)
	end, function(data, menu)
		menu.close()
	end)
end

-- Police Color Menu:
function OpenColorMenu(type, value, colortype)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'extra_actions', {
		title    = Config.TitleValues,
		align    = 'top-left',
		elements = GetColors(value)
	}, function(data, menu)
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local pr,sec = GetVehicleColours(vehicle)
		if colortype == 'primary' then
			SetVehicleColours(vehicle, data.current.index, sec)
		elseif colortype == 'secondary' then
			SetVehicleColours(vehicle, pr, data.current.index)
		end
		
	end, function(data, menu)
		menu.close()
	end)
end
