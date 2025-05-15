local collision = {
    IdList = {}  
}
     function collision.RemoveId(isGroup,IDIDID)
        if isGroup == true then
            table.remove(collision.GroupList,IDIDID)

        else
            table.remove(IdList,IDIDID)
        end
    end
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

    collision.GroupList = {}


local function getElementById(ID)
    return collision.IdList[ID]
end

local function distance(x1,y1,x2,y2)
    return math.sqrt((x2-x1)^2+(y2-y1)^2)
end

function collision.CreateRectHitbox(x, y, width, height, id)
    collision.IdList[id] = { x = x, y = y, width = width, height = height }
end

function collision.CreateCircHitbox(x, y, radius, id)
    collision.IdList[id] = { x = x, y = y, radius = radius, shape = "circle" }
end

function collision.objectTouch(id1, id2)
        local function distance(x1, y1, x2, y2)
        return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
        end

    -- Rectangle-Rectangle
    local function rectRect(r1, r2)
        return r1.x < r2.x + r2.width and
               r1.x + r1.width > r2.x and
               r1.y < r2.y + r2.height and
               r1.y + r1.height > r2.y
    end

    -- Circle-Circle
    local function circCirc(c1, c2)
        return distance(c1.x, c1.y, c2.x, c2.y) < (c1.radius + c2.radius)
    end

    -- Rectangle-Circle
    local function rectCirc(rect, circ)
        local closestX = math.max(rect.x, math.min(circ.x, rect.x + rect.width))
        local closestY = math.max(rect.y, math.min(circ.y, rect.y + rect.height))
        return distance(closestX, closestY, circ.x, circ.y) < circ.radius
    end

    -- Polygon Helper: Convert flat vertex list to { {x, y}, ... }
    local function getPolyPoints(poly)
        local points = {}
        for i = 1, #poly.vertices - 1, 2 do
            table.insert(points, { poly.vertices[i], poly.vertices[i + 1] })
        end
        return points
    end

    -- Polygon collision using SAT (simplified)
    local function projectPolygon(axis, points)
        local min = (points[1][1] * axis[1] + points[1][2] * axis[2])
        local max = min
        for i = 2, #points do
            local p = points[i][1] * axis[1] + points[i][2] * axis[2]
            if p < min then min = p end
            if p > max then max = p end
        end
        return min, max
    end

    local function polygonsOverlap(p1, p2)
        for _, poly in ipairs({p1, p2}) do
            for i = 1, #poly do
                local j = (i % #poly) + 1
                local edge = {
                    poly[j][1] - poly[i][1],
                    poly[j][2] - poly[i][2]
                }
                -- perpendicular axis
                local axis = { -edge[2], edge[1] }

                local min1, max1 = projectPolygon(axis, p1)
                local min2, max2 = projectPolygon(axis, p2)
                if max1 < min2 or max2 < min1 then
                    return false
                end
            end
        end
        return true
    end

    -- Polygon-Polygon
    local function polyPoly(p1, p2)
        return polygonsOverlap(getPolyPoints(p1), getPolyPoints(p2))
    end

    -- Polygon-Circle
    local function polyCirc(poly, circ)
        local polyPoints = getPolyPoints(poly)
        -- Check if circle center is inside polygon
        if pointInPolygon(circ.x, circ.y, poly.vertices) then return true end
        -- Check distance to edges
        for i = 1, #polyPoints do
            local j = (i % #polyPoints) + 1
            local x1, y1 = polyPoints[i][1], polyPoints[i][2]
            local x2, y2 = polyPoints[j][1], polyPoints[j][2]
            local dx, dy = x2 - x1, y2 - y1
            local len = math.sqrt(dx * dx + dy * dy)
            local dot = ((circ.x - x1) * dx + (circ.y - y1) * dy) / (len * len)
            local closestX = x1 + dot * dx
            local closestY = y1 + dot * dy
            if distance(closestX, closestY, circ.x, circ.y) <= circ.radius then
                return true
            end
        end
        return false
    end

    -- Polygon-Rectangle
    local function polyRect(poly, rect)
        local rectPoly = {
            vertices = {
                rect.x, rect.y,
                rect.x + rect.width, rect.y,
                rect.x + rect.width, rect.y + rect.height,
                rect.x, rect.y + rect.height
            },
            shape = "polygon"
        }
        return polyPoly(poly, rectPoly)
    end
    local ids1 = resolveToIds(id1)
    local ids2 = resolveToIds(id2)

    for _, aId in ipairs(ids1) do
        for _, bId in ipairs(ids2) do
            if aId ~= bId then
                local a = getElementById(aId)
                local b = getElementById(bId)
                if a and b then
                    local shapeA = a.shape or "rect"
                    local shapeB = b.shape or "rect"
                    if shapeA == "rect" and shapeB == "rect" and rectRect(a, b) then return true end
                    if shapeA == "circle" and shapeB == "circle" and circCirc(a, b) then return true end
                    if shapeA == "rect" and shapeB == "circle" and rectCirc(a, b) then return true end
                    if shapeA == "circle" and shapeB == "rect" and rectCirc(b, a) then return true end
                    if shapeA == "polygon" and shapeB == "polygon" and polyPoly(a, b) then return true end
                    if shapeA == "polygon" and shapeB == "circle" and polyCirc(a, b) then return true end
                    if shapeA == "circle" and shapeB == "polygon" and polyCirc(b, a) then return true end
                    if shapeA == "polygon" and shapeB == "rect" and polyRect(a, b) then return true end
                    if shapeA == "rect" and shapeB == "polygon" and polyRect(b, a) then return true end
                end
            end
        end
    end

    return false
end

function collision.ChangeValue(id, ...)
    local obj = getElementById(id)
    if not obj then return end

    if obj.shape == "circle" then
        local newX, newY, newRadius = ...
        obj.x = newX
        obj.y = newY
        obj.radius = newRadius

    elseif obj.shape == "polygon" then
        local newVertices = ...
        if type(newVertices) == "table" then
            obj.vertices = newVertices
        end

    else -- default: rectangle
        local newX, newY, newWidth, newHeight = ...
        obj.x = newX
        obj.y = newY
        obj.width = newWidth
        obj.height = newHeight
    end
end

function collision.CheckClick(id)
    local function isClicked(obj)
        local mouseX = love.mouse.getX()
        local mouseY = love.mouse.getY()
        local shape = obj.shape or "rect"

        if shape == "rect" then
            return mouseX > obj.x and mouseX < obj.x + obj.width and
                   mouseY > obj.y and mouseY < obj.y + obj.height

        elseif shape == "circle" then
            local dx = mouseX - obj.x
            local dy = mouseY - obj.y
            return math.sqrt(dx*dx + dy*dy) <= obj.radius

        elseif shape == "polygon" then
            return pointInPolygon(mouseX, mouseY, obj.vertices)
        end

        return false
    end

    local function resolveToIds(id)
        if collision.GroupList and collision.GroupList[id] then
            return collision.GroupList[id]
        else
            return { id }
        end
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

function collision.CreatePolygonHitbox(vertices, id)
    collision.IdList[id] = { vertices = vertices, shape = "polygon" }
end

return collision
