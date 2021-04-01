local utilities = {}
  
-- Collision detection function.
-- Checks if a an d b overlap.
-- w and h mean width and height.
function utilities.checkBoxCollision(ax1,ay1,aw,ah,bx1,by1,bw,bh)
  return ax1 < (bx1 + bw) and 
         (ax1 + aw) > bx1 and 
         ay1 < (by1 + bh) and 
         (ay1 + ah) > by1
end

function utilities.checkBoxCollisionC(a,b)
  return a:getX() < (b:getX() + b:getWidth()) and 
        (a:getX() + a:getWidth()) > b:getX() and 
         a:getY() < (b:getY() + b:getHeight()) and 
        (a:getY() + a:getHeight()) > b:getY()
end

function utilities.gradientMesh(dir, ...)
    -- Check for direction
    local isHorizontal = true
    if dir == "vertical" then
        isHorizontal = false
    elseif dir ~= "horizontal" then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    -- Check for colors
    local colorLen = select("#", ...)
    if colorLen < 2 then
        error("color list is less than two", 2)
    end

    -- Generate mesh
    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {x, 1, x, 1, color[1], color[2], color[3], color[4] or 1}
            meshData[#meshData + 1] = {x, 0, x, 0, color[1], color[2], color[3], color[4] or 1}
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3], color[4] or 1}
            meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3], color[4] or 1}
        end
    end

    -- Resulting Mesh has 1x1 image size
    return love.graphics.newMesh(meshData, "strip", "static")
end

return utilities
