class 'Messages'

function Messages:__init()
	Network:Subscribe( "ClientError", self, self.ClientError )

	self.err_prefix = "[Смэрть] "

	Events:Subscribe( "ModuleError", self, self.ModuleError )
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
end

function Messages:ClientError( args )
	Events:Fire( "ToDiscordConsole", { text = "**[Error] Client error has occurred! Module: " .. args.moduletxt .. "**" .. "\nERROR CODE:\n```" .. args.errortxt .. "```" } )
end

function Messages:ModuleError( e )
	local tagColor = Color.White
	local errColor = Color.Red

	Chat:Broadcast( self.err_prefix, tagColor, "Произошла критическая ошибка сервера, сообщите администрации!", errColor )
	Chat:Broadcast( self.err_prefix, tagColor, "Discord: [empty_link]", errColor )
	Chat:Broadcast( self.err_prefix, tagColor, "Steam: [empty_link]", errColor )
	Chat:Broadcast( self.err_prefix, tagColor, "VK: [empty_link]", errColor )

	Events:Fire( "ToDiscord", { text = "**[Error] Critical server error has occurred! Module: " .. e.module .. "**" })
	Events:Fire( "ToDiscordConsole", { text = "**[Error] Critical server error has occurred! Module: " .. e.module .. "**" .. "\nERROR CODE:\n```" .. e.error .. "```" } )

	Network:Broadcast( "textTw", { error = e.module } )
end

function Messages:ModulesLoad()
	Events:Fire( "ToDiscordConsole", { text = "[Status] Module(s) loaded." } )
end

messages = Messages()
