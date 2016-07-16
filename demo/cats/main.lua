
-- Add root directory to package.path so the lib can be found by require
package.path = package.path .. ";../../?.lua"

-- Save old love.graphics before overriding it so we can toggle between it for
-- the purpose of the demo
local origLoveGraphics = love.graphics

require "autobatch"

--==============================================================================
-- Cat
--==============================================================================

love.graphics.setDefaultFilter("nearest")

local shadowImage = love.graphics.newImage("shadow.png")
local catImage = love.graphics.newImage("cat.png")

local frames = {}
for y = 0, 3 do
  for x = 0, 7 do
    local w, h = catImage:getDimensions()
    local q = love.graphics.newQuad(x * w / 8, y * h / 4, w / 8, h / 4, w, h)
    table.insert(frames, q)
  end
end

local Cat = {}
Cat.__index = Cat

function Cat.new()
  local self = setmetatable({}, Cat)
  local w, h = love.graphics.getDimensions()
  self.x, self.y = math.random() * w, math.random() * h
  self.vx, self.vy = 0, 0
  self.cat = math.random(0, 3)
  self.flip = math.random() < .5
  self.animSpeed = .8 + math.random() * .3
  self.moveTimer = 0
  return self
end


function Cat:update(dt)
  -- Add velocity to position and wrap to screen
  local w, h = love.graphics.getDimensions()
  self.x = (self.x + self.vx * dt) % w
  self.y = (self.y + self.vy * dt) % h
  -- Update move timer -- if we hit zero then change or zero velocity
  self.moveTimer = self.moveTimer - dt
  if self.moveTimer < 0 then
    if math.random() < .2 then
      self.vx = (math.random() * 2 - 1) * 30
      self.vy = (math.random() * 2 - 1) * 15
      self.flip = self.vx < 0
    else
      self.vx, self.vy = 0, 0
    end
    self.moveTimer = 1 + math.random() * 5
  end
end


function Cat:draw()
  -- Get current animation frame
  local e = love.timer.getTime() * self.animSpeed
  local frameidx = 1 + self.cat * 8 + math.floor(e * 8 % 4)
  if self.vx ~= 0 or self.vy ~= 0 then
    frameidx = frameidx + 4
  end
  -- Get x scale based on flip flag
  local xscale = self.flip and -1 or 1
  -- Draw
  local x, y = self.x, self.y
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(catImage, frames[frameidx], x, y, 0, xscale, 1, 7)
end


function Cat:drawShadow()
  love.graphics.setColor(255, 255, 255, 255 * .6)
  love.graphics.draw(shadowImage, self.x, self.y + 10, 0, 1, 1, 7)
end


--==============================================================================
-- Main
--==============================================================================

local cats = {}

function love.load()
  for i = 1, 4000 do
    table.insert(cats, Cat.new())
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
  -- Update cats
  for i, v in ipairs(cats) do
    v:update(dt)
  end
  -- Sort cats by their y-axis so they're drawn back-to-front
  table.sort(cats, function(a, b) return a.y < b.y end)
end


function love.draw()
  love.graphics.clear(200, 200, 200)
  -- Draw all the cat shadows
  for i, v in ipairs(cats) do
    v:drawShadow()
  end
  -- Draw all the cats
  for i, v in ipairs(cats) do
    v:draw()
  end
  -- Draw debug information in corner
  local stats = love.graphics.getStats()
  local status = love.graphics == origLoveGraphics and "disabled" or "enabled"
  love.graphics.reset()
  love.graphics.setColor(0, 0, 0, 255 * .75)
  love.graphics.rectangle("fill", 5, 5, 110, 65, 2)
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(love.timer.getFPS() .. "fps", 10, 10)
  love.graphics.print("drawcalls: " .. stats.drawcalls, 10, 30)
  love.graphics.print(status, 10, 50)
end
