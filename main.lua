love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setPointSize(2)

local Ffi = require("ffi")

local SetColor = love.graphics.newShader("setColor.glsl")
local Render   = love.graphics.newShader("render.glsl")
local Physics  = love.graphics.newShader("physics.glsl")

local _WIDTH, _HEIGHT = love.graphics.getDimensions()

local particleCount = 128
local vertexCount   = particleCount * 6
local dataSize      = math.sqrt(vertexCount)


Ffi.cdef[[
   typedef struct {
      float x, y;
      float u, v;
   } fm_vertex;
]]

local vertexSize  = Ffi.sizeof("fm_vertex")
local memoryUsage = vertexCount * vertexSize

local byteData = love.data.newByteData(memoryUsage)
local data     = Ffi.cast("fm_vertex*", byteData:getPointer())

for vertex = 0, vertexCount - 1 do
   local vertexPointer = data[vertex]

   vertexPointer.u = (vertex == 1 or vertex == 3) and 1 or 0
   vertexPointer.v = (vertex == 2 or vertex == 3) and 1 or 0
end

local Particle_mesh = love.graphics.newMesh({
   {"VertexPosition", "float", 2},
   {"VertexTexCoord", "float", 2},
}, byteData, "triangles", "static")
Particle_mesh:setTexture(love.graphics.newImage("timticle.png"))

local Dummy_mesh = love.graphics.newMesh({
   {0, 0, 0, 0},
   {Data_texture_size, 0, 1, 0},
   {0, Data_texture_size, 0, 1},

   {Data_texture_size, 0, 1, 0},
   {0, Data_texture_size, 0, 1},
   {Data_texture_size, Data_texture_size, 1, 1},
}, "strip", "static")

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
      love.graphics.drawInstanced(Particle_mesh, 16)
   love.graphics.setShader()
end