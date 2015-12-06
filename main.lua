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

function love.load()
  math.randomseed(os.time())                                                -- LOAD LOAD LOAD
  debug = true                                                        -- this time I am logging everything
  SCREEN = {}                                                         -- dont change these things... yet
  SCREEN.WIDTH, SCREEN.HEIGHT, SCREEN.FLAGS = love.window.getMode()
  session = {}
  session.time = 0
  love.window.setTitle('um... I had something for this')
  titleFont = love.graphics.newFont(100)
  bodyFont = love.graphics.newFont(30)
  smallFont = love.graphics.newFont(20)
  layout = newLayout()
  user = newUser()
  canvas = newButtonArray(20, 20, layout.canvas)
  palette = newPalette()
  love.graphics.setBackgroundColor(layout.background.color)
  -- TEXT MENU
  clearButton = newButton(layout.tab, layout.tab, layout.palette.dim / 5, layout.palette.dim, {255, 255, 255, 255})
  guideButton = newButton(layout.tab, clearButton.y.max, layout.palette.dim / 5, layout.palette.dim, {255, 255, 255, 255})
  guideButton.debounceLatch = 0
  golButton = newButton(layout.tab, guideButton.y.max, layout.palette.dim / 5, layout.palette.dim, {255, 255, 255, 255})
  golButton.debounceLatch = 0
  gameoflife = {}
  gameoflife.toggle = false
  gameoflife.update = 0
  print('hi')
end

function love.update(dt)                                              -- UPDATE UPDATE UPDATE
  session.time = session.time + dt
  if love.mouse.isGrabbed then                                        -- mouse moved callback doesnt give any better resolution
    user.x = love.mouse.getX()
    user.y = love.mouse.getY()
    if love.mouse.isDown('l') then
      -- DRAW
      for i, button in ipairs(canvas.pixels.buttons) do               -- run through all pixels in the canvas, looking for mouse. TODO better
        if user.x <= button.x.max and user.y <= button.y.max and user.x >= button.x.min and user.y >= button.y.min then
          button.color = user.color.active
          button.state.current = 1
          if user.color.active == user.color.disactive then
            button.state.current = 0
            button.state.future = 0
          end
        end
      end
      -- USER CONTROL
      -- PALETTE
      for i, button in ipairs(palette.pixels.buttons) do               -- run through all pixels in palette, looking for mouse. TODO better
        if user.x <= button.x.max and user.y <= button.y.max and user.x >= button.x.min and user.y >= button.y.min then
          user.color.active = button.color
        end
      end
      -- CLEAR SCREEN
      if user.x <= clearButton.x.max and user.y <= clearButton.y.max and user.x >= clearButton.x.min and user.y >= clearButton.y.min then
        for i, button in ipairs(canvas.pixels.buttons) do               -- clear every pixel
          button.color = user.color.disactive
          button.state.current = 0
          button.state.future = 0
        end
      end
      -- TOGGLE VISIBLE GUIDES
      if user.x <= guideButton.x.max and user.y <= guideButton.y.max and user.x >= guideButton.x.min and user.y >= guideButton.y.min and session.time > guideButton.debounceLatch then
        user.guides = not user.guides
        guideButton.debounceLatch = session.time + 0.2
      end
      if guideButton.debounceLatch < session.time then
        guideButton.debounceLatch = session.time
      end
      -- TOGGLE GAME OF LIFE
      if user.x <= golButton.x.max and user.y <= golButton.y.max and user.x >= golButton.x.min and user.y >= golButton.y.min and session.time > golButton.debounceLatch then
        gameoflife.toggle = not gameoflife.toggle
        if gameoflife.toggle then
          gameoflife.update = session.time + 1/user.fps
        end
        golButton.debounceLatch = session.time + 0.2

      end
      if golButton.debounceLatch < session.time then
        golButton.debounceLatch = session.time
      end
    end
  end
  -- GAME OF LIFE
  if gameoflife.toggle then
    if session.time > gameoflife.update then
      gameoflife.update = session.time + 1/user.fps
      -- GAME OF LIFE LOGIC
      for i, button in ipairs(canvas.pixels.buttons) do
        local count = countNeighbours(i, canvas)
        neighbourCount = count.neighbourCount
        neighbourColors = count.neighbourColors
        if button.state.current == 1 and neighbourCount < 2 then
          button.state.future = 0
        elseif button.state.current == 1 and neighbourCount > 3 then
          button.state.future = 0
        end
        if button.state.current == 0 and neighbourCount == 3 then
          button.state.future = 1
        end
      end
      -- ADD COLORS
      newColor = user.color.active
      for i, color in ipairs(neighbourColors) do
        print(i)
        for j = 1, 4 do
          print(newColor[j])
          -- newColor[j] = newColor[j] + color[j]
        end
      end

      -- UPDATE CELL STATES
      for i, button in ipairs(canvas.pixels.buttons) do
        button.state.current = button.state.future
      end
      -- UPDATE CELL COLOR
      for i, button in ipairs(canvas.pixels.buttons) do
        if button.state.current == 1 then
          button.color = newColor
          -- if not button.color == user.color.disactive then
          --   button.color = button.color
          -- else
          --   button.color = user.color.active
          -- end
        end
        if button.state.current == 0 then
          button.color = user.color.disactive
        end
      end
    end
  end
end

function love.draw()                                                  -- DRAW DRAW DRAW

  love.graphics.setColor(user.color.disactive)
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
   if gameoflife.toggle then
     love.graphics.printf("PAUSE", golButton.x.min + layout.tab, golButton.y.min + layout.tab, golButton.width, 'left')
   else
     love.graphics.printf("PLAY", golButton.x.min + layout.tab, golButton.y.min + layout.tab, golButton.width, 'left')
   end
end

function countNeighbours(i, buttonArray)
  neighbourIndex = {}
  local neighbours = {}
  local neighbourCount = 0
  table.insert(neighbourIndex, i + 1)
  table.insert(neighbourIndex, i - 1)
  table.insert(neighbourIndex, i + buttonArray.x.resolution)
  table.insert(neighbourIndex, i + buttonArray.x.resolution - 1)
  table.insert(neighbourIndex, i + buttonArray.x.resolution + 1)
  table.insert(neighbourIndex, i - buttonArray.x.resolution)
  table.insert(neighbourIndex, i - buttonArray.x.resolution - 1)
  table.insert(neighbourIndex, i - buttonArray.x.resolution + 1)
  if user.toroid then
    for i, index in ipairs(neighbourIndex) do
      if index < 0 then
        index = index + buttonArray.pixels.length
      elseif index > buttonArray.pixels.length then
        index = index - buttonArray.pixels.length
      end
      table.insert(neighbours, buttonArray.pixels.buttons[index])
    end
  end
  local neighbourColors = {}
  for i, neighbour in ipairs(neighbours) do
    if neighbour.state.current == 1 then
      neighbourCount = neighbourCount + 1
      table.insert(neighbourColors, neighbour.color)
    end
  end
  local count = {}                                                           -- TODO learn / fix return
  count.neighbourCount = neighbourCount
  count.neighbourColors = neighbourColors
  return count
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
  user.toroid = true
  user.color = {}
  user.color.active = {100, 250, 100, 255}
  user.color.disactive = {255, 255, 255, 255}
  user.x = 0
  user.y = 0
  user.guides = true
  user.fps = 5
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
  button.state = {}
  button.state.current = 0
  button.state.future = 0
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
  buttonArray.pixels.length = xResolution * yResolution
  for j = 0, buttonArray.y.resolution - 1 do
    for i = 0, buttonArray.x.resolution - 1 do
      local buttonx = i * buttonArray.pixels.width + type.x.min
      local buttony = j * buttonArray.pixels.height + type.y.min
          local button = newButton(buttonx, buttony, buttonArray.pixels.height, buttonArray.pixels.width, user.color.disactive)
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
  -- PALETTE
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
