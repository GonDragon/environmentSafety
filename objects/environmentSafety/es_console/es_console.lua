require "/scripts/util.lua"
require "/scripts/poly.lua"
require "/scripts/es_util.lua"

function init()
  self = config.getParameter("es_console")
  if not self then
    sb.logInfo("Console at %s is missing configuration.", object.position())
    return
  end

  environment = config.getParameter("environment")
  loadDefaultStatus()
  object.setInteractive(self.interactive)
  self.position = object.toAbsolutePosition(self.position)
  storage.house = scan()
  timeToCheck = self.deltaCheck
  
  message.setHandler("getAttributes", function(_, _)
    return getAttributes()
  end)
  message.setHandler("swapAttribute", function(_, _, attribute)
    swapAttribute(attribute)
  end)
end

function update(dt)

  if storage.house then
    applyStatus()
    object.setAllOutputNodes(true)
    checkIntegrity(dt)
  else
    object.setAllOutputNodes(false)
    animator.setAnimationState("switchState", "error")
    storage.house = scan()
  end
end

function applyStatus()
  util.debugPoly(storage.house.poly, "red")
  local entitiesInside = entitiesInsidePoly()
    
  for c, entityInside in ipairs(entitiesInside) do
    local entityPos = world.entityPosition(entityInside)
    spawnStatusProjectile(entityPos, entity.id())
      
    world.debugText("Inside Area", entityPos, "yellow") --DEBUG    
  end
end

function checkIntegrity(dt)
  timeToCheck = timeToCheck - dt
  if timeToCheck < 0 then
    timeToCheck = self.deltaCheck
    storage.house = scan()
  end
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

function entitiesInsidePoly()
  local polyCenter = poly.center(storage.house.poly)
  local polyRadius = getPolyRadius(storage.house.poly, polyCenter)
  
  local posibleEntities = world.playerQuery(polyCenter, polyRadius)
  mergeTables(posibleEntities, world.npcQuery(polyCenter, polyRadius))
  
  local finalEntities = {}
  for count = 1, #posibleEntities do
    local pos = world.entityPosition(posibleEntities[count])
    if world.polyContains(storage.house.poly, pos) then
      table.insert(finalEntities, posibleEntities[count])
    end
  end
  return finalEntities
end
  
function getPolyRadius(poly, polyCenter)
  local maxRadius = 0.0
  
  for poinCount = 1, #poly do
    local parcialRadius = getDist(polyCenter, poly[poinCount])
    if parcialRadius > maxRadius then maxRadius = parcialRadius end
  end
  return maxRadius
end

function getDist(vecA, vecB)
  local x = vecB[1] - vecA[1]
  local y = vecB[2] - vecB[2]
  return pitagoras(x, y)
end

function pitagoras(x, y)
  return math.sqrt((x*x) + (y*y))
end

function scan()
  local house = findHouseBoundary(self.position, self.maxPerimeter)

  if house.poly and world.regionActive(polyBoundBox(house.poly)) then
    animator.setAnimationState("switchState", "idle")
    return house
  elseif not house.poly then
    --util.debugLog("Scan failed")
    return nil
  else
    util.debugLog("Parts of the house are unloaded - skipping scan")
    return nil
  end
end