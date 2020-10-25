local function OxygenBloodOver(self)
    function self:UpdateState()
        if (self.owner.IsFreezing and self.owner:IsFreezing()) or
                (self.owner.IsOverheating and self.owner:IsOverheating()) or
                (self.owner.replica.hunger and self.owner.replica.hunger:IsStarving()) or
                (self.owner.replica.oxygen and self.owner.replica.oxygen:IsDrowning()) then
            self:TurnOn()
        else
            self:TurnOff()
        end
    end

    local function _UpdateState() self:UpdateState() end

    self.inst:ListenForEvent("startdrowning", _UpdateState, self.owner)
    self.inst:ListenForEvent("stopdrowning", _UpdateState, self.owner)
end

AddClassPostConstruct("widgets/bloodover", OxygenBloodOver)