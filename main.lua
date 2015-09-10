local socket = require "socket"
local address, port = "localhost", 12345
local entity -- entity is what we'll be controlling
local updaterate = 0.1 -- how long to wait, in seconds, before requesting an update
local t

function love.load()
	bauru = love.graphics.newImage("gfx/bauru.png")
	bicho = love.graphics.newImage("gfx/bicho.png")
	celso = love.graphics.newImage("gfx/celso.png")
	glauber = love.graphics.newImage("gfx/glauber.png")
	pedro = love.graphics.newImage("gfx/pedro.png")
	silvia = love.graphics.newImage("gfx/silvia.png")
	vagner = love.graphics.newImage("gfx/vagner.png")
	ze = love.graphics.newImage("gfx/ze.png")
	objects = {}

	print("teste")
	for i,v in ipairs(objects) do
		print(i,v)
	end
	COEFICIENTEFORCA = 5



	udp = socket.udp()
	udp:settimeout(0)
	udp:setpeername(address, port)
	math.randomseed(os.time()) 
 
	entity = tostring(math.random(99999))
	objects[entity] = loadPlayer(-1,-1,bauru)
	local dg = string.format("%s %s %d %d", entity, 'at', 320, 240)
	--udp:send(dg)
	t = 0 -- (re)set t to 0
end



function love.draw()
	love.graphics.setColor(255,0, 0)
	love.graphics.setLineWidth(10.0)
    love.graphics.circle("line", love.window.getWidth()/2, love.window.getHeight()/2, 300, 100); -- Draw white circle with 100 segments.
	for i,v in ipairs(objects) do
		v.draw()	
	end
end

function love.update(dt)
	local fx = ((love.window.getWidth()/2-objects[entity].x))*COEFICIENTEFORCA
	local fy = ((love.window.getHeight()/2-objects[entity].y))*COEFICIENTEFORCA


	t = t + dt
	if t > updaterate then
		local x, y = 0, 0
		local dg = string.format("%s %s %f %f", entity, 'update', fx, fy)
		udp:send(dg)
		t=t-updaterate -- set t for the next round
	end

	repeat
		data, msg = udp:receive()
 
		if data then 
			ent, cmd, parms = data:match("^(%S*) (%S*) (.*)")
			if cmd == 'at' then
				local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
				assert(x and y) 
				x, y = tonumber(x), tonumber(y)
				if objects[ent] then
					objects[ent].x = x
					objects[ent].y = y
				else
					objects[ent] = loadPlayer(x,y,bauru)
				end
			else
				print("unrecognised command:", cmd)
			end
		elseif msg ~= 'timeout' then 
			error("Network error: "..tostring(msg))
		end
	until not data 
end

local function drawCauda(cauda,tamMax,tamanhoCauda)

	for i,v in ipairs(cauda) do

		love.graphics.setColor(255, 255, 255,math.max((i/tamanhoCauda)*255-20,20))
		love.graphics.circle("fill", v.x, v.y, (tamMax-5)*(i/tamanhoCauda)+5)
	end
end

local function geraFuncaoDraw(grafico,raio,body)
	local escala = 2*raio/grafico:getWidth()
	local cauda = {}
	return  function() 
				drawCauda(cauda,grafico:getWidth()*escala/2,20)
				love.graphics.draw(grafico,body:getX(),body:getY(),body:getAngle(),escala,escala,grafico:getWidth()/2,grafico:getWidth()/2)
				table.insert(cauda,{x=body:getX(),y=body:getY()})
				if #cauda==20 then table.remove(cauda,1) end
	end
end	

function loadPlayer(x,y,grafico)     
	local player = {}
	player.x = x
	player.y = y
	player.draw = geraFuncaoDraw(grafico,40,player.body)     
	return player 
end
