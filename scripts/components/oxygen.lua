local function CalcRate(inst)
    local map = TheWorld.Map
    local x, y, z = inst.Transform:GetWorldPosition()
    local grounds = {
        map:GetTile(map:GetTileCoordsAtPoint(x, y, z)),
        map:GetTile(map:GetTileCoordsAtPoint(x + 5, y, z)),
        map:GetTile(map:GetTileCoordsAtPoint(x - 5, y, z)),
        map:GetTile(map:GetTileCoordsAtPoint(x, y, z + 5)),
        map:GetTile(map:GetTileCoordsAtPoint(x, y, z - 5)),
    }
    for k, ground in pairs(grounds) do
        if ground == GROUND.SAND then
           return -1
        else
            --TODO HANDLE OTHER GROUNDS
        end
    end
    return 0
end

local function OnChangeArea(inst, area)
    inst.components.oxygen:SetUnderWater(area ~= nil and area.tags ~= nil and table.contains(area.tags, "deeparea"))
end

local Oxygen = Class(function(self, inst)
    self.inst = inst
    self.max = 60
    self.rate = -1
    self.current = self.max
    self.underwater = false

    self.hurtrate = 12
    self.inst:StartUpdatingComponent(self)
    self.inst:ListenForEvent("changearea", OnChangeArea)
end, nil, {
    max = function(self, max) self.inst.replica.oxygen:SetMax(max) end,
    rate = function(self, rate) self.inst.replica.oxygen:SetRate(rate) end,
    current = function(self, current) self.inst.replica.oxygen:SetCurrent(current) end,
    underwater = function(self, underwater) self.inst.replica.oxygen:SetUnderWater(underwater) end,
})

function Oxygen:IsDrowning()
    return self.current <= 0
end

function Oxygen:IsUnderWater()
    return self.underwater
end

function Oxygen:IsBurning()
    return self.rate ~= 0
end

function Oxygen:SetUnderWater(underwater)
    if self.underwater ~= underwater then
        self.underwater = underwater
        TheWorld:PushEvent("underwaterchanged", { underwater = self.underwater })
    end
end

function Oxygen:GetPercent()
    return self.current / self.max
end

function Oxygen:OnSave()
    return {
        current = self.current,
        underwater = self.underwater
    }
end

function Oxygen:OnLoad(data)
    self.current = data.current or self.max
    self:SetUnderWater(data.underwater or false)
    self:OnUpdate(0)
end

function Oxygen:DoDelta(delta, overtime)
    if self.inst.components.health and self.inst.components.health.invincible or self.inst.is_teleporting then
        return
    end

    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)
    self.inst:PushEvent("oxygendelta", { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime })

    if old > 0 then
        if self.current <= 0 then
            self.inst:PushEvent("startdrowning")
        end
    elseif self.current > 0 or (self.inst.components.health and self.inst.components.health:IsDead()) then
        self.inst:PushEvent("stopdrowning")
    end
end

function Oxygen:OnUpdate(dt)
    self.rate = CalcRate(self.inst)

    if self.rate == 0 then
        self.current = self.max
        return;
    end

    self:DoDelta(self.rate * dt, true)

    if self:IsDrowning() and self.inst.components.health and not self.inst.components.health:IsDead() then
        self.inst.components.health:DoDelta(-self.hurtrate * dt, true, "drowning")
    end
end

Oxygen.LongUpdate = Oxygen.OnUpdate

return Oxygen