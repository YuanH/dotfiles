-- Ported from ~/.vimrc
-- Neovim already defaults to: syntax on, filetype plugin/indent on, autoread,
-- smarttab, showcmd, hlsearch, nobackup, noerrorbells. They're omitted here.

local opt = vim.opt

-- display
opt.cursorline = true       -- highlight the current line
opt.number = true           -- show line numbers
opt.relativenumber = true   -- show relative line numbers
opt.showmode = true         -- show INSERT, VISUAL, etc. mode
opt.showmatch = true        -- show matching brackets
opt.scrolloff = 5           -- show at least 5 lines above/below
opt.foldlevelstart = 99     -- open files with all folds expanded

-- column-width visual indication (shade everything past column 80)
opt.colorcolumn = table.concat(vim.fn.range(81, 999), ",")

-- tabs and indenting
opt.autoindent = true       -- auto indenting
opt.smartindent = true      -- smart indenting
opt.expandtab = true        -- spaces instead of tabs
opt.tabstop = 2             -- 2 spaces for tabs
opt.shiftwidth = 2          -- 2 spaces for indentation

-- bells
opt.visualbell = true       -- visual bell instead of audio

-- mouse
opt.mouse = "a"             -- enable mouse in all modes (select, scroll, resize)

-- clipboard
opt.clipboard = "unnamed"   -- allow yy, etc. to interact with macOS clipboard

-- leader key (must be set before plugins load)
vim.g.mapleader = " "

-- plugin manager: lazy.nvim (auto-installs itself on first launch)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 10000,
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    -- needs: brew install tree-sitter-cli
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "bash", "css", "diff", "dockerfile", "gitcommit", "html",
        "javascript", "json", "lua", "markdown", "markdown_inline",
        "python", "query", "regex", "sql", "toml", "tsx", "typescript",
        "vim", "vimdoc", "yaml",
      })
      -- turn on treesitter highlighting and folding for any file with a parser
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.wo[0][0].foldmethod = "expr"
          end
        end,
      })
    end,
  },
  {
    "preservim/nerdtree",
    keys = { { "<leader>e", "<cmd>NERDTreeToggle<CR>", desc = "Toggle file tree" } },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "Search text" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "Open buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",  desc = "Help tags" },
      { "<C-p>", "<cmd>Telescope find_files<CR>",                desc = "Find files" },
      { "<C-g>", "<cmd>Telescope live_grep<CR>",                 desc = "Search text in project" },
      { "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search in current file" },
    },
  },
})

-- center after half-page jumps
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- auto-close braces
vim.keymap.set("i", "{", "{}<Left>")
vim.keymap.set("i", "{<CR>", "{<CR>}<Esc>O")
vim.keymap.set("i", "{{", "{")
vim.keymap.set("i", "{}", "{}")

-- column-width shade color (set after the colorscheme so it isn't overridden)
vim.api.nvim_set_hl(0, "ColorColumn", { ctermbg = 235, bg = "#001D2F" })
