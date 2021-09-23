-------------------------------------------------------------------------------------------------------------
-- Copyright 2013-2021, Ishmaeel. Source code released under the WTFPL v2. Graphics stolen from Interwebz.
-- Last modified: 2021.09.23
-------------------------------------------------------------------------------------------------------------

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit")
  end
end

-- Inserts thousand separators into a number.
-- Stolen from http://lua-users.org/wiki/FormattingNumbers
function formatNumber(amount)
  local formatted = amount
  local k
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function readNumber(file)
  local fileInfo = love.filesystem.getInfo(file)
  if fileInfo and fileInfo.type == "file" then
      local data = love.filesystem.read(file)
      return data and tonumber(data) or 0
  end
  return 0
end

function love.load()
  love.filesystem.setIdentity("wooshavoidsspikeds")

  highScore = readNumber("dat")
  missionMarker = readNumber("save")

  dying = 0
  previousScoreText = ""

  mineSprite = love.graphics.newImage("spiked.png")
  mineWidth = mineSprite:getWidth() / 2
  mineHeight = mineSprite:getHeight() / 2

  shipSprite = love.graphics.newImage("woosh.png")
  shipWidth = shipSprite:getWidth() / 2
  shipHeight = shipSprite:getHeight() / 2

  starSprite = love.graphics.newImage("fav.png")
  starWidth = starSprite:getWidth() / 2
  starHeight = starSprite:getWidth() / 2

  font = love.graphics.setNewFont(18)
  starPadding = starHeight-(font:getHeight()/2)

  init()
end

function init()
  math.randomseed(42) -- what else?
  lastVerticalSpeed = 0;
  verticalDirection = .1;
  level = 1;
  love.mouse.setVisible( true )
  hiddenCodeData = { [10]=21,[11]=1972,[12]=413,[13]=365,[14]=415,[15]=307,[16]=334,[17]=416,[18]=312,[19]=418,[20]=324,[21]=420,[22]=10 }
  distanceTraveled = 0
  mineDensity = 1
  nextSpawnDistance = 500
  nextStarLevel = 2
  mineBatchDistance = 200
  shouldSpawnStar = true
  Mines = {}
  speedUpCounter = 0
  shipSpeed = 200
  score = 0
  backgroundColorValue = 1
  backgroundColorChange = -.0001
  isPlayerDead = true
  shipPosX=400
  shipPosY=350
  shipOrientation=0
  starPosX=0
  starPosY=0
  starFlash=0

  -- If the default ship location is already under the mouse, move the ship somewhere else.
  if (detectCollision(shipPosX, shipPosY, love.mouse.getX(), love.mouse.getY(), 1, 50)) then
    shipPosY = 450
  end

  local Mine = { Position = {x = 400 , y = -100}, RotationSpeed=1, VerticalSpeed=0, ShowTutorial=true}

  checkForMissionComplete()

  if shouldSpawnStar then
    isStarAlive=true
    starPosX=400
    starPosY=400
    isFirstStar=true
  end

  table.insert (Mines, Mine)
end

function love.update(dt)
  if isPlayerDead then
    wait(dt)
  else
    play(dt)
  end
end

function wait(dt)
  if dying > 0 then
    dying = dying - (2 * dt)
  elseif (detectCollision(shipPosX, shipPosY, love.mouse.getX(), love.mouse.getY(), 1, 17)) then
    love.mouse.setVisible( false )
    isPlayerDead = false
  end
end

function die()
  if (score >= highScore) then
    highScore = score
    love.filesystem.write("dat", highScore )
  end

  dying=1

  init()
end

function missionComplete()
  shouldSpawnStar=false
  missionMarker=hiddenCodeData[11]
  love.filesystem.write(  "save" , missionMarker )
end

function play(dt)

  shipPosX = love.mouse.getX()
  shipPosY = love.mouse.getY()

  distanceTraveled = distanceTraveled + (shipSpeed * dt)

  if starFlash > 0 then starFlash = starFlash - dt end

  speedUpCounter = speedUpCounter + dt
  if speedUpCounter > 1 then
    shipSpeed = shipSpeed + 1
    speedUpCounter = 0
    if mineDensity < 50 then mineDensity = mineDensity + 1 end
  end

  shipOrientation = (400-shipPosX)/2000

  if distanceTraveled > nextSpawnDistance then
    addMines()
  end

  mineCount = 0
  for mi, mine in pairs(Mines) do
    if distanceTraveled - mine.Position.y > 900 then table.remove(Mines, mi) end

    mine.Position.x = mine.Position.x + (mine.VerticalSpeed)
    mineCount = mineCount + 1

    if (detectCollision(mine.Position.x, distanceTraveled - mine.Position.y-200, love.mouse.getX(), love.mouse.getY(), 1, 17)) then
      die()
      return
    end
  end

  backgroundColorValue = backgroundColorValue + backgroundColorChange

  if (backgroundColorValue <0 or backgroundColorValue > 1) then backgroundColorChange = -backgroundColorChange end

  level = math.floor((shipSpeed - 200) / 10) + 1
  score = score + level * (math.ceil( (600 - (love.mouse.getY())) / 60 ))

  if (score > highScore) then highScore = score end

  if (distanceTraveled-starPosY > 800) then
    isFirstStar=false
    isStarAlive=false
  end

  if isStarAlive then
    if (detectCollision(starPosX, distanceTraveled - starPosY, love.mouse.getX(), love.mouse.getY(), 1, 17)) then
      collectStar()
    elseif (detectCollision(starPosX, distanceTraveled - starPosY, love.mouse.getX(), love.mouse.getY(), 1, 50)) then
      useStarMagnet()
    end
  end

end

function checkForMissionComplete()
  if missionMarker == 0 then
    return
  end

  while hiddenCodeData[11]~=missionMarker do
    updateHiddenCodeData()
  end
end

function useStarMagnet()
  gravityX = .005
  mouseX = love.mouse.getX()
  starX = starPosX
  if (starX > mouseX) then gravityX = -gravityX end
  gravityX = (math.abs( 100-(starX-mouseX))) * gravityX
  starPosX = starPosX + gravityX

  gravityY = 0
  mouseY = love.mouse.getY()
  starY = distanceTraveled - starPosY
  if (starY > mouseY) then gravityY = .015 else gravityY = -.005 end
  gravityY = (math.abs( 100-(starY-mouseY))) * gravityY
  starPosY = starPosY + gravityY
end

function collectStar()
  isFirstStar = false
  isStarAlive = false
  starFlash = .05
  updateHiddenCodeData()
end

function detectCollision(ax, ay, bx, by, ar, br)
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

  if (starFlash>0) then
    love.graphics.setBackgroundColor(1,1,0)
  else
    love.graphics.setBackgroundColor(1-backgroundColorValue, 0.78, backgroundColorValue)
  end

  for _, mine in pairs(Mines) do
    love.graphics.draw(mineSprite, mine.Position.x, distanceTraveled - mine.Position.y - 200, math.rad((distanceTraveled*mine.RotationSpeed) % 360), 1, 1, mineWidth, mineHeight)

    if (mine.ShowTutorial == true) then
      love.graphics.print( "< AVOID", addBounce(mine.Position.x + 30), distanceTraveled - mine.Position.y - 210 , 0, 1)
    end
  end

  if isStarAlive then
    love.graphics.draw(starSprite, starPosX, distanceTraveled - starPosY, math.rad(distanceTraveled % 360), 1, 1, starWidth, starHeight)

    if (isFirstStar) then
      love.graphics.print( "< COLLECT", addBounce(starPosX+20), distanceTraveled - starPosY - 10, 0, 1)
    end
  end

  love.graphics.draw(shipSprite, shipPosX, shipPosY , shipOrientation, 1, 1, shipWidth, shipHeight)

  currentScoreText="Level " ..  level .. "  |  Score " .. formatNumber(score)

  love.graphics.print( currentScoreText , 20, 20)

  drawHiddenCodeStars()

  love.graphics.printf( "Hi " .. formatNumber(highScore), 380, 20, 400, "right")

  if (isPlayerDead) then
    love.graphics.print( "< POINT", addBounce(shipPosX + 25) , shipPosY -10 , 0, 1)
    if (previousScoreText  ~= "") then
      love.graphics.print( "Last:", 20, 60 )
      love.graphics.print( previousScoreText, 20, 80 )
    end
  else
    previousScoreText = currentScoreText
  end

end

function updateHiddenCodeData()
  for index=11, 21 do
    codeData=hiddenCodeData[index]
    if codeData>400 then
      if codeData <500 then
        hiddenCodeData[index]=codeData+100
        hiddenCodeData[11]=hiddenCodeData[11]+codeData
        return
      elseif codeData <600 then
        hiddenCodeData[index]=codeData+1000
        hiddenCodeData[11]=hiddenCodeData[11]+codeData
        if index==hiddenCodeData[10] then
          missionComplete()
        end
        return
      end
    end
  end
end

function addBounce(value)
  return value + ((math.cos((love.timer.getTime()) * 3 * math.pi)) * 5) -- I have no idea what I'm doing.
end

function drawHiddenCodeStars()
  codeStarPosition=0
  for arrayIndex = 11, 21 do dataValue = hiddenCodeData[arrayIndex]
    if dataValue>500 and dataValue<1900 then
      codeStarPosition=codeStarPosition+1
      love.graphics.setColor(1,1,0)
      love.graphics.draw(starSprite, 250+(codeStarPosition*50), 30, 0, 1, 1, starWidth, starHeight)

      if dataValue>1000 and dataValue<1900 then
        obfuscatedCodeChar = hiddenCodeData[dataValue-1500]
        realCodeChar = string.char(obfuscatedCodeChar-255)

        love.graphics.setColor(0,0,0)
        love.graphics.printf(realCodeChar, (250-starWidth)+(codeStarPosition*50), 30-starPadding, starWidth*2, "center")
      end
    end
  end
  love.graphics.setColor(1,1,1)
end

function spawnStar()
  if shouldSpawnStar then
    starPosX=(math.random() * 600) + 100
    starPosY=distanceTraveled
    isStarAlive=true
    nextStarLevel = level + 1
  end
end

function addMines()
  if (level >= nextStarLevel) then
    spawnStar()
  end

  local mineCount = (math.random() * mineDensity) + 15
  local verticalSpeedChange = verticalDirection * math.random()
  local offset = 50

  lastVerticalSpeed = lastVerticalSpeed + verticalSpeedChange
  if lastVerticalSpeed > .5 then
    lastVerticalSpeed = .5
  end

  if lastVerticalSpeed < -.5 then
    lastVerticalSpeed = -.5
  end

  if math.random() > .5 then verticalDirection = -verticalDirection end

  for i = 0, mineCount-1, 1 do
    local gap =  (2400 / mineCount )

    offset = -offset

    local Mine = { Position = {x = -800 + (i * gap) , y = distanceTraveled + offset},
      RotationSpeed=math.random()-math.random() ,
      VerticalSpeed=lastVerticalSpeed }

    table.insert (Mines, Mine)
    nextSpawnDistance = distanceTraveled + mineBatchDistance
  end
end