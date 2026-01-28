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

--- Extension name constant
local EXTENSION_NAME = "preview-colour"

--- Load utils and colour modules
local utils = require(quarto.utils.resolve_path("_modules/utils.lua"):gsub("%.lua$", ""))
local colour = require(quarto.utils.resolve_path("_modules/colour.lua"):gsub("%.lua$", ""))

--- Flag to track if deprecation warning has been shown.
--- @type boolean
local deprecation_warning_shown = false

--- Flag to track if LaTeX escape warning has been shown.
--- @type boolean
local latex_escape_warning_shown = false

--- Default configuration for preview colour features.
--- @type table<string, boolean>
local preview_colour_meta = {
  ["text"] = false,
  ["code"] = true
}

--- Default glyphs for each output format.
--- @type table<string, string>
local default_glyphs = {
  ["html"] = "&#9673;",
  ["latex"] = "\\textbullet",
  ["typst"] = "◉",
  ["docx"] = "●",
  ["pptx"] = "●"
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

--- Common LaTeX glyph commands (without backslash prefix).
--- @type table<integer, string>
local latex_glyph_commands = {
  "textbullet", "bullet", "circ", "cdot", "star", "ast",
  "diamond", "bigcirc", "square", "blacksquare", "triangleright"
}

--- Check and escape LaTeX commands in glyph string.
--- Detects unescaped LaTeX commands (single backslash) and escapes them.
--- Also detects when backslash was lost (e.g., \t interpreted as tab).
--- @param glyph string The glyph string to check.
--- @return string The glyph with properly escaped LaTeX commands.
local function escape_latex_glyph(glyph)
  if glyph == nil or glyph == "" then
    return glyph
  end

  -- Debug: log the actual bytes received
  local bytes = {}
  for i = 1, math.min(#glyph, 4) do
    table.insert(bytes, string.byte(glyph, i))
  end
  quarto.log.output("[preview-colour] DEBUG glyph bytes: " .. table.concat(bytes, ", ") .. " (length: " .. #glyph .. ")")

  -- Early exit: if starts with two backslashes (byte 92), already escaped
  if string.byte(glyph, 1) == 92 and string.byte(glyph, 2) == 92 then
    return glyph
  end

  -- Check if backslash was lost (e.g., \textbullet became [TAB]extbullet)
  -- by looking for known command names preceded by a tab
  for _, cmd in ipairs(latex_glyph_commands) do
    -- Check if string starts with tab + rest of command (backslash interpreted as \t)
    local tab_pattern = "\t" .. string.sub(cmd, 2)
    if string.sub(glyph, 1, #tab_pattern) == tab_pattern then
      local escaped = "\\\\" .. cmd
      if not latex_escape_warning_shown then
        utils.log_warning(
          EXTENSION_NAME,
          'LaTeX glyph backslash was interpreted as escape sequence. ' ..
          'Automatically fixed. In YAML, use: \'\\\\' .. cmd .. '\''
        )
        latex_escape_warning_shown = true
      end
      return escaped
    end
  end

  -- Check if starts with single backslash (needs escaping)
  if string.sub(glyph, 1, 1) == "\\" then
    local escaped = "\\" .. glyph
    if not latex_escape_warning_shown then
      utils.log_warning(
        EXTENSION_NAME,
        'LaTeX glyph contains unescaped backslash. ' ..
        'Automatically escaped. In YAML, use double backslash: \'\\\\textbullet\''
      )
      latex_escape_warning_shown = true
    end
    return escaped
  end

  return glyph
end

--- Get glyph for a specific output format.
--- Checks user configuration and falls back to defaults.
--- @param format string Output format (html, latex, typst, docx, pptx).
--- @return string The glyph to use for the format.
local function get_glyph_for_format(format)
  local glyph_config = preview_colour_meta['glyph']

  if glyph_config == nil then
    return default_glyphs[format] or default_glyphs["html"]
  end

  -- In Pandoc Lua, metadata values are never plain strings.
  -- Simple string config (glyph: "●") becomes MetaInlines (table with numeric keys).
  -- Per-format config (glyph: {html: "●"}) becomes MetaMap (table with string keys).
  -- Check if it's a MetaMap by looking for string keys.
  local is_format_table = false
  if type(glyph_config) == "table" then
    for k, _ in pairs(glyph_config) do
      if type(k) == "string" then
        is_format_table = true
        break
      end
    end
  end

  local glyph = nil

  if is_format_table then
    -- Per-format configuration (MetaMap)
    if glyph_config[format] then
      glyph = utils.stringify(glyph_config[format])
    elseif glyph_config["default"] then
      glyph = utils.stringify(glyph_config["default"])
    end
  else
    -- Simple string configuration (MetaInlines) or plain string
    local glyph_str = utils.stringify(glyph_config)
    if glyph_str and glyph_str ~= "" then
      glyph = glyph_str
    end
  end

  -- Fall back to default if no glyph found
  if glyph == nil then
    return default_glyphs[format] or default_glyphs["html"]
  end

  -- For LaTeX format, check for unescaped commands and escape them
  if format == "latex" then
    glyph = escape_latex_glyph(glyph)
  end

  return glyph
end


--- Create colour preview mark for HTML format.
--- @param hex string Hex colour code.
--- @param glyph string Glyph character to use for the preview.
--- @return string HTML colour preview mark.
local function create_html_colour_mark(hex, glyph)
  return '<span style="font-size: 1lh; font-family: system-ui, sans-serif; color: ' ..
      hex ..
      '; cursor: pointer; user-select: none; -webkit-user-select: none; -moz-user-select: none; -ms-user-select: none; position: relative;" title="Colour preview: ' ..
      hex ..
      ' (click to copy)" aria-label="Colour preview: ' ..
      hex ..
      ' (click to copy)" onclick="navigator.clipboard.writeText(\'' ..
      hex ..
      '\').then(() => { const span = this; const originalTitle = span.title; span.title = \'Copied: ' ..
      hex ..
      '\'; let tooltip = document.createElement(\'div\'); tooltip.textContent = \'Copied!\'; tooltip.style.cssText = \'position:absolute;top:-30px;left:50%;transform:translateX(-50%);background:#333;color:white;padding:4px 8px;border-radius:4px;font-size:12px;font-family:sans-serif;white-space:nowrap;z-index:9999;box-shadow:0 2px 4px rgba(0,0,0,0.3);pointer-events:none;\'; span.appendChild(tooltip); setTimeout(() => { span.title = originalTitle; if (span.contains(tooltip)) span.removeChild(tooltip); }, 1500); }).catch(() => console.error(\'Failed to copy colour code\'));">' .. glyph .. '</span>'
end

--- Create colour preview mark for LaTeX format.
--- @param hex string Hex colour code.
--- @param glyph string Glyph character to use for the preview.
--- @return string LaTeX colour preview mark.
local function create_latex_colour_mark(hex, glyph)
  local hex_colour_six = colour.expand_hex_colour(hex)
  return "\\textcolor[HTML]{" .. string.gsub(hex_colour_six, '#', '') .. "}{" .. glyph .. "}"
end

--- Create colour preview mark for Typst format.
--- @param hex string Hex colour code.
--- @param glyph string Glyph character to use for the preview.
--- @return string Typst colour preview mark.
local function create_typst_colour_mark(hex, glyph)
  local hex_colour_six = colour.expand_hex_colour(hex)
  return '#text(fill: rgb("' .. string.lower(hex_colour_six) .. '"))[' .. glyph .. ']'
end

--- Create colour preview mark for DOCX format using OpenXML.
--- @param hex string Hex colour code.
--- @param glyph string Glyph character to use for the preview.
--- @return string DOCX colour preview mark using OpenXML.
local function create_docx_colour_mark(hex, glyph)
  local hex_colour_six = colour.expand_hex_colour(hex)
  local hex_without_hash = string.gsub(hex_colour_six, '#', '')
  return '<w:r><w:rPr><w:color w:val="' .. hex_without_hash .. '"/></w:rPr><w:t>' .. glyph .. '</w:t></w:r>'
end

--- Create colour preview mark for PPTX format using OpenXML.
--- @param hex string Hex colour code.
--- @param glyph string Glyph character to use for the preview.
--- @return string PPTX colour preview mark using OpenXML.
local function create_pptx_colour_mark(hex, glyph)
  local hex_colour_six = colour.expand_hex_colour(hex)
  local hex_without_hash = string.gsub(hex_colour_six, '#', '')
  return '<a:r><a:rPr dirty="0"><a:solidFill><a:srgbClr val="' ..
      hex_without_hash .. '" /></a:solidFill></a:rPr><a:t>' .. glyph .. '</a:t></a:r>'
end

--- Create colour preview mark for the specified format.
--- @param hex string Hex colour code.
--- @param format string Output format (html, latex, typst, docx, pptx).
--- @param glyph string Glyph character to use for the preview.
--- @return string Colour preview mark for the format.
local function create_colour_mark(hex, format, glyph)
  local colour_mark_functions = {
    html = create_html_colour_mark,
    latex = create_latex_colour_mark,
    typst = create_typst_colour_mark,
    docx = create_docx_colour_mark,
    pptx = create_pptx_colour_mark
  }

  local create_mark = colour_mark_functions[format]
  if create_mark then
    return create_mark(hex, glyph)
  else
    error('Unsupported format: ' .. format)
  end
end

--- Extract all colour matches from element text with positions.
--- Supports multiple colours and colours embedded within other text.
--- @param element table Pandoc element containing text to analyse.
--- @return table Array of match objects sorted by start position.
---         Each match: { hex = "#RRGGBB", original = "...", start_pos = n, end_pos = m, format = "hex6" }
local function get_all_colours(element)
  local matches = {}
  local text = element.text

  -- Pattern definitions with priority (hex6 before hex3 to avoid partial matches)
  local patterns = {
    { name = 'hex6',        pattern = '#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]' },
    { name = 'rgb',         pattern = 'rgb%s*%(%s*%d+%s*,%s*%d+%s*,%s*%d+%s*%)' },
    { name = 'rgb_percent', pattern = 'rgb%s*%(%s*%d+%s*%%%s*,%s*%d+%s*%%%s*,%s*%d+%s*%%%s*%)' },
    { name = 'hsl',         pattern = 'hsl%s*%(%s*%d+%s*,%s*%d+%s*%%,%s*%d+%s*%%s*%)' },
    { name = 'hwb',         pattern = 'hwb%s*%(%s*%d+%s+%d+%%%s+%d+%%%s*%)' },
    { name = 'hex3',        pattern = '#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]' } -- Last to avoid false positives
  }

  -- Track covered positions to prevent overlaps
  local covered = {}

  --- Check if a position range overlaps with any covered range.
  --- @param start_pos number Start position to check.
  --- @param end_pos number End position to check.
  --- @return boolean True if position overlaps with a covered range.
  local function is_position_covered(start_pos, end_pos)
    for _, range in ipairs(covered) do
      if (start_pos >= range[1] and start_pos <= range[2]) or
          (end_pos >= range[1] and end_pos <= range[2]) or
          (start_pos <= range[1] and end_pos >= range[2]) then
        return true
      end
    end
    return false
  end

  for _, pat in ipairs(patterns) do
    local pos = 1
    while pos <= #text do
      local start_pos, end_pos = string.find(text, pat.pattern, pos)
      if not start_pos then break end

      -- Check if position is already covered by a previous match
      if not is_position_covered(start_pos, end_pos) then
        local matched_text = string.sub(text, start_pos, end_pos)
        local hex = colour.to_html(matched_text, pat.name)
        table.insert(matches, {
          hex = hex,
          original = matched_text,
          start_pos = start_pos,
          end_pos = end_pos,
          format = pat.name
        })
        table.insert(covered, { start_pos, end_pos })
      end

      pos = end_pos + 1
    end
  end

  -- Sort by start position for sequential processing
  table.sort(matches, function(a, b) return a.start_pos < b.start_pos end)

  return matches
end

--- Escape HTML special characters in text.
--- @param text string Text to escape.
--- @return string Escaped text safe for HTML.
local function escape_html(text)
  local replacements = {
    ['&'] = '&amp;',
    ['<'] = '&lt;',
    ['>'] = '&gt;',
    ['"'] = '&quot;',
    ["'"] = '&#39;'
  }
  return (text:gsub('[&<>"\']', replacements))
end

--- Reconstruct a Code element with colour marks inserted after each colour.
--- Keeps the code as a single visual unit with marks embedded inside.
--- @param element table Pandoc Code element.
--- @param matches table Array of colour matches with positions.
--- @param format string Output format (html, latex, typst, docx, pptx).
--- @param language string Language for RawInline.
--- @param glyph string Glyph character to use for the preview.
--- @return table Pandoc RawInline with code and embedded colour marks.
local function reconstruct_code_with_marks(element, matches, format, language, glyph)
  if #matches == 0 then
    return element
  end

  local text = element.text
  local result_text = ""
  local last_pos = 1

  -- Build the content with embedded colour marks
  for _, match in ipairs(matches) do
    -- Add text before this colour
    if match.start_pos > last_pos then
      local prefix = string.sub(text, last_pos, match.start_pos - 1)
      if format == "html" then
        prefix = escape_html(prefix)
      elseif format == "latex" then
        prefix = utils.escape_text(prefix, format)
      elseif format == "typst" then
        prefix = utils.escape_text(prefix, format)
      end
      result_text = result_text .. prefix
    end

    -- Add the colour code
    local colour_text = match.original
    if format == "html" then
      colour_text = escape_html(colour_text)
    elseif format == "latex" then
      colour_text = utils.escape_text(colour_text, format)
    elseif format == "typst" then
      colour_text = utils.escape_text(colour_text, format)
    end
    result_text = result_text .. colour_text

    -- Add the colour mark
    result_text = result_text .. create_colour_mark(match.hex, format, glyph)

    last_pos = match.end_pos + 1
  end

  -- Add remaining text after last colour
  if last_pos <= #text then
    local suffix = string.sub(text, last_pos)
    if format == "html" then
      suffix = escape_html(suffix)
    elseif format == "latex" then
      suffix = utils.escape_text(suffix, format)
    elseif format == "typst" then
      suffix = utils.escape_text(suffix, format)
    end
    result_text = result_text .. suffix
  end

  -- Wrap in format-specific code markup
  if format == "html" then
    return pandoc.RawInline(language, '<code>' .. result_text .. '</code>')
  elseif format == "latex" then
    return pandoc.RawInline(language, '\\texttt{' .. result_text .. '}')
  end

  -- For Typst and OpenXML, keep the split approach as they have limitations
  -- with embedding marks inside code content
  local result = {}
  last_pos = 1
  for _, match in ipairs(matches) do
    if match.start_pos > last_pos then
      local prefix = string.sub(text, last_pos, match.start_pos - 1)
      if #prefix > 0 then
        table.insert(result, pandoc.Code(prefix, element.attr))
      end
    end
    table.insert(result, pandoc.Code(match.original, element.attr))
    local colour_mark = create_colour_mark(match.hex, format, glyph)
    table.insert(result, pandoc.RawInline(language, colour_mark))
    last_pos = match.end_pos + 1
  end
  if last_pos <= #text then
    local suffix = string.sub(text, last_pos)
    if #suffix > 0 then
      table.insert(result, pandoc.Code(suffix, element.attr))
    end
  end
  return pandoc.Span(result)
end

--- Reconstruct a Str element with colour marks inserted after each colour.
--- @param element table Pandoc Str element.
--- @param matches table Array of colour matches with positions.
--- @param format string Output format (html, latex, typst, docx, pptx).
--- @param language string Language for RawInline.
--- @param glyph string Glyph character to use for the preview.
--- @return table Pandoc Span or RawInline depending on format.
local function reconstruct_str_with_marks(element, matches, format, language, glyph)
  if #matches == 0 then
    return element
  end

  local text = element.text

  -- For OpenXML formats, use Span with separate elements
  if language == "openxml" then
    local result = {}
    local last_pos = 1

    for _, match in ipairs(matches) do
      if match.start_pos > last_pos then
        local prefix = string.sub(text, last_pos, match.start_pos - 1)
        if #prefix > 0 then
          table.insert(result, pandoc.Str(prefix))
        end
      end

      table.insert(result, pandoc.Str(match.original))
      local colour_mark = create_colour_mark(match.hex, format, glyph)
      table.insert(result, pandoc.RawInline(language, colour_mark))

      last_pos = match.end_pos + 1
    end

    if last_pos <= #text then
      local suffix = string.sub(text, last_pos)
      if #suffix > 0 then
        table.insert(result, pandoc.Str(suffix))
      end
    end

    return pandoc.Span(result)
  end

  -- For LaTeX/Typst/HTML, build a single raw inline with escaping
  local result_text = ""
  local last_pos = 1

  for _, match in ipairs(matches) do
    if match.start_pos > last_pos then
      local prefix = string.sub(text, last_pos, match.start_pos - 1)
      if format == "latex" or format == "typst" then
        prefix = utils.escape_text(prefix, format)
      end
      result_text = result_text .. prefix
    end

    local colour_text = match.original
    if format == "latex" or format == "typst" then
      colour_text = utils.escape_text(colour_text, format)
    end
    result_text = result_text .. colour_text
    result_text = result_text .. create_colour_mark(match.hex, format, glyph)

    last_pos = match.end_pos + 1
  end

  if last_pos <= #text then
    local suffix = string.sub(text, last_pos)
    if format == "latex" or format == "typst" then
      suffix = utils.escape_text(suffix, format)
    end
    result_text = result_text .. suffix
  end

  return pandoc.RawInline(language, result_text)
end

--- Add colour preview marks to a Pandoc element.
--- Handles multiple colours and colours embedded within other text.
--- Supports multiple output formats (HTML, LaTeX, Typst, DOCX, PPTX).
--- @param element table Pandoc Str or Code element to process.
--- @return table Pandoc element with colour previews, or original element if no colours found.
local function add_colour_mark(element)
  local matches = get_all_colours(element)

  if #matches == 0 then
    return element -- No colours found, return original element.
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

  local glyph = get_glyph_for_format(format)

  if element.t == "Code" then
    return reconstruct_code_with_marks(element, matches, format, language, glyph)
  elseif element.t == "Str" then
    return reconstruct_str_with_marks(element, matches, format, language, glyph)
  end

  return element
end

--- Extract and configure colour preview settings from document metadata.
--- @param meta table<string, any> Document metadata table.
--- @return table<string, any> Updated metadata table with preview-colour configuration.
local function get_colour_preview_meta(meta)
  local preview_colour_text = get_preview_colour_option('text', meta)
  local preview_colour_code = get_preview_colour_option('code', meta)

  -- Get glyph configuration (can be string or table)
  -- Note: Do NOT use utils.get_metadata_value here as it stringifies the result,
  -- which would concatenate all table values. We need the raw metadata object.
  local glyph_config = nil
  if meta['extensions'] and meta['extensions']['preview-colour'] and meta['extensions']['preview-colour']['glyph'] then
    glyph_config = meta['extensions']['preview-colour']['glyph']
  end
  if glyph_config == nil then
    -- Check deprecated top-level config
    if meta['preview-colour'] and meta['preview-colour']['glyph'] then
      glyph_config = meta['preview-colour']['glyph']
      if not deprecation_warning_shown then
        utils.log_warning(
          EXTENSION_NAME,
          'Top-level "preview-colour" configuration is deprecated. ' ..
          'Please use:\n' ..
          'extensions:\n' ..
          '  preview-colour:\n' ..
          '    glyph: value'
        )
        deprecation_warning_shown = true
      end
    end
  end

  meta['extensions']['preview-colour'] = {
    ["text"] = preview_colour_text,
    ["code"] = preview_colour_code,
    ["glyph"] = glyph_config
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
