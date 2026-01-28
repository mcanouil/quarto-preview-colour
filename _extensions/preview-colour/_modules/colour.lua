--[[
# MIT License
#
# Copyright (c) 2026 Mickaël Canouil
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
]]

--- MC Colour - Colour conversion utilities for Quarto Lua filters and shortcodes
--- @module colour
--- @author Mickaël Canouil
--- @version 1.0.0

local colour_module = {}

-- ============================================================================
-- CSS NAMED COLOURS
-- ============================================================================

--- CSS Named Colours lookup table (CSS Level 4 specification).
--- Maps colour names (lowercase) to hex values.
--- @type table<string, string>
local CSS_NAMED_COLOURS = {
  -- Basic colours
  black = "#000000",
  silver = "#C0C0C0",
  gray = "#808080",
  grey = "#808080",
  white = "#FFFFFF",
  maroon = "#800000",
  red = "#FF0000",
  purple = "#800080",
  fuchsia = "#FF00FF",
  green = "#008000",
  lime = "#00FF00",
  olive = "#808000",
  yellow = "#FFFF00",
  navy = "#000080",
  blue = "#0000FF",
  teal = "#008080",
  aqua = "#00FFFF",
  -- Extended colours (CSS Level 3/4)
  aliceblue = "#F0F8FF",
  antiquewhite = "#FAEBD7",
  aquamarine = "#7FFFD4",
  azure = "#F0FFFF",
  beige = "#F5F5DC",
  bisque = "#FFE4C4",
  blanchedalmond = "#FFEBCD",
  blueviolet = "#8A2BE2",
  brown = "#A52A2A",
  burlywood = "#DEB887",
  cadetblue = "#5F9EA0",
  chartreuse = "#7FFF00",
  chocolate = "#D2691E",
  coral = "#FF7F50",
  cornflowerblue = "#6495ED",
  cornsilk = "#FFF8DC",
  crimson = "#DC143C",
  cyan = "#00FFFF",
  darkblue = "#00008B",
  darkcyan = "#008B8B",
  darkgoldenrod = "#B8860B",
  darkgray = "#A9A9A9",
  darkgrey = "#A9A9A9",
  darkgreen = "#006400",
  darkkhaki = "#BDB76B",
  darkmagenta = "#8B008B",
  darkolivegreen = "#556B2F",
  darkorange = "#FF8C00",
  darkorchid = "#9932CC",
  darkred = "#8B0000",
  darksalmon = "#E9967A",
  darkseagreen = "#8FBC8F",
  darkslateblue = "#483D8B",
  darkslategray = "#2F4F4F",
  darkslategrey = "#2F4F4F",
  darkturquoise = "#00CED1",
  darkviolet = "#9400D3",
  deeppink = "#FF1493",
  deepskyblue = "#00BFFF",
  dimgray = "#696969",
  dimgrey = "#696969",
  dodgerblue = "#1E90FF",
  firebrick = "#B22222",
  floralwhite = "#FFFAF0",
  forestgreen = "#228B22",
  gainsboro = "#DCDCDC",
  ghostwhite = "#F8F8FF",
  gold = "#FFD700",
  goldenrod = "#DAA520",
  greenyellow = "#ADFF2F",
  honeydew = "#F0FFF0",
  hotpink = "#FF69B4",
  indianred = "#CD5C5C",
  indigo = "#4B0082",
  ivory = "#FFFFF0",
  khaki = "#F0E68C",
  lavender = "#E6E6FA",
  lavenderblush = "#FFF0F5",
  lawngreen = "#7CFC00",
  lemonchiffon = "#FFFACD",
  lightblue = "#ADD8E6",
  lightcoral = "#F08080",
  lightcyan = "#E0FFFF",
  lightgoldenrodyellow = "#FAFAD2",
  lightgray = "#D3D3D3",
  lightgrey = "#D3D3D3",
  lightgreen = "#90EE90",
  lightpink = "#FFB6C1",
  lightsalmon = "#FFA07A",
  lightseagreen = "#20B2AA",
  lightskyblue = "#87CEFA",
  lightslategray = "#778899",
  lightslategrey = "#778899",
  lightsteelblue = "#B0C4DE",
  lightyellow = "#FFFFE0",
  limegreen = "#32CD32",
  linen = "#FAF0E6",
  magenta = "#FF00FF",
  mediumaquamarine = "#66CDAA",
  mediumblue = "#0000CD",
  mediumorchid = "#BA55D3",
  mediumpurple = "#9370DB",
  mediumseagreen = "#3CB371",
  mediumslateblue = "#7B68EE",
  mediumspringgreen = "#00FA9A",
  mediumturquoise = "#48D1CC",
  mediumvioletred = "#C71585",
  midnightblue = "#191970",
  mintcream = "#F5FFFA",
  mistyrose = "#FFE4E1",
  moccasin = "#FFE4B5",
  navajowhite = "#FFDEAD",
  oldlace = "#FDF5E6",
  olivedrab = "#6B8E23",
  orange = "#FFA500",
  orangered = "#FF4500",
  orchid = "#DA70D6",
  palegoldenrod = "#EEE8AA",
  palegreen = "#98FB98",
  paleturquoise = "#AFEEEE",
  palevioletred = "#DB7093",
  papayawhip = "#FFEFD5",
  peachpuff = "#FFDAB9",
  peru = "#CD853F",
  pink = "#FFC0CB",
  plum = "#DDA0DD",
  powderblue = "#B0E0E6",
  rebeccapurple = "#663399",
  rosybrown = "#BC8F8F",
  royalblue = "#4169E1",
  saddlebrown = "#8B4513",
  salmon = "#FA8072",
  sandybrown = "#F4A460",
  seagreen = "#2E8B57",
  seashell = "#FFF5EE",
  sienna = "#A0522D",
  skyblue = "#87CEEB",
  slateblue = "#6A5ACD",
  slategray = "#708090",
  slategrey = "#708090",
  snow = "#FFFAFA",
  springgreen = "#00FF7F",
  steelblue = "#4682B4",
  tan = "#D2B48C",
  thistle = "#D8BFD8",
  tomato = "#FF6347",
  turquoise = "#40E0D0",
  violet = "#EE82EE",
  wheat = "#F5DEB3",
  whitesmoke = "#F5F5F5",
  yellowgreen = "#9ACD32"
}

--- Check if a string is a valid CSS named colour.
--- @param name string The potential colour name.
--- @return boolean True if valid CSS colour name.
function colour_module.is_named_colour(name)
  if type(name) ~= "string" then
    return false
  end
  return CSS_NAMED_COLOURS[string.lower(name)] ~= nil
end

--- Convert CSS named colour to HTML hex format.
--- @param name string The CSS colour name (case-insensitive).
--- @return string|nil HTML hex colour code or nil if not found.
function colour_module.named_to_HTML(name)
  if type(name) ~= "string" then
    return nil
  end
  return CSS_NAMED_COLOURS[string.lower(name)]
end

-- ============================================================================
-- COLOUR CONVERSION UTILITIES
-- ============================================================================

--- Expand 3-character hex colour to 6-character format.
--- @param hex string Hex colour code (either #123 or #123456 format)
--- @return string 6-character hex colour code (e.g., #123 becomes #112233)
function colour_module.expand_hex_colour(hex)
  if string.len(hex) == 4 then
    return (string.gsub(hex, "#(%x)(%x)(%x)", "#%1%1%2%2%3%3"))
  end
  return hex
end

--- Convert RGB colour notation to HTML hex format.
--- @param rgb string RGB colour string in format "rgb(r, g, b)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function colour_module.RGB_to_HTML(rgb)
  local r, g, b = rgb:match("rgb%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
  r = tonumber(r)
  g = tonumber(g)
  b = tonumber(b)
  return string.upper(string.format("#%02x%02x%02x", r, g, b))
end

--- Convert RGB percentage notation to HTML hex format.
--- @param rgb string RGB colour string in format "rgb(r%, g%, b%)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function colour_module.RGBPercent_to_HTML(rgb)
  local r, g, b = rgb:match("rgb%((%d+)%s*%%%s*,%s*(%d+)%s*%%%s*,%s*(%d+)%s*%%%s*%)")
  r = math.floor(tonumber(r) * 255 / 100 + 0.5)
  g = math.floor(tonumber(g) * 255 / 100 + 0.5)
  b = math.floor(tonumber(b) * 255 / 100 + 0.5)
  return string.upper(string.format("#%02x%02x%02x", r, g, b))
end

--- Helper function to convert hue to RGB component.
--- @param p number
--- @param q number
--- @param t number
--- @return number RGB component value
function colour_module.hue_to_rgb(p, q, t)
  if t < 0 then t = t + 1 end
  if t > 1 then t = t - 1 end
  if t < 1 / 6 then return p + (q - p) * 6 * t end
  if t < 1 / 2 then return q end
  if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
  return p
end

--- Convert HSL colour notation to HTML hex format.
--- @param hsl string HSL colour string in format "hsl(h, s%, l%)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function colour_module.HSL_to_HTML(hsl)
  local h, s, l = hsl:match("hsl%((%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*%)")
  h = tonumber(h) / 360
  s = tonumber(s) / 100
  l = tonumber(l) / 100

  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = colour_module.hue_to_rgb(p, q, h + 1 / 3)
    g = colour_module.hue_to_rgb(p, q, h)
    b = colour_module.hue_to_rgb(p, q, h - 1 / 3)
  end

  r = math.floor(r * 255 + 0.5)
  g = math.floor(g * 255 + 0.5)
  b = math.floor(b * 255 + 0.5)

  return string.upper(string.format("#%02x%02x%02x", r, g, b))
end

--- Convert HWB colour notation to HTML hex format.
--- @param hwb string HWB colour string in format "hwb(h w% b%)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function colour_module.HWB_to_HTML(hwb)
  local h, w, b = hwb:match("hwb%((%d+)%s+(%d+)%%%s+(%d+)%%%s*%)")
  h = tonumber(h)
  w = tonumber(w) / 100
  b = tonumber(b) / 100

  local sum = w + b
  if sum > 1 then
    w = w / sum
    b = b / sum
  end

  h = h / 360

  local r, g, b_colour
  local q = 1
  local p = 0
  r = colour_module.hue_to_rgb(p, q, h + 1 / 3)
  g = colour_module.hue_to_rgb(p, q, h)
  b_colour = colour_module.hue_to_rgb(p, q, h - 1 / 3)

  r = r * (1 - w - b) + w
  g = g * (1 - w - b) + w
  b_colour = b_colour * (1 - w - b) + w

  r = math.floor(r * 255 + 0.5)
  g = math.floor(g * 255 + 0.5)
  b_colour = math.floor(b_colour * 255 + 0.5)

  return string.upper(string.format("#%02x%02x%02x", r, g, b_colour))
end

--- Convert a colour code to HTML format based on its format type.
--- @param code string The colour code to convert
--- @param format string The colour format (e.g., "hwb", "hsl", "rgb", "rgb_percent", "hex")
--- @return string HTML hex colour code
function colour_module.to_html(code, format)
  local converters = {
    hwb = colour_module.HWB_to_HTML,
    hsl = colour_module.HSL_to_HTML,
    rgb = colour_module.RGB_to_HTML,
    rgb_percent = colour_module.RGBPercent_to_HTML,
    hex = colour_module.expand_hex_colour,
    hex3 = colour_module.expand_hex_colour,
    hex6 = colour_module.expand_hex_colour,
    named = colour_module.named_to_HTML
  }

  local converter = converters[format]
  if converter then
    return converter(code)
  else
    error("Unsupported colour format: " .. format)
  end
end

-- ============================================================================
-- MODULE EXPORT
-- ============================================================================

return colour_module
