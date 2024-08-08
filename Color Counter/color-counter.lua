local debugMode = false
local MAX_ALPHA = 255

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

-- Where rgb is a table containing 3 elements (R, G, B) that are between 0 and 255 inclusive
local function hash(rgb)
  return 1000000000 + rgb[1] * 1000000 + rgb[2] * 1000 + rgb[3]
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

    local r = app.pixelColor.rgbaR(pixelValue)
    local g = app.pixelColor.rgbaG(pixelValue)
    local b = app.pixelColor.rgbaB(pixelValue)

    if debugMode then
      print("(" .. it.x .. ", " .. it.y .. "): [" .. r .. ", " .. g .. ", " .. b .. ", " .. a .. "]")
    end

    local rgb = { r, g, b }
    local colorExists = false

    for color, count in pairs(colors) do
      if color[1] == rgb[1] and color[2] == rgb[2] and color[3] == rgb[3] then
        colors[color] = count + 1
        colorExists = true
        num_pixels = num_pixels + 1
        break
      end
    end

    if colorExists == false then
      colors[rgb] = 1
      num_pixels = num_pixels + 1
    end

    ::continue::
  end

  print("# Pixels: " .. num_pixels)
  return colors
end

local function outputColorCounts(colors)
  local withLineBreak = true
  printDottedLine(withLineBreak)
  print("Color counts (RGB):")
  local withoutLineBreak = false
  printDottedLine(withoutLineBreak)

  for rgb, count in pairs(colors) do
    print("(" .. rgb[1] .. ", " .. rgb[2] .. ", " .. rgb[3] .. "): " .. count)
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
   local colors = countRgbColors(image)
  outputColorCounts(colors)
end

local function count_pixels()
  local startClock = os.clock()
  calculate_counts()
  local endClock = os.clock()
  local runTime = round(endClock - startClock)
  print("\nElapsed time is: " .. runTime .. "s")
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