require "nvchad.options"
local opt = vim.opt
local o = vim.o
local g = vim.g

local blink_all = "blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"

o.cursorlineopt ='both' -- to enable cursorline!
o.gcr = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:" .. blink_all

o.undofile = true
o.updatetime = 100 -- Faster completion

o.number = true
o.relativenumber = true

o.autoindent = true
o.clipboard = "unnamed,unnamedplus"
o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2

o.ignorecase = true
o.incsearch = true
o.smartcase = true
o.wildmode = "list:longest"

-- swapfile = false

o.mouse = "a"

o.cursorline = true
o.cursorlineopt = "number"

opt.fillchars = { eob = " " }

-- disable some default providers
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0