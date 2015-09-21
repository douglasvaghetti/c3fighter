socket = require "socket"

udp = socket.udp()

function love.load(args)
	graficos = {
		bauru = love.graphics.newImage("gfx/bauru.png"),
		bicho = love.graphics.newImage("gfx/bicho.png"),
		celso = love.graphics.newImage("gfx/celso.png"),
		glauber = love.graphics.newImage("gfx/glauber.png"),
		pedro = love.graphics.newImage("gfx/pedro.png"),
		silvia = love.graphics.newImage("gfx/silvia.png"),
		vagner = love.graphics.newImage("gfx/vagner.png"),
		ze = love.graphics.newImage("gfx/ze.png")
	}

	for i,v in pairs(graficos) do 
		print (i,v)
	end
	local teste = "bauru"
	print (graficos[teste])

	udp:settimeout(0)
	udp:setsockname('*', 12345)
	jogadores = {} 
	data, msg_or_ip, port_or_nil = udp:receivefrom()

	love.physics.setMeter(64) --the height of a meter our worlds will be 64px
	world = love.physics.newWorld(0, 0, true)
	COEFICIENTEFORCA = 1
end

function love.update(dt)
	repeat
		data, msg_or_ip, port_or_nil = udp:receivefrom()
		if data then
			entity, cmd, parms = data:match("^(%S*) (%S*) (.*)")		
			if cmd == 'update' then
				local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
				assert(x and y) -- validation is better, but asserts will serve.
				x, y = tonumber(x), tonumber(y)
				print("rodando update, entity = ",entity,"fx = ",x,"fy =",y)
				jogadores[entity].fx = x
				jogadores[entity].fy = y
				for k, v in pairs(jogadores) do
					udp:sendto(string.format("%s %s %d %d", k, 'at', v.body:getX(), v.body:getY()), msg_or_ip,  port_or_nil)
				end
			elseif cmd =='init' then
				local nome = parms:match("^(%S*)$")
				print("recebeu init, nome ='"..nome.."' entidade = ",entity)
				local angulo = (math.random(360)/180.0)*math.pi
				jogadores[entity] = loadPlayer(love.window.getWidth()/2+math.cos(angulo)*100,love.window.getHeight()/2+math.sin(angulo)*10,graficos[nome])
				for k, v in pairs(jogadores) do
					udp:sendto(string.format("%s %s %d %d", k, 'at', v.body:getX(), v.body:getY()), msg_or_ip,  port_or_nil)
				end
			elseif msg_or_ip ~= 'timeout' then
				error("Unknown network error: "..tostring(msg))
			else	
				print("unrecognised command:", cmd)
			end
		end
	until not data

	world:update(dt)
	for i,v in pairs(jogadores) do
		v.body:applyForce(v.fx,v.fy)
		local fx = (love.window.getWidth()/2-v.body:getX())*COEFICIENTEFORCA
		local fy = (love.window.getHeight()/2-v.body:getY())*COEFICIENTEFORCA
		v.body:applyForce(fx+v.fx,fy+v.fy)
	end
end

function love.draw()
	love.graphics.setColor(255,0, 0)
	love.graphics.setLineWidth(10.0)
    love.graphics.circle("line", love.window.getWidth()/2, love.window.getHeight()/2, 300, 100); -- Draw white circle with 100 segments.
	for i,v in pairs(jogadores) do
		v.draw()	
	end
end

local function drawCauda(cauda,tamMax,tamanhoCauda)
	for i,v in ipairs(cauda) do
		love.graphics.setColor(255, 255, 255,math.max((i/tamanhoCauda)*255-20,20))
		love.graphics.circle("fill", v.x, v.y, (tamMax-5)*(i/tamanhoCauda)+5)
		--print ("i = "..i.." "..math.max((i/tamanhoCauda)*255-20,20))
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

function loadPlayer(posx,posy,grafico)
	local player = {}
	player.body = love.physics.newBody(world, posx, posy, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
	player.shape = love.physics.newCircleShape(40) --the ball's shape has a radius of 20
	player.fixture = love.physics.newFixture(player.body, player.shape, 1) -- Attach fixture to body and give it a density of 1.
	player.fixture:setRestitution(0.9) --let the ball bounce
	player.draw = geraFuncaoDraw(grafico,40,player.body)
	player.fx = 0
	player.fy = 0
	return player
end