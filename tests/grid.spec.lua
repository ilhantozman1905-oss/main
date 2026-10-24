-- Run from repository root with Lua 5.3+ or fengari.
local Grid = dofile("src/shared/Grid.lua")
local count = 0
local function test(name, run)
    run()
    count = count + 1
    print("PASS " .. name)
end
local function near(actual, expected)
    assert(math.abs(actual - expected) < 0.000001, tostring(actual) .. " ~= " .. tostring(expected))
end

test("grid bounds include minimum and exclude maximum", function()
    assert(Grid.cellAt(-32, -32, 4, 16, 16) == 1)
    assert(Grid.cellAt(31.99, 31.99, 4, 16, 16) == 256)
    assert(Grid.cellAt(32, 0, 4, 16, 16) == nil)
    assert(Grid.cellAt(-32.01, 0, 4, 16, 16) == nil)
end)
test("brush intersects neighboring cells at an edge", function()
    local ids = Grid.cellsWithin(0, 0, 1.6, 4, 16, 16)
    assert(#ids == 4)
    local centered = Grid.cellsWithin(2, 2, 1.6, 4, 16, 16)
    assert(#centered == 1)
end)
test("tank cannot overflow and dust is conserved", function()
    local cells = {4, 4}
    local amount = Grid.collect(cells, {1, 2}, 6, 49, 50)
    near(amount, 1)
    near(cells[1] + cells[2] + amount, 8)
end)
test("full tank and negative budget collect nothing", function()
    local cells = {4}
    near(Grid.collect(cells, {1}, 10, 50, 50), 0)
    near(Grid.collect(cells, {1}, -2, 0, 50), 0)
    assert(cells[1] == 4)
end)
test("two cleaners cannot collect the same dust twice", function()
    local cells = {4}
    local a = Grid.collect(cells, {1}, 3, 0, 50)
    local b = Grid.collect(cells, {1}, 3, 0, 50)
    near(a + b, 4)
    near(cells[1], 0)
end)
test("partial cells produce exact deltas", function()
    local cells = {0.2, 4}
    local amount, changes = Grid.collect(cells, {1, 2}, 0.6, 0, 50)
    near(amount, 0.6)
    near(changes[1], 0)
    near(changes[2], 3.6)
end)
test("NaN infinity and non-number coordinates are rejected", function()
    assert(Grid.finiteVector(0, -1, 100))
    assert(not Grid.finiteVector(0/0, 0, 0))
    assert(not Grid.finiteVector(0, math.huge, 0))
    assert(not Grid.finiteVector("0", 0, 0))
end)
test("repeated fractional collection never overfills", function()
    local cells, tank = {}, 0
    for id = 1, 256 do cells[id] = 4 end
    for id = 1, 256 do
        for _ = 1, 10 do
            tank = tank + Grid.collect(cells, {id}, 0.6, tank, 50)
        end
    end
    near(tank, 50)
    local remaining = 0
    for _, dust in ipairs(cells) do assert(dust >= 0); remaining = remaining + dust end
    near(remaining + tank, 1024)
end)
print(string.format("%d tests passed", count))
