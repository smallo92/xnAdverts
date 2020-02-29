local hasSentAdvert = false
local AdCooldown = Config.AdCooldownMinutes * 60

local outstring = ""
for k, v in pairs(Config.AllAds) do
	outstring = outstring .. k .. ", "
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if hasSentAdvert then
			Citizen.Wait(1000)
			AdCooldown = AdCooldown - 1
			if AdCooldown == 0 then
				hasSentAdvert = false
				AdCooldown = Config.AdCooldownMinutes * 60
			end
		end
	end
end)

RegisterNetEvent("xnAdverts:DisplayAd")
AddEventHandler('xnAdverts:DisplayAd', function(ImageName, ImageName2, AdTitle, AdSubtitle, Message)
	AdvertNotification(AdTitle, AdSubtitle, Message, ImageName, ImageName2)
end)

RegisterNetEvent("xnAdverts:ShowMessage")
AddEventHandler('xnAdverts:ShowMessage', function(Message)
	AdvertChatMessage("Adverts", Message)
end)

Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/ads', "Lists all the available advert types" )
	TriggerEvent('chat:addSuggestion', '/ad', "Send an advert to everyone", {
		{ name="Advert Type", help = "The type of advert you want to send. Available Adverts: " .. outstring },
		{ name="Advert Message", help = "The message to include with your advert" }
	})
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('chat:removeSuggestion', '/ads')
		TriggerEvent('chat:removeSuggestion', '/ad')
	end
end)

function ReqTextures(texture)
	RequestStreamedTextureDict(texture)
	while not HasStreamedTextureDictLoaded(texture) do
		Citizen.Wait(0)
	end
end

function AdvertNotification(title, subject, msg, icon, icon2)
	AddTextEntry("FullMessage", msg)
	ReqTextures(icon)
	SetNotificationTextEntry("FullMessage")
	SetNotificationMessage(icon, icon2, false, 1, title, subject)
	DrawNotification(false, true)
	SetStreamedTextureDictAsNoLongerNeeded(icon)
end

function AdvertChatMessage(heading, message)
	TriggerEvent('chat:addMessage', {
		color = { 255, 153, 51},
		template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(41, 41, 41, 0.6);">{0} {1}</div>',
		args = {"^2" .. heading .. ":", ' ^7' .. message}
	})
end

RegisterCommand('ads', function()
	AdvertChatMessage("Available Adverts", outstring)
end)

RegisterCommand('ad', function(source, args)
	if source == 0 then
		if not hasSentAdvert then
			if args[1] ~= nil then
				local selectedAd = args[1]
				if Config.AllAds[selectedAd] then
					if args[2] ~= nil then
						local message = ""
						local optionalSubtitle = message and Config.AllAds[selectedAd][4] or ""
						for k, v in ipairs(args) do
							if k ~= 1 then
								message = message .. v .. " "
							end
						end
						TriggerServerEvent('xnAdverts:SendAdToAll', Config.AllAds[selectedAd][1], Config.AllAds[selectedAd][2], Config.AllAds[selectedAd][3], optionalSubtitle, message, selectedAd)
						hasSentAdvert = true
					else
						AdvertChatMessage("xnAdverts", "You didn't include a message.")
					end
				else
					AdvertChatMessage("xnAdverts", "That is not a valid ad type. Use /ads to check what types there are.")
				end
			else
				AdvertChatMessage("xnAdverts", "You didn't specify an ad type. Use /ads to check what types there are.")
			end
		else
			AdvertChatMessage("xnAdverts", "You have already sent an advert recently. Please wait before sending another.")
		end
	end
end)