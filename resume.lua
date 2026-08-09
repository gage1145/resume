--[[ resume.lua -------------------------------------------------------------

Bridges Markdown fenced divs to the environments defined in resume.cls, so the
.qmd can be written as prose while the PDF keeps inheriting its typography from
the class.

    ::: {.twocolentry right="Jan 2024--present"}
    -> \begin{twocolentry}{Jan 2024--present} ... \end{twocolentry}

    ::: {.software url="https://..." label="github.com/..."}
    -> \begin{software}{\href{https://...}{github.com/...}} ... \end{software}

    ::: highlights
    - a bullet
    -> \begin{highlights} \item a bullet \end{highlights}

For HTML the divs survive as <div class="...">, styled by resume.css; this
filter only lifts the right-column argument into a real element and drops the
LaTeX-only attributes so they don't leak into the markup.

The header block is generated from document metadata, so one YAML block in
resume.qmd feeds both formats.
--]]

local stringify = pandoc.utils.stringify

local IS_LATEX = FORMAT:match('latex') ~= nil
local IS_HTML = FORMAT:match('html') ~= nil

-- Div class -> how to render it.
--   arg   : takes a mandatory argument (from `right=`, or `url=` + `label=`)
--   list  : the environment IS an itemize, so the inner bullet list becomes
--           bare \item lines rather than a nested list
--   env   : LaTeX environment name, when it differs from the class name
--   pre   : raw LaTeX emitted just inside \begin
local ENVS = {
  onecolentry   = {},
  twocolentry   = { arg = true },
  threecolentry = { arg = true },
  software      = { arg = true },
  pubs          = { arg = true },
  patents       = { arg = true },
  highlights    = { list = true },
  skills        = { list = true },
  summary       = { env = 'centering', pre = '\\Large' },
}

-- Contact icons. fontawesome5 for print; Bootstrap Icons ship with Quarto's
-- default HTML theme. ORCID has no Bootstrap glyph, so it borrows person-badge.
local ICONS = {
  email    = { tex = '\\faEnvelope', html = 'bi-envelope' },
  phone    = { tex = '\\faPhone',    html = 'bi-telephone' },
  github   = { tex = '\\faGithub',   html = 'bi-github' },
  orcid    = { tex = '\\faOrcid',    html = 'bi-person-badge' },
  linkedin = { tex = '\\faLinkedin', html = 'bi-linkedin' },
  website  = { tex = '\\faGlobe',    html = 'bi-globe' },
  location = { tex = '\\faMapMarker', html = 'bi-geo-alt' },
}

-- pdflatex with T1 encoding silently drops characters it cannot encode -- they
-- vanish from the PDF with only a log warning. These are the symbols most likely
-- to end up in a resume; map them to LaTeX equivalents so that can't happen.
-- HTML needs no help.
local TEX_SUBS = {
  ['\u{223C}'] = '$\\sim$',        -- ∼ tilde operator ("approximately")
  ['\u{2248}'] = '$\\approx$',     -- ≈
  ['\u{2264}'] = '$\\leq$',        -- ≤
  ['\u{2265}'] = '$\\geq$',        -- ≥
  ['\u{00D7}'] = '$\\times$',      -- ×
  ['\u{2192}'] = '$\\rightarrow$', -- →
}

local function trim(s)
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

-- Render inlines to a target format without applying any template.
local function write_inlines(inlines, fmt)
  if not inlines then return nil end
  return trim(pandoc.write(pandoc.Pandoc({ pandoc.Plain(inlines) }), fmt))
end

local function write_blocks(blocks, fmt)
  return trim(pandoc.write(pandoc.Pandoc(blocks), fmt))
end

local function html_escape(s)
  return (s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;'):gsub('"', '&quot;'))
end

-- LaTeX dashes are written literally in attributes; render them for HTML.
local function dashify(s)
  return (s:gsub('%-%-%-', '\u{2014}'):gsub('%-%-', '\u{2013}'))
end

--[[ Divs -------------------------------------------------------------------]]

local function env_for(el)
  for _, class in ipairs(el.classes) do
    local spec = ENVS[class]
    if spec then return class, spec end
  end
  return nil, nil
end

-- The mandatory argument, as raw LaTeX, including its braces.
local function latex_arg(el)
  local url = el.attributes.url
  if url then
    return '{\\href{' .. url .. '}{' .. (el.attributes.label or url) .. '}}'
  end
  if el.attributes.right then
    return '{' .. el.attributes.right .. '}'
  end
  return ''
end

-- highlights/skills are themselves itemize environments, so their bullet list
-- has to be flattened into bare \item lines to avoid a list inside a list.
local function items_latex(blocks)
  local lines = {}
  for _, block in ipairs(blocks) do
    if block.t == 'BulletList' then
      for _, item in ipairs(block.content) do
        table.insert(lines, '    \\item ' .. write_blocks(item, 'latex'))
      end
    else
      -- anything that isn't a list passes through untouched
      table.insert(lines, write_blocks({ block }, 'latex'))
    end
  end
  return table.concat(lines, '\n')
end

local function div_latex(el, name, spec)
  local env = spec.env or name
  local open = '\\begin{' .. env .. '}'
  if spec.arg then open = open .. latex_arg(el) end
  if spec.pre then open = open .. '\n' .. spec.pre end

  if spec.list then
    return pandoc.RawBlock('latex',
      open .. '\n' .. items_latex(el.content) .. '\n\\end{' .. env .. '}')
  end

  -- Splice the content back into the AST rather than pre-rendering it, so
  -- nested divs and normal Markdown keep working.
  local out = pandoc.List({ pandoc.RawBlock('latex', open) })
  out:extend(el.content)
  out:insert(pandoc.RawBlock('latex', '\\end{' .. env .. '}'))
  return out
end

local function div_html(el, name, spec)
  local right
  if el.attributes.url then
    right = '<a href="' .. html_escape(el.attributes.url) .. '">'
      .. html_escape(el.attributes.label or el.attributes.url) .. '</a>'
  elseif el.attributes.right then
    right = html_escape(dashify(el.attributes.right))
  end

  -- These are meaningful to LaTeX only; leaving them would emit bogus
  -- attributes on the div.
  el.attributes.right = nil
  el.attributes.url = nil
  el.attributes.label = nil

  if right then
    el.content:insert(pandoc.RawBlock('html',
      '<div class="right">' .. right .. '</div>'))
  end
  return el
end

function Div(el)
  local name, spec = env_for(el)
  if not spec then return nil end
  if IS_LATEX then return div_latex(el, name, spec) end
  if IS_HTML then return div_html(el, name, spec) end
  return nil
end

--[[ Unencodable characters -------------------------------------------------]]

-- Runs before Div (pandoc processes contents before their container), so the
-- substitutions are already in place when list items get written out.
function Str(el)
  if not IS_LATEX then return nil end

  local found = false
  for _, code in utf8.codes(el.text) do
    if TEX_SUBS[utf8.char(code)] then
      found = true
      break
    end
  end
  if not found then return nil end

  local out = pandoc.List({})
  local buffer = {}
  local function flush()
    if #buffer > 0 then
      out:insert(pandoc.Str(table.concat(buffer)))
      buffer = {}
    end
  end

  for _, code in utf8.codes(el.text) do
    local char = utf8.char(code)
    local replacement = TEX_SUBS[char]
    if replacement then
      flush()
      out:insert(pandoc.RawInline('latex', replacement))
    else
      table.insert(buffer, char)
    end
  end
  flush()
  return out
end

--[[ Header -----------------------------------------------------------------]]

local function contacts_of(meta)
  local list = {}
  if not meta.contacts then return list end
  for _, entry in ipairs(meta.contacts) do
    table.insert(list, {
      icon = entry.icon and stringify(entry.icon) or nil,
      text = entry.text,
      url = entry.url and stringify(entry.url) or nil,
    })
  end
  return list
end

-- Mirrors the header block of the original resume.tex line for line.
local function header_latex(meta)
  local out = { '\\begin{header}', '' }

  local name = write_inlines(meta.name, 'latex')
  local line = '    \\fontsize{25 pt}{25 pt}\\selectfont ' .. name
  if meta.headline then
    line = line .. ' \\textbf{' .. write_inlines(meta.headline, 'latex') .. '}'
  end
  table.insert(out, line .. '\\\\')
  table.insert(out, '    \\vspace{5 pt}')
  table.insert(out, '    \\normalsize')

  local contacts = contacts_of(meta)
  for i, contact in ipairs(contacts) do
    local icon = ICONS[contact.icon or '']
    local label = write_inlines(contact.text, 'latex')
    if icon then label = icon.tex .. '{ }' .. label end
    if contact.url then
      table.insert(out,
        '    \\mbox{\\hrefWithoutArrow{' .. contact.url .. '}{' .. label .. '}}')
    else
      table.insert(out, '    \\mbox{' .. label .. '}')
    end
    if i < #contacts then table.insert(out, '    \\AND') end
  end

  table.insert(out, '\\end{header}')
  table.insert(out, '')
  table.insert(out, '\\vspace{5 pt - 0.3 cm}')
  return pandoc.RawBlock('latex', table.concat(out, '\n'))
end

local function header_html(meta)
  local out = { '<header class="resume-header">' }

  local line = '<span class="name">' .. write_inlines(meta.name, 'html') .. '</span>'
  if meta.headline then
    line = line .. ' <span class="headline">'
      .. write_inlines(meta.headline, 'html') .. '</span>'
  end
  table.insert(out, '<div class="name-line">' .. line .. '</div>')

  local contacts = contacts_of(meta)
  if #contacts > 0 then
    table.insert(out, '<div class="contacts">')
    for i, contact in ipairs(contacts) do
      local icon = ICONS[contact.icon or '']
      local label = write_inlines(contact.text, 'html')
      if icon and icon.html then
        label = '<i class="bi ' .. icon.html .. '" aria-hidden="true"></i> ' .. label
      end
      if contact.url then
        table.insert(out, '<a href="' .. html_escape(contact.url) .. '">' .. label .. '</a>')
      else
        table.insert(out, '<span>' .. label .. '</span>')
      end
      if i < #contacts then
        table.insert(out, '<span class="sep" aria-hidden="true">|</span>')
      end
    end
    table.insert(out, '</div>')
  end

  table.insert(out, '</header>')
  return pandoc.RawBlock('html', table.concat(out, '\n'))
end

function Pandoc(doc)
  if not doc.meta.name then return doc end

  local header
  if IS_LATEX then
    header = header_latex(doc.meta)
  elseif IS_HTML then
    header = header_html(doc.meta)
  end

  if header then doc.blocks:insert(1, header) end
  return doc
end
