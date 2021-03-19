local utilities = {}
  
-- Collision detection function.
-- Checks if a an d b overlap.
-- w and h mean width and height.
function utilities.checkBoxCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
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
