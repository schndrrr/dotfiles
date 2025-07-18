# My Personal dotfiles

includes:
- neovim config
- tmux config
- p10k theme
- my zshrc

clone github
```
$ cd dotfiles 
$ stow .
```
stow . puts everything inside the directory you are in into the parent directory as a symlink

when conflicts do:
```
$ stow --adopt .
```
