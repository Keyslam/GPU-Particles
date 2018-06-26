love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setPointSize(2)

local _WIDTH, _HEIGHT = love.graphics.getDimensions()
local Data_texture_size = 16

local SetColor = love.graphics.newShader("setColor.glsl")
local Render = love.graphics.newShader("render.glsl")
local Physics = love.graphics.newShader("physics.glsl")

local buffer = {}
for i = 0, Data_texture_size * Data_texture_size * 6 - 1 do
   local j = i % 6 + 1

   local vert = {0, 0, 0, 0}

   if j == 1 then
      vert[3] = 0
      vert[4] = 0
   elseif j == 2 then
      vert[3] = 1
      vert[4] = 0
   elseif j == 3 then
      vert[3] = 1
      vert[4] = 1
   elseif j == 4 then
      vert[3] = 0
      vert[4] = 0
   elseif j == 5 then
      vert[3] = 0
      vert[4] = 1
   elseif j == 6 then
      vert[3] = 1
      vert[4] = 1
   end

   buffer[i + 1] = vert
end

local Image = love.graphics.newImage("timticle.png")

local Particle_mesh = love.graphics.newMesh({
   {"VertexPosition", "float", 2},
   {"VertexTexCoord", "float", 2},
}, buffer, "triangles")

Particle_mesh:setTexture(Image)

local Dummy_mesh = love.graphics.newMesh({
   {0, 0, 0, 0},
   {Data_texture_size, 0, 1, 0},
   {0, Data_texture_size, 0, 1},

   {Data_texture_size, 0, 1, 0},
   {0, Data_texture_size, 0, 1},
   {Data_texture_size, Data_texture_size, 1, 1},
}, "triangles", "static")


local Transform_front = love.graphics.newCanvas(Data_texture_size, Data_texture_size, {format = "rgba32f"})
local Transform_back  = love.graphics.newCanvas(Data_texture_size, Data_texture_size, {format = "rgba32f"})

love.graphics.setBlendMode("none")
love.graphics.setCanvas(Transform_back)
   for i = 1, Data_texture_size do
      for j = 1, Data_texture_size do
         local r = love.math.random(0, 200 * math.pi) / 100
         local a = love.math.random(0, 20)
         local f = love.math.random(200, 600) / 10

         SetColor:send("new_color", {_WIDTH/2 + a * math.cos(r), _HEIGHT/2 + a * math.sin(r), f * math.cos(r), f * math.sin(r)})
         love.graphics.setShader(SetColor)
         love.graphics.points(i, j)
         love.graphics.setShader()
      end
   end
love.graphics.setCanvas()
love.graphics.setBlendMode("alpha", "alphamultiply")

local Lifetime_front = love.graphics.newCanvas(Data_texture_size, Data_texture_size, {format = "rgba32f"})
local Lifetime_back = love.graphics.newCanvas(Data_texture_size, Data_texture_size, {format = "rgba32f"})
local Lifetime = 8
love.graphics.setBlendMode("none")
love.graphics.setCanvas(Lifetime_back)
love.graphics.setColor(0, 1, 1, 1)
love.graphics.rectangle("fill", 1, 1, 512, 512)
love.graphics.setCanvas()
love.graphics.setBlendMode("alpha", "alphamultiply")



function love.update(dt)
   love.window.setTitle(love.timer.getFPS())

   Physics:send("dt", dt)
   Physics:send("lifetime", Lifetime)

   Render:send("lifetime", Lifetime)
end

function love.draw()
   love.graphics.setColor(1, 1, 1, 1)

   love.graphics.setBlendMode("none")
   Physics:send("transform_texture", Transform_back)
   Physics:send("lifetime_texture", Lifetime_back)
   love.graphics.setShader(Physics)
      love.graphics.setCanvas(Transform_front, Lifetime_front)
         love.graphics.draw(Dummy_mesh)
      love.graphics.setCanvas()
   love.graphics.setShader()

   Transform_front, Transform_back = Transform_back, Transform_front
   Lifetime_front, Lifetime_back = Lifetime_back, Lifetime_front

   love.graphics.setBlendMode("alpha", "alphamultiply")
   Render:send("transform_texture", Transform_back)
   Render:send("lifetime_texture", Lifetime_back)
   love.graphics.setShader(Render)
      love.graphics.draw(Particle_mesh)
   love.graphics.setShader()
end
