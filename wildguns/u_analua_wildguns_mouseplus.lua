--[[Wild Guns Mouse Control Script]]--
--by mntorankusu
--only supports single player, the second player must use a standard controller for now

--Feburary 2022 update:
--Hello everyone I'm very sorry I never released this until now. Have a good time.
--This version supports analog control, which only works with a proprietary UDP server app that I haven't released yet.
--In fact, I think I'm talking to myself now, because why would I release this without the UDP server.

 --SETTINGS
EnableMouseAiming = true --if true, enable mouse controls. If you only want to use this script for the other features, set to false.
EnforceHardMode = true --If true, always play on hard mode. I don't actually know if this works.
MouseLag = 0 --make the mouse pointer lag by this number of frames. to increase the difficulty I guess?
SkipNatsumeLogo = true --if true, skip the natsume logo and go straight to the title screen.
EasyLasso = true --if true, hold the middle mouse button to ready the lasso
EasySkipToStageSelect = true --if true, hold L and press Start on the character select screen to skip the intro stage
--normally, you hold select and press AAAABBBBABABABAB to accomplish this
EasySkipToFinalBoss = true --if true, press L on the level select screen to skip to the final boss
--I also discovered that the same cheat code allows you to skip to the final boss from the level select. this seems to be new information?

 -- ANALOG SETTINGS
LeftAnalogControl = true --experimental? analog stick control. this game doesn't work especially well with it, but it's a neat thing to try.
RightAnalogControl = true --aiming with right analog. will automatically disable mouse aiming if a packet is received with controller data. if false, you can use the left side of your controller and the mouse at the same time.
CanMoveWhileJumping = true --if true, allows you to adjust your jump in the air
CanMoveWhileDoubleJumping = true --if true, allows you to adjust your jump in the air after double jumping
OriginalDoubleJumpPhysics = true --if true, allows you to change your direction midair instantly when doublejumping. if false, you will keep any existing momentum when double jumping
AnnieMaxWalkingSpeed = 2 --2 is the default walking speed.  values are dithered so fractions are fine
ClintMaxWalkingSpeed = 1 --clint's walking speed is actually 1.5(?). the game uses integers only, though, so it's 1 and 1+1 with some dithering happening somewhere(?)
AccelerationRate = 0.125 --this is the rate of speed that your character will increase their walking speed when using analog controls
DecelerationRate = 0.25 --this is the rate of speed that your character will decrease their walking speed when using analog controls
JumpAccelerationRate = 0.05 --speed at which you can change your jump trajectory, if CanMoveWhileJumping is true.
deadzone = 50 --deadzone of the analog stick, range 0 to 128
udptimeout = 100 --in frames, how long to wait without input before abandoning analog input
--[[end of settings]]


xscreenoffset = 0
currentscreen = 0
xcursoroffset = -2
ycursoroffset = -2

screens = {
--most of these aren't used in the script, but I've documented them for reference
natsume = 0,
title = 2,
beatfinalboss = 8,
ending = 10,
option = 12,
characterselect = 16,
stageselect = 18,
continue = 20,
colortest = 22,
ingame = 26 ,
gameresults = 28,
versusmode_2p = 34,
versusmode_com = 42,
versusmoderesults = 44,
copyright = 46
}

xmouselag = {}
ymouselag = {}

for i = 1,MouseLag do
	xmouselag[i] = 0
	ymouselag[i] = 0
end

controls = {
AnalogLeftX = 0, 
AnalogLeftY = 0, 
AnalogRightX = 0, 
AnalogRightY = 0,
MouseX = 0,
MouseY = 0, 
LT = 0, 
RT = 0, 
A = false, 
B = false, 
X = false, 
Y = false, 
up = false, 
down = false,
left = false, 
right = false, 
L = false, 
R = false, 
sl = false, 
st = false,
moveintent = 0,
movespeed = 0,
movespeed_buffer = 0,
movespeed_output = 0,
state = 0,
addresses = {},
values = {
	character = 0,
	canmove = false,
	isjumping = false,
	primary = "leftclick",
	secondary = "rightclick",
	tertiary = "space",
	lasso = "middleclick"
	},
}

players = {
controls,
controls
}

--player specific addresses should be added like this
players[1].addresses.cursorx = 0x7E1609
players[1].addresses.cursory = 0x7E1709
players[1].addresses.character = 0x7E04B6
players[1].addresses.state = 0x7E1100

--player specific values


--global addresses
address_currentscreen = 0x7E0000
address_xscreenoffset = 0x7E0020

clamp = .125

switch = true

messagelength = 200
messagetimer = 0
announceevery = 60
announcetimer = 0



string_receivedmessage = "Analog mode enabled."
string_timedout = nil
string_announce = "wildgunu"

gui.opacity(0.7)
print("Mouse Control for Wild Guns by mntorankusu - AnaLua project")
print("Use the arrow keys to adjust the X and Y offset until the crosshair position matches your mouse. This is likely to change if you resize the emulator window.")

if (LeftAnalogControl) then
	local socket = require "socket"
	udp = socket.udp()
	udp:settimeout(0)
	udp:setpeername("localhost", 3478)
	udpcontrol_timer = 0
	sendstring = "wildgunu"
	udp:send(sendstring)
end

function writemessage(themessage)
	if (themessage) then
		messagetimer = 0
		osdmessage = themessage
	end
end

function mousecontrol()
	--only works for player 1 until I get remote dinput mice working.
	output = {}
	keyinput = {}
	
	xscreenoffset = memory.readbyte(address_xscreenoffset)
	currentscreen = memory.readbyte(address_currentscreen)
	players[1].character = memory.readbyte(players[1].addresses.character)

	keyinput = input.get()
	
	if (osdmessage) then
		gui.text(2,219, osdmessage)
		messagetimer = messagetimer + 1
		if (messagetimer > messagelength) then
			osdmessage = nil
		end
	end
	
	if (MouseLag == 0) then
		players[1].MouseX = keyinput.xmouse+xscreenoffset-xcursoroffset
		players[1].MouseY = keyinput.ymouse-ycursoroffset
	else
		for i = 1,MouseLag-1 do
			xmouselag[i] = xmouselag[i+1]
			ymouselag[i] = ymouselag[i+1]
		end
		xmouselag[MouseLag] = keyinput.xmouse+xscreenoffset-xcursoroffset
		ymouselag[MouseLag] = keyinput.ymouse-ycursoroffset
		players[1].MouseX = xmouselag[1]
		players[1].MouseY = ymouselag[1]
	end
	
	gui.line(players[1].MouseX-xscreenoffset-5, players[1].MouseY-2, players[1].MouseX-xscreenoffset+1, players[1].MouseY-2, 999999)
	gui.line(players[1].MouseX-xscreenoffset-2, players[1].MouseY-5, players[1].MouseX-xscreenoffset-2, players[1].MouseY+1, 999999)
	
	if (currentscreen == screens.ingame) then
		
		if input.get()[players[1].values.primary] then
			output.Y = true
		end

		if input.get()[players[1].values.secondary] then
			output.B = true
		end
	
		if input.get()[players[1].lasso] and EasyLasso then
			output.Y = switch
			switch = not switch
		end

	end
	
	
	if (currentscreen == screens.stageselect) then
		if (players[1].MouseX >= 92 and  players[1].MouseX <= 163) then
			if (players[1].MouseY >= 19 and players[1].MouseY <= 82) then
				output.up = true
			elseif (players[1].MouseY >= 147 and players[1].MouseY <= 210) then
				output.down = true
			end
		elseif (players[1].MouseY <= 147 and players[1].MouseY >= 82) then
			if (players[1].MouseX <= 82 and players[1].MouseX >= 12) then
				output.left = true
			elseif (players[1].MouseX <= 243 and players[1].MouseX >= 172) then
				output.right = true
			end
		end
		
		if joypad.get(1).L and joypad.get(1).Select and EasySkipToFinalBoss then
			memory.writebyte(0x7E05F0, -1)
			memory.writebyte(0x7E05F1, -1)
		end
		
		if input.get()[players[1].values.primary] then
			output.start = true
		end
		
	elseif (currentscreen == screens.characterselect) then
		gui.text(0,16,players[1].character)
		if (players[1].MouseX > 128 and players[1].character == 0) then
			output.right = true
		elseif (players[1].MouseX < 128 and players[1].character == 1) then
			output.left = true
		end
		
		if input.get()[players[1].values.primary] then
			output.start = true
		end
		
		if (joypad.get(1).L or input.get()[players[1].values.secondary]) and EasySkipToStageSelect then
			memory.writebyte(0x7E05F0, -1)
			memory.writebyte(0x7E05F1, -1)
		end
		
	elseif (currentscreen == screens.title) then
		if input.get()[players[1].values.primary] then
			output.start = true
		end
	end
	
	if input.get().left then
		xcursoroffset = xcursoroffset+0.25
		writemessage(string.format("X offset: %i", xcursoroffset))
	elseif input.get().right then
		xcursoroffset = xcursoroffset-0.25
		writemessage(string.format("X offset: %i", xcursoroffset))
	elseif input.get().up then
		ycursoroffset = ycursoroffset+0.25
		writemessage(string.format("Y offset %i", ycursoroffset))
	elseif input.get().down then
		ycursoroffset = ycursoroffset-0.25
		writemessage(string.format("Y offset %i", ycursoroffset))
	end 
		
	if (LeftAnalogControl) then
		udpsendreceive()
		analogcontrol()
	end
	
	joypad.set(1, output)
	
end

function udpsendreceive()
timedout = false
	repeat 
		data = nil
		data = udp:receive()
		if data then
			print(data)
			if string.byte(data,1) == 141 then
				udpcontrol_timer = 0
				players[1].AnalogLeftX = string.byte(data,2)-127
				players[1].AnalogLeftY = string.byte(data,3)-127
				players[1].AnalogRightX = string.byte(data,4)-127
				players[1].AnalogRightY = string.byte(data,5)-127
				players[1].LT = string.byte(data,6)-127
				players[1].RT = string.byte(data,7)-127
				if (timedout) then
					timedout = false
					udpcontrol_timer = 0
					writemessage(string_receivedmessage)
				end
			else
				udpcontrol_timer = udpcontrol_timer + 1
			end
		else
				udpcontrol_timer = udpcontrol_timer + 1
		end
	until data == nil 
	
	if (udpcontrol_timer >= udptimeout) then
		timedout = true
		if (udpcontrol_timer == udptimeout) then
			writemessage(string_timedout)
		end
		udpcontrol_timer = udptimeout+1
	end
	udp:send(string_announce)
end

function analogcontrol()
	
	if players[1].values.state ~= 8 and memory.readbyte(players[1].addresses.state) == 8 and OriginalDoubleJumpPhysics then
		players[1].movespeed = players[1].moveintent
	end
	
	players[1].values.state = memory.readbyte(players[1].addresses.state)
	
	players[1].canmove = false
	players[1].isjumping = false
	
	if players[1].values.state == 2 then 
		players[1].canmove = true 
	end
	
	if players[1].values.state == 6 then
		players[1].isjumping = true
		if CanMoveWhileJumping then
			players[1].players[1].canmove = true
		end
	end

	if players[1].values.state == 8 then
		players[1].isjumping = true
		if CanMoveWhileDoubleJumping then
			players[1].players[1].canmove = true
		end
	end
	
	if (players[1].character == 0) then
		maxspeed_l = ClintMaxWalkingSpeed+1
		maxspeed_r = ClintMaxWalkingSpeed
	else
		maxspeed_l = AnnieMaxWalkingSpeed
		maxspeed_r = AnnieMaxWalkingSpeed
	end
	
	AccelMultiplier = maxspeed_l / maxspeed_r
	
	if players[1].AnalogLeftX > deadzone then
		players[1].moveintent = (players[1].AnalogLeftX * maxspeed_r) / 127
	elseif players[1].AnalogLeftX < -deadzone then
		players[1].moveintent = (players[1].AnalogLeftX * maxspeed_l) / 127
	elseif joypad.get(1).left == true then
		players[1].moveintent = -maxspeed_l
	elseif joypad.get(1).right == true then
		players[1].moveintent = maxspeed_r
	else
		players[1].moveintent = 0
	end
	
	if (players[1].movespeed < players[1].moveintent) then 
		if (players[1].isjumping) then players[1].movespeed = players[1].movespeed + (JumpAccelerationRate) 
		elseif (players[1].movespeed < 0) then players[1].movespeed = players[1].movespeed + (DecelerationRate*AccelMultiplier)
		else players[1].movespeed = players[1].movespeed + (AccelerationRate) end
	end
	
	if (players[1].movespeed > players[1].moveintent) then 
		if (players[1].isjumping) then players[1].movespeed = players[1].movespeed - (JumpAccelerationRate*AccelMultiplier)
		elseif (players[1].movespeed > 0) then players[1].movespeed = players[1].movespeed - (DecelerationRate)
		else players[1].movespeed = players[1].movespeed - (AccelerationRate*AccelMultiplier) end
	end
	
	if (not players[1].canmove) then players[1].movespeed = 0 end
	
	if (players[1].movespeed > 0) then output.right = true end
	if (players[1].movespeed < 0) then output.left = true end
	
	if (players[1].moveintent > 0 and not players[1].canmove) then output.right = true end
	if (players[1].moveintent < 0 and not players[1].canmove) then output.left= true end
	
	if (players[1].moveintent == 0 and players[1].movespeed > 0 and players[1].movespeed <= clamp) then players[1].movespeed = 0
	elseif (players[1].moveintent == 0 and players[1].movespeed < 0 and players[1].movespeed >= -clamp*AccelMultiplier) then players[1].movespeed = 0 end
	
	players[1].movespeed_buffer = players[1].movespeed_buffer + players[1].movespeed
	
	players[1].movespeed_output = 0
	
	 while players[1].movespeed_buffer > 1 do
		 players[1].movespeed_output = players[1].movespeed_output  + 1
		 players[1].movespeed_buffer = players[1].movespeed_buffer - 1
	 end
	
	 while players[1].movespeed_buffer < -1 do
		 players[1].movespeed_output = players[1].movespeed_output  - 1
		 players[1].movespeed_buffer = players[1].movespeed_buffer + 1
	 end
	 
	 moveit()
end

function effect_gunshoot(player)
    if (memory.readbyte(0x7E1400) == 5) then
		--print("SHOOT")
		if (players[1].currentgun == 6) then
			udp:send("r2")
		else
			udp:send("r1")
		end
	end
end

function current_gun()
	players[1].currentgun = memory.readbyte(0x7E1FA8)
end

function hardmode()
	memory.writebyte(0x7EFF34, 2)
end

function current_gun()
	players[1].currentgun = memory.readbyte(0x7E1FA8)
end

function xcursor_set()
	if (screens.ingame) then memory.writeword(players[1].addresses.cursorx, players[1].MouseX) end
end

function ycursor_set()
	if (screens.ingame) then memory.writebyte(players[1].addresses.cursory, players[1].MouseY) end
end

function gamecurrentscreen()
	currentscreen = memory.readbyte(0x7E0000)
	if (SkipNatsumeLogo and currentscreen == screens.natsume) then
		memory.writebyte(0x7E0000, 2)
		currentscreen = 2
	end
end

emu.registerbefore(mousecontrol)

if (EnforceHardMode) then
	memory.register(0x7EFF34, hardmode)
end

function moveit()
	if players[1].canmove and (currentscreen == screens.ingame or currentscreen == screens.versusmode_2p or currentscreen == screens.versusmode_com) then
		memory.writebyte(0x7E1C01, players[1].movespeed_output)
	end
end

memory.registerwrite(0x7E0000, gamecurrentscreen)

if (LeftAnalogControl) then
	memory.register(0x7E1FA8, current_gun)
	memory.register(0x7E1400, effect_gunshoot)
	memory.register(0x7E1C01, moveit)
end

memory.registerwrite(players[1].addresses.cursorx, 2, xcursor_set)
memory.registerwrite(players[1].addresses.cursory, 1, ycursor_set)
memory.registerread(players[1].addresses.cursorx, 2, xcursor_set)
memory.registerread(players[1].addresses.cursory, 1, ycursor_set)

writemessage("Wild Guns Mouse Control Script - AnaLua project")
