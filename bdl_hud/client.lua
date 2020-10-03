-- [ E&G VENDAS - https://discord.gg/bABGBEX ] --
-- [ SCRIPT GRATUITO! NÃO RE-VENDER ] --
-- [ FEITO POR: Edu#0188 PARA DIVULGAÇÃO DA BASE DO BDL v3 ] --
-- [ GITHUB DO PROJETO: https://github.com/badlandproject ] --
-- [ LINK DE DOWNLOAD AUTORIZADO DESSE SCRIPT: https://github.com/badlandproject/bdl_hud ] --

-- [ TUNELAGEM ] --
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
cRP = {}
Tunnel.bindInterface("bdl_hud",cRP)
vSERVER = Tunnel.getInterface("vrp_garages")

-- [ VARIÁVEIS ] --
local hour = 0
local voice = 2
local minute = 0
local month = ""
local hunger = 100
local thirst = 100
local dayMonth = 0
local varDay = "th"
local showHud = true
local showMovie = false
local showRadar = false
local sBuffer = {}
local seatbelt = false
local ExNoCarro = false
local timedown = 0
local talking = false


-- [ ESCONDER HUD AO PEGAR CELULAR ] --
local menu_celular = false
RegisterNetEvent("status:celular")
AddEventHandler("status:celular",function(status)
	menu_celular = status
end)


-- [ CALCULO ALEATÓRIO DE TEMPO ] --
function calculateTimeDisplay()
	hour = GetClockHours()
	month = GetClockMonth()
	minute = GetClockMinutes()
	dayMonth = GetClockDayOfMonth()

	if hour <= 9 then
		hour = "0"..hour
	end

	if minute <= 9 then
		minute = "0"..minute
	end

	if month == 0 then
		month = "January"
	elseif month == 1 then
		month = "February"
	elseif month == 2 then
		month = "March"
	elseif month == 3 then
		month = "April"
	elseif month == 4 then
		month = "May"
	elseif month == 5 then
		month = "June"
	elseif month == 6 then
		month = "July"
	elseif month == 7 then
		month = "August"
	elseif month == 8 then
		month = "September"
	elseif month == 9 then
		month = "October"
	elseif month == 10 then
		month = "November"
	elseif month == 11 then
		month = "December"
	end
end

-- [ CONFIGS DE TOKOVOIP QUE EU NÃO SEI ] --
RegisterNetEvent("vrp_hud:Tokovoip")
AddEventHandler("vrp_hud:Tokovoip",function(status)
	voice = status
end)

RegisterNetEvent("vrp_hud:TokovoipTalking")
AddEventHandler("vrp_hud:TokovoipTalking",function(status)
	talking = status
end)

-- [ EEVENTO PRA ESCONDER A HUD (DAR TRIGGER NAS PARADA Q TU QUEIRA Q A HUD SUMA) ] --
RegisterNetEvent("hudActived")
AddEventHandler("hudActived",function()
	showHud = true
end)

-- [ THREAD PRINCIPAL DA HUD (NÂO COLOCAR SLEEP PQ FICA UMA MERDA) ] --
Citizen.CreateThread(function()
	while true do
		if IsPauseMenuActive() or IsScreenFadedOut() or menu_celular then
			SendNUIMessage({ hud = false, movie = false })
		else
			local ped = PlayerPedId()
			local armour = GetPedArmour(ped)
			local health = (GetEntityHealth(GetPlayerPed(-1))-100)/300*100
			local stamina = GetPlayerSprintStaminaRemaining(PlayerId())

			local x,y,z = table.unpack(GetEntityCoords(ped))
			local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))

			calculateTimeDisplay()

			if dayOfMonth == 1 then
				varDay = "st"
			elseif dayOfMonth == 2 then
				varDay = "nd"
			elseif dayOfMonth == 3 then
				varDay = "rd"
			else
				varDay = "th"
			end

			local ped = PlayerPedId()
			local car = GetVehiclePedIsIn(ped)

			if not showHud then 
				showRadar = false 
			end

			if IsPedOnAnyBike(ped) then
				showRadar = true
			end
			
			if not IsPedInAnyVehicle(ped) then 
				showRadar = false
				DisplayRadar(showRadar)
			end

			if IsPedInAnyVehicle(ped) then
				showRadar = true
				local vehicle = GetVehiclePedIsIn(ped)

				local fuel = GetVehicleFuelLevel(vehicle)
				local speed = GetEntitySpeed(vehicle) * 3.6

				SendNUIMessage({ hud = showHud, movie = showMovie, car = true, day = dayMonth..varDay, month = month, hour = hour, minute = minute, street = street, radio = radioDisplay, voice = voice, talking = talking, health = parseInt(health), armour = parseInt(armour), thirst = parseInt(thirst), hunger = parseInt(hunger), stamina = parseInt(stamina), fuel = parseInt(fuel), speed = parseInt(speed), seatbelt = seatbelt })
			else
				SendNUIMessage({ hud = showHud, movie = showMovie, car = false, day = dayMonth..varDay, month = month, hour = hour, minute = minute, street = street, radio = radioDisplay, voice = voice, talking = talking, health = parseInt(health), armour = parseInt(armour), thirst = parseInt(thirst), hunger = parseInt(hunger), stamina = parseInt(stamina) })
			end
		end

		Citizen.Wait(200)
	end
end)

-- [ ESCONDER HUD AO DAR /HUD ] --
RegisterCommand("hud",function(source,args)
	showHud = not showHud
	showRadar = not showRadar
--	print(showRadar)
end)

-- [ EFEITINHO DE FILME AO DAR /MOVIE ] --
RegisterCommand("movie",function(source,args)
	showMovie = not showMovie
end)

-- [ FUNÇÕES QUE EU NÃO PRESTEI ATENÇÃO ] --
IsCar = function(veh)
	local vc = GetVehicleClass(veh)
	return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 15 and vc <= 20)
end

Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		local ped = PlayerPedId()
		local car = GetVehiclePedIsIn(ped)

		if car ~= 0 and (ExNoCarro or IsCar(car)) then
			ExNoCarro = true
			if seatbelt then
				DisableControlAction(0,75)
			end

			timeDistance = 4
			sBuffer[2] = sBuffer[1]
			sBuffer[1] = GetEntitySpeed(car)

			if sBuffer[2] ~= nil and not seatbelt and GetEntitySpeedVector(car,true).y > 1.0 and sBuffer[1] > 10.25 and (sBuffer[2] - sBuffer[1]) > (sBuffer[1] * 0.255) then
				SetEntityHealth(ped,GetEntityHealth(ped)-10)
				TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped),4160)
				timedown = 10
			end

			if IsControlJustReleased(1,47) then
				if seatbelt then
					TriggerEvent("vrp_sound:source","unbelt",0.5)
					seatbelt = false
				else
					TriggerEvent("vrp_sound:source","belt",0.5)
					seatbelt = true
				end
			end

			if IsPedOnAnyBike(ped) then
				showRadar = true
			end

			if not seatbelt and not showHud then 
				showRadar = false
			end

		elseif ExNoCarro then
			ExNoCarro = false
			seatbelt = false
			sBuffer[1],sBuffer[2] = 0.0,0.0
		end
		DisplayRadar(showRadar)
		Citizen.Wait(timeDistance)
	end
end)

-- [ TIMEDOWN ] --
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local ped = PlayerPedId()
		if timedown > 0 and GetEntityHealth(ped) > 101 then
			timedown = timedown - 1
			if timedown <= 1 then
				TriggerServerEvent("vrp_inventory:Cancel")
			end
		end
	end
end)

-- [ RAGDOLL (TIRA ESSA MERDA SE VC DA VALOR AO SEU SERVIDOR) ] --
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local ped = PlayerPedId()
		if timedown > 1 and GetEntityHealth(ped) > 101 then
			if not IsEntityPlayingAnim(ped,"anim@heists@ornate_bank@hostages@hit","hit_react_die_loop_ped_a",3) then
				vRP.playAnim(false,{"anim@heists@ornate_bank@hostages@hit","hit_react_die_loop_ped_a"},true)
			end
		end
	end
end)

-- [ BLOCKS DE CONTROLES ] --
Citizen.CreateThread(function()
	while true do
		local TimeDistance = 500
		if timedown > 0 then
			TimeDistance = 4
			DisableControlAction(0,288,true)
			DisableControlAction(0,289,true)
			DisableControlAction(0,170,true)
			DisableControlAction(0,187,true)
			DisableControlAction(0,189,true)
			DisableControlAction(0,190,true)
			DisableControlAction(0,188,true)
			DisableControlAction(0,57,true)
			DisableControlAction(0,105,true)
			DisableControlAction(0,167,true)
			DisableControlAction(0,20,true)
			DisableControlAction(0,29,true)
		end
		Citizen.Wait(TimeDistance)
	end
end)