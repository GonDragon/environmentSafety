function init()
  effect.addStatModifierGroup({
  {stat = "asteroidImmunity", amount = 1}
  })
  self.gravityDesired = config.getParameter("gravityDesired")
  self.movementParams = mcontroller.baseParameters()

  setGravityMultiplier()
end

function setGravityMultiplier()

  local currentGravity = world.gravity(mcontroller.position())
  
  if currentGravity == 0 then
    effect.expire()
    return
  end
  
  self.newGravityMultiplier = self.gravityDesired / currentGravity
end

function update(dt)
  mcontroller.controlParameters({
     gravityMultiplier = self.newGravityMultiplier
  })
end

function uninit()

end
