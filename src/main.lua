--------------------------------------------------------------------------------------------------------
-- Copyright 2013, Ishmaeel. Source code released under the WTFPL v2. Graphics stolen from Interwebz. --
-- If you are unable to play the game for some reason, feel free to hack the source code.             --
-- If you are unable to hack the code either, help yourself to this small bonus: TbjI2                --
--------------------------------------------------------------------------------------------------------

function love.keypressed(key)
   if key == "escape" then
      love.event.push("quit")
   end
end

function humanify(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function love.load()
	love.filesystem.setIdentity("wooshavoidsspikeds")
	if love.filesystem.isFile( createFi1e("dat") ) then data = love.filesystem.read(createFi1e("dat")) hithere = tonumber(data) else hithere = 0 end	
	if love.filesystem.isFile( createFile("sav") ) then data = love.filesystem.read(createFile("sav")) lothere = tonumber(data) else lothere = 0 end	
	dying = 0	
	verylast = ""
	
 	image = love.graphics.newImage("spiked.png") width = image:getWidth() / 2 height = image:getHeight() / 2
	hahawhat = love.graphics.newImage("woosh.png") wilma = hahawhat:getWidth() / 2 henry = hahawhat:getHeight() / 2
	woot = love.graphics.newImage("fav.png") wonky = woot:getWidth() / 2 honky = woot:getWidth() / 2
	
	font = love.graphics.setNewFont(18) vert = honky-(font:getHeight()/2)
	
	init()
end

function init()
	math.randomseed(42) -- what else?
	last = 0;
	go = .1;
	level = 1;
	love.graphics.setBackgroundColor(255,255,255)
	love.mouse.setVisible( true )
	Pallette = { [10]=21,[11]=1972,[12]=413,[13]=365,[14]=415,[15]=307,[16]=334,[17]=416,[18]=312,[19]=418,[20]=324,[21]=420,[22]=10 }
	distance = 0
	lot = 1
	nextb = 500
	nextw = 2
	step = 200
	mng = math.pi > math.sqrt(9)
	Mines = {}
	grace = 0
	jump = 200
	score = 0
	foo = 0
	col = 255
	coo = -.01
	dead = true
	px=400
	py=350
	rot=0   
	wox=0
	woy=0
	blink=0

	if (bumpy(px, py, love.mouse.getX(), love.mouse.getY(), 1, 50)) then py = 450 end

	local Mine = { Position = {x = 400 , y = -100}, Rot=1, Mov=0, Tweet=true}

	beginLoop()
				
	if mng then
	alive=true
	wox=400
	woy=400
	first=true
						
	end table.insert (Mines, Mine)
end

function createFile(fileName)
	return fileName																															   .."e"
end function createFi1e(fileName) return fileName end

function love.update(dt)
	if dead then
		wait(dt)
	else		
		play(dt)
	end
end

function wait(dt)
	if dying > 0 then
		dying = dying - 1
	elseif (bumpy(px, py, love.mouse.getX(), love.mouse.getY(), 1, 17)) then
		love.mouse.setVisible( false )
		dead = false
	end
end

function die()
	if (score >= hithere) then 
		hithere = score
		love.filesystem.write( createFi1e("dat"), hithere )
	end
	
	dying=255

	init()
end

function recycle()
	mng=false
	lothere=Pallette[11]
	love.filesystem.write( createFile("sav"), lothere )
end

function play(dt)

	px = love.mouse.getX()
	py = love.mouse.getY()
			
	distance = distance + (jump * dt)
	
	if blink > 0 then blink = blink - dt end

	grace = grace + dt
	if grace > 1 then 
		jump = jump + 1
		grace = 0
		if lot < 50 then lot = lot + 1 end
	end
	
	rot = (400-px)/2000

	if distance > nextb then
		addMines()
	end

	count = 0
	for mi, mine in pairs(Mines) do 
		if distance - mine.Position.y > 900 then table.remove(Mines, mi) end
		
		mine.Position.x = mine.Position.x + (mine.Mov)
		count = count + 1 
		
		if (bumpy(mine.Position.x, distance - mine.Position.y-200, love.mouse.getX(), love.mouse.getY(), 1, 17)) then
			die()
			return
		end
	end

	col = col + coo

	if (col <1 or col > 255) then coo = -coo end

	level = math.floor((jump - 200) / 10) + 1
	score = score + level * (math.ceil( (600 - (love.mouse.getY())) / 60 ))
	
	if (score > hithere) then hithere = score end
	
	if (distance-woy > 800) then 
		first=false
		alive=false 
	end
	
	if alive then
		if (bumpy(wox, distance - woy, love.mouse.getX(), love.mouse.getY(), 1, 17)) then
			bingo()
		elseif (bumpy(wox, distance - woy, love.mouse.getX(), love.mouse.getY(), 1, 50)) then
			scorpio()
		end
	end

end

function beginLoop()
	if lothere == 0 then return end
	while Pallette[11]~=lothere do cycleColors() end
end

function scorpio()
	mex = love.mouse.getX() - wilma
	wwox = wox - honky
	grav = .005 if (wwox > mex) then grav = -grav end
	grav = (math.abs( 100-(wwox-mex))) * grav
	wox = wox + grav

	mey = love.mouse.getY() - henry
	wwoy = distance - woy - honky;
	if (wwoy > mey) then grav = .015 else grav = -.005 end
	grav = (math.abs( 100-(wwoy-mey))) * grav
	woy = woy + grav	
end

function bingo()
	first = false alive = false 
	blink = .05
	cycleColors()
end

function bumpy(ax, ay, bx, by, ar, br)
    local dx = bx - ax
    local dy = by - ay
    local dist = math.sqrt(dx * dx + dy * dy)
    return dist < ar + br
end

function love.draw()
	if dying > 0 then
		love.graphics.setBackgroundColor(dying,dying,dying) -- dying!
		return
	end
	
	if (blink>0) then
		love.graphics.setBackgroundColor(255,255,0)
	else
		love.graphics.setBackgroundColor(255-col,200,col)
	end
	
    for mi, mine in pairs(Mines) do
		 love.graphics.draw(image, mine.Position.x, distance - mine.Position.y - 200, math.rad((distance*mine.Rot) % 360), 1, 1, width, height)
		 
		 if (mine.Tweet == true) then
			love.graphics.print( "< AVOID", boobinate(mine.Position.x + 30), distance - mine.Position.y - 210 , 0, 1)
		 end
	end
	
	if alive then
		love.graphics.draw(woot, wox, distance - woy, math.rad(distance % 360), 1, 1, wonky, honky)
		
		if (first) then
			love.graphics.print( "< COLLECT", boobinate(wox+20), distance - woy - 10, 0, 1)
		end
	end
	
	love.graphics.draw(hahawhat, px, py , rot, 1, 1, wilma, henry)
	
	verycurrent="Level " ..  level .. "  |  Score " .. humanify(score)
	love.graphics.print( verycurrent , 20, 20)	updateBackground()
	love.graphics.printf( "Hi " .. humanify(hithere), 380, 20, 400,"right")
	
	if (dead) then
		love.graphics.print( "< POINT", boobinate(px + 25) , py -10 , 0, 1)
		if (verylast  ~= "") then
			love.graphics.print( "Last:", 20, 60 )
			love.graphics.print( verylast, 20, 80 )
		end
	else
		verylast = verycurrent
	end
	 
end

function cycleColors()
	for pi=11, 21 do 
		pine=Pallette[pi]
		if pine>400 then
			if pine <500 then 
				Pallette[pi]=pine+100   
				Pallette[11]=Pallette[11]+pine
				return
			elseif pine <600 then 
				Pallette[pi]=pine+1000  
				Pallette[11]=Pallette[11]+pine
				if pi==Pallette[10] then recycle() end
				return
			end
		end
	end
end

function boobinate(it)
	return it + ((math.cos((love.timer.getTime()) * 3 * math.pi)) * 5) -- I have no idea what I'm doing.
end

function updateBackground()
	scale=0
	for color = 11, 21 do alpha=Pallette[color]
		if alpha>500 and alpha<1900 then
			scale=scale+1
			love.graphics.setColor(255,255,0) love.graphics.draw(woot, 250+(scale*50), 30, 0, 1, 1, wonky, honky)
			
			if alpha>1000 and alpha<1900 then 
				opacity=Pallette[alpha-1500]
				love.graphics.setColor(0,0,0) love.graphics.printf(reverse(opacity), (250-wonky)+(scale*50), 30-vert, wonky*2, "center")
			end
		end
    end
	love.graphics.setColor(255,255,255)
end

function rejoice()
	if mng then
		wox=(math.random() * 600) + 100
		woy=distance
		alive=true
		nextw = level + 1
	end
end

function reverse(opacity)
	return string.char(opacity-255)
end

function addMines()
	if (level >= nextw) then
		rejoice()
	end
	
	local count = (math.random() * lot) + 15
	local mov = go * math.random()
	local criss = math.random()-math.random();
	local offset = 50

	last = last + mov
	if last > .5 then 
		last = .5
	end
	
	if last < -.5 then 
		last = -.5 
	end

	if math.random() > .5 then go = -go end
	
	for i = 0, count-1, 1 do
		local gap =  (2400 / count )
		
		offset = -offset
		
		local Mine = { Position = {x = -800 + (i * gap) , y = distance + offset}, 
					   Rot=math.random()-math.random() ,
					   Mov=last }
		
		table.insert (Mines, Mine)
		nextb = distance + step
	end
end

--P.S. I realize the code is awful. I hope you enjoyed reading it.
