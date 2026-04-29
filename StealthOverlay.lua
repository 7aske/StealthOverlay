-- CONFIG SECTION --
STEALTHOVERLAY_SHOWTIME = 2;
STEALTHOVERLAY_FADETIME = 0.05;
STEALTHOVERLAY_CANCELTIME = 3;
local L_STEALTH = "Stealth";
local L_PROWL = "Prowl";
-- END --

local _, class = UnitClass("player");
class = strupper(class);

local stealthState = false;

local function StealthOverlay_IsStealthed()
	if class == "ROGUE" then
		for i = 1, 40 do
			local name = UnitBuff("player", i);
			if name == L_STEALTH then
				return true;
			end
		end
	elseif class == "DRUID" then
		for i = 1, 40 do
			local name = UnitBuff("player", i);
			if name == L_PROWL then
				return true;
			end
		end
	end
	return false;
end

function StealthOverlay_OnLoad(self)
	if ( class ~= "ROGUE" and class ~= "DRUID" ) then
		DisableAddOn("StealthOverlay");
		ReloadUI();
		return;
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_AURA");

	SlashCmdList["STEALTHOVERLAY_SLASHCMD"] = function(msg)
		if ( msg == "" ) then
			StealthOverlay_Stealth(STEALTHOVERLAY_CANCELTIME);
		else
			StealthOverlay_Stealth(tonumber(msg));
		end
	end

	SLASH_STEALTHOVERLAY_SLASHCMD1 = '/caststealth'
	SLASH_STEALTHOVERLAY_SLASHCMD2 = '/stealth'
	SLASH_STEALTHOVERLAY_SLASHCMD3 = '/prowl'
end

function StealthOverlay_OnEvent(self, event, arg1, arg2)
	if ( event == "UNIT_AURA" ) then
		if ( arg1 ~= "player" ) then
			return;
		end
		local now = StealthOverlay_IsStealthed();
		if ( now == stealthState ) then
			return;
		end
		stealthState = now;
		if ( now ) then
			StealthOverlayFrame.display = true;
			StealthOverlayFrame.onload = false;
			StealthOverlayFrame.timer = STEALTHOVERLAY_SHOWTIME;
			StealthOverlayFrame:SetAlpha(0);
			StealthOverlayFrame:Show();
		else
			StealthOverlayFrame.display = false;
			StealthOverlayFrame.onload = false;
			StealthOverlayFrame.timer = STEALTHOVERLAY_FADETIME;
			StealthOverlayFrame:SetAlpha(1);
			StealthOverlayFrame:Show();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		stealthState = StealthOverlay_IsStealthed();
		if ( stealthState ) then
			StealthOverlayFrame.display = true;
			StealthOverlayFrame.onload = true;
			StealthOverlayFrame.timer = STEALTHOVERLAY_SHOWTIME;
			StealthOverlayFrame:SetAlpha(1);
			StealthOverlayFrame:Show();
		else
			StealthOverlayFrame:Hide();
			StealthOverlayFrame.display = false;
			StealthOverlayFrame.onload = false;
		end
	end
end

local function StealthOverlay_HasStealthBuff(spellName)
	for i = 1, 40 do
		local name = UnitBuff("player", i);
		if ( name == spellName ) then
			return true;
		end
	end
	return false;
end

function StealthOverlay_Stealth(t)
	if ( class ~= "ROGUE" and class ~= "DRUID" ) then
		return;
	end
	local spellName = ( class == "ROGUE" ) and L_STEALTH or L_PROWL;
	if not t then t = STEALTHOVERLAY_CANCELTIME; end

	local isActive = StealthOverlay_HasStealthBuff(spellName);
	local timeNow = time();

	if not isActive then
		__LST = timeNow;
		CastSpellByName(spellName);
	else
		if __LST ~= nil then
			if __LST+t < timeNow then
				CastSpellByName(spellName);
			end
		else
			CastSpellByName(spellName);
		end
	end
end

function StealthOverlay_OnUpdate(self, elapsed)
	self.timer = self.timer - elapsed;
	if self.timer <= 0 then
		if not self.display then
			self:Hide();
		end
	elseif self.timer > 0 then
		if self.onload then return end
		if self.display then
			self:SetAlpha( 1 - ( ( (self.timer/STEALTHOVERLAY_SHOWTIME) * 100) / 100)  );
		else
			self:SetAlpha(( (self.timer/STEALTHOVERLAY_SHOWTIME) * 100) / 100);
		end
	end
end
