local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local OxygenBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, "oxygen", owner)

    self.oxygenarrow = self.underNumber:AddChild(UIAnim())
    self.oxygenarrow:GetAnimState():SetBank("sanity_arrow")
    self.oxygenarrow:GetAnimState():SetBuild("sanity_arrow")
    self.oxygenarrow:GetAnimState():PlayAnimation("neutral")
    self.oxygenarrow:SetClickable(false)

    self:StartUpdating()
end)

function OxygenBadge:OnUpdate(dt)
    local anim = "neutral"

    if self.arrowdir ~= anim then
        self.arrowdir = anim
        self.oxygenarrow:GetAnimState():PlayAnimation(anim, true)
    end
end

return OxygenBadge