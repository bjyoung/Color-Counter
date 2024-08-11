local debugMode = false
local MAX_ALPHA = 255
local MAX_SPRITE_SIZE = 1500000
local LARGE_SPRITE_ALERT_TITLE = "Large Sprite Warning"
local LARGE_SPRITE_ALERT_TEXT = "The active sprite is big. The script might take a while or freeze if you continue. Continue anyways?"
local CONTINUE_BTN_PRESSED = 1

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

local function round(num)
  return tonumber(string.format("%.4f", num))
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

-- Count number of times each RGB value is used and return as a table of RGB to count values
local function countRgbColors(image)
  local colors = {}

  if debugMode then
    print ("(x, y): [r, g, b, a]")
  end

  local num_pixels = 0

  for it in image:pixels() do
    local pixelValue = it()
    local a = app.pixelColor.rgbaA(pixelValue)

    -- Ignore semi-transparent and transparent pixels
    if a < MAX_ALPHA then
      goto continue
    end

    num_pixels = num_pixels + 1
    local r = app.pixelColor.rgbaR(pixelValue)
    local g = app.pixelColor.rgbaG(pixelValue)
    local b = app.pixelColor.rgbaB(pixelValue)
    local currColorData = ColorData:new{nil, r = r, g = g, b = b}

    if debugMode then
      print("(" .. it.x .. ", " .. it.y .. "): [" .. r .. ", " .. g .. ", " .. b .. ", " .. a .. "]")
    end

    local currHashStr = tostring(currColorData:getHash())
    local colorDataEntry = colors[currHashStr]

    if colorDataEntry ~= nil then
      colorDataEntry.count = colorDataEntry.count + 1
    else
      colors[currHashStr] = currColorData
    end

    ::continue::
  end

  print("# Pixels: " .. num_pixels)
  return colors
end

local function outputColorCounts(colorDataList)
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

local function calculate_counts()
  local image = app.image

  if image == nil then
    print("No active sprite found")
    return
  end

  if image.colorMode ~= ColorMode.RGB then
    print("Sprite color mode not set to RGB")
    return
  end

  printImageStats(image)
  local imageSize = image.width * image.height

  if imageSize >= MAX_SPRITE_SIZE then
    local warning_result = app.alert{
      title=LARGE_SPRITE_ALERT_TITLE,
      text=LARGE_SPRITE_ALERT_TEXT,
      buttons={"Continue", "Cancel"}
    }

    if warning_result ~= CONTINUE_BTN_PRESSED then
      return
    end
  end

  local colors = countRgbColors(image)
  outputColorCounts(colors)
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

local function count_pixels()
  StartClock = os.clock()
  calculate_counts()
  print("\nElapsed time is: " .. getElapsedTime() .. "s")
end

function init(plugin)
  print("Initializing Colors Counter")

  plugin:newCommand {
    id="CountColors",
    title="Count Colors",
    group="sprite_properties",
    onclick=count_pixels
  }
end

function exit(plugin)
  print("Closing Color Counter")
end