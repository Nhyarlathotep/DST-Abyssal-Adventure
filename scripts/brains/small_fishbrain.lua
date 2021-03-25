require "behaviours/wander"
require "behaviours/runaway"

local wandertimes = {
    minwalktime = 2,
    randwalktime = 2,
    minwaittime = 0.1,
    randwaittime = 0.1,
}

local AVOID_PLAYER_DIST = 5
local AVOID_PLAYER_STOP = 8

local MAX_IDLE_WANDER_DIST = 10

local SmallFish = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SmallFish:OnStart()
    local root = PriorityNode({
        RunAway(self.inst, "scarytoprey", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_IDLE_WANDER_DIST, wandertimes),
    }, .25)
    self.bt = BT(self.inst, root)
end

function SmallFish:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()))
end

return SmallFish