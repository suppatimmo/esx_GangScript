local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local colors = { ["GREEN"] = '<span style="color:green;">', ["RED"] = '<span style="color:red;">', ["END"] = '</span>' }
local PlayerData                = {}
local GUI                       = {}
local HasAlreadyEnteredMarker   = false
local LastStation               = nil
local LastPart                  = nil
local LastPartNum               = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}

ESX                             = nil
GUI.Time                        = 0

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
  
    if ESX.IsPlayerLoaded() then
		PlayerData = ESX.GetPlayerData()
    end  
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(response)
	PlayerData = response
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

Citizen.CreateThread(function()

	for k,v in pairs(Config.Gangs) do
		if v.JobName ~= nil then
			TriggerServerEvent('esx_gangScript:registerSocieties', v.JobName)
		end
		if v.Blip ~= nil then
			local blip = AddBlipForCoord(v.Blip.Pos.x, v.Blip.Pos.y, v.Blip.Pos.z)
			SetBlipSprite (blip, v.Blip.Sprite)
			SetBlipDisplay(blip, v.Blip.Display)
			SetBlipScale  (blip, v.Blip.Scale)
			SetBlipColour (blip, v.Blip.Colour)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.Blip.Name)
			EndTextCommandSetBlipName(blip)
		end
	end

	while true do
		local sleepThread = 500
		local isInMarker     = false
		local currentStation = nil
		local currentPart    = nil
		local currentPartNum = nil
		local hasExited = false		
		for k,v in pairs(Config.Gangs) do
			if PlayerData.job ~= nil and PlayerData.job.name == v.JobName then
				local playerPed = GetPlayerPed(-1)
				local coords    = GetEntityCoords(playerPed)
				
				if v.Armories ~= nil then 
					for i=1, #v.Armories, 1 do
						if GetDistanceBetweenCoords(coords,  v.Armories[i].x,  v.Armories[i].y,  v.Armories[i].z,  true) < Config.DrawDistance then
							DrawMarker(Config.MarkerType, v.Armories[i].x, v.Armories[i].y, v.Armories[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
							sleepThread = 5
						end
						
						if GetDistanceBetweenCoords(coords,  v.Armories[i].x,  v.Armories[i].y,  v.Armories[i].z,  true) < Config.MarkerSize.x then
							isInMarker     = true
							currentStation = k
							currentPart    = 'Armory'
							currentPartNum = i
						end					
					end
				end
				
				if v.Vehicles ~= nil then 
					for i=1, #v.Vehicles, 1 do
						if GetDistanceBetweenCoords(coords,  v.Vehicles[i].Spawner.x,  v.Vehicles[i].Spawner.y,  v.Vehicles[i].Spawner.z,  true) < Config.DrawDistance then
							DrawMarker(Config.MarkerType, v.Vehicles[i].Spawner.x, v.Vehicles[i].Spawner.y, v.Vehicles[i].Spawner.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
							sleepThread = 5
						end
						
						if GetDistanceBetweenCoords(coords,  v.Vehicles[i].Spawner.x,  v.Vehicles[i].Spawner.y,  v.Vehicles[i].Spawner.z,  true) < Config.MarkerSize.x then
							isInMarker     = true
							currentStation = k
							currentPart    = 'VehicleSpawner'
							currentPartNum = i
						end					
					end
				end	
				if v.VehicleDeleters ~= nil then 
					for i=1, #v.VehicleDeleters, 1 do
						if GetDistanceBetweenCoords(coords,  v.VehicleDeleters[i].x,  v.VehicleDeleters[i].y,  v.VehicleDeleters[i].z,  true) < Config.DrawDistance then
							DrawMarker(Config.MarkerType, v.VehicleDeleters[i].x, v.VehicleDeleters[i].y, v.VehicleDeleters[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
						end
						
						if GetDistanceBetweenCoords(coords,  v.VehicleDeleters[i].x,  v.VehicleDeleters[i].y,  v.VehicleDeleters[i].z,  true) < Config.MarkerSize.x then
							isInMarker     = true
							currentStation = k
							currentPart    = 'VehicleDeleter'
							currentPartNum = i
						end							
					end				
				end
				if v.EnablePlayerManagement then
					for i=1, #v.AuthorizedToBossActionsRanks, 1 do
						if PlayerData.job.grade_name == v.AuthorizedToBossActionsRanks[i] then
							for i=1, #v.BossActions, 1 do
								if GetDistanceBetweenCoords(coords,  v.BossActions[i].x,  v.BossActions[i].y,  v.BossActions[i].z,  true) < Config.DrawDistance then
									DrawMarker(Config.MarkerType, v.BossActions[i].x, v.BossActions[i].y, v.BossActions[i].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
									sleepThread = 5
								end
								
								if GetDistanceBetweenCoords(coords,  v.BossActions[i].x,  v.BossActions[i].y,  v.BossActions[i].z,  true) < Config.MarkerSize.x then
									isInMarker     = true
									currentStation = k
									currentPart    = 'BossActions'
									currentPartNum = i

								end								
							end								
						end
					end
				end

				if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum) ) then
					if
					  (LastStation ~= nil and LastPart ~= nil and LastPartNum ~= nil) and
					  (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
					then
					  TriggerEvent('esx_gangScript:hasExitedMarker', LastStation, LastPart, LastPartNum)
					  hasExited = true
					end
					
					HasAlreadyEnteredMarker = true
					LastStation             = currentStation
					LastPart                = currentPart
					LastPartNum             = currentPartNum				
					TriggerEvent('esx_gangScript:hasEnteredMarker', currentStation, currentPart, currentPartNum)	
				end

				if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
					HasAlreadyEnteredMarker = false
					TriggerEvent('esx_gangScript:hasExitedMarker', LastStation, LastPart, LastPartNum)
				end
				
				if CurrentAction ~= nil then
					SetTextComponentFormat('STRING')
					AddTextComponentString(CurrentActionMsg)
					DisplayHelpTextFromStringLabel(0, 0, 1, -1)

					if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 150 then
						if CurrentAction == 'menu_armory' then
							OpenArmoryMenu(CurrentActionData.station, v.JobName)
						elseif CurrentAction == 'menu_boss_actions' then		
							ESX.UI.Menu.CloseAll()
							TriggerEvent('esx_society:openBossMenu', v.JobName, function(data, menu)
							menu.close()
							CurrentAction     = 'menu_boss_actions'
							CurrentActionMsg  = _U('open_bossmenu')
							CurrentActionData = {}
							end, {grades = false})
						elseif CurrentAction == 'menu_vehicle_spawner' then
							OpenVehicleSpawnerMenu(CurrentActionData.station, CurrentActionData.partNum, v.JobName)
						elseif CurrentAction == 'delete_vehicle' then
							local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
							TriggerServerEvent('esx_gangScript:validateCar',v.JobName, vehicleProps.plate, CurrentActionData.vehicle)
						end	
					CurrentAction = nil
					GUI.Time      = GetGameTimer()
					end
				end			
			end
		end
		Citizen.Wait(sleepThread)
	end
end)

function OpenVehicleSpawnerMenu(station, partNum, societyName)

	local elements = {}
	ESX.TriggerServerCallback('esx_gangScript:getSocietyVehicles', function(vehicles)
		for _,v in pairs(vehicles) do
			local hashVehicule = v.vehicle.model
    		local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
    		local vehicleLabel

    		if(v.state)then
				vehicleLabel = colors["GREEN"] .. '✓ : ' .. colors["END"] .. vehicleName
    		else
				vehicleLabel = colors["RED"] .. '✗ : ' .. colors["END"] .. vehicleName
    		end	
			table.insert(elements, {label = vehicleLabel , value = v})	
		end

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'spawn_vehicle',
		{
			title    = 'Garaż organizacji',
			align    = 'left',
			elements = elements,
		},
		function(data, menu)
			if data.current.value.state then
				menu.close()
				SpawnVehicle(data.current.value.vehicle, station, partNum)
			else
				ESX.ShowNotification(_U('car_state_false'))			
			end
		end,
		function(data, menu)
			menu.close()
		end
	)	
	end, societyName)
end

function SpawnVehicle(vehicle, station, garageNumber)
	TriggerServerEvent('esx_gangScript:updateVehicleState',  vehicle.plate,0)
	ESX.Game.SpawnVehicle(vehicle.model, Config.Gangs[station].Vehicles[garageNumber].SpawnPoint, Config.Gangs[station].Vehicles[garageNumber].Heading, 
	function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		SetVehRadioStation(callback_vehicle, "OFF")
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
		local plate = GetVehicleNumberPlateText(callback_vehicle)
		TriggerServerEvent("ls:mainCheck", plate, callback_vehicle, true)
	end)
end

  --[[  ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(garageVehicles)

      for i=1, #garageVehicles, 1 do
        table.insert(elements, {label = GetDisplayNameFromVehicleModel(garageVehicles[i].model) .. ' [' .. garageVehicles[i].plate .. ']', value = garageVehicles[i]})
      end

      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'vehicle_spawner',
        {
          title    = _U('vehicle_menu'),
          align    = 'left',
          elements = elements,
        },
        function(data, menu)

          menu.close()

          local vehicleProps = data.current.value

          ESX.Game.SpawnVehicle(vehicleProps.model, vehicles[partNum].SpawnPoint, 270.0, function(vehicle)
            ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
            local playerPed = GetPlayerPed(-1)
            TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)
          end)

          TriggerServerEvent('esx_society:removeVehicleFromGarage', societyName, vehicleProps)

        end,
        function(data, menu)

          menu.close()

          CurrentAction     = 'menu_vehicle_spawner'
          CurrentActionMsg  = _U('vehicle_spawner')
          CurrentActionData = {station = station, partNum = partNum}

        end
      )

    end, societyName)

  else


end--]]

function OpenArmoryMenu(station, societyName)
    local elements = {}
	table.insert(elements, {label = _U('get_weapon'), value = 'get_weapon'})
	table.insert(elements, {label = _U('put_weapon'), value = 'put_weapon'})
	table.insert(elements, {label = _U('get_stock'),  value = 'get_stock'})
	table.insert(elements, {label = _U('put_stock'),  value = 'put_stock'})	
	ESX.UI.Menu.CloseAll()
	
    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'armory',
      {
        title    = _U('armory'),
        align    = 'left',
        elements = elements,
      },
      function(data, menu)
		if data.current.value == 'get_weapon' then
			OpenGetWeaponMenu(societyName)
		elseif data.current.value == 'put_weapon' then
			OpenPutWeaponMenu(societyName)
        elseif data.current.value == 'put_stock' then
			OpenPutStocksMenu(societyName)
		elseif data.current.value == 'get_stock' then
			OpenGetStocksMenu(societyName)
		end
		
		local weapon = data.current.value
		TriggerServerEvent('esx_gangScript:giveWeapon', weapon,  1000)
      end,
      function(data, menu)
        menu.close()
        CurrentAction     = 'menu_armory'
        CurrentActionMsg  = _U('open_armory')
        CurrentActionData = {station = station}
      end
   )
end

function OpenGetWeaponMenu(societyName)
	ESX.TriggerServerCallback('esx_gangScript:getArmoryWeapons', function(weapons)
		local elements = {}

		for i=1, #weapons, 1 do
			if weapons[i].count > 0 then
				table.insert(elements, {
					label = colors["GREEN"] .. weapons[i].count .. 'x ' .. colors["END"] .. ESX.GetWeaponLabel(weapons[i].name),
					value = weapons[i].name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'get_weapon_menu', {
			title    = _U('get_weapon'),
			align    = 'left',
			elements = elements
		}, function(data, menu)
			menu.close()

			ESX.TriggerServerCallback('esx_gangScript:removeArmoryWeapon', function()
			OpenGetWeaponMenu(societyName)
			end, data.current.value, societyName)
		end, function(data, menu)
			menu.close()
		end)
	end, societyName)
end

function OpenPutWeaponMenu(societyName)
	local elements   = {}
	local playerPed  = PlayerPedId()
	local weaponList = ESX.GetWeaponList()

	for i=1, #weaponList, 1 do
		local weaponHash = GetHashKey(weaponList[i].name)

		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
			table.insert(elements, {
				label = weaponList[i].label,
				value = weaponList[i].name
			})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'put_weapon_menu', {
		title    = _U('put_weapon'),
		align    = 'left',
		elements = elements
	}, function(data, menu)
		menu.close()

		ESX.TriggerServerCallback('esx_gangScript:addArmoryWeapon', function()
		OpenPutWeaponMenu(societyName)
		end, societyName, data.current.value, true)
	end, function(data, menu)
		menu.close()
	end)
end

function OpenGetStocksMenu(societyName)
  ESX.TriggerServerCallback('esx_gangScript:getStockItems', function(items)
    local elements = {}
    for i=1, #items, 1 do
		if items[i].count > 0 then 
			table.insert(elements, {label = colors['GREEN'] .. 'x' .. items[i].count .. colors['END'] .. ' ' .. items[i].label, value = items[i].name})
		end
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('stock'),
		align    = 'left',		
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
          {
            title = _U('quantity')
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil or count < 0 then
              ESX.ShowNotification(_U('quantity_invalid'))
            else
              menu2.close()
              menu.close()
              TriggerServerEvent('esx_gangScript:getStockItem', itemName, count, societyName)
              OpenGetStocksMenu(societyName)			  
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )
  end, societyName)
end

function OpenPutStocksMenu(societyName)

  ESX.TriggerServerCallback('esx_gangScript:getPlayerInventory', function(inventory)

    local elements = {}

    for i=1, #inventory.items, 1 do

      local item = inventory.items[i]

      if item.count > 0 then
        table.insert(elements, {label = colors['GREEN'] .. 'x' .. item.count .. colors['END'] .. ' ' .. item.label, type = 'item_standard', value = item.name})
      end

    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('inventory'),
		align = 'left',
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
          {
            title = _U('quantity')
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil or count < 0 then
				ESX.ShowNotification(_U('quantity_invalid'))
            else
				menu2.close()
				menu.close()
				TriggerServerEvent('esx_gangScript:putStockItems', itemName, count, societyName)
				OpenPutStocksMenu(societyName)
            end
          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )
  end)
end

AddEventHandler('esx_gangScript:hasEnteredMarker', function(station, part, partNum)
  if part == 'Armory' then
    CurrentAction     = 'menu_armory'
    CurrentActionMsg  = _U('open_armory')
    CurrentActionData = {station = station}
  end

  if part == 'VehicleSpawner' then
    CurrentAction     = 'menu_vehicle_spawner'
    CurrentActionMsg  = _U('vehicle_spawner')
    CurrentActionData = {station = station, partNum = partNum}
  end


  if part == 'VehicleDeleter' then
    local playerPed = GetPlayerPed(-1)
    local coords    = GetEntityCoords(playerPed)
    if IsPedInAnyVehicle(playerPed,  false) then
      local vehicle = GetVehiclePedIsIn(playerPed, false)
      if DoesEntityExist(vehicle) then
        CurrentAction     = 'delete_vehicle'
        CurrentActionMsg  = _U('store_vehicle')
        CurrentActionData = {vehicle = vehicle}
      end
    end
  end

  if part == 'BossActions' then
    CurrentAction     = 'menu_boss_actions'
    CurrentActionMsg  = _U('open_bossmenu')
    CurrentActionData = {}
  end

end)

AddEventHandler('esx_gangScript:hasExitedMarker', function(station, part, partNum)
  ESX.UI.Menu.CloseAll()
  CurrentAction = nil
end)

RegisterNetEvent("esx_gangScript:hideVehicle")
AddEventHandler('esx_gangScript:hideVehicle', function(vehicle)
	ESX.Game.DeleteVehicle(vehicle)
end)
