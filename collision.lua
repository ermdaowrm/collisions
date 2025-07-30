local collision = {
    IdList = {},
    GroupList = {}
}

function collision.CreateGroup(id, idList)
    collision.GroupList[id] = idList
end

local function resolveToIds(id)
    if collision.GroupList[id] then
        return collision.GroupList[id]
    else
        return { id }
    end
end

local function getElementById(ID)
    return collision.IdList[ID]
end

function collision.CreateRectHitbox(x, y, width, height, id)
    collision.IdList[id] = { x = x, y = y, width = width, height = height }
end

function collision.objectTouch(id1, id2)
    local function rectRect(r1, r2)
        return r1.x < r2.x + r2.width and
               r1.x + r1.width > r2.x and
               r1.y < r2.y + r2.height and
               r1.y + r1.height > r2.y
    end

    local ids1 = resolveToIds(id1)
    local ids2 = resolveToIds(id2)

    for _, aId in ipairs(ids1) do
        for _, bId in ipairs(ids2) do
            if aId ~= bId then
                local a = getElementById(aId)
                local b = getElementById(bId)
                if a and b and rectRect(a, b) then
                    return true
                end
            end
        end
    end

    return false
end

function collision.ChangeValue(id, newX, newY, newWidth, newHeight)
    local obj = getElementById(id)
    if not obj then return end

    obj.x = newX
    obj.y = newY
    obj.width = newWidth
    obj.height = newHeight
end

function collision.CheckClick(id)
    local function isClicked(obj)
        local mouseX = love.mouse.getX()
        local mouseY = love.mouse.getY()

        return mouseX > obj.x and mouseX < obj.x + obj.width and
               mouseY > obj.y and mouseY < obj.y + obj.height
    end

    if love.mouse.isDown(1) then
        for _, singleId in ipairs(resolveToIds(id)) do
            local obj = getElementById(singleId)
            if obj and isClicked(obj) then
                return true
            end
        end
    end

    return false
end

return collision
