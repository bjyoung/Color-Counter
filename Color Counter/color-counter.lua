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
  local numPixels = width * height

  print("Width: " .. width)
  print("Height: " .. height)
  print("# Pixels: " .. numPixels)
end

-- Count number of times each RGB value is used and return as a table of RGB to count values
local function countColors(image)
  local colors = {}

  if debugMode then
    print ("(x, y): [r, g, b, a]")
  end

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
        break
      end
    end

    if colorExists == false then
      colors[rgb] = 1
    end
      ::continue::
  end

  return colors
end

local function outputColorCounts(colors)
  printDottedLine(true)
  print("Color counts (RGB):")
  printDottedLine(false)

  for rgb, count  in pairs(colors) do
    print("(" .. rgb[1] .. ", " .. rgb[2] .. ", " .. rgb[3] .. "): " .. count)
  end

  printDottedLine(false)
end

local function calculate_counts()
  local image = app.image

  if image == nil then
    print("No active sprite found")
    return
  end

  printImageStats(image)
  local colors = countColors(image)
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