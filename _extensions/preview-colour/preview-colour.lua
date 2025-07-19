--[[
# MIT License
#
# Copyright (c) 2025 Mickaël Canouil
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
]]

local function is_empty(s)
  return s == nil or s == ''
end

local preview_colour_meta = {
  ["text"] = true,
  ["code"] = true
}

function RGBtoHTML(rgb)
  local r, g, b = rgb:match("rgb%((%d+)%s*,%s*(%d+)%s*,%s*(%d+)%)")
  r = tonumber(r)
  g = tonumber(g)
  b = tonumber(b)
  return string.upper(string.format("#%02x%02x%02x", r, g, b))
end

function RGBPercentToHTML(rgb)
  local r, g, b = rgb:match("rgb%((%d+)%s*%%%s*,%s*(%d+)%s*%%%s*,%s*(%d+)%s*%%%s*%)")
  r = math.floor(tonumber(r) * 255 / 100 + 0.5)
  g = math.floor(tonumber(g) * 255 / 100 + 0.5)
  b = math.floor(tonumber(b) * 255 / 100 + 0.5)
  return string.upper(string.format("#%02x%02x%02x", r, g, b))
end

function HSLtoHTML(hsl)
  local h, s, l = hsl:match("hsl%((%d+)%s*,%s*(%d+)%%%s*,%s*(%d+)%%%s*%)")
  h = tonumber(h) / 360
  s = tonumber(s) / 100
  l = tonumber(l) / 100
  
  local function hue_to_rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1/6 then return p + (q - p) * 6 * t end
    if t < 1/2 then return q end
    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
    return p
  end
  
  local r, g, b
  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue_to_rgb(p, q, h + 1/3)
    g = hue_to_rgb(p, q, h)
    b = hue_to_rgb(p, q, h - 1/3)
  end
  
  r = math.floor(r * 255 + 0.5)
  g = math.floor(g * 255 + 0.5)
  b = math.floor(b * 255 + 0.5)
  
  return string.upper(string.format("#%02x%02x%02x", r, g, b))
end

function HWBtoHTML(hwb)
  local h, w, b = hwb:match("hwb%((%d+)%s+(%d+)%%%s+(%d+)%%%s*%)")
  h = tonumber(h)
  w = tonumber(w) / 100
  b = tonumber(b) / 100
  
  -- Normalize whiteness and blackness
  local sum = w + b
  if sum > 1 then
    w = w / sum
    b = b / sum
  end
  
  -- Convert HWB to RGB
  -- First convert hue to RGB (assuming full saturation and 50% lightness)
  h = h / 360
  local function hue_to_rgb(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1/6 then return p + (q - p) * 6 * t end
    if t < 1/2 then return q end
    if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
    return p
  end
  
  local r, g, b_color
  local q = 1
  local p = 0
  r = hue_to_rgb(p, q, h + 1/3)
  g = hue_to_rgb(p, q, h)
  b_color = hue_to_rgb(p, q, h - 1/3)
  
  -- Apply whiteness and blackness
  r = r * (1 - w - b) + w
  g = g * (1 - w - b) + w
  b_color = b_color * (1 - w - b) + w
  
  r = math.floor(r * 255 + 0.5)
  g = math.floor(g * 255 + 0.5)
  b_color = math.floor(b_color * 255 + 0.5)
  
  return string.upper(string.format("#%02x%02x%02x", r, g, b_color))
end

function escape_latex(text)
  -- Escape special LaTeX characters
  -- Note: Order matters - backslash must be escaped first
  text = string.gsub(text, "\\", "\\textbackslash{}")
  text = string.gsub(text, "%{", "\\{")
  text = string.gsub(text, "%}", "\\}")
  text = string.gsub(text, "%$", "\\$")
  text = string.gsub(text, "%&", "\\&")
  text = string.gsub(text, "%%", "\\%%")  -- Escape % in replacement string
  text = string.gsub(text, "%#", "\\#")
  text = string.gsub(text, "%^", "\\textasciicircum{}")
  text = string.gsub(text, "%_", "\\_")
  text = string.gsub(text, "~", "\\textasciitilde{}")
  return text
end

function escape_lua_pattern(text)
  -- Escape special Lua pattern characters for use in string.gsub
  text = string.gsub(text, "%%", "%%%%")  -- % must be escaped first
  text = string.gsub(text, "%^", "%%^")
  text = string.gsub(text, "%$", "%%$")
  text = string.gsub(text, "%(", "%%(")
  text = string.gsub(text, "%)", "%%)")
  text = string.gsub(text, "%.", "%%.")
  text = string.gsub(text, "%[", "%%[")
  text = string.gsub(text, "%]", "%%]")
  text = string.gsub(text, "%*", "%%*")
  text = string.gsub(text, "%+", "%%+")
  text = string.gsub(text, "%-", "%%-")
  text = string.gsub(text, "%?", "%%?")
  return text
end

function expand_hex_colour(hex)
  -- Convert 3-character hex to 6-character hex (e.g., #123 -> #112233)
  if string.len(hex) == 4 then  -- #123 format
    return string.gsub(hex, "#(%x)(%x)(%x)", "#%1%1%2%2%3%3")
  end
  return hex  -- Already 6-character or other format
end

function get_colour_preview_meta(meta)
  local preview_colour_text = true
  local preview_colour_code = true
  if not is_empty(meta['preview-colour']) then
    if not is_empty(meta['preview-colour']['text']) then
      preview_colour_text = meta['preview-colour']['text']
    end
    if not is_empty(meta['preview-colour']['code']) then
      preview_colour_code = meta['preview-colour']['code']
    end
  end
  meta['preview-colour'] = {
    ["text"] = preview_colour_text,
    ["code"] = preview_colour_code
  }
  preview_colour_meta = meta['preview-colour']
  return meta
end

function get_colour(element)
  function get_hex_color(n)
    return '#' .. string.rep('[0-9a-fA-F]', n)
  end

  local hex = nil
  local original_colour_text = nil
  
  for i = 6, 3, -1 do
    hex = element.text:match('(' .. get_hex_color(i) .. ')')
    if (i == 5 or i == 4) and hex ~= nil then
      hex = nil
      break
    end
    if hex ~= nil and (i == 6 or i == 3) then
      original_colour_text = hex
      break
    end
  end
  if hex == nil then
    original_colour_text = element.text:match('(rgb%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%))')
    if original_colour_text ~= nil then
      hex = RGBtoHTML(original_colour_text)
    end
  end
  if hex == nil then
    original_colour_text = element.text:match('(rgb%s*%(%s*%d+%s*%%%s*,%s*%d+%s*%%%s*,%s*%d+%s*%%%s*%))')
    if original_colour_text ~= nil then
      hex = RGBPercentToHTML(original_colour_text)
    end
  end
  if hex == nil then
    original_colour_text = element.text:match('(hsl%s*%(%s*%d+%s*,%s*%d+%s*%%,%s*%d+%s*%%s*%))')
    if original_colour_text ~= nil then
      hex = HSLtoHTML(original_colour_text)
    end
  end
  if hex == nil then
    original_colour_text = element.text:match('(hwb%s*%(%s*%d+%s+%d+%%%s+%d+%%%s*%))')
    if original_colour_text ~= nil then
      hex = HWBtoHTML(original_colour_text)
    end
  end

  return hex, original_colour_text
end

function process_str(element, meta)
  if preview_colour_meta['text'] == false then
    return element
  end
  if preview_colour_meta['text'] == true then
    local hex, original_colour_text = get_colour(element)
    if hex ~= nil and original_colour_text ~= nil then
      if quarto.doc.is_format("html:js") then
        colour_preview_mark = "<span style=\"display: inline-block; color: " .. hex .. ";\">&#9673;</span>"
        local escaped_pattern = escape_lua_pattern(original_colour_text)
        local escaped_replacement = string.gsub(original_colour_text, "%%", "%%%%") .. colour_preview_mark
        new_text = string.gsub(
          element.text,
          escaped_pattern,
          escaped_replacement
        )
        return pandoc.RawInline('html', new_text)
      elseif quarto.doc.is_format("latex") then
        local hex_colour_six = expand_hex_colour(hex)
        colour_preview_mark = "\\textcolor[HTML]{" .. string.gsub(hex_colour_six, '#', '') .. "}{\\textbullet}"
        local escaped_original = escape_latex(original_colour_text)
        local escaped_pattern = escape_lua_pattern(original_colour_text)
        local escaped_replacement = string.gsub(escaped_original, "%%", "%%%%") .. colour_preview_mark
        new_text = string.gsub(
          element.text,
          escaped_pattern,
          escaped_replacement
        )
        return pandoc.RawInline('latex', new_text)
      end
    end
  end
end

function process_code(element)
  if preview_colour_meta['code'] == false then
    return element
  end
  if preview_colour_meta['code'] == true then
    local hex, original_colour_text = get_colour(element)
    if hex ~= nil and original_colour_text ~= nil then
      if quarto.doc.is_format("html:js") then
        colour_preview_mark = "<span style=\"display: inline-block; color: " .. hex .. ";\">&#9673;</span>"
        return pandoc.Span({element, pandoc.RawInline('html', colour_preview_mark)})
      elseif quarto.doc.is_format("latex") then
        local hex_colour_six = expand_hex_colour(hex)
        colour_preview_mark = "\\textcolor[HTML]{" .. string.gsub(hex_colour_six, '#', '') .. "}{\\textbullet}"
        return pandoc.Span({element, pandoc.RawInline('latex', colour_preview_mark)})
      end
    end
  end
end

return {
  {Meta = get_colour_preview_meta},
  {Str = process_str},
  {Code = process_code}
}
