--- MC Colour - Colour conversion utilities for Quarto Lua filters and shortcodes
--- @module colour
--- @license MIT
--- @copyright 2026 Mickaël Canouil
--- @author Mickaël Canouil
--- @version 1.0.0

local M = {}

-- ============================================================================
-- COLOUR CONVERSION UTILITIES
-- ============================================================================

--- Expand 3-character hex colour to 6-character format.
--- @param hex string Hex colour code (either #123 or #123456 format)
--- @return string 6-character hex colour code (e.g., #123 becomes #112233)
function M.expand_hex_colour(hex)
  if string.len(hex) == 4 then
    return (string.gsub(hex, "#(%x)(%x)(%x)", "#%1%1%2%2%3%3"))
  end
  return hex
end

--- Convert RGB colour notation to HTML hex format.
--- @param rgb string RGB colour string in format "rgb(r, g, b)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function M.RGB_to_HTML(rgb)
  local r, g, b = rgb:match("rgb%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
  r = tonumber(r)
  g = tonumber(g)
  b = tonumber(b)
  return string.upper(string.format("#%02x%02x%02x", r, g, b))
end

--- Convert RGB percentage notation to HTML hex format.
--- @param rgb string RGB colour string in format "rgb(r%, g%, b%)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function M.RGBPercent_to_HTML(rgb)
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
function M.hue_to_rgb(p, q, t)
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
function M.HSL_to_HTML(hsl)
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
    r = M.hue_to_rgb(p, q, h + 1 / 3)
    g = M.hue_to_rgb(p, q, h)
    b = M.hue_to_rgb(p, q, h - 1 / 3)
  end

  r = math.floor(r * 255 + 0.5)
  g = math.floor(g * 255 + 0.5)
  b = math.floor(b * 255 + 0.5)

  return string.upper(string.format("#%02x%02x%02x", r, g, b))
end

--- Convert HWB colour notation to HTML hex format.
--- @param hwb string HWB colour string in format "hwb(h w% b%)"
--- @return string HTML hex colour code in uppercase format (e.g., "#FF0000")
function M.HWB_to_HTML(hwb)
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
  r = M.hue_to_rgb(p, q, h + 1 / 3)
  g = M.hue_to_rgb(p, q, h)
  b_colour = M.hue_to_rgb(p, q, h - 1 / 3)

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
function M.to_html(code, format)
  local converters = {
    hwb = M.HWB_to_HTML,
    hsl = M.HSL_to_HTML,
    rgb = M.RGB_to_HTML,
    rgb_percent = M.RGBPercent_to_HTML,
    hex = M.expand_hex_colour,
    hex3 = M.expand_hex_colour,
    hex6 = M.expand_hex_colour
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

return M
