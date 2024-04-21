import "spriteSheetAnimationSystem"
import "listUtil"
import "mathUtil"

clear

print "Loading..."

normaliseVector2 = function(vector)
    abs = sqrt(vector.x * vector.x + vector.y * vector.y)
    if abs != 0 then return {"x" : vector.x / abs,"y": vector.y /abs}
    return {"x": 0, "y": 0}
end function

PLAYERSPAWN = {
    "x": 400,
    "y": 320}

PLAYERSPEED = 100

setupBackground = function()
    display(7).color = color.white
    display(5).clear(color.clear)
    display(3).clear
end function

setupUI = function()
    display(2).mode = displayMode.pixel
    display(2).clear(color.clear)
end function

bgWind = file.loadSound("audio/wind.ogg")

player = {}
player.x = PLAYERSPAWN.x
player.y = PLAYERSPAWN.y
player.sprite = new Sprite
player.sideimage = file.loadImage("images/character_side.png")
player.frontimage = file.loadImage("images/character_front.png")
player.backimage = file.loadImage("images/character_back.png")
player.sprite.image = player.frontimage
player.sprite.localBounds = new Bounds
player.sprite.localBounds.width = 24
player.sprite.localBounds.height = 16
player.sprite.localBounds.y = -16
player.flip = 1
player.sticksCollected = false

player.update = function(delta)
    movementInput = normaliseVector2({"x": key.axis("Horizontal"),"y": key.axis("Vertical")})
    
    flip = player.flip
    if abs(movementInput.y) > abs(movementInput.x) then 
        if movementInput.y > 0 then
            player.sprite.image = player.backimage
        else
            player.sprite.image = player.frontimage
        end if
        player.flip = 1
    else if abs(movementInput.y) < abs(movementInput.x) then
        player.sprite.image = player.sideimage
        if movementInput.x > 0 then
            player.flip = -1
        else
            player.flip = 1
        end if
    end if
    player.sprite.scale = [player.flip, 1]

    player.x = player.x + movementInput.x * PLAYERSPEED * delta
    player.y = player.y + movementInput.y * PLAYERSPEED * delta
    player.sprite.x = player.x
    player.sprite.y = player.y

    if player.sticksCollected then
        if player.sprite.overlaps(campfire.sprite) then
            campfire.fireLevel = [campfire.fireLevel + 5, 30].min
            sticks.randomPosition
            player.sticksCollected = false
        end if
    else
        if player.sprite.overlaps(sticks.sprite) then
            player.sticksCollected = true
        end if
    end if
end function

campfire = {}
campfire.x = 480
campfire.y = 320
campfire.fireLevel = 30
campfire.animationSystem = new spriteSheetAnimationSystem.SpriteSheetAnimationSystem
campfire.animationSystem.init "images/campfire.png", 2, 1
campfire.animationSystem.addAnimation "burn", [[0,0],[1,0]], 4
campfire.animationSystem.switchAnimation "burn"
campfire.sprite = new Sprite
campfire.sprite.localBounds = new Bounds
campfire.sprite.localBounds.width = 32
campfire.sprite.localBounds.height = 16
campfire.sprite.localBounds.y = -16
campfire.sprite.scale = [2,2]


campfire.update = function(delta)
    self.fireLevel = self.fireLevel - delta
    self.animationSystem.update delta
    self.sprite.x = self.x
    self.sprite.y = self.y
    self.sprite.image = self.animationSystem.getFrame
end function

sticks = {}
sticks.x = 0
sticks.y = 0
sticks.sprite = new Sprite
sticks.sprite.image = file.loadImage("images/sticks.png")
sticks.sprite.localBounds = new Bounds
sticks.sprite.localBounds.width = sticks.sprite.image.width
sticks.sprite.localBounds.height = sticks.sprite.image.height
sticks.randomPosition = function()
    xOffset = 100 + ceil(rnd * 300)
    yOffset = 100 + ceil(rnd * 200)
    if rnd > 0.5 then
        self.x = 430 + xOffset    
    else
        self.x = 430 - xOffset
    end if
    if rnd > 0.5 then
        self.y = 320 + yOffset
    else
        self.y = 320 - yOffset
    end if 
end function

sticks.update = function(delta)
    if player.sticksCollected then
        self.sprite.tint = color.clear
    else
        self.sprite.tint = color.white
    end if
    self.sprite.x = self.x
    self.sprite.y = self.y
end function

drawUI = function
    display(2).clear(color.clear)
    fireLevel = ceil(campfire.fireLevel)
    if fireLevel > 0 then
        display(2).print("Firelevel: ", 32, 600, color.orange)
        display(2).color = color.orange
        display(2).fillRect 32, 572, 896 * campfire.fireLevel/30, 16
    else
        display(2).print("Game Over!", 32, 600, color.orange)
        display(2).print("You survived " + round(time - firstTimestamp) + " seconds. Press 'Q' to exit application.", 32, 572, color.orange)
    end if
end function

sticks.randomPosition

display(4).sprites.push player.sprite
display(4).sprites.push campfire.sprite
display(4).sprites.push sticks.sprite

setupBackground
setupUI
bgWind.play

gameRunning = true
lastTimestamp = time
firstTimestamp = time
lastDisplay = true
while gameRunning
    currentTimestamp = time
    delta = currentTimestamp - lastTimestamp
    lastTimestamp = currentTimestamp
    if key.pressed("q") and not lastDisplay then gameRunning = false
    if(campfire.fireLevel > 0) then
        player.update delta
        campfire.update delta
        sticks.update delta
        display(4).sprites.sort "y"
        display(4).sprites.reverse
        drawUI
    else if lastDisplay then
        lastDisplay = false
        drawUI
    end if
    yield    
end while

Sound.stopAll
key.clear
clear