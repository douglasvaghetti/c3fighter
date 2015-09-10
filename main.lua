function love.load()
	love.physics.setMeter(64) --the height of a meter our worlds will be 64px
	world = love.physics.newWorld(0, 0, true)
	bauru = love.graphics.newImage("gfx/bauru.jpg")
	bicho = love.graphics.newImage("gfx/bicho.jpg")
	celso = love.graphics.newImage("gfx/celso.jpg")
	glauber = love.graphics.newImage("gfx/glauber.jpg")
	pedro = love.graphics.newImage("gfx/pedro.jpg")
	silvia = love.graphics.newImage("gfx/silvia.jpg")
	vagner = love.graphics.newImage("gfx/vagner.jpg")
	ze = love.graphics.newImage("gfx/ze.jpg")
	objects = {}
	print("teste")
	table.insert(objects,loadPlayer(100,300,pedro))
	table.insert(objects,loadPlayer(300,300,bauru))
	for i,v in ipairs(objects) do
		print(i,v)
	end
	COEFICIENTEFORCA = 30
	
end

function love.draw()
	for i,v in ipairs(objects) do

		--love.graphics.draw(v.grafico,v.body:getX()-v.shape:getRadius(),v.body:getY()-v.shape:getRadius())
		v.draw()
		--print(v.body:getX(),v.body:getY())
	end
end

function love.update(dt)
	world:update(dt)
	for i,v in ipairs(objects) do
		if i ~= 1 then 
			x, y = love.mouse.getPosition( )
			local fx,fy = (x-v.body:getX()),(y-v.body:getY())
			v.body:applyForce(fx*5,fy*5)
		end
		local fx = (love.window.getWidth()/2-v.body:getX())*COEFICIENTEFORCA
		local fy = (love.window.getHeight()/2-v.body:getY())*COEFICIENTEFORCA
		v.body:applyForce(fx,fy)
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
	return player
end