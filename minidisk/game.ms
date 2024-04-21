import "spriteSheetAnimationSystem"
import "listUtil"

clear

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
end function

setupUI = function()
    display(2).mode = displayMode.pixel
    display(2).clear(color.clear)
end function

player = {}
player.x = PLAYERSPAWN.x
player.y = PLAYERSPAWN.y
player.sprite = new Sprite
player.sideimage = file.loadImage("images/character_side.png")
player.frontimage = file.loadImage("images/character_front.png")
player.backimage = file.loadImage("images/character_back.png")
player.sprite.image = player.frontimage
player.flip = 1

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
end function

campfire = {}
campfire.x = 480
campfire.y = 320
campfire.timeLeft = 30
campfire.animationSystem = new spriteSheetAnimationSystem.SpriteSheetAnimationSystem
campfire.animationSystem.init "images/campfire.png", 2, 1
campfire.animationSystem.addAnimation "burn", [[0,0],[1,0]], 4
campfire.animationSystem.switchAnimation "burn"
campfire.sprite = new Sprite
campfire.sprite.scale = [2,2]

campfire.update = function(delta)
    self.timeLeft = self.timeLeft - delta

    self.animationSystem.update delta
    self.sprite.x = self.x
    self.sprite.y = self.y
    self.sprite.image = self.animationSystem.getFrame
end function

drawUI = function
    display(2).clear(color.clear)
    secondsLeft = ceil(campfire.timeLeft)
    if secondsLeft > 0 then
        display(2).print("Fire left: " + secondsLeft + "s", 32, 600, color.orange)
    else
        display(2).print("Game Over", 32, 600, color.orange)
    end if
end function

display(4).sprites.push player.sprite
display(4).sprites.push campfire.sprite

setupBackground
setupUI

gameRunning = true
lastTimestamp = time
while gameRunning
    currentTimestamp = time
    delta = currentTimestamp - lastTimestamp
    lastTimestamp = currentTimestamp
    if key.pressed("q") then gameRunning = false
    if(campfire.timeLeft > 0) then
        player.update delta
        campfire.update delta
        display(4).sprites.sort "y"
        display(4).sprites.reverse
    end if
    drawUI
    yield    
end while

key.clear
clear