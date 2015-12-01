range = require("range")

function love.load()
  debug = true                                                        -- this time I am logging everything
  SCREEN = {}
  SCREEN.WIDTH, SCREEN.HEIGHT, SCREEN.FLAGS = love.window.getMode()
  if debug then
    print("Screen Setup")
    print(SCREEN.WIDTH .. ' ' .. SCREEN.HEIGHT)
  end
  layout = newLayout()
  user = newUser()
  canvas = newCanvas(2, 2)
  print('hi')
end

-- function love.update(dt)
--   if love.mouse.isGrabbed then
--   end
-- end

function love.draw()
  if debug then
    love.graphics.print('Hello World!', 400, 300)
  end
  love.graphics.setColor(user.color2)
  love.graphics.rectangle("fill", layout.grid.x.min, layout.grid.y.min, layout.grid.dim, layout.grid.dim)
  for i, button in ipairs(canvas.pixels.buttons) do
    -- love.graphics.setColor(button.color)
    love.graphics.setColor({255/(i*2), 0 + i*9, 255, 255})
    love.graphics.rectangle("fill", button.x.min, button.y.min, button.width, button.height)
  end
end

function newUser()
  local user = {}
  user.color = {255, 255, 0, 255}
  user.color2 = {255, 0, 255, 255}
  return user
end

function newButton(x, y, height, width, color, border)
  local button = {}
  button.color = color
  button.border = border
  button.width = width
  button.height = height
  button.x = {}
  button.x.tab = width * border
  button.x.min = x + button.x.tab
  button.x.max = x + width - button.x.tab
  button.y = {}
  button.y.tab = height * border
  button.y.min = y + button.y.tab
  button.y.max = y + height - button.y.tab
  button.value = false
  if debug then
    print('New Button')
    print(button.x.min .. ' ' .. button.x.max)
    print(button.y.min .. ' ' .. button.y.max)
  end
  return button
end

function newCanvas(xResolution, yResolution)
  local canvas = {}
  canvas.x = {}
  canvas.x.resolution = xResolution
  canvas.y = {}
  canvas.y.resolution = yResolution
  canvas.cell = {}
  canvas.pixels = {}                                -- fake pixels = fauxils?
  canvas.pixels.width = layout.grid.dim / xResolution
  canvas.pixels.height = layout.grid.dim / yResolution
  canvas.pixels.buttons = {}
  local x_thresh = layout.grid.x.min
  local y_thresh = layout.grid.y.min
  -- for j = layout.grid.y.min, layout.grid.y.max do
  --   for i = layout.grid.x.min, layout.grid.x.max do
  --     if math.mod(i, canvas.pixels.width) < 1 and math.mod(j, canvas.pixels.height) < 1 then
  --       x_thresh = i + canvas.pixels.width
  --       y_thresh = i + canvas.pixels.height
  --       local button = newButton(i, j, canvas.pixels.height, canvas.pixels.width, user.color, 0.5)
  --       table.insert(canvas.pixels.buttons, button)
  --     end
  --   end
  -- end
  for j in range(layout.grid.y.min, layout.grid.y.max, canvas.y.resolution) do
    for i in range(layout.grid.x.min, layout.grid.x.max, canvas.x.resolution) do
      local button = newButton(i, j, canvas.pixels.height, canvas.pixels.width, user.color, 0.5)
      table.insert(canvas.pixels.buttons, button)
    end
  end

  if debug then
    print('Pixels')
    print(canvas.pixels.width .. ' ' .. canvas.pixels.height)
    for i, button in ipairs(canvas.pixels.buttons) do
      print(button.x.min .. ' ' .. button.x.max)
      print(button.y.min .. ' ' .. button.y.max)
    end
  end

  return canvas
end

function newLayout()
  local layout = {}
  layout.grid = {}
  layout.maxSquareSide = SCREEN.HEIGHT                                -- max length of box
  layout.grid.maxAlign = (SCREEN.WIDTH - layout.maxSquareSide)      -- max hand side for max screen box
  layout.border = 0.01                                                -- proportional border
  layout.tab = layout.border * layout.maxSquareSide                   -- converted to pixels
  layout.grid.x = {}                                               -- make bordered grid dimensions
  layout.grid.x.min = layout.grid.maxAlign + layout.tab
  layout.grid.x.max = SCREEN.WIDTH - layout.tab
  layout.grid.y = {}
  layout.grid.y.min = layout.tab
  layout.grid.y.max = SCREEN.HEIGHT - layout.tab
  layout.grid.dim = layout.grid.x.max - layout.grid.x.min          -- get width of bordered grid
  if debug then
    print("Setup Grid")
    print(layout.grid.x.min .. " " .. layout.grid.x.max)
    print(layout.grid.y.min .. " " .. layout.grid.y.max)
  end
  return layout
end

function range(a, b, step)
  if not b then
    b = a
    a = 1
  end
  step = step or 1
  local f =
    step > 0 and
      function(_, lastvalue)
        local nextvalue = lastvalue + step
        if nextvalue <= b then return nextvalue end
      end or
    step < 0 and
      function(_, lastvalue)
        local nextvalue = lastvalue + step
        if nextvalue >= b then return nextvalue end
      end or
      function(_, lastvalue) return lastvalue end
  return f, nil, a - step
end
