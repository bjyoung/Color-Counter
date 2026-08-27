-- Config options

-- Num pixels in a sprite until the large sprite warning appears
local LARGE_SPRITE_SIZE = 2000000

-- Number of colors allowed in the sprite until the script aborts
local MAX_NUM_COLORS = 1000

-- Disable script after a period of time when true
local stopAutomatically = true

-- Number of seconds the script waits before the script stops automatically
local MAX_RUNTIME = 120

-- If true, skip the large sprite warning
local DISABLE_LARGE_SPRITE_WARNING = false

-- Config options END

local debugMode = false
local totalNumPixels = nil
local MAX_ALPHA = 255
local LARGE_SPRITE_ALERT_TITLE = "Large Sprite Warning"
local LARGE_SPRITE_ALERT_TEXT = "Large sprite detected. The script might take a while or freeze if you continue. Continue anyways?"
local CONTINUE_BTN_PRESSED = 1
local DIALOG_TITLE_PREFIX = "RGB Counts"

-- How many loops before runtime is checked to see if script went on for too long
local TIME_CHECK_RATE = 250000

-- ColorData class
ColorData = {r = 0, g = 0, b = 0}

local function hashRgb(r, g, b)
  return 1000000000 + r * 1000000 + g * 1000 + b
end

function ColorData:new(o, r, g, b)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.r = r or 0
  self.g = g or 0
  self.b = b or 0
  self.count = 1
  self.percent = 0.0
  return o
end

function ColorData:getHash()
  return hashRgb(self.r, self.g, self.b)
end

function ColorData:equals(otherColorData)
  return self.r == otherColorData.r and self.g == otherColorData.g and self.b == otherColorData.b
end

function ColorData:toString()
  return "[" .. self.r .. ", " .. self.g .. ", " .. self.b .. "]: " .. self.count
end
-- ColorData class END

local function printError(error)
  if debugMode then
    print(error)
  end
end

local function round(num)
  return tonumber(string.format("%.4f", num))
end

-- Get how much time passed since the script started running
-- StartClock must be initialized
local function getElapsedTime()
  if StartClock == nil then
    print("StartClock is not initialized")
    return nil
  end

  local endClock = os.clock()
  local runTime = round(endClock - StartClock)
  return runTime
end

-- Print how much time has passed since the given start time in sec
local function printElapsedTime(startTime, message)
  if debugMode then
    if startTime ~= nil then
      local startTime = round(os.clock() - startTime)
      print("\n" .. message ..": " .. startTime .. "s")
    end
  end
end

local function printDottedLine(withLineBreak)
  local line = ""

  if withLineBreak then
    line = "\n"
  end

  line = line .. "--------------------------"
  print(line)
end

local function printImageStats(image)
  local width = image.width
  local height = image.height

  print("Width: " .. width)
  print("Height: " .. height)
end

-- Count how often each RGB value is used and return as a table of hash nums to ColorData objects
local function countRgbColors(image)
  if debugMode then
    ColorCountStart = os.clock()
  end

  local colors = {}
  local selection = app.sprite.selection
  local hasSelection = not selection.isEmpty

  if debugMode then
    if hasSelection == false then
      print ("Nothing is selected")
    else
      local selectionBounds = selection.bounds
      local boundXStr = tostring(selectionBounds.x)
      local boundYStr = tostring(selectionBounds.y)
      local boundWidthStr = tostring(selectionBounds.width)
      local boundHeightStr = tostring(selectionBounds.height)
      print ("Has selection with bounds: (" .. boundXStr .. ", " .. boundYStr .. "), width = " .. boundWidthStr .. ", height = " .. boundHeightStr)
    end

    print ("(x, y): [r, g, b, a]")
  end

  local loopNum = 0
  totalNumPixels = 0
  local num_colors = 0

  -- Setting up loop variables
  local pixelValue = nil
  local alpha = nil
  local r = nil
  local g = nil
  local b = nil
  local currHash = nil
  local colorDataEntry = nil

  for it in image:pixels() do
    loopNum = loopNum + 1

    if stopAutomatically and loopNum % TIME_CHECK_RATE == 0 and getElapsedTime() > MAX_RUNTIME then
      local laggingScriptErrorMessage = "The script is hanging. Try with a smaller sprite."
      printError(laggingScriptErrorMessage)
      app.alert(laggingScriptErrorMessage)
      return nil
    end

    -- Ignore pixels outside of selection, if there is one
    if hasSelection and selection:contains(it.x, it.y) == false then
      goto continue
    end

    pixelValue = it()
    alpha = app.pixelColor.rgbaA(pixelValue)

    -- Ignore semi-transparent and transparent pixels
    if alpha < MAX_ALPHA then
      goto continue
    end

    totalNumPixels = totalNumPixels + 1
    
    r = app.pixelColor.rgbaR(pixelValue)
    g = app.pixelColor.rgbaG(pixelValue)
    b = app.pixelColor.rgbaB(pixelValue)
    currHash = hashRgb(r, g, b)
    colorDataEntry = colors[currHash]

    if colorDataEntry ~= nil then
      colorDataEntry.count = colorDataEntry.count + 1
    else
      colors[currHash] = ColorData:new{nil, r = r, g = g, b = b}
      num_colors = num_colors + 1

      if num_colors > MAX_NUM_COLORS then
        local colorLimitErrorMessage = 'Over ' .. tostring(MAX_NUM_COLORS) .. ' colors detected. Stopping the script.'
        printError(colorLimitErrorMessage)
        app.alert(colorLimitErrorMessage)
        return nil
      end
    end

    ::continue::
  end

  -- Calculate percentage 
  local colorPercent = nil

  for i, colorData in pairs(colors) do
    if colorData ~= nil then
      colorPercent = (colorData.count * 1.0) / (totalNumPixels * 1.0) * 100.0
      colors[i].percent = string.format("%.1f", colorPercent)
    end
  end

  if debugMode then
    print("# Pixels: " .. totalNumPixels)
    printElapsedTime(ColorCountStart, "Color count took")
  end

  return colors
end

local function toList(colorDataTable)
  local colorDataList = {}
  local index = 0

  for _, colorData in pairs(colorDataTable) do
    index = index + 1
    colorDataList[index] = colorData
  end

  return colorDataList
end

local function compareColorCountsDesc(a, b)
  return a.count > b.count
end

-- Convert hash table to a list and return an indexed list of color data, sorted by count descending
local function sortColorData(colorData)
  if debugMode then
    SortStart = os.clock()
  end

  local colorDataList = toList(colorData)

  if debugMode then
    print('Sorting table by count')
  end

  table.sort(colorDataList, compareColorCountsDesc)

  if debugMode then
    print('Done sorting')
    printElapsedTime(SortStart, "Sorting took")
  end

  return colorDataList
end

local function outputCountsToConsole(colorDataList)
  local withLineBreak = true
  printDottedLine(withLineBreak)
  print("Color counts (RGB):")
  local withoutLineBreak = false
  printDottedLine(withoutLineBreak)

  for _, colorData in pairs(colorDataList) do
    print("(" .. colorData.r .. ", " .. colorData.g .. ", " .. colorData.b .. "): " .. colorData.count .. " (" .. colorData.percent .. "%)")
  end

  printDottedLine(withoutLineBreak)
end

local function outputCountsToDialog(colorDataList)
  local dialogTitle = ""
  local hasSelection = not app.sprite.selection.isEmpty
  
  if hasSelection then
    dialogTitle = "Selected Area " .. DIALOG_TITLE_PREFIX
  else
    dialogTitle =  DIALOG_TITLE_PREFIX
  end

  if totalNumPixels ~= nil then
    dialogTitle = dialogTitle .. " (" .. tostring(totalNumPixels) .. " pixels)"
  end

  local dlg = Dialog {
    title=dialogTitle
  }

  local loop_num = 0

  for _, colorData in pairs(colorDataList) do
    loop_num = loop_num + 1
    local colorId = "color_" .. loop_num

    local currColor = Color {
      r=colorData.r,
      g=colorData.g,
      b=colorData.b
    }

    local colorLabel = "(" .. colorData.r .. ", " .. colorData.g .. ", " .. colorData.b .. "):"

    dlg:color {
      id=colorId,
      label=colorLabel,
      color=currColor,
      enabled=false,
    }

    local labelId = "label_" .. loop_num
    local countPercentText = colorData.count .. " (" .. colorData.percent .."%)"

    dlg:label {
        id=labelId,
        label="Count (%):",
        text=countPercentText
    }

    local separatorId = "separator_" .. loop_num

    dlg:separator {
      id = separatorId,
    }
  end

  dlg:show {
    wait=false,
    autoscrollbars=true
  }
end

local function calculateAndOutputCounts()
  local image = app.image

  if image == nil then
    local noActiveSpriteErrorMessage = "No active sprite found"
    printError(noActiveSpriteErrorMessage)
    app.alert(noActiveSpriteErrorMessage)
    return
  end

  if image.colorMode ~= ColorMode.RGB then
    local invalidModeErrorMessage = "Sprite color mode not set to RGB"
    printError(invalidModeErrorMessage)
    app.alert(invalidModeErrorMessage)
    return
  end

  if debugMode then
    printImageStats(image)
  end
  
  local imageSize = image.width * image.height

  if DISABLE_LARGE_SPRITE_WARNING == false then
    if imageSize >= LARGE_SPRITE_SIZE then
      local warningResult = app.alert{
        title=LARGE_SPRITE_ALERT_TITLE,
        text=LARGE_SPRITE_ALERT_TEXT,
        buttons={"Continue", "Cancel"}
      }

      if warningResult ~= CONTINUE_BTN_PRESSED then
        return
      end
    end
  end

  local colorData = countRgbColors(image)

  if colorData == nil then
    return
  end

  local sortedColorData = sortColorData(colorData)

  if debugMode then
    outputCountsToConsole(sortedColorData)
  end

  outputCountsToDialog(sortedColorData)
end

-- Main function: time script, count pixels and output counts
local function count_pixels()
  StartClock = os.clock()
  calculateAndOutputCounts()

  if debugMode then
    print("\nElapsed time is: " .. getElapsedTime() .. "s")
  end
end

function init(plugin)
  if debugMode then
    print("Initializing Colors Counter")
  end

  plugin:newCommand {
    id="CountColors",
    title="Count Colors",
    group="sprite_properties",
    onclick=count_pixels
  }
end
