require'nvim-treesitter.configs'.setup {
  parser_install_dir = "~/.config/treesitter/parsers",
  ensure_installed = { "c", "lua", "rust", "zig" },
  sync_install = false,

  auto_install = true,

  ignore_install = { "javascript" },

  highlight = {
    enable = true,

    additional_vim_regex_highlighting = false,
    disable = function(lang, buf)
        local max_filesize = 10 * 1024 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,
  },
}
