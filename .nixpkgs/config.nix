 { pkgs, ... } :
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
  unstable = import <unstable> {};
  homeDir = builtins.getEnv "HOME";
 in
 {
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; rec {
    my_vim = unstable.vim_configurable.customize {
      name = "vim";
      # add here code from the example section
      vimrcConfig.customRC = ''
        filetype plugin on
        set omnifunc=syntaxcomplete#Complete
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
        colorscheme desert
        hi! Normal ctermbg=NONE guibg=NONE
        hi! NonText ctermbg=NONE guibg=NONE
        hi! MatchParen cterm=bold ctermbg=none ctermfg=magenta
        hi! Search cterm=bold ctermbg=none ctermfg=red
        set nolbr
        set tw=0
        set pastetoggle=<F2>
        set rtp+=/opt/homebrew/opt/fzf
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
        " Zig Stuff
        let g:zig_fmt_autosave = 0

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
          start = [ 
          zig-vim
          editorconfig-vim
          packer-nvim
          (nvim-treesitter.withPlugins (
          plugins: with plugins; [
            tree-sitter-nix
            tree-sitter-python
            tree-sitter-c
            tree-sitter-rust
          ]))];
          opt = [ ];
        }; 
      };
      vimAlias = true;
    };
    all = pkgs.buildEnv {
      name = "all";
      paths = [
        #my_vim
	unstable.myNeovim
        unstable.fd
        unstable.helix
      ];
  
    };
  };
}


