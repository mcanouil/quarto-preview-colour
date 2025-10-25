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

--- Extension name constant
local EXTENSION_NAME = "preview-colour"

--- Load utils and colour modules
local utils = require(quarto.utils.resolve_path("_modules/utils.lua"):gsub("%.lua$", ""))
local colour = require(quarto.utils.resolve_path("_modules/colour.lua"):gsub("%.lua$", ""))

--- Flag to track if deprecation warning has been shown.
--- @type boolean
local deprecation_warning_shown = false

--- Default configuration for preview colour features.
--- @type table<string, boolean>
local preview_colour_meta = {
  ["text"] = false,
  ["code"] = true
}

--- Check for deprecated top-level preview-colour configuration and emit warning if found.
--- @param meta table<string, any> Document metadata table.
--- @param key string The configuration key being accessed.
--- @return boolean|nil The value from deprecated config, or nil if not found.
local function check_deprecated_config(meta, key)
  local value
  value, deprecation_warning_shown = utils.check_deprecated_config(meta, 'preview-colour', key, deprecation_warning_shown)
  return value
end

--- Get preview-colour option from metadata with deprecation support.
--- @param key string The option name to retrieve.
--- @param meta table<string, any> Document metadata table.
--- @return boolean The option value as a boolean.
local function get_preview_colour_option(key, meta)
  -- Check new nested structure: extensions.preview-colour.key
  local meta_value = utils.get_metadata_value(meta, 'preview-colour', key)
  if not utils.is_empty(meta_value) then
    return meta_value
  end

  -- Check deprecated top-level structure: preview-colour.key (with warning)
  local deprecated_value = check_deprecated_config(meta, key)
  if deprecated_value ~= nil then
    return deprecated_value
  end

  -- Return default values: code: true, text: false
  if key == 'code' then
    return true
  elseif key == 'text' then
    return false
  end

  return true -- fallback for any other keys
end


--- Create colour preview mark for HTML format.
--- @param hex string Hex colour code.
--- @return string HTML colour preview mark.
local function create_html_colour_mark(hex)
  return '<span style="display: inline-block; color: ' ..
      hex ..
      '; cursor: pointer; user-select: none; -webkit-user-select: none; -moz-user-select: none; -ms-user-select: none; position: relative;" title="Colour preview: ' ..
      hex ..
      ' (click to copy)" aria-label="Colour preview: ' ..
      hex ..
      ' (click to copy)" onclick="navigator.clipboard.writeText(\'' ..
      hex ..
      '\').then(() => { const span = this; const originalTitle = span.title; span.title = \'Copied: ' ..
      hex ..
      '\'; let tooltip = document.createElement(\'div\'); tooltip.textContent = \'Copied!\'; tooltip.style.cssText = \'position:absolute;top:-30px;left:50%;transform:translateX(-50%);background:#333;color:white;padding:4px 8px;border-radius:4px;font-size:12px;font-family:sans-serif;white-space:nowrap;z-index:9999;box-shadow:0 2px 4px rgba(0,0,0,0.3);pointer-events:none;\'; span.appendChild(tooltip); setTimeout(() => { span.title = originalTitle; if (span.contains(tooltip)) span.removeChild(tooltip); }, 1500); }).catch(() => console.error(\'Failed to copy colour code\'));">&#9673;</span>'
end

--- Create colour preview mark for LaTeX format.
--- @param hex string Hex colour code.
--- @return string LaTeX colour preview mark.
local function create_latex_colour_mark(hex)
  local hex_colour_six = colour.expand_hex_colour(hex)
  return "\\textcolor[HTML]{" .. string.gsub(hex_colour_six, '#', '') .. "}{\\textbullet}"
end

--- Create colour preview mark for Typst format.
--- @param hex string Hex colour code.
--- @return string Typst colour preview mark.
local function create_typst_colour_mark(hex)
  local hex_colour_six = colour.expand_hex_colour(hex)
  return '#text(fill: rgb("' .. string.lower(hex_colour_six) .. '"))[◉]'
end

--- Create colour preview mark for DOCX format using OpenXML.
--- @param hex string Hex colour code.
--- @return string DOCX colour preview mark using OpenXML.
local function create_docx_colour_mark(hex)
  local hex_colour_six = colour.expand_hex_colour(hex)
  local hex_without_hash = string.gsub(hex_colour_six, '#', '')
  return '<w:r><w:rPr><w:color w:val="' .. hex_without_hash .. '"/></w:rPr><w:t>●</w:t></w:r>'
end

--- Create colour preview mark for PPTX format using OpenXML.
--- @param hex string Hex colour code.
--- @return string PPTX colour preview mark using OpenXML.
local function create_pptx_colour_mark(hex)
  local hex_colour_six = colour.expand_hex_colour(hex)
  local hex_without_hash = string.gsub(hex_colour_six, '#', '')
  return '<a:r><a:rPr dirty="0"><a:solidFill><a:srgbClr val="' ..
      hex_without_hash .. '" /></a:solidFill></a:rPr><a:t>●</a:t></a:r>'
end

local function create_colour_mark(hex, format)
  local colour_mark_functions = {
    html = create_html_colour_mark,
    latex = create_latex_colour_mark,
    typst = create_typst_colour_mark,
    docx = create_docx_colour_mark,
    pptx = create_pptx_colour_mark
  }

  local create_mark = colour_mark_functions[format]
  if create_mark then
    return create_mark(hex)
  else
    error('Unsupported format: ' .. format)
  end
end

--- Extract colour information from a pandoc element.
--- @param element table Pandoc element containing text to analyse.
--- @return string|nil Extracted hex colour code or nil if no colour found.
--- @return string|nil Original colour text that was matched.
local function get_colour(element)
  --- Generate hex colour pattern for matching.
  --- @param n number Number of hex characters to match.
  --- @return string Lua pattern for matching hex colours.
  local function get_hex_colour(n)
    return '#' .. string.rep('[0-9a-fA-F]', n)
  end

  local hex6 = element.text:match(get_hex_colour(6))
  local matches = {}
  if hex6 then
    for match in string.gmatch(element.text, get_hex_colour(6)) do
      table.insert(matches, { name = 'hex6', value = match })
    end
  else
    local hex3 = element.text:match(get_hex_colour(3))
    if hex3 then
      for match in string.gmatch(element.text, get_hex_colour(3)) do
        table.insert(matches, { name = 'hex3', value = match })
      end
    end
  end
  -- Now check other patterns (skip hex6/hex3).
  local patterns = {
    { name = 'rgb',         pattern = 'rgb%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)' },
    { name = 'rgb_percent', pattern = 'rgb%s*%(%s*%d+%s*%%%s*,%s*%d+%s*%%%s*,%s*%d+%s*%%%s*%)' },
    { name = 'hsl',         pattern = 'hsl%s*%(%s*%d+%s*,%s*%d+%s*%%,%s*%d+%s*%%s*%)' },
    { name = 'hwb',         pattern = 'hwb%s*%(%s*%d+%s+%d+%%%s+%d+%%%s*%)' }
  }
  for _, pat in ipairs(patterns) do
    for match in string.gmatch(element.text, pat.pattern) do
      table.insert(matches, { name = pat.name, value = match })
    end
  end

  local hex = nil
  local original_colour_text = nil
  if #matches > 1 then
    utils.log_warning(
      EXTENSION_NAME,
      'Multiple colour matches found in text: "' .. utils.stringify(element.text) .. '". ' ..
      'No colour preview will be generated.'
    )
    return nil, nil -- More than one colour match found, return nil.
  end

  for _, match in ipairs(matches) do
    original_colour_text = match.value
    hex = colour.to_html(match.value, match.name)
  end

  -- Check if the matched colour text is the entire element text.
  -- This prevents partial matches from being considered valid.
  -- https://github.com/mcanouil/quarto-preview-colour/issues/24
  if #matches == 1 and #matches[1].value ~= #element.text then
    return nil, nil
  end

  return hex, original_colour_text
end

--- Process text replacement for string elements with colour previews.
--- @param element table Pandoc element containing text.
--- @param format string Output format name.
--- @param colour_mark string Colour preview mark for the format.
--- @param original_colour_text string|nil Original colour text found in element.
--- @return table Modified pandoc element.
local function process_element(element, format, colour_mark, original_colour_text)
  if element.t ~= "Str" and element.t ~= "Code" then
    return element -- Return original element if not a Str or Code.
  end

  if element.t == "Code" and colour_mark ~= nil then
    return pandoc.Span({ element, pandoc.RawInline(format, colour_mark) })
  end

  if element.t == "Str" and original_colour_text ~= nil and colour_mark ~= nil then
    -- For OpenXML formats (DOCX/PPTX), we need to return a Span with separate elements.
    if format == "openxml" then
      local escaped_pattern = utils.escape_text(original_colour_text, "lua")
      local escaped_replacement = string.gsub(original_colour_text, "%%", "%%%%")
      local new_text = string.gsub(element.text, escaped_pattern, escaped_replacement)
      return pandoc.Span({
        pandoc.Str(new_text),
        pandoc.RawInline(format, colour_mark)
      })
    end

    -- For other formats (LaTeX, Typst), use the existing concatenation approach.
    local escaped_original = original_colour_text
    if format == "latex" or format == "typst" then
      escaped_original = utils.escape_text(original_colour_text, format)
    end

    local escaped_pattern = utils.escape_text(original_colour_text, "lua")
    local escaped_colour_mark = string.gsub(colour_mark, "%%", "%%%%")
    local escaped_replacement = string.gsub(escaped_original, "%%", "%%%%") .. escaped_colour_mark
    local new_text = string.gsub(element.text, escaped_pattern, escaped_replacement)

    return pandoc.RawInline(format, new_text)
  end

  return element
end

--- Add a colour preview mark to a Pandoc element if a valid colour is found.
--- Handles multiple output formats (HTML, LaTeX, Typst, DOCX, PPTX).
--- @param element table Pandoc Str or Code element to process.
--- @return table Pandoc element (Str, Code, RawInline, or Span) with colour preview if a valid colour is found, otherwise the original element.
local function add_colour_mark(element)
  local hex, original_colour_text = get_colour(element)
  if hex == nil then
    return element -- No valid colour found, return original element.
  end
  local format, language = utils.get_quarto_format()
  if format == "unknown" then
    utils.log_warning(
      EXTENSION_NAME,
      'Unsupported output format for colour preview: "' .. language .. '". ' ..
      'No colour preview will be generated.'
    )
    return element -- Unsupported format, return original element.
  end
  return process_element(element, language, create_colour_mark(hex, format), original_colour_text)
end

--- Extract and configure colour preview settings from document metadata.
--- @param meta table<string, any> Document metadata table.
--- @return table<string, any> Updated metadata table with preview-colour configuration.
local function get_colour_preview_meta(meta)
  local preview_colour_text = get_preview_colour_option('text', meta)
  local preview_colour_code = get_preview_colour_option('code', meta)

  meta['extensions']['preview-colour'] = {
    ["text"] = preview_colour_text,
    ["code"] = preview_colour_code
  }
  preview_colour_meta = meta['extensions']['preview-colour']
  return meta
end

--- Process string elements to add colour previews in text.
--- @param element table Pandoc Str element.
--- @return table|nil Modified pandoc element with colour preview, or original element.
local function process_str(element)
  if preview_colour_meta['text'] == false then
    return element
  end

  return add_colour_mark(element)
end

--- Process code elements to add colour previews.
--- @param element table Pandoc Code element.
--- @return table|nil Modified pandoc element with colour preview, or original element.
local function process_code(element)
  if preview_colour_meta['code'] == false then
    return element
  end

  return add_colour_mark(element)
end

--- Pandoc filter configuration.
--- Defines the processing pipeline for different pandoc elements.
--- @return table Filter table for Pandoc.
return {
  { Meta = get_colour_preview_meta },
  { Str = process_str },
  { Code = process_code }
}
