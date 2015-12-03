
function love.load()                                                  -- LOAD LOAD LOAD
  debug = true                                                        -- this time I am logging everything
  SCREEN = {}                                                         -- dont change these things... yet
  SCREEN.WIDTH, SCREEN.HEIGHT, SCREEN.FLAGS = love.window.getMode()
  SESSION = {}
  SESSION.time = 0
  -- if debug then
  --   print("Screen Setup")
  --   print(SCREEN.WIDTH .. ' ' .. SCREEN.HEIGHT)
  -- end
  layout = newLayout()
  user = newUser()
  canvas = newCanvas(50, 50)
  love.graphics.setBackgroundColor(layout.background.color)
  print('hi')
end

function love.update(dt)                                              -- UPDATE UPDATE UPDATE
  SESSION.time = SESSION.time + dt
  if love.mouse.isGrabbed then
    user.x = love.mouse.getX()
    user.y = love.mouse.getY()
    if love.mouse.isDown('l') then
      for i, button in ipairs(canvas.pixels.buttons) do
        if user.x <= button.x.max and user.y <= button.y.max and user.x >= button.x.min and user.y >= button.y.min then
          -- if debug then
          --   print('The Cursor Is HERE!')
          --   print(button.x.min .. ' ' .. user.x .. ' ' .. button.x.max)
          --   print(button.y.min .. ' ' .. user.y ..' ' .. button.y.max)
          -- end
          button.color = user.color1
        end
      end
    end
  end
end

function love.draw()                                                  -- DRAW DRAW DRAW

  love.graphics.setColor(user.color2)
  love.graphics.rectangle("fill", layout.grid.x.min, layout.grid.y.min, layout.grid.dim, layout.grid.dim)
  for i, button in ipairs(canvas.pixels.buttons) do
    love.graphics.setColor(button.color)
    love.graphics.rectangle("fill", button.x.min, button.y.min, button.width, button.height)
  end
end

function newUser()
  local user = {}
  user.color1 = {100, 250, 100, 255}
  user.color2 = {90, 110, 255, 255}
  user.x = 0
  user.y = 0
  return user
end

function newButton(x, y, height, width, color)
  local button = {}
  button.color = color
  button.width = width
  button.height = height
  button.x = {}
  button.x.min = x
  button.x.max = x + width
  button.y = {}
  button.y.min = y
  button.y.max = y + height
  button.value = false
  -- if debug then
  --   print('New Button')
  --   print(button.x.min .. ' ' .. button.x.max)
  --   print(button.y.min .. ' ' .. button.y.max)
  -- end
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
  -- if debug then
  --   print("Pixel Info")
  --   print("Grid Side " .. layout.grid.dim)
  --   print(canvas.pixels.width .. ' ' .. canvas.pixels.height)
  -- end
  canvas.pixels.buttons = {}
  for j = 0, canvas.y.resolution - 1 do
    for i = 0, canvas.x.resolution - 1 do
      local buttonx = i * canvas.pixels.width + layout.grid.x.min
      local buttony = j * canvas.pixels.height + layout.grid.y.min
          local button = newButton(buttonx, buttony, canvas.pixels.height, canvas.pixels.width, user.color2)
          table.insert(canvas.pixels.buttons, button)
    end
  end
  -- if debug then
  --   print('Pixels')
  --   print(canvas.pixels.width .. ' ' .. canvas.pixels.height)
  --   for i, button in ipairs(canvas.pixels.buttons) do
  --     print(button.x.min .. ' ' .. button.x.max)
  --     print(button.y.min .. ' ' .. button.y.max)
  --   end
  -- end
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
  layout.background = {}
  layout.background.color = {200, 200, 200, 200}
  -- if debug then
  --   print("Setup Grid")
  --   print(layout.grid.x.min .. " " .. layout.grid.x.max)
  --   print(layout.grid.y.min .. " " .. layout.grid.y.max)
  -- end
  return layout
end
