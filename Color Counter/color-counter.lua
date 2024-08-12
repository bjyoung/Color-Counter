-- Config options

-- Num pixels in a sprite until the large sprite warning appears
local LARGE_SPRITE_SIZE = 1500000

-- Number of colors allowed in the sprite until the script aborts
local MAX_NUM_COLORS = 1000

-- Disable script after a period of time, does not disable script when set to false
local stopAutomatically = true

-- Number of seconds the script waits before the script stops automatically
local MAX_RUNTIME = 120

-- Config options END

local debugMode = false
local totalNumPixels = nil
local MAX_ALPHA = 255
local LARGE_SPRITE_ALERT_TITLE = "Large Sprite Warning"
local LARGE_SPRITE_ALERT_TEXT = "The active sprite is big. The script might take a while or freeze if you continue. Continue anyways?"
local CONTINUE_BTN_PRESSED = 1
local DIALOG_TITLE_PREFIX = "RGB Counts"

-- How many loops before runtime is checked to see if script went on for too long
local TIME_CHECK_RATE = 250000

-- ColorData class
ColorData = {r = 0, g = 0, b = 0}

function ColorData:new(o, r, g, b)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.r = r or 0
  self.g = g or 0
  self.b = b or 0
  self.count = 1
  return o
end

function ColorData:getHash()
  return 1000000000 + self.r * 1000000 + self.g * 1000 + self.b
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

-- Count number of times each RGB value is used and return as a table of hash to ColorData objects
local function countRgbColors(image)
  local colors = {}

  if debugMode then
    print ("(x, y): [r, g, b, a]")
  end

  local loopNum = 0
  totalNumPixels = 0
  local num_colors = 0

  for it in image:pixels() do
    loopNum = loopNum + 1

    if stopAutomatically and loopNum % TIME_CHECK_RATE == 0 and getElapsedTime() > MAX_RUNTIME then
      local laggingScriptErrorMessage = "The script is hanging. Try with a smaller sprite."
      printError(laggingScriptErrorMessage)
      app.alert(laggingScriptErrorMessage)
      return nil
    end

    local pixelValue = it()
    local a = app.pixelColor.rgbaA(pixelValue)

    -- Ignore semi-transparent and transparent pixels
    if a < MAX_ALPHA then
      goto continue
    end

    totalNumPixels = totalNumPixels + 1
    local r = app.pixelColor.rgbaR(pixelValue)
    local g = app.pixelColor.rgbaG(pixelValue)
    local b = app.pixelColor.rgbaB(pixelValue)
    local currColorData = ColorData:new{nil, r = r, g = g, b = b}

    local currHashStr = tostring(currColorData:getHash())
    local colorDataEntry = colors[currHashStr]

    if colorDataEntry ~= nil then
      colorDataEntry.count = colorDataEntry.count + 1
    else
      colors[currHashStr] = currColorData
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

  if debugMode then
    print("# Pixels: " .. totalNumPixels)
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

-- Convert hash table and return an indexed list of color data, sorted by count descending
local function sortColorData(colorData)
  local colorDataList = toList(colorData)

  if debugMode then
    print('Sorting table by count')
  end

  table.sort(colorDataList, compareColorCountsDesc)

  if debugMode then
    print('Done sorting')
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
    print("(" .. colorData.r .. ", " .. colorData.g .. ", " .. colorData.b .. "): " .. colorData.count)
  end

  printDottedLine(withoutLineBreak)
end

local function outputCountsToDialog(colorDataList)
  local dialogTitle = DIALOG_TITLE_PREFIX

  if totalNumPixels ~= nil then
    dialogTitle = dialogTitle .. " (Total # Pixels: " .. tostring(totalNumPixels) .. ")"
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

    dlg:label {
        id=labelId,
        label="Count:",
        text=colorData.count
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

-- Time script and activate main script function
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
