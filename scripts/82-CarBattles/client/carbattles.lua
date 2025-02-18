class 'CarBattles'

function CarBattles:__init()
	self.check = true

	self.pts = 0
	self.scores = {}

	local lang = LocalPlayer:GetValue( "Lang" )
	if lang and lang == "EN" then
		self:Lang()
	else
		self.name = "Загрузка..."
		self.nameTw = "Загрузка идет слишком долго? Перезайдите на сервер."
		self.nameTh = "Нажмите R, чтобы встать на колеса"
		self.healtxt = "++ Восстановление ++"
		self.yourscorestxt = "Ваши очки: "
		self.leaderboardtxt = "[Лидеры]"
	end

	self.cooldown = 20
	self.cooltime = 0

	--Network:Subscribe( "GetTime", self, self.GetTime )
	Network:Subscribe( "RespawnTimer", self, self.RespawnTimer )
	Network:Subscribe( "MapFinished", self, self.MapFinished )
	Network:Subscribe( "Enter", self, self.Enter )
	Network:Subscribe( "Exit", self, self.Exit )
	Network:Subscribe( "Sound", self, self.Sound )
	Network:Subscribe( "HealSound", self, self.HealSound )
	Network:Subscribe( "CarBattlesUpdatePoints", self, self.UpdatePoints )
	Network:Subscribe( "CarBattlesUpdateScores", self, self.UpdateScores )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "GoCB", self, self.GoCB )
end

function CarBattles:GetTime( args )
	self.Time = args.MapTime
end

function CarBattles:RespawnTimer()
	if not self.PostTickEvent then
		self.timer = Timer()
		self.PostTickEvent = Events:Subscribe( "PostTick", self, self.PostTick )
		LocalPlayer:SetOutlineColor( Color( 0, 255, 0 ) )
		LocalPlayer:SetOutlineEnabled( true )
	end
end

function CarBattles:PostTick()
	if self.timer:GetSeconds() >= 15 then
		Network:Send( "EnableCollision" )
		if self.PostTickEvent then
			Events:Unsubscribe( self.PostTickEvent ) self.PostTickEvent = nil
			LocalPlayer:SetOutlineEnabled( false )
		end
		self.timer = nil
	end
end

function CarBattles:Lang()
	self.name = "Loading..."
	self.nameTw = "Loading very long? Reconnect to the server."
	self.nameTh = "Press R to stand on wheels"
	self.healtxt = "++ Healing ++"
	self.yourscorestxt = "Your points: "
	self.leaderboardtxt = "[Leaders]"
end

function CarBattles:GoCB()
	Network:Send( "GoCB" )
end

function CarBattles:MapFinished()
	Mouse:SetVisible( true )
	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.2, 0.2 ) )
	self.window:SetMinimumSize( Vector2( 500, 200 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( true )
	self.window:SetTitle( "Игра окончена!" )
	self.window:Subscribe( "WindowClosed", self, self.Exit )

	self.errorText = Label.Create( self.window )
	self.errorText:SetPosition( Vector2( 20, 30 ) )
	self.errorText:SetSize( Vector2( 450, 100 ) )
	self.errorText:SetText( "Победитель:" )
	self.errorText:SetTextSize( 20 )

	self.leaveButton = Button.Create( self.window )
	self.leaveButton:SetSize( Vector2( 100, 40 ) )
	self.leaveButton:SetDock( GwenPosition.Bottom )
	self.leaveButton:SetText( "Продолжить" )
	self.leaveButton:Subscribe( "Press", self, self.Exit )
end

function CarBattles:Sound()
	local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 17,
			sound_id = 13,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
	})

	sound:SetParameter(0,0)
	sound:SetParameter(1,0)
	sound:SetParameter(2,1)
	sound:SetParameter(3,0)
end

function CarBattles:HealSound()
	local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 19,
			sound_id = 30,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
	})

	sound:SetParameter(0,1)
	Events:Fire( "CastCenterText", { text = self.healtxt, time = 4, color = Color.GreenYellow } )
end

function CarBattles:Enter()
	if not self.LocalPlayerInputEvent then self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput ) end
	if not self.LocalPlayerExitVehicleEvent then self.LocalPlayerExitVehicleEvent = Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle ) end
	if not self.LocalPlayerEjectVehicleEvent then self.LocalPlayerExitVehicleEvent = Events:Subscribe( "LocalPlayerEjectVehicle", self, self.LocalPlayerEjectVehicle ) end
	if not self.RenderEvent then self.RenderEvent = Events:Subscribe( "Render", self, self.Render ) end
	if not self.GameRenderEvent then self.GameRenderEvent = Events:Subscribe( "GameRender", self, self.GameRender ) end
	if not self.LocalPlayerDeathEvent then self.LocalPlayerDeathEvent = Events:Subscribe( "LocalPlayerDeath", self, self.LocalPlayerDeath ) end
	if not self.GameLoadEvent then self.GameLoadEvent = Events:Subscribe( "GameLoad", self, self.GameLoad ) end
	if not self.KeyUpEvent then self.KeyUpEvent = Events:Subscribe( "KeyUp", self, self.KeyUp ) end
	if not self.RespawnEvent then self.RespawnEvent = Events:Subscribe( "LocalPlayerInput", self, self.Respawn ) end

	self.antifly = true
end

function CarBattles:Exit()
	if self.LocalPlayerInputEvent then Events:Unsubscribe( self.LocalPlayerInputEvent ) self.LocalPlayerInputEvent = nil end
	if self.LocalPlayerExitVehicleEvent then Events:Unsubscribe( self.LocalPlayerExitVehicleEvent ) self.LocalPlayerExitVehicleEvent = nil end
	if self.LocalPlayerEjectVehicleEvent then Events:Unsubscribe( self.LocalPlayerEjectVehicleEvent ) self.LocalPlayerEjectVehicleEvent = nil end
	if self.RenderEvent then Events:Unsubscribe( self.RenderEvent ) self.RenderEvent = nil end
	if self.GameRenderEvent then Events:Unsubscribe( self.GameRenderEvent ) self.GameRenderEvent = nil end
	if self.LocalPlayerDeathEvent then Events:Unsubscribe( self.LocalPlayerDeathEvent ) self.LocalPlayerDeathEvent = nil end
	if self.GameLoadEvent then Events:Unsubscribe( self.GameLoadEvent ) self.GameLoadEvent = nil end
	if self.KeyUpEvent then Events:Unsubscribe( self.KeyUpEvent ) self.KeyUpEvent = nil end
	if self.RespawnEvent then Events:Unsubscribe( self.RespawnEvent ) self.RespawnEvent = nil end

	if LocalPlayer:GetOutlineEnabled() == true then
		Network:Send( "EnableCollision" )
		LocalPlayer:SetOutlineEnabled( false )
	end

	Game:FireEvent( "ply.unpause" )
end

function CarBattles:LocalPlayerInput( args )
	if args.input == Action.StuntJump or args.input == Action.ParachuteOpenClose or args.input == Action.UseItem or args.input == Action.ExitVehicle then return false end

	local vehicle = LocalPlayer:GetVehicle()

	if vehicle then
		if vehicle:GetHealth() >= 0.3 then
			if args.input == Action.FireLeft or args.input == Action.VehicleFireRight or args.input == Action.VehicleFireLeft or args.input == Action.FireVehicleWeapon then return true end
		else
			if args.input == Action.FireLeft or args.input == Action.VehicleFireRight or args.input == Action.VehicleFireLeft or args.input == Action.FireVehicleWeapon then return false end
		end
	end
end

function CarBattles:UpdatePoints( pts )
	self.pts = pts
end

function CarBattles:UpdateScores( scores )
	self.scores = scores
end

function CarBattles:RightText( msg, y, color )
	local w = Render:GetTextWidth( msg )
	Render:DrawShadowedText( Vector2( Render.Width - w - 5, y ), msg, color, Color.Black )
end

function CarBattles:Render()
	local vehicle = LocalPlayer:GetVehicle()

	if self.check then
		if not LocalPlayer:InVehicle() then
			self.warning = true
			Game:FireEvent( "ply.pause" )
		else
			if self.antifly then
				if vehicle then
					vehicle:SetLinearVelocity( Vector3.Zero )
				end
				self.antifly = nil
			end
			self.warning = false
			Game:FireEvent( "ply.unpause" )
		end
	end

	if vehicle then
		Network:Send( "Health" )

		if vehicle:GetHealth() <= 0.1 then
			Network:Send( "NoVehicle" )
		end
	end

	if Game:GetState() ~= GUIState.Game then return end

	local color = Color.White

	self:RightText( self.yourscorestxt .. self.pts, Render:GetTextHeight( "A" ) * 3.5, Color( 255, 255, 0 ) )
	self:RightText( self.leaderboardtxt, Render:GetTextHeight( self.yourscorestxt .. self.pts ) * 5, Color( 255, 255, 0 ) )

	for i = 1, math.min(#self.scores, 10), 1 do
		self:RightText( ""..i..". "..self.scores[i].name..": "..self.scores[i].pts, Render:GetTextHeight( self.leaderboardtxt ) * 5 + i * 16, self.scores[i].it and Color( 255, 170, 0 ) or color )
	end

	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

--	local text = "До конца игры: " .. self.Time
--	if self.Time then
--		local pos = Vector2 ((Render.Size.x / 2) - (Render:GetTextSize(text, 18).x / 2), 30 )
--		Render:DrawShadowedText( pos, tostring( text ), Color.White, Color.Black, 18 )
--	end

	if self.warning then
		local text_width = Render:GetTextWidth( self.name, TextSize.VeryLarge )
		local text_height = Render:GetTextHeight( self.name, TextSize.VeryLarge )
		local pos = Vector2( ( Render.Width - text_width )/2, ( Render.Height - text_height - 200 ) / 2 )
		Render:DrawShadowedText( pos, self.name, Color.White, Color( 25, 25, 25, 150 ), TextSize.VeryLarge )

		pos.y = pos.y + 45
		pos.x = ( Render.Width - Render:GetTextWidth( self.nameTw, TextSize.Default ) ) / 2
		Render:DrawShadowedText( pos, self.nameTw, Color.DarkGray, Color( 25, 25, 25, 150 ), TextSize.Default )
	end

	if vehicle then
		local angle = vehicle:GetAngle()

		if vehicle:GetLinearVelocity():Length() < 1 and ( math.abs( angle.pitch ) > 1.5 or math.abs( angle.roll ) > 1.5 ) then
			local text_size = 24
			local text_width = Render:GetTextWidth( self.nameTh, text_size )
			local text_height = Render:GetTextHeight( self.nameTh, text_size )
			local pos = Vector2( Render.Size.x / 2 - text_width / 2, ( Render.Size.y / 2 - text_height / 2 ) - 100 )

			Render:DrawShadowedText( pos, self.nameTh, Color.White, Color( 25, 25, 25, 150 ), text_size )
		end
	end
end

function CarBattles:GameRender()
	Render:FillArea( Vector2.Zero, Render.Size, Color( 20, 25, 0, 100 ) )
end

function CarBattles:LocalPlayerExitVehicle()
	self.check = false

	if not LocalPlayer:IsTeleporting() then
		Network:Send( "NoVehicle" )
	end
end

function CarBattles:LocalPlayerEjectVehicle()
    if LocalPlayer:GetPosition().y > 200.5 then
		return false
	end
end

function CarBattles:LocalPlayerDeath()
	self.check = false
	Game:FireEvent( "ply.invulnerable" )
	self.antiboom = true
end

function CarBattles:KeyUp()
	if self.antiboom then
		Game:FireEvent( "ply.vulnerable" )
		self.antiboom = false
	end
end

function CarBattles:GameLoad()
	self.check = true
end

function CarBattles:Respawn( args )
	if args.input == Action.Reload then
		local time = Client:GetElapsedSeconds()
		if time < self.cooltime then return end
		Network:Send( "Respawn" )
		self.cooltime = time + self.cooldown
		return false
	end
end

carbattles = CarBattles()