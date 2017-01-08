require "/scripts/util.lua"
require "/scripts/poly.lua"
require "/scripts/es_util.lua"

function init()
  self = config.getParameter("es_environmentManipulator")
  environment = config.getParameter("environment")
  loadDefaultStatus()
  object.setInteractive(self.interactive)
  self.position = object.toAbsolutePosition(self.position)
  object.setLightColor({100, 100, 100})
  
  message.setHandler("getAttributes", function(_, _)
    return getAttributes()
  end)
  message.setHandler("swapAttribute", function(_, _, attribute)
    swapAttribute(attribute)
  end)
end

function update(dt)
  local entities = getEntitiesInRadius()
  for _, entityAfected in ipairs(entities) do
    local entityPos = world.entityPosition(entityAfected)
    spawnStatusProjectile(entityPos, entity.id())
    world.debugText("Inside Area", entityPos, "yellow") --DEBUG
  end
end

function getEntitiesInRadius()
  local posibleEntities = world.playerQuery(self.position, self.radio)
  mergeTables(posibleEntities, world.npcQuery(self.position, self.radio))
  return posibleEntities
end

function spawnStatusProjectile(pos, idSpawmer)
  local attributes = getAttributes()
  for attribute, isActive in pairs(attributes) do
    if isActive then
      local projectil = string.format("es_%s", attribute)
      world.spawnProjectile(projectil, pos, idSpawmer)
    end
  end
end

function loadDefaultStatus()
  if storage.gravity == nil then
    storage.gravity = environment.gravity
    storage.breath = environment.breath
    storage.nanoheal = environment.nanoheal
    storage.heat = environment.heat
    storage.cold = environment.cold
    storage.radiation = environment.radiation
  end
end

function swapAttribute(attribute)
  -- This looks ugly. I hate big if/else statments. But whatever.
  -- Solution: Individual swapAtribute functions. But I'm lazy. At least right now.
  if (attribute == "gravity") then
    storage.gravity = not storage.gravity
  elseif (attribute == "breath") then
    storage.breath = not storage.breath
  elseif (attribute == "nanoheal") then
    storage.nanoheal = not storage.nanoheal
  elseif (attribute == "heat") then
    storage.heat =  not storage.heat
  elseif (attribute == "cold") then
    storage.cold = not storage.cold
  elseif (attribute == "radiation") then
    storage.radiation = not storage.radiation
  else sb.logInfo("Console at %s recibed an unknow attribute to swap state.", object.position())
  end
end

function getAttributes()
  return {
    gravity = storage.gravity,
    breath = storage.breath,
    nanoheal = storage.nanoheal,
    heat = storage.heat,
    cold = storage.cold,
    radiation = storage.radiation
  }
end