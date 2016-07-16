
-- Add root directory to package.path so the lib can be found by require
package.path = package.path .. ";../../?.lua"

-- Save old love.graphics before overriding it so we can toggle between it for
-- the purpose of the demo
local origLoveGraphics = love.graphics

require "autobatch"

--==============================================================================
-- Star
--==============================================================================

local image = love.graphics.newImage("star.png")

local Star = {}
Star.__index = Star

function Star.new()
  local self = setmetatable({}, Star)
  local w, h = love.graphics.getDimensions()
  self.x, self.y = math.random() * w, math.random() * h
  self.vx, self.vy = (math.random() * 2 - 1) * 30, (math.random() * 2 - 1) * 30
  self.r = 0
  self.vr = (math.random() * 2 - 1) * 2
  self.color = { math.random(255), math.random(255), math.random(255) }
  self.scale = .1 + math.random() ^ 4 * .7
  return self
end


function Star:update(dt)
  -- Add velocity to position / rotation and wrap to screen
  local w, h = love.graphics.getDimensions()
  self.x = (self.x + self.vx * dt) % w
  self.y = (self.y + self.vy * dt) % h
  self.r = self.r + self.vr * dt
end


function Star:draw()
  local scale = self.scale
  love.graphics.setColor( unpack(self.color) )
  love.graphics.draw(image, self.x, self.y, self.r, scale, scale, 16, 16)
end


--==============================================================================
-- Main
--==============================================================================

local stars = {}

function love.load()
  for i = 1, 10000 do
    table.insert(stars, Star.new())
  end
end


function love.keypressed(k)
  if k == "space" then
    if love.graphics == origLoveGraphics then
      love.graphics = require("autobatch")
    else
      love.graphics = origLoveGraphics
    end
  end
end


function love.update(dt)
  for i, v in ipairs(stars) do
    v:update(dt)
  end
end


function love.draw()
  -- Draw all the stars with additive blending
  love.graphics.setBlendMode("add")
  for i, v in ipairs(stars) do
    v:draw()
  end
  -- Draw debug information in corner
  local stats = love.graphics.getStats()
  local status = love.graphics == origLoveGraphics and "disabled" or "enabled"
  love.graphics.reset()
  love.graphics.setColor(0, 0, 0, 255 * .75)
  love.graphics.rectangle("fill", 5, 5, 120, 65, 2)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(love.timer.getFPS() .. "fps", 10, 10)
  love.graphics.print("drawcalls: " .. stats.drawcalls, 10, 30)
  love.graphics.print(status, 10, 50)
end
