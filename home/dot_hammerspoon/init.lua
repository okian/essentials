-- Hammerspoon config (managed by chezmoi → ~/.hammerspoon/init.lua).
--
-- Keyboard-layout fixer
-- ─────────────────────
-- Typed a sentence in the wrong keyboard layout? (Meant Persian, but the
-- US layout was active, so you got "sghl" instead of "سلام" — or vice-versa.)
-- Select the mangled text and press the hotkey: it detects the script,
-- re-maps every character positionally to the OTHER layout, and pastes the
-- correction over the selection. Your clipboard is preserved.
--
--   Hotkey:  ⌘⌥K   (Cmd-Alt-K — change LAYOUT_FIX_HOTKEY below)
--
-- One-time setup (cannot be scripted — macOS gates synthetic keystrokes):
--   System Settings → Privacy & Security → Accessibility → enable Hammerspoon.
--   Hammerspoon → Preferences → "Launch Hammerspoon at login".

local LAYOUT_FIX_HOTKEY = { mods = { "cmd", "alt" }, key = "k" }

-- ── Layout map ──────────────────────────────────────────────────────────────
-- Positional: US-QWERTY key → the glyph the same physical key types on the
-- macOS "Persian – Standard" layout (ISIRI base layer). Only the base layer is
-- mapped — shifted/AltGr glyphs (ژ، ؤ، ZWNJ، …) are left untouched.
local en2fa = {
  -- top letter row  q w e r t y u i o p [ ]
  q = "ض", w = "ص", e = "ث", r = "ق", t = "ف", y = "غ",
  u = "ع", i = "ه", o = "خ", p = "ح", ["["] = "ج", ["]"] = "چ",
  -- home row  a s d f g h j k l ; '
  a = "ش", s = "س", d = "ی", f = "ب", g = "ل", h = "ا",
  j = "ت", k = "ن", l = "م", [";"] = "ک", ["'"] = "گ",
  -- bottom row  z x c v b n m , . /
  z = "ظ", x = "ط", c = "ز", v = "ر", b = "ذ", n = "د",
  m = "پ", [","] = "و", ["."] = ".", ["/"] = "/",
  -- digit row → Persian digits
  ["1"] = "۱", ["2"] = "۲", ["3"] = "۳", ["4"] = "۴", ["5"] = "۵",
  ["6"] = "۶", ["7"] = "۷", ["8"] = "۸", ["9"] = "۹", ["0"] = "۰",
}

-- Inverse map (Persian glyph → US-QWERTY key), built once.
local fa2en = {}
for k, v in pairs(en2fa) do fa2en[v] = k end

-- ── Detection + translation ──────────────────────────────────────────────────
-- Text counts as Persian if it holds any codepoint in the Arabic block
-- (U+0600–U+06FF) — covers every Persian letter and the Persian digits.
local function isPersian(s)
  for _, cp in utf8.codes(s) do
    if cp >= 0x0600 and cp <= 0x06FF then return true end
  end
  return false
end

local function translate(s, map)
  local out = {}
  for _, cp in utf8.codes(s) do
    local ch = utf8.char(cp)
    out[#out + 1] = map[ch] or map[string.lower(ch)] or ch
  end
  return table.concat(out)
end

-- ── Copy → remap → paste → restore ───────────────────────────────────────────
-- Grab the current selection via ⌘C, polling the pasteboard's change-count so
-- we read the freshly-copied text rather than racing it.
local function copySelection()
  local before = hs.pasteboard.changeCount()
  hs.eventtap.keyStroke({ "cmd" }, "c", 0)
  for _ = 1, 50 do                          -- up to ~500ms
    if hs.pasteboard.changeCount() ~= before then break end
    hs.timer.usleep(10000)
  end
  return hs.pasteboard.getContents()
end

local function fixSelection()
  local saved = hs.pasteboard.getContents()
  local sel = copySelection()
  if not sel or sel == "" then
    hs.alert.show("No text selected")
    return
  end

  local fixed, label
  if isPersian(sel) then
    fixed, label = translate(sel, fa2en), "→ English"
  else
    fixed, label = translate(sel, en2fa), "→ فارسی"
  end

  hs.pasteboard.setContents(fixed)
  hs.eventtap.keyStroke({ "cmd" }, "v", 0)  -- replace the selection
  hs.alert.show(label)

  -- Restore the user's clipboard once the paste has consumed our text.
  hs.timer.doAfter(0.25, function()
    if saved ~= nil then hs.pasteboard.setContents(saved) end
  end)
end

hs.hotkey.bind(LAYOUT_FIX_HOTKEY.mods, LAYOUT_FIX_HOTKEY.key, fixSelection)

-- ── Auto-reload on config change ──────────────────────────────────────────────
-- chezmoi rewrites this file on apply; reload Hammerspoon so edits take effect.
hs.pathwatcher.new(hs.configdir, function(files)
  for _, f in ipairs(files) do
    if f:sub(-4) == ".lua" then hs.reload() end
  end
end):start()

hs.alert.show("Hammerspoon ready · ⌘⌥K fixes layout")
