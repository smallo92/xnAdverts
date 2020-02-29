RegisterServerEvent("xnAdverts:SendAdToAll")
AddEventHandler('xnAdverts:SendAdToAll', function(ImageName, ImageName2, AdTitle, AdSubtitle, Message, AdType)
	local mySource = source
	if mySource ~= nil then
		TriggerClientEvent('xnAdverts:DisplayAd', -1, ImageName, ImageName2, AdTitle, AdSubtitle, Message)
	end
end)