grid_size = 32
cell_size = 10
cell_gap = 2

grid = {}
for i=1,grid_size do
  grid[i] = {}
  for j = 1,grid_size do
    grid[i][j] = 0
  end
end
screen_side = grid_size * (cell_size + cell_gap) + cell_gap
love.window.setMode(screen_side, screen_side)

function love.load()
  iter = 0
  paused = false
end

function iterate()
  new_grid = {}
  for y,xk in ipairs(grid) do
    new_grid[y] = {}
    for x,v in ipairs(xk) do
      if v == 1 then
        if getNeighbors(x, y) == 2 or getNeighbors(x, y) == 3 then
          new_grid[y][x] = 1
        else
          new_grid[y][x] = 0
        end
      elseif v == 0 then
        if getNeighbors(x, y) == 3 then
          new_grid[y][x] = 1
        else
          new_grid[y][x] = 0
        end
      end
    end
  end
  grid = new_grid
  iter = iter + 1
end

function love.update(dt)
  love.timer.sleep(0.1)
  if not paused then iterate() end
end

function love.keyreleased(key)
  if key == "space" then paused = not paused end
end

function love.mousepressed(x, y, button, isTouch)
  
end

function getFromGrid(x, y)
  if x == 0 then
    x = grid_size
  elseif x == grid_size + 1 then
    x = 1
  end
  if y == 0 then
    y = grid_size
  elseif y == grid_size + 1 then
    y = 1
  end
  return grid[y][x]
end

function getNeighbors(x, y)
  return
    getFromGrid(x-1, y-1) + getFromGrid(x, y-1) + getFromGrid(x+1, y-1) +
    getFromGrid(x-1, y) + getFromGrid(x+1, y) +
    getFromGrid(x-1, y+1) + getFromGrid(x, y+1) + getFromGrid(x+1, y+1)
end

function love.draw()
  for y,xk in ipairs(grid) do
    for x,v in ipairs(xk) do
      if v == 1 then love.graphics.setColor(0, 200, 200) else love.graphics.setColor(50, 50, 50) end
      love.graphics.rectangle("fill", cell_gap + (cell_gap + cell_size) * (x - 1), cell_gap + (cell_gap + cell_size) * (y - 1), cell_size, cell_size)
    end
  end
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(iter, cell_gap, cell_gap)
end
