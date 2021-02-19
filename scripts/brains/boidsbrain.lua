require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/follow"

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5

local AVOID_PLAYER_DIST = 3
local AVOID_PLAYER_STOP = 6

local SEE_BAIT_DIST = 20
local MAX_WANDER_DIST = 20

local function FindCloseFriends(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 10, {'boids'})

    local num_friends = 0
    for k,v in pairs(ents) do
        if v ~= inst then
            num_friends = num_friends + 1
        end
    end
    return num_friends
end

local function GoToCenterOfMass(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 10, {'boids'})

    local num_friends = 0
    local center_of_mass = Point(0, 0, 0)
    for k, v in pairs(ents) do
        if v ~= inst then
            num_friends = num_friends + 1
            center_of_mass = center_of_mass + Point(v.Transform:GetWorldPosition())
        end
    end
   center_of_mass = center_of_mass / num_friends
    return (center_of_mass - Point(inst.Transform:GetWorldPosition())) * 0.5
end

local function KeepDistance(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 1.5, {'boids'})

    local c = Point(0, 0, 0)
    for k, v in pairs(ents) do
        if v ~= inst then
            c = c - (Point(v.Transform:GetWorldPosition()) - Point(inst.Transform:GetWorldPosition()))
        end
    end
    return c;
end

local function MatchVelocity(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 10, {'boids'})

    local vel = Point(0, 0, 0)
    local num_friends = 0
    for k, v in pairs(ents) do
        if v ~= inst then
            num_friends = num_friends + 1
            vel = vel + Point(v.Physics:GetVelocity())
        end
    end
    vel = vel / num_friends
    return (vel - Point(inst.Physics:GetVelocity()))
end

local function BoidsBehaviour(inst)
    local v1 = GoToCenterOfMass(inst)
    local v2 = KeepDistance(inst)
    local v3 = MatchVelocity(inst)

    local vel = Point(inst.Physics:GetVelocity()) + v1 + v2 + v3
    inst.Physics:SetVel(vel.x, vel.y, vel.z)
    --local pos = Point(inst.Transform:GetWorldPosition()) + vel
    --inst.Physics:Teleport(pos.x, pos.y, pos.z)
    inst.components.locomotor:GoToPoint(Point(inst.Transform:GetWorldPosition()) + vel)
    --inst.components.locomotor:GoToPoint(Point(inst.Transform:GetWorldPosition()) + v1 + v2 + v3)
    --print(inst.Physics:GetVelocity())


   -- local rotation = inst.Transform:GetRotation() * DEGREES
   -- local forward_x, forward_z = math.cos(rotation), -math.sin(rotation)
   -- print("------")
   -- print(forward_x)
   -- print(forward_z)
end

--WalkInDirection
local BoidsBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function BoidsBrain:OnStart()
    local root = PriorityNode(
        {
            WhileNode(function() return FindCloseFriends(self.inst) == 0 end, "No Friends Near",
                Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("spawnpoint") end, 100, {minwaittime = 1, randwaittime = 1})),

            WhileNode(function() return FindCloseFriends(self.inst) ~= 0 end, "Friends Near",
                ActionNode(function() return BoidsBehaviour(self.inst) end)),
        }, .25)
   self.bt = BT(self.inst, root)
end

function BoidsBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return BoidsBrain