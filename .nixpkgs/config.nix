 pkgs : {
  packageOverrides = pkgs: with pkgs; rec {
    my_vim = vim_configurable.customize {
      name = "vim";
      # add here code from the example section
      vimrcConfig.customRC = ''
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
    '';
    #vimrcConfig.plug.plugins = with pkgs.vimPlugins; [zig-vim];
    vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
      start = [ zig-vim editorconfig-vim ];
    };
    };
    myNeovim = neovim.override {
      configure = {
        customRC = ''
          set cc=100
          set nobackup 
          set noswapfile
          set noundofile
          set background=dark
          set expandtab
          set tabstop=4
          set shiftwidth=4
          set mouse=a
          syntax on
          syntax enable
          colorscheme desert
          :hi Normal guibg=NONE ctermbg=NONE
       '';
        packages.myVimPackage = with pkgs.vimPlugins; {
          # see examples below how to use custom packages
          start = [ ];
          opt = [ ];
        }; 
      };     
    };
    all = pkgs.buildEnv {
      name = "all";
      paths = [
        my_vim
				myNeovim
      ];
    };
  };
}


