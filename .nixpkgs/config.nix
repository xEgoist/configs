{ pkgs, ... }:
let
  discordRPC = pkgs.vimUtils.buildVimPlugin {
    name = "";
    src = pkgs.fetchFromGitHub {
      owner = "pucka906";
      repo = "vdrpc";
      rev = "master";
      sha256 = "y4dh9cv68a3YaTAuHDUP01nlKr1cfCzRGqwawLXPFx0=";
    };
  };
  unstable = import <unstable> { };
  homeDir = builtins.getEnv "HOME";
in {
  allowUnfree = true;
  packageOverrides = pkgs:
    with pkgs; rec {
      my_vim = unstable.vim_configurable.customize {
        name = "vim";
        # add here code from the example section
        vimrcConfig.customRC = ''


          " An example for a vimrc file.
          "
          " Maintainer:   Bram Moolenaar <Bram@vim.org>
          " Last change:  2019 Dec 17
          "
          " To use it, copy it to
          "              for Unix:  ~/.vimrc
          "             for Amiga:  s:.vimrc
          "        for MS-Windows:  $VIM\_vimrc
          "             for Haiku:  ~/config/settings/vim/vimrc
          "           for OpenVMS:  sys$login:.vimrc

          " When started as "evim", evim.vim will already have done these settings, bail
          " out.
          if v:progname =~? "evim"
            finish
          endif

          " Get the defaults that most users want.
          source $VIMRUNTIME/defaults.vim

          if has("vms")
            set nobackup          " do not keep a backup file, use versions instead
          else
            set backup            " keep a backup file (restore to previous version)
            if has('persistent_undo')
              set undofile        " keep an undo file (undo changes after closing)
            endif
          endif

          if &t_Co > 2 || has("gui_running")
            " Switch on highlighting the last used search pattern.
            set hlsearch
          endif

          " Put these in an autocmd group, so that we can delete them easily.
          augroup vimrcEx
            au!

            " For all text files set 'textwidth' to 78 characters.
            autocmd FileType text setlocal textwidth=78
          augroup END

          " Add optional packages.
          "
          " The matchit plugin makes the % command work better, but it is not backwards
          " compatible.
          " The ! means the package won't be loaded right away but when plugins are
          " loaded during initialization.
          if has('syntax') && has('eval')
            packadd! matchit
          endif

          set nobackup
          set noundofile
          set noswapfile
          set tabstop=4
          set shiftwidth=4
          set number
          set cc=80
          set clipboard=unnamedplus
          set expandtab

          " Highlight extra whitespace.
          " http://vim.wikia.com/wiki/Highlight_unwanted_spaces
          highlight ExtraWhitespace ctermbg=lightred guibg=lightred
          " Show trailing whitespace and spaces before a tab:
          match ExtraWhitespace /\s\+$\| \+\ze\t/          
        '';
        #vimrcConfig.plug.plugins = with pkgs.vimPlugins; [zig-vim];
        vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
          start = [ zig-vim editorconfig-vim discordRPC ];
        };
      };
      myNeovim = neovim.override {
        configure = {
          customRC = ''
            syntax on
            filetype on
            set expandtab
            set bs=2
            set tabstop=2
            set shiftwidth=2
            set smartindent
            set smartcase
            set ignorecase
            set modeline
            set nocompatible
            set encoding=utf-8
            set hlsearch
            set history=700
            set background=dark
            set tabpagemax=1000
            set ruler
            set nojoinspaces
            set shiftround
            set cc=100
            colorscheme carbonfox
            let g:c_syntax_for_h = 1
            set nolbr
            set tw=0
            set pastetoggle=<F2>
            " My Mappings
            " Save using doas
            cmap w!! w !doas tee % >/dev/null
            " ctrl v to copy paste from wl-copy for wayland
            xnoremap "+y y:call system("wl-copy", @")<cr>
            nnoremap "+p :let @"=substitute(system("wl-paste --no-newline"), '<C-v><C-m>', ''', 'g')<cr>p
            nnoremap "*p :let @"=substitute(system("wl-paste --no-newline --primary"), '<C-v><C-m>', ''', 'g')<cr>p
            vmap <C-c> "+yi
            vmap <C-x> "+c
            vmap <C-v> c<ESC>"+p
            imap <C-v> <ESC>"+pa
            " Hate accidentally pressing these
            map <End> <Nop>
            map <Home> <Nop>
            map <PageUp> <Nop>
            map <PageDown> <Nop>
            set backupcopy=yes
            map <ScrollWheelUp> <C-Y>
            map <ScrollWheelDown> <C-E>
            set so=999
            let g:zig_fmt_autosave = 0
            au VimLeave * set guicursor=a:ver90
            set mouse=
            lua require('init')
            lua require('plugins')
          '';
          packages.myVimPackage = with pkgs.vimPlugins; {
            start = [ zig-vim editorconfig-vim packer-nvim nvim-treesitter ];
            opt = [ ];
          };
        };
      };
      all = pkgs.buildEnv {
        name = "all";
        paths = [ my_vim unstable.myNeovim unstable.fd unstable.helix ];

      };
    };
}

