--[[Mouse/Lightgun script for Yuu Yuu Hakusho Yami Shoubu!! Ankoku Bujutsu-kai
by mntorankusu
Created for use with BizHawk 2.8. If it doesn't work, try that exact version.
BizHawk needs two settings to be changed to be playable with the mouse:
Config -> Display -> Window -> Allow Double-Click Fullscreen OFF
Config -> Customize -> Enable Context Menu OFF]]--


--Change these options if you wanna
hidecrosshair = false 
--looks a little weird, but I haven't found any other way of disabling the crosshair yet. Better than nothing.
autocharge = true 
--if enabled, you don't have to hold the trigger to charge your normal attack. That might make it feel better to play on a lightgun.
actimer = 8 
--how long to wait before autocharging. The autocharge feature just holds the button for you, so it will shoot once when it starts charging. Setting a shorter timer will make that less noticeable.
rapidfire = true
--shoot rapidly while holding the trigger. You can only use this with autocharge because otherwise you won't be able to charge your attack.
rapidfirespeed = 8
--how many frames between firing in rapidfire mode.

function clamp(in_value, in_max, in_min)
	if in_value > in_max then in_value = in_max
	elseif in_value < in_min then in_value = in_min end
	return in_value
end
--all buttons not being used must be set to nil to be able to mix input with the controller you have configured in the emulator, because explicitly setting it to "false" will override any other value. using this function to set buttons makes it easier to do that.
function setbutton(button_in)
	if button_in then return true
	else return nil end
end

debugon = false
switch = true
rfcount = 0
acstart = 0
charsel = 1
function setCharacterSelect()
	mainmemory.writebyte(0x002C,0)
end

while true do
	in_mouse = {}
	output = {}
	switch = not switch

	in_mouse = input.getmouse()
	mx = clamp(in_mouse.X, 255, 0)
	 
	my = clamp(in_mouse.Y, 231, 0)
	inbattle = false
	currentscreen = mainmemory.readbyte(0x0800)
	cursorposx = mainmemory.readbyte(0x09C1)
	cursorposy = mainmemory.readbyte(0x0A21)
	
	scr_characterselect = 5
	scr_vs = 1
	scr_b1 = 2
	scr_cont_title = 0
	scr_win = 9
	scr_chardemo = 0
	scr_balance = 3
	
	pointcursor_addr = {0x062D, 0x0A20}
	
	pointcursor_0 = {0, 56}
	pointcursor_1 = {1, 72}
	pointcursor_2 = {2, 88}
	pointcursor_3 = {3, 104}
	
	
	--[[charselcursor_addr = {0x0011,0x002C, 0x006C,0x06B4, 0x06B5, 0x09C0,0x0A20,	0x0A80,0x0AC0,0x0E00,0x0E02,0x0E08,0x0E0A,0x0E0B,0x0E10,0x0E12,0x0E18,0x0E1A,
	0x0E20,0x0E22,0x0E23,0x0E0B,0x0E23}
	char0cursor_val = {128,0, 0, 0, 132, 48, 112, 80, 200, 128, 40, 128, 104, 0, 192, 40, 192, 72, 192, 104, 0, 0, 0}
	char1cursor_val = {0, 1, 32, 16, 164, 128, 64, 160, 152, 80, 120, 80, 184, 0, 144, 120, 144, 152, 144, 184, 0, 0, 0}
	char2cursor_val = {32, 2, 64, 32, 196, 208, 112, 240, 200, 128, 200, 128, 8, 1, 192, 200, 192, 232, 192, 8, 1, 1, 1}
	char3cursor_val = {64,3, 96, 48, 228, 176, 200, 208, 32, 216, 168, 216, 232, 0, 24, 168, 24, 200, 24, 232, 0, 0, 0}
	char4cursor_val = {96,4, 128, 64, 4, 80, 200, 112, 32, 216, 72, 216, 136, 0, 24, 72, 24, 104, 24, 136, 0, 0, 0}--]]
	
	--if infinitehealth then mainmemory.writebyte(0x1007,127) end
	--if infinitespecial then mainmemory.writebyte(0x1006,5) end
	
	if currentscreen == scr_b1 then
		--set cursor position to match mouse
		--battle screen y begins at 24 and ends at 151, so subtract 24 and clamp
		mainmemory.writebyte(0x09C1, mx)
		mainmemory.writebyte(0x0A21, clamp(my-24, 151,0))
		
		if hidecrosshair then mainmemory.writebyte(0x08a1,127) end

		if rapidfire then
			if in_mouse.Left then
				output["II"] = rfcount == rapidfirespeed
				rfcount = rfcount+1
				if rfcount > rapidfirespeed then rfcount = 0 end
			else
				rfcount = rapidfirespeed;
				output["II"] = setbutton(in_mouse.Left)
			end
		else
			output["II"] = setbutton(in_mouse.Left)
		end
		
		if autocharge then
			if not in_mouse.Left then acstart = acstart+1 else acstart = 0 end
			if acstart > actimer then output["II"] = true end
		end

		output["I"] = setbutton(in_mouse.Right)
		output["Select"] = setbutton(in_mouse.Middle)
		output["Run"] = setbutton(in_mouse.X1)
		
		if debugon then gui.text(16, 64, "Battle") end
		
	elseif currentscreen == scr_balance then
		output["I"] = in_mouse.Left
		output["II"] = in_mouse.Right
		if mx > 32 and mx < 224 then
		if my > 60 and my < 80 then 
			mainmemory.writebyte(0x062D,0)
			mainmemory.writebyte(0x0A20,56)
		end
		if my > 80 and my < 96 then 
			mainmemory.writebyte(0x062D,1)
			mainmemory.writebyte(0x0A20,72)
		end
		if my > 96 and my < 112 then 
			mainmemory.writebyte(0x062D,2)
			mainmemory.writebyte(0x0A20,88)
		end
		if my > 112 and my < 128 then 
			mainmemory.writebyte(0x062D,3)
			mainmemory.writebyte(0x0A20,104)
		end
		end
		
		if debugon then gui.text(16, 64, "Balance") end
	elseif (currentscreen == scr_characterselect) then 
		
		currentchar = mainmemory.readbyte(0x002C)
		output["II"] = setbutton(in_mouse.Left)
		
		if mx > 10 and mx < 80 and my > 60 and my < 130 then 
			charsel = 0
			--for i,v in ipairs(charselcursor_addr) do
				--mainmemory.writebyte(v,char0cursor_val[i])
			--end
		end
		if mx > 90 and mx < 160 and my > 20 and my < 80 then 
			charsel = 1
			--for i,v in ipairs(charselcursor_addr) do
				--mainmemory.writebyte(v,char1cursor_val[i])
			--end
		end
		if mx > 175 and mx < 240 and my > 60 and my < 130 then 
			charsel = 2
			--for i,v in ipairs(charselcursor_addr) do
				--mainmemory.writebyte(v,char2cursor_val[i])
			--end
		end
		if mx > 144 and mx < 208 and my > 160 and my < 215 then
			charsel = 3		
			--for i,v in ipairs(charselcursor_addr) do
				--mainmemory.writebyte(v,char3cursor_val[i])
			--end
		end
		if mx > 48 and mx < 112 and my > 160 and my < 215 then
			charsel = 4
			--for i,v in ipairs(charselcursor_addr) do
				--mainmemory.writebyte(v,char4cursor_val[i])
			--end
		end
		

		if currentchar ~= charsel then 
			output["Right"] = switch
		end
		gui.text(1, 64, "Character Select")
	elseif true then
		output["Run"] = setbutton(in_mouse.Left)
		output["II"] = setbutton(in_mouse.Right)
	end
	
	joypad.set(output, 1)
	if debugon then 
	gui.text(1, 1, string.format("%i, %i", mx, my))
	gui.text(1, 16, string.format("current screen: %i", currentscreen))
	gui.text(1, 32, string.format("%i, %i", cursorposx, cursorposy))
	end
	emu.frameadvance();
end

--pceyuyuj

