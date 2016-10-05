table = require("table")

grid_size = 32
cell_size = 15
cell_gap = 2

delay = 0.05

Cell = {
  gx = 0,
  gy = 0,
  x = 0,
  y = 0,
  v = 0,
  color_hover = {75, 75, 75},
  color_on = {0, 200, 200},
  color_off = {50, 50, 50}
}

pressed = {
  space = false,
  f = false,
}

function gridToXY(gx, gy)
  return {
    (gx - 1) * (cell_size + cell_gap) + cell_gap,
    (gy - 1) * (cell_size + cell_gap) + cell_gap
  }
end

function Cell:new(x, y)
  o = {}
  o.gx = x
  o.gy = y
  o.x = gridToXY(o.gx, o.gy)[1]
  o.y = gridToXY(o.gx, o.gy)[2]
  setmetatable(o, self)
  self.__index = self
  return o
end

function Cell:contains(x, y)
  if self.x < x and x < self.x + cell_size and self.y < y and y < self.y + cell_size then
    return true
  else
    return false
  end
end

function Cell:toggle()
  if self.v == 0 then self.v = 1
  else self.v = 0 end
end

grid = {}
for y=1,grid_size do
  grid[y] = {}
  for x = 1,grid_size do
    grid[y][x] = Cell:new(x, y)
  end
end
toolbar = {
  Cell:new(1, 1)
}
toolbar_width = 5 * (cell_size + cell_gap)
screen_side = grid_size * (cell_size + cell_gap) + cell_gap
love.window.setMode(screen_side + toolbar_width, screen_side)

speed_control = {
  min_y = cell_gap * 2 + cell_size,
  max_y = cell_gap + 8 * (cell_gap + cell_size),
  x = screen_side + cell_size + cell_gap,
  y = cell_gap * 2 + cell_size,
  base_color = {0, 0, 0},
  width = (cell_size + cell_gap) * 4 - cell_gap,
  height = cell_size,
  is_being_dragged = false,
}
last_time = 0

function speed_control:update()
  mx = love.mouse.getX()
  my = love.mouse.getY()
  if not love.mouse.isDown(1) then self.is_being_dragged = false end
  if self.is_being_dragged then
    if self.min_y <= my - self.height / 2 then
      if my - self.height / 2 <= self.max_y then
        self.y = my - self.height / 2
      else
        self.y = self.max_y
      end
    else
      self.y = self.min_y
    end
  end
  local percent = (self.y - self.min_y) / (self.max_y - self.min_y)
  delay = percent
  self.base_color = {percent * 255, (1 - percent) * 255, (1 - percent) * 255}
  self.color_deselected = {
    self.base_color[1] - 20,
    self.base_color[2] - 20,
    self.base_color[3] - 20
  }
  self.color_selected = {
    self.base_color[1],
    self.base_color[2],
    self.base_color[3]
  }
  self.color_hover = {
    self.base_color[1] - 10,
    self.base_color[2] - 10,
    self.base_color[3] - 10
  }
  if self.x <= mx and mx <= self.x + self.width
    and self.y <= my and my <= self.y + self.height then
      if love.mouse.isDown(1) then
        self.color = self.color_selected
        self.is_being_dragged = true
      else
        self.color = self.color_hover
      end
  else
    self.color = self.color_deselected
  end
end

function toggle(x, y)
  if grid[y][x].v == 0 then grid[y][x].v = 1
  else grid[y][x].v = 0
  end
end

function love.load()
  iter = 0
  grid[16][15].v = 1
  grid[16][16].v = 1
  grid[16][17].v = 1
  grid[17][15].v = 1
  grid[18][16].v = 1
  paused = true
  mousemode = 0
  font = love.graphics.newFont("courier.ttf", 14)
  love.graphics.setFont(font)
end

function iterate()
  new_grid = {}
  for y,xk in ipairs(grid) do
    new_grid[y] = {}
    for x,c in ipairs(xk) do
      new_grid[y][x] = Cell:new(x, y)
      if c.v == 1 then
        if getNeighbors(x, y) == 2 or getNeighbors(x, y) == 3 then
          new_grid[y][x].v = 1
        else
          new_grid[y][x].v = 0
        end
      elseif c.v == 0 then
        if getNeighbors(x, y) == 3 then
          new_grid[y][x].v = 1
        else
          new_grid[y][x].v = 0
        end
      end
    end
  end
  grid = new_grid
  iter = iter + 1
end

function love.update(dt)
  if not paused and love.timer.getTime() - last_time >= delay then
    last_time = love.timer.getTime()
    iterate()
  end
  if love.mouse.isDown(1) then
    c = findCellThatContains(love.mouse.getX(), love.mouse.getY())
    if c then c.v = 1 end
  elseif love.mouse.isDown(2) then
    c = findCellThatContains(love.mouse.getX(), love.mouse.getY())
    if c then c.v = 0 end
  else
    c = findCellThatContains(love.mouse.getX(), love.mouse.getY())
  end
  speed_control:update()
end

function love.keypressed(key)
  if key == "space" and not pressed.space then
    last_time = 0
    paused = not paused
    pressed.space = true
  end
  if key == "f" and not pressed.f then
    iterate()
    last_time = 0
    pressed.f = true
  end
  if key == "escape" then love.event.quit() end
end

function love.keyreleased(key)
  if key == "space" then pressed.space = false end
  if key == "f" then pressed.f = false end
end

function findCellThatContains(x, y)
  for i,xk in ipairs(grid) do
    for j,c in ipairs(xk) do
      if c:contains(x, y) then return c end
    end
  end
end

function love.mousepressed(mx, my, button, isTouch)
  c = findCellThatContains(mx, my)
  if c then
    c:toggle()
    print(c.gx, c.gy)
  end
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
    getFromGrid(x-1, y-1).v + getFromGrid(x, y-1).v + getFromGrid(x+1, y-1).v +
    getFromGrid(x-1, y).v + getFromGrid(x+1, y).v +
    getFromGrid(x-1, y+1).v + getFromGrid(x, y+1).v + getFromGrid(x+1, y+1).v
end

function love.draw()
  for y,xk in ipairs(grid) do
    for x,cell in ipairs(xk) do
      if cell.v == 1 then
        love.graphics.setColor(cell.color_on[1], cell.color_on[2], cell.color_on[3])
      else
        if cell:contains(love.mouse.getX(), love.mouse.getY()) then
          love.graphics.setColor(cell.color_hover[1], cell.color_hover[2], cell.color_hover[3])
        else
          love.graphics.setColor(cell.color_off[1], cell.color_off[2], cell.color_off[3])
        end
      end
      love.graphics.rectangle(
        "fill",
        cell.x,
        cell.y,
        cell_size,
        cell_size
      )
    end
  end
  love.graphics.setColor(20, 20, 20)
  love.graphics.rectangle(
    "fill",
    screen_side,
    cell_gap,
    cell_size,
    screen_side - (cell_gap * 2)
  )
  love.graphics.rectangle(
    "fill",
    screen_side + cell_gap + cell_size,
    cell_gap,
    (cell_size + cell_gap) * 4 - cell_gap,
    cell_size
  )
  love.graphics.setColor(30, 30, 30)
  love.graphics.rectangle(
    "fill",
    speed_control.x + speed_control.width / 2 - cell_size / 2,
    speed_control.min_y,
    cell_size,
    speed_control.max_y - speed_control.min_y + cell_size
  )
  love.graphics.setColor(10, 10, 10)
  love.graphics.rectangle(
    "fill",
    speed_control.x + speed_control.width / 2 - cell_size / 6,
    speed_control.min_y + cell_size / 3,
    cell_size / 3,
    speed_control.max_y - speed_control.min_y + cell_size - 2 * cell_size / 3
  )
  love.graphics.setColor(
    speed_control.color[1],
    speed_control.color[2],
    speed_control.color[3]
  )
  love.graphics.rectangle(
    "fill",
    speed_control.x,
    speed_control.y,
    speed_control.width,
    speed_control.height
  )
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("iter:\n" .. iter, screen_side + cell_gap + cell_size, screen_side - 3*(cell_gap + cell_size))
end
