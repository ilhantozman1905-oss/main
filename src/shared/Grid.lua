--!strict
-- Pure grid math. No Parts, networking, or Roblox services.
local Grid = {}

function Grid.index(column, row, columns)
    return (row - 1) * columns + column
end

function Grid.cellAt(x, z, cellSize, columns, rows)
    local column = math.floor((x + columns * cellSize / 2) / cellSize) + 1
    local row = math.floor((z + rows * cellSize / 2) / cellSize) + 1
    if column < 1 or column > columns or row < 1 or row > rows then return nil end
    return Grid.index(column, row, columns)
end

function Grid.cellsWithin(x, z, radius, cellSize, columns, rows)
    local result = {}
    for row = 1, rows do
        for column = 1, columns do
            local left = (column - 1) * cellSize - columns * cellSize / 2
            local top = (row - 1) * cellSize - rows * cellSize / 2
            local nearestX = math.max(left, math.min(x, left + cellSize))
            local nearestZ = math.max(top, math.min(z, top + cellSize))
            if (nearestX - x)^2 + (nearestZ - z)^2 <= radius^2 then
                table.insert(result, Grid.index(column, row, columns))
            end
        end
    end
    return result
end

function Grid.collect(cells, ids, budget, tank, capacity)
    local remaining = math.max(0, math.min(budget, capacity - tank))
    local collected, changes = 0, {}
    for _, id in ipairs(ids) do
        local available = cells[id] or 0
        local amount = math.min(available, remaining)
        if amount > 0 then
            cells[id] = available - amount
            changes[id] = cells[id]
            remaining = remaining - amount
            collected = collected + amount
        end
        if remaining <= 0 then break end
    end
    return collected, changes
end

function Grid.finiteVector(x, y, z)
    for _, value in ipairs({x, y, z}) do
        if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then
            return false
        end
    end
    return true
end

return Grid
