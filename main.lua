-- Tonight:
-- Background Color Picker
-- Brush Color Picker *
-- Eraser
-- Clear Screen
-- Set Resolution
-- Set Brush Size
--
-- Stretch Goals
-- Different Shaped Brushes
-- Stroke Interpolation

function love.load()                                                  -- LOAD LOAD LOAD
  debug = true                                                        -- this time I am logging everything
  SCREEN = {}                                                         -- dont change these things... yet
  SCREEN.WIDTH, SCREEN.HEIGHT, SCREEN.FLAGS = love.window.getMode()
  SESSION = {}
  SESSION.time = 0
  love.window.setTitle('um... I had something for this')
  titleFont = love.graphics.newFont("8-BIT WONDER.TTF", 100)
  bodyFont = love.graphics.newFont("8-BIT WONDER.TTF", 30)
  smallFont = love.graphics.newFont("8-BIT WONDER.TTF", 20)
  layout = newLayout()
  user = newUser()
  canvas = newButtonArray(20, 20, layout.canvas)
  palette = newPalette()
  love.graphics.setBackgroundColor(layout.background.color)
  -- TEXT MENU
  clearButton = newButton(layout.tab, layout.tab, layout.palette.dim / 5, layout.palette.dim, {255, 255, 255, 255})
  guideButton = newButton(layout.tab, 2 * layout.tab + clearButton.y.max, layout.palette.dim / 5, layout.palette.dim, {255, 255, 255, 255})
  guideButton.debounceLatch = 0
  print('hi')
end

function love.update(dt)                                              -- UPDATE UPDATE UPDATE
  SESSION.time = SESSION.time + dt
  if love.mouse.isGrabbed then                                        -- mouse moved callback doesnt give any better resolution
    user.x = love.mouse.getX()
    user.y = love.mouse.getY()
    if love.mouse.isDown('l') then
      for i, button in ipairs(canvas.pixels.buttons) do               -- run through all pixels in the canvas, looking for mouse. TODO better
        if user.x <= button.x.max and user.y <= button.y.max and user.x >= button.x.min and user.y >= button.y.min then
          button.color = user.color1
        end
      end
      for i, button in ipairs(palette.pixels.buttons) do               -- run through all pixels in palette, looking for mouse. TODO better
        if user.x <= button.x.max and user.y <= button.y.max and user.x >= button.x.min and user.y >= button.y.min then
          user.color1 = button.color
        end
      end
      if user.x <= clearButton.x.max and user.y <= clearButton.y.max and user.x >= clearButton.x.min and user.y >= clearButton.y.min then
        for i, button in ipairs(canvas.pixels.buttons) do               -- clear every pixel
          button.color = user.color2
        end
      end
      if user.x <= guideButton.x.max and user.y <= guideButton.y.max and user.x >= guideButton.x.min and user.y >= guideButton.y.min and SESSION.time > guideButton.debounceLatch then
        user.guides = not user.guides
        guideButton.debounceLatch = SESSION.time + 0.2
      end
      if guideButton.debounceLatch < SESSION.time then
        guideButton.debounceLatch = SESSION.time
      end
    end
  end
end

function love.draw()                                                  -- DRAW DRAW DRAW

  love.graphics.setColor(user.color2)
  love.graphics.rectangle("fill", layout.canvas.x.min, layout.canvas.y.min, layout.canvas.dim, layout.canvas.dim)
  for i, button in ipairs(canvas.pixels.buttons) do                   -- Draw the Canvas (Painting area thing)
    love.graphics.setColor(button.color)
    love.graphics.rectangle("fill", button.x.min, button.y.min, button.width, button.height)
    if user.guides then                                               -- Add little dots to show square placement
      love.graphics.setColor(InverseColor(button.color))
      love.graphics.rectangle("fill", button.x.min, button.y.min, 1, 1)
    end
  end
  for i, button in ipairs(palette.pixels.buttons) do                   -- Draw the palette (Painting area thing)
    love.graphics.setColor(button.color)
    love.graphics.rectangle("fill", button.x.min, button.y.min, button.width, button.height)
  end
  -- TEXT MENU
  love.graphics.setColor(InverseColor(layout.background.color))
  love.graphics.setFont(bodyFont)
  love.graphics.printf("CLEAR", clearButton.x.min + layout.tab, clearButton.y.min + layout.tab, clearButton.width, 'left')
  love.graphics.printf("GUIDE", guideButton.x.min + layout.tab, guideButton.y.min + layout.tab, guideButton.width, 'left')
end

function InverseColor(color)
  newColor = {255 - color[1], 255 - color[2], 255 - color[3], color[4]}
  return newColor
end

function newPalette()
  local palette = newButtonArray(8, 8, layout.palette)
  for i, button in ipairs(palette.pixels.buttons) do                   -- Draw the palette (Painting area thing)
    button.color = {(math.floor(8 * math.random()) * 255 / 8), (math.floor(8 * math.random()) * 255 / 8), (math.floor(8 * math.random()) * 255 / 8), 255}
    if i == 1 then
      button.color = {255, 255, 255, 255}
    elseif i == 2 then
      button.color = {0, 0, 0, 255}
    elseif i == 3 then
      button.color = {255, 0, 0, 255}
    elseif i == 4 then
      button.color = {255, 255, 0, 255}
    elseif i == 5 then
      button.color = {0, 255, 0, 255}
    elseif i == 6 then
      button.color = {0, 255, 255, 255}
    elseif i == 7 then
      button.color = {0, 0, 255, 255}
    elseif i == 8 then
      button.color = {255, 0, 255, 255}
    end
  end
  return palette
end

function newUser()
  local user = {}
  user.color1 = {100, 250, 100, 255}
  user.color2 = {255, 255, 255, 255}
  user.x = 0
  user.y = 0
  user.guides = true
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
  return button
end

function newButtonArray(xResolution, yResolution, type)
  local buttonArray = {}
  buttonArray.x = {}
  buttonArray.x.resolution = xResolution
  buttonArray.y = {}
  buttonArray.y.resolution = yResolution
  buttonArray.cell = {}
  buttonArray.pixels = {}                                -- fake pixels = fauxils?
  buttonArray.pixels.width = type.dim / xResolution
  buttonArray.pixels.height = type.dim / yResolution
  buttonArray.pixels.buttons = {}
  for j = 0, buttonArray.y.resolution - 1 do
    for i = 0, buttonArray.x.resolution - 1 do
      local buttonx = i * buttonArray.pixels.width + type.x.min
      local buttony = j * buttonArray.pixels.height + type.y.min
          local button = newButton(buttonx, buttony, buttonArray.pixels.height, buttonArray.pixels.width, user.color2)
          table.insert(buttonArray.pixels.buttons, button)
    end
  end
  return buttonArray
end

function newLayout()
  local layout = {}
  layout.border = 0.01                                                -- proportional border
  layout.background = {}
  layout.background.color = {200, 200, 200, 200}
  layout.maxSquareSide = SCREEN.HEIGHT                                -- max length of box
  layout.tab = layout.border * layout.maxSquareSide                   -- converted to pixels
  -- CANVAS
  layout.canvas = {}
  layout.canvas.maxAlign = SCREEN.WIDTH - layout.maxSquareSide      -- max hand side for max screen box
  layout.canvas.x = {}                                               -- make bordered canvas dimensions
  layout.canvas.x.min = layout.canvas.maxAlign + layout.tab
  layout.canvas.x.max = SCREEN.WIDTH - layout.tab
  layout.canvas.y = {}
  layout.canvas.y.min = layout.tab
  layout.canvas.y.max = SCREEN.HEIGHT - layout.tab
  layout.canvas.dim = layout.canvas.x.max - layout.canvas.x.min          -- get width of bordered canvas
  -- PAL
  layout.palette = {}
  layout.palette.maxAlign = 0
  layout.palette.x = {}
  layout.palette.x.min = 0 + layout.tab
  layout.palette.x.max = layout.canvas.maxAlign
  layout.palette.y = {}
  layout.palette.y.min = SCREEN.HEIGHT - layout.canvas.x.min + layout.tab
  layout.palette.y.max = SCREEN.HEIGHT - layout.tab
  layout.palette.dim = layout.palette.x.max - layout.palette.x.min
  return layout
end
