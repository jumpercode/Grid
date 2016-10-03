-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local akeys = {a=true, up=true, down=true, right=true, left=true}
local keys = {a=false, up=false, down=false, right=false, left=false}

local minX = 1      -- Min y Max Grid Map
local maxX = 12     -- X: 800 / 64 = 12
local minY = 1      -- Y: 600 / 64 = 9
local maxY = 9
local zones = {}    -- Zonas de movimiento posible
local sel = nil     -- Unidad Seleccionada

local last = 0

local ip = "res/img/"

local units = {}

local fondo = display.newImageRect(ip .. "fondo.png", 800, 600)
fondo.x = display.contentCenterX
fondo.y = display.contentCenterY

local caballero = display.newImageRect(ip .. "caballero.png", 64, 64)
caballero.px = 6        -- Pos X = 6 -> (6*64)-32
caballero.py = 4        -- Pos Y = 4 -> (4*64)-32
caballero.mov = 3       -- Maximos puntos de movimientp
caballero.status = 0    -- 0: Esperando, 1: Moviendo, 2: Usado

local cursor = display.newImageRect(ip .. "cursor.png", 64, 64)
cursor.px = 1
cursor.py = 1
cursor.status = 0       -- O: Libre, 1: Seleccionado, 2: Esperando

local debug = display.newText(cursor.px .. " " .. cursor.py, 100, 100, 200, 200, native.systemFontBold, 12)
debug:setFillColor(1, 0, 0)

units.caballero = caballero
units.cursor = cursor

local function clearZones()

    for i,v in ipairs(zones) do
        zones[i]:removeSelf()
        zones[i] = nil
    end

    zones = {}

end

local function getUnit(px, py)

    res = nil

    for k,v in pairs(units) do

        if(k ~= "cursor") then
            if(v.px == px and v.py == py and v.status == 0 ) then
                res = v
                break
            end
        end

    end

    return res

end

local function zona(px, py)

    local uni = getUnit(px, py)

    clearZones()

    if(uni ~= nil) then

        for i=(-1*uni.mov),uni.mov do

            for j=(-1*uni.mov), uni.mov do

                if( (math.abs(i)+math.abs(j)) <= uni.mov ) then

                    if( uni.px+i <= maxX and uni.px+i >= minX and uni.py+j <= maxY and uni.py+j >= minY ) then

                        if(i ~= 0 or j ~= 0) then
                            local zon = display.newImageRect(ip .. "zon.png", 64, 64)
                            zon.px = uni.px+i
                            zon.py = uni.py+j
                            table.insert( zones, zon )
                        end

                    end

                end


            end

        end

        cursor.status = 1
        sel = uni

    else

        cursor.status = 0
        sel = nil

    end

end

function posible(px, py)

    local res = false

    for i,v in ipairs(zones) do

        if(v.px == px and v.py == py) then
            res = true
        end

    end

    return res

end

function mover(px, py)

    if(posible(px, py)) then
        sel.px = px
        sel.py = py
        clearZones()
        cursor.status = 2
        sel.status = 1
    else
        clearZones()
        cursor.status = 0
        sel = nil
    end

end

local function keyControl(event)

    if(akeys[event.keyName]) then
        if(event.phase == "down") then
            keys[event.keyName] = true
        else
            keys[event.keyName] = false
        end

    end

end

local function gameLoop()

    local actu = system.getTimer()

    if(actu - last > 120) then

        if(cursor.status == 0 or cursor.status == 1) then

            if(keys.a and cursor.status == 0) then
                zona(cursor.px, cursor.py)
            elseif(keys.a and cursor.status == 1) then
                mover(cursor.px, cursor.py)
            elseif(keys.up and cursor.py > minY) then
                cursor.py = cursor.py - 1
            elseif(keys.down and cursor.py < maxY) then
                cursor.py = cursor.py + 1
            elseif(keys.left and cursor.px > minX) then
                cursor.px = cursor.px - 1
            elseif(keys.right and cursor.px < maxX) then
                cursor.px = cursor.px + 1
            end

            last = actu
        end
    end

    if(cursor.status == 0 or cursor.status == 1) then
        for k,v in pairs(units) do
            v.x = (v.px*64)-32
            v.y = (v.py*64)-32
        end

        for k,v in pairs(zones) do
            v.x = (v.px*64)-32
            v.y = (v.py*64)-32
        end
    else

        local tx = (sel.px*64)-32

        if(sel.x == tx) then

            local ty = (sel.py*64)-32

            if(ty == sel.y) then
                sel.status = 0
                sel = nil
                cursor.status = 0
            else
                local dif = (sel.y - ty)
                print(ty, sel.y, dif)
                if(math.abs(dif) < 1 ) then
                    sel.y = ty
                else
                    sel.y = sel.y - (dif/10)
                end
            end


        else

            local dif = (sel.x - tx)

            if(math.abs(dif) < 1 ) then
                sel.x = tx
            else
                sel.x = sel.x - (dif/10)
            end

        end

    end

    debug.text = cursor.px .. " " .. cursor.py

end

local gameTimer = timer.performWithDelay( 16, gameLoop, 0)
Runtime:addEventListener("key", keyControl)
