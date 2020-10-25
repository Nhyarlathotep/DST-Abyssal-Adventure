local function OxygenUiClock(self, owner)
    local NUM_SEGS = 16
    local DAY_COLOUR = GLOBAL.Vector3(254 / 255, 212 / 255, 86 / 255)
    local DUSK_COLOUR = GLOBAL.Vector3(165 / 255, 91 / 255, 82 / 255)
    local CAVE_DAY_COLOUR = GLOBAL.Vector3(174 / 255, 195 / 255, 108 / 255)
    local CAVE_DUSK_COLOUR = GLOBAL.Vector3(113 / 255, 127 / 255, 108 / 255)
    local UNDERWATER_DAY_COLOUR = GLOBAL.Vector3(39 / 255, 154 / 255, 241 / 255)
    local UNDERWATER_DUSK_COLOUR = GLOBAL.Vector3(24 / 255, 138 / 255, 141 / 255)
    local DARKEN_PERCENT = .75

    local OldUpdateCaveClock = self.UpdateCaveClock
    self.UpdateCaveClock = function(self, owner)
        if owner.replica.oxygen and owner.replica.oxygen:IsUnderWater() then
            if not self._caveopen then
                self:OpenCaveClock()
            end
        else
            OldUpdateCaveClock(self, owner)
        end
    end

    self.OnClockSegsChanged = function(self, data)
        local day = data.day or 0
        local dusk = data.dusk or 0
        local night = data.night or 0
        GLOBAL.assert(day + dusk + night == NUM_SEGS, "invalid number of time segs")

        local dark = true
        for k, seg in pairs(self._segs) do
            if k > day + dusk then
                seg:Hide()
            else
                seg:Show()

                local color
                if k <= day then
                    color = (self._cave and ((owner.replica.oxygen:IsUnderWater() and UNDERWATER_DAY_COLOUR) or CAVE_DAY_COLOUR)) or DAY_COLOUR
                else
                    color = (self._cave and ((owner.replica.oxygen:IsUnderWater() and UNDERWATER_DUSK_COLOUR) or CAVE_DUSK_COLOUR)) or DUSK_COLOUR
                end

                if dark then
                    color = color * DARKEN_PERCENT
                end
                dark = not dark

                seg:SetTint(color.x, color.y, color.z, 1)
            end
        end
        self._daysegs = day
    end
end

AddClassPostConstruct("widgets/uiclock", OxygenUiClock)