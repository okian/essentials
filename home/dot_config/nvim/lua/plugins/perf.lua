-- Snappy, no-animation scrolling. LazyVim enables snacks.scroll (smooth
-- scrolling) and snacks.animate by default; both are turned off here so
-- scrolling is instant and nothing animates the viewport.
return {
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false }, -- no smooth-scroll animation
      animate = { enabled = false }, -- disable snacks animations globally
    },
  },
}
