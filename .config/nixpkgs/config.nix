{pkgs, ...}: let
  unstable = import <unstable> {};
  homeDir = builtins.getEnv "HOME";
in {
  allowUnfree = true;
  packageOverrides = pkgs:
    with pkgs; rec {
      my_vim = vim_configurable.customize {
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

          set backupcopy=yes
          set nobackup
          set undodir=~/.vim/undos
          set undofile
          set noswapfile
          set tabstop=4
          set shiftwidth=4
          set number
          set cc=100
          set clipboard=unnamedplus
          set expandtab
          colorscheme torte
          set splitright
          set viminfo='500,<200,s100
          set viminfofile=~/.vim/viminfo

          " Highlight extra whitespace.
          " http://vim.wikia.com/wiki/Highlight_unwanted_spaces

          highlight ExtraWhitespace ctermbg=lightred guibg=lightred

          " Show trailing whitespace and spaces before a tab:
          match ExtraWhitespace /\s\+$\| \+\ze\t/
          nnoremap <F5> :silent! %s/\s\+$//e<Bar>silent! %s/ \+\ze\t//e<CR>

          let &t_SI = "\e[6 q"
          let &t_EI = "\e[2 q"
          autocmd VimLeave * silent !echo -ne "\e[6 q"
          cnoremap w!! execute 'silent! write !doas tee % >/dev/null' <bar> edit!
        '';
        #vimrcConfig.plug.plugins = with pkgs.vimPlugins; [zig-vim];
        vimrcConfig.packages.myVimPackage = with pkgs.vimPlugins; {
          start = [zig-vim editorconfig-vim];
        };
      };
      all = pkgs.buildEnv {
        name = "all";
        paths = [
          my_vim
          fd
          entr
          ripgrep
        ];
      };
    };
}
