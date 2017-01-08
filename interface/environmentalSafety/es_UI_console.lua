function init()

  self.promise = world.sendEntityMessage(pane.sourceEntity(), "getAttributes")
  self.attributes = world.getObjectParameter(pane.sourceEntity(), "environment")
  actualice()
end

function update(dt)
  if self.promise:finished() then
    self.attributes = self.promise:result()
    self.promise = world.sendEntityMessage(pane.sourceEntity(), "getAttributes")
    actualice()
  end
end

function actualice()
  setStatus("gravity",self.attributes.gravity)
  setStatus("breath",self.attributes.breath)
  setStatus("nanoheal",self.attributes.nanoheal)
  setStatus("heat",self.attributes.heat)
  setStatus("cold",self.attributes.cold)
  setStatus("radiation",self.attributes.radiation)
end

function setStatus(attribute, isActive)
  --attribute must be a string with a button, label and description in the panel.
  --isActive is the status of the attribute, must be a boolean.
  local light_color = {255, 255, 255}
  local dark_color = {255, 255, 255}
  
  if isActive then
    light_color = {54, 190, 255}
    dark_color = {00, 124, 188}
  else
    light_color = {253, 53, 53}
    dark_color = {186, 00, 00}
  end

  widget.setFontColor(string.format("lbl_%s", attribute), light_color)
  widget.setFontColor(string.format("desc_%s", attribute), dark_color)
  widget.setChecked(string.format("check_%s", attribute), isActive)
end

function swapStatusGravity()
  swapStatus("gravity")
end

function swapStatusBreath()
  swapStatus("breath")
end

function swapStatusNanoheal()
  swapStatus("nanoheal")
end

function swapStatusHeat()
  swapStatus("heat")
end

function swapStatusCold()
  swapStatus("cold")
end

function swapStatusRadiation()
  swapStatus("radiation")
end

function swapStatus(attribute)
  world.sendEntityMessage(pane.sourceEntity(), "swapAttribute", attribute)
  actualice()
end