local function OxygenStatusDisplays(self)
    local OxygenBadge = GLOBAL.require "widgets/oxygenbadge"

    self.oxygen = self:AddChild(OxygenBadge(self.owner))
    self.owner.oxygenbadge = self.oxygen

    local AlwaysOnStatus = false
    for k, v in ipairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
        local Mod = GLOBAL.KnownModIndex:GetModInfo(v).name
        if Mod == "Combined Status" then
            AlwaysOnStatus = true
        end
    end

    if AlwaysOnStatus then
        self.oxygen:SetPosition(-125, 35, 0)
    else
        self.oxygen:SetPosition(-120, 20, 0)
    end

    function self:SetOxygenPercent(pct)
        if self.owner.replica.oxygen then
            self.oxygen:SetPercent(pct, self.owner.replica.oxygen:Max())
        end

        if pct <= .33 then
            self.oxygen:StartWarning()
        else
            self.oxygen:StopWarning()
        end
    end

    function self:OxygenDelta(data)
        self:SetOxygenPercent(data.newpercent)

        if not data.overtime then
            if data.newpercent > data.oldpercent then
                self.oxygen:PulseGreen()
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_up")
            elseif data.newpercent < data.oldpercent then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_down")
                self.oxygen:PulseRed()
            end
        end
    end

    local function OnSetPlayerMode(self)
        if self.onoxygendelta == nil then
            self.onoxygendelta = function(owner, data) self:OxygenDelta(data) end
            self.onoxygenratechanged = function(owner, data) if data ~= 0 then self.oxygen:Show() else self.oxygen:Hide() end end

            self.inst:ListenForEvent("oxygendelta", self.onoxygendelta, self.owner)
            self.inst:ListenForEvent("oxygenratechanged", self.onoxygenratechanged, self.owner)

            if self.owner.replica.oxygen then
                self:SetOxygenPercent(self.owner.replica.oxygen:GetPercent())
            end
        end
    end

    OnSetPlayerMode(self)

    local oldSetGhostMode = self.SetGhostMode
    self.SetGhostMode = function(self, ghostmode)
        oldSetGhostMode(self, ghostmode)
        if self.isghostmode or (self.owner.replica.oxygen and not self.owner.replica.oxygen:IsUnderWater()) then
            self.oxygen:Hide()
        end
    end
end

AddClassPostConstruct("widgets/statusdisplays", OxygenStatusDisplays)

