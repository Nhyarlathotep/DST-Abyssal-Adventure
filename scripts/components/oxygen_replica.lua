local Oxygen = Class(function(self, inst)
    self.inst = inst

    self.max = net_ushortint(inst.GUID, "oxygen.max", "oxygendirty")
    self.current = net_ushortint(inst.GUID, "oxygen.current", "oxygendirty")
    self.overtime = net_bool(inst.GUID, "oxygen.overtime", "oxygendirty")

    self.rate = net_shortint(inst.GUID, "oxygen.rate", "ratedirty")
    self.underwater = net_bool(inst.GUID, "oxygen.underwater", "underwaterdirty")

    if TheWorld.ismastersim then
        -- Server
        local function OnOxygenDelta(inst, data)
            if not data.overtime and data.newpercent ~= data.oldpercent then
                self.overtime:set_local(false)
                self.overtime:set(false)
            end
        end

        inst:ListenForEvent("oxygendelta", OnOxygenDelta, inst)
    else
        -- Client
        local function OnOxygenDirty(inst)
            local percent = self:GetPercent()
            local oldpercent = self.oldoxygenpercent
            local data = {
                oldpercent = oldpercent,
                newpercent = percent,
                overtime = self.overtime:value()
            }

            self.oldoxygenpercent = percent
            self.overtime:set_local(true)

            inst:PushEvent("oxygendelta", data)
            if oldpercent > 0 then
                if percent <= 0 then
                    inst:PushEvent("startdrowning")
                end
            elseif percent > 0 then
                inst:PushEvent("stopdrowning")
            end
        end

        local function OnRateDirty(inst)
            inst:PushEvent("oxygenratechanged", self.rate:value())
        end

        local function OnUnderWaterDirty(inst)
            TheWorld:PushEvent("underwaterchanged", { underwater = self.underwater:value() })
        end

        self.oldoxygenpercent = 1
        self.overtime:set_local(true)
        inst:ListenForEvent("oxygendirty", OnOxygenDirty)
        inst:ListenForEvent("ratedirty", OnRateDirty)
        inst:ListenForEvent("underwaterdirty", OnUnderWaterDirty)
    end
end)

function Oxygen:SetCurrent(current)
    if TheWorld.ismastersim then
        self.current:set(current)
    end
end

function Oxygen:Max()
    if self.inst.components.oxygen then
        return self.inst.components.oxygen.max
    elseif not TheWorld.ismastersim then
        return self.max:value()
    else
        return 100
    end
end

function Oxygen:SetMax(max)
    if TheWorld.ismastersim then
        self.max:set(max)
    end
end

function Oxygen:IsBurning()
    if self.inst.components.oxygen then
        return self.inst.components.oxygen:IsBurning()
    elseif not TheWorld.ismastersim then
        return self.rate:value() ~= 0
    else
        return false
    end
end

function Oxygen:SetRate(rate)
    if TheWorld.ismastersim then
        self.rate:set(rate)
    end
end

function Oxygen:IsUnderWater()
    if self.inst.components.oxygen then
        return self.inst.components.oxygen:IsUnderWater()
    elseif not TheWorld.ismastersim then
        return self.underwater:value()
    else
        return false
    end
end

function Oxygen:SetUnderWater(underwater)
    if TheWorld.ismastersim then
        self.underwater:set(underwater)
    end
end

function Oxygen:GetPercent()
    if self.inst.components.oxygen then
        return self.inst.components.oxygen:GetPercent()
    elseif not TheWorld.ismastersim then
        return self.current:value() / self.max:value()
    else
        return 1
    end
end

function Oxygen:IsDrowning()
    if self.inst.components.oxygen then
        return self.inst.components.oxygen:IsDrowning()
    else
        return not TheWorld.ismastersim and self.current:value() <= 0
    end
end

return Oxygen