clear

normaliseVector2 = function(vector)
    abs = sqrt(vector.x * vector.x + vector.y * vector.y)
    if abs != 0 then return {"x" : vector.x / abs,"y": vector.y /abs}
    return {"x": 0, "y": 0}
end function

PLAYERSPAWN = {
    "x": 480,
    "y": 320}

PLAYERSPEED = 100

setupBackground = function()
    display(7).color = color.white
    display(5).clear(color.clear)
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

display(4).sprites.push player.sprite
setupBackground

gameRunning = true
lastTimestamp = time
while gameRunning
    currentTimestamp = time
    delta = currentTimestamp - lastTimestamp
    lastTimestamp = currentTimestamp

    if key.pressed("q") then gameRunning = false
    player.update delta
    yield    
end while

key.clear
clear