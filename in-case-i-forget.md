I have multiple repos for my config because I just **have** to be *extra*.the purpose is to keep the private repo from being viewed in my dotfiles repo. and to keep the nvim config repo separate so it can one day be showcased on dotfyle.com.

so it's the private repo, this one daught-fylz (AKA dotfiles) and lua-is-the-devil (nvim)

So, in case i forget how i linked everything to dot config

1. jump into dot config, you might have to create it

`cd ~/.config`

2. create symbolic links for `dotfiles` and the `private` repos

```bash
ln -s ~/.dotfiles/* .
ln -s ~/.private/* .
```
> [!NOTE]
The asterisks is to symlink all files/dirs in parent dir, and the period tells the command to "link here (pwd)" in case you hit your head again without a helmet or riding gear, survive and don't remember bash basics 

3. make nvim directory in dot config and symlink lua-is-the-devil in pwd

```bash
mkdir -p nvim
ln -s ~/.lua-is-the-devil/* .
```
> [!NOTE]
You have to use mkdir -p because you probaly are on a new Mac and still fuck up the script to automate everything and don't have `alias mk=mkdir -pv` setup 

4. go into each local repo and git pull to be current…

```bash
cd ~/.dotfiles
git pull origin main

cd ~/.private
git pull origin main

cd ~/.lua-is-the-devil
git pull origin main
```
> [!NOTE]
This could work to but i think it outputs as a quote and not a comment. we'll see what le Git Hoob chose

5. R U N the relevant local repo dir?

```bash
cd ~/.dotfiles/
```

6. add commit push `gac` if aliases/functions.zsh is in place already

```bash
git add -A
git commit -m "type message"
git push origin main
```

7. or run a script that you're too lazy to write rn

```bash
#!/bin/bash
REPOS=(".dotfiles" ".private" ".lua-is-the-devil")

for repo in "${REPOS[@]}"; do
  cd "$HOME/$repo"
  git pull origin main
done
```

> [!NOTE]
I'll probably figure something out later to streamline this… with some AI help.
