-- Semantic color palettes, one per colorscheme.
--
-- Everything in this config that would otherwise hardcode a hex value reads it
-- from here, so switching schemes re-tints the tweaks instead of stranding them
-- on the previous palette. Both tables define exactly the same keys; only the
-- values differ. Consumers ask for a role ("the active tab's background"), never
-- for a specific color.
--
-- Read by:
--   lua/plugins/colorscheme.lua  diagnostics, git columns, file icons, cursor line
--   lua/plugins/bufferline.lua   the tab bar
--   lua/plugins/lualine.lua      picks a matching statusline theme
--   ~/.config/tmux/themes/*.conf the same values, by hand (tmux can't read Lua)
--
-- To add a scheme: add a palette with every key below, teach normalize() its
-- name, and drop a matching file in ~/.config/tmux/themes/.

local M = {}

--- The colorscheme LazyVim loads at startup. This is the switch.
--- After changing it, run `tmux-theme <same name>` to move the shell to match.
M.scheme = "lackluster-mint"

--- Palettes are built lazily, so a scheme's plugin is only required when that
--- scheme is actually the active one.
M.palettes = {}

--- slugbyte/lackluster.nvim, mint variant.
---
--- Tones are pulled from the plugin's own palette rather than copied, so a
--- future update to lackluster carries through. The surface ramp matches the
--- Lackluster Mint VSCode theme, which paints editor, sidebar, panel and
--- terminal all at gray2 -- one step up from lackluster's stock #101010.
M.palettes.lackluster = function()
  local c = require("lackluster").color

  return {
    -- Surfaces, darkest to lightest.
    bg_dim = c.gray1, -- #080808  inactive statusline (tmux)
    bg = c.gray2, -- #191919  buffer, sidebar, floats, tab bar
    bg_statusline = "#242424", -- lackluster's color_special.statusline
    bg_border = c.gray3, -- #2a2a2a  1px tab border
    bg_visible = c.gray4, -- #444444  visible-but-unfocused tab
    bg_active = c.gray5, -- #555555  active tab

    -- Text, dimmest to brightest.
    fg_inactive = c.gray6, -- #7a7a7a  inactive tab
    fg_dim = c.gray7, -- #aaaaaa  statusline, tab-bar header
    fg = c.gray8, -- #cccccc  normal text
    fg_visible = c.gray8, -- #cccccc  visible-but-unfocused tab
    fg_active = c.luster, -- #deeeed  active tab, current line number

    -- Accents.
    red = c.red, -- #d70000
    orange = c.orange, -- #ffaa88
    yellow = c.yellow, -- #abab77
    green = c.green, -- #789978  the mint accent
    blue = c.blue, -- #7788aa
    accent = c.lack, -- #708090  lualine mode block, search, active pane border
    subtle = c.gray4, -- #444444  gitignored files

    -- File-type icons. The conventional nvim-web-devicons brand hues: under
    -- lackluster every MiniIcons link resolves to #444444 or plain grey, so
    -- nearly every icon reads as invisible. Folder icons are untouched --
    -- neo-tree only runs the icon provider for file nodes, so directories keep
    -- NeoTreeDirectoryIcon's mint.
    icons = {
      azure = "#6cb6eb",
      blue = "#519aba",
      cyan = "#56b6c2",
      green = "#8dc149",
      grey = c.gray7,
      orange = "#e37933",
      purple = "#a074c4",
      red = "#cc3e44",
      yellow = "#cbcb41",
    },
  }
end

--- retrobox, Neovim's builtin gruvbox port ($VIMRUNTIME/colors/retrobox.vim).
---
--- Hexes are lifted from the scheme's own dark variant so the tweaks can't
--- drift from it. The roles are mapped to keep the *relationships* the
--- lackluster setup establishes, not to copy its tones: the tab bar still sits
--- flush with the buffer, and the surface ramp still climbs one step at a time
--- (bg0 -> bg1 -> bg2 -> bg3).
M.palettes.retrobox = function()
  return {
    -- Surfaces, darkest to lightest.
    bg_dim = "#121212", -- Folded background
    bg = "#1c1c1c", -- Normal background (gruvbox bg0)
    bg_statusline = "#303030", -- CursorLine: the same one-step lift #242424 gives lackluster
    bg_border = "#3c3836", -- bg1, retrobox's own TabLine/Pmenu tone
    bg_visible = "#504945", -- bg2, its PmenuSel
    bg_active = "#665c54", -- bg3

    -- Text, dimmest to brightest.
    fg_inactive = "#928374", -- the Comment grey
    fg_dim = "#a89984", -- fg4, retrobox's own TabLine foreground
    fg = "#ebdbb2", -- Normal foreground
    fg_visible = "#bdae93", -- fg3
    fg_active = "#fbf1c7", -- fg0, its TabLineSel foreground

    -- Accents.
    red = "#fb5944", -- Error, Keyword
    orange = "#fe8019", -- Special, Delimiter
    yellow = "#fabd2f", -- Type, CursorLineNr, ModeMsg
    green = "#b8bb26", -- String, Function, Directory
    blue = "#83a598", -- Identifier
    -- retrobox already paints CursorLineNr and ModeMsg in yellow, so yellow is
    -- its "you are here" hue -- the role lackluster's slate `lack` plays.
    accent = "#fabd2f",
    subtle = "#665c54", -- gitignored files

    -- File-type icons, kept in-palette rather than using the devicons brand
    -- hues, which read as too saturated against gruvbox. The overrides are
    -- needed here too: mini.icons links its nine groups to Function/Constant/
    -- Diagnostic*, so Orange and Yellow both land on DiagnosticWarn, Green
    -- lands on the undefined DiagnosticOk, and Grey is left unset entirely.
    icons = {
      azure = "#83a598",
      blue = "#458588",
      cyan = "#8ec07c",
      green = "#b8bb26",
      grey = "#a89984",
      orange = "#fe8019",
      purple = "#d3869b",
      red = "#fb5944",
      yellow = "#fabd2f",
    },
  }
end

--- uloco/bluloco.nvim, dark variant.
---
--- Surfaces come from the grey ramp bluloco authors for its own lualine theme
--- (lua/lualine/themes/bluloco.lua: grey3..grey20), which is why bg_statusline
--- lands exactly on lualine's section-c background rather than being guessed at.
--- Accents are the syntax colors from lua/lush_theme/bluloco.lua.
M.palettes.bluloco = function()
  return {
    -- Surfaces, darkest to lightest.
    bg_dim = "#21232c", -- NormalFloat / Pmenu
    bg = "#282c34", -- Normal background
    bg_statusline = "#2d333e", -- grey3, lualine's own statusline tone
    bg_border = "#333a48", -- grey5
    bg_visible = "#384252", -- grey7, also CursorLine
    bg_active = "#3c495d", -- grey10

    -- Text, dimmest to brightest. bluloco has no neutral brighter than its
    -- Normal foreground, so fg_active is that -- the active tab leans on its
    -- lighter background and bold weight to separate itself instead.
    fg_inactive = "#5f697c", -- its own TabLine foreground
    fg_dim = "#8691a3", -- lualine's statusline foreground
    fg = "#abb2bf", -- Normal foreground
    fg_visible = "#8691a3",
    fg_active = "#abb2bf",

    -- Accents.
    red = "#ff2e3f", -- error
    orange = "#ff936a", -- attribute
    yellow = "#f9c859", -- string
    green = "#3fc56b", -- method
    blue = "#3691ff", -- tag, info, primary
    -- bluloco's signature blue: what it paints keywords, Directory and its own
    -- selected tab with. The "you are here" hue, so it takes the accent role.
    accent = "#10b1fe",
    subtle = "#3c495d", -- gitignored files

    -- File-type icons, kept in bluloco's own palette: it is vivid enough that
    -- the devicons brand hues would read as a second, competing scheme.
    icons = {
      azure = "#3691ff", -- tag
      blue = "#10b1fe", -- keyword
      cyan = "#50acae", -- label
      green = "#3fc56b", -- method
      grey = "#636d83", -- comment
      orange = "#ff936a", -- attribute
      purple = "#9f7efe", -- constant
      red = "#ff6480", -- type
      yellow = "#f9c859", -- string
    },
  }
end

--- Map a colorscheme name onto a palette key.
---@param name string?
---@return string?
local function normalize(name)
  if type(name) ~= "string" then
    return nil
  end
  -- lackluster ships mint/hack/night variants that share one palette.
  if name:match("^lackluster") then
    return "lackluster"
  end
  if name == "retrobox" then
    return "retrobox"
  end
  -- bluloco sets colors_name to plain "bluloco" for *both* its variants, so the
  -- name alone cannot tell them apart -- ask the plugin which one it loaded.
  -- Only the dark palette is defined above; light gets no tweaks rather than
  -- dark's colors on a light background.
  if name:match("^bluloco") then
    local ok, bluloco = pcall(require, "bluloco")
    if ok and bluloco.config and bluloco.config.style == "light" then
      return nil
    end
    return "bluloco"
  end
  return nil
end

--- The palette for a colorscheme, or nil if we have no opinion about it.
---
--- nil is the useful answer, not a failure: callers skip their tweaks entirely,
--- so loading some third scheme gets that scheme as its author intended rather
--- than half of it wearing lackluster's colors.
---
---@param name string? colorscheme to look up; defaults to the one currently loaded
---@return table? palette
function M.palette(name)
  local key = normalize(name or vim.g.colors_name or M.scheme)
  local build = key and M.palettes[key]
  return build and build() or nil
end

--- The lualine theme matching a colorscheme.
---
--- lualine's "auto" theme looks for a theme file named after vim.g.colors_name.
--- There is no lackluster-mint.lua (lackluster ships its theme as plain
--- "lackluster") and no retrobox.lua, so for these two auto falls back to
--- deriving a palette from the highlight groups, which comes out clashing.
--- Name them explicitly instead.
---
---@param name string? colorscheme to look up; defaults to the one currently loaded
---@return string lualine theme name; "auto" for a scheme we have no palette for
function M.lualine_theme(name)
  return ({
    lackluster = "lackluster",
    retrobox = "gruvbox_dark", -- same gruvbox lineage, near-identical hexes
    bluloco = "bluloco", -- shipped by the plugin itself
  })[normalize(name or vim.g.colors_name or M.scheme)] or "auto"
end

return M
