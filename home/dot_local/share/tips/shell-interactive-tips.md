# What you have

`alias | rgx git` to see your git aliases
`show-x` to see all show-x subcommands
`show-dev-x, show-funny-x, show-hw-x` to see possible commands
`type <cmd>` to see location
`command -v <cmd>` to see location
`which <cmd>` to see location
`man <cmd>` to see a full official explanation of the command
`tldr <cmd>` to see quick examples

# Expansions

`!! or sudo !!` to expand to last command
`!$` to expand to last arg from last command

```sh
mkdir /tmp/test
cd $                # cd /tmp/test
```

`***` to expand to `| fzf`

Zsh -> `**<TAB>` to open in fzf

# Command substitution

Fish -> `nvim (fdx config)` to use the result as an arg
Zsh -> `nvim $(fdx config)` to use the result as an arg

# Tab completion

Use `<cmd> <Tab>` to show list with subcommands/flags
Use `<cmd> halfText<Tab>` to complete with suggested


```sh
git <Tab>                   # lista subcomandos
git checkout <Tab>          # lista branches
docker <Tab>                # lista subcomandos docker
docker run <Tab>            # flags e imagenes
systemctl status <Tab>      # servicios disponibles
```

# Vim mode

`Esc` to enter vim mode in terminal, `i` to return to INSERT mode.

```sh
- `Esc` / `Ctrl+[` → modo normal.
- `i` → modo insert.
- `v` → abre `$EDITOR` (nvim) para editar la linea actual.
- `gg`, `G`, `0`, `$`, `w`, `b`, `dd`, `yy` funcionan en el buffer de la linea.

Nota: las autosuggestions y `Tab` siguen funcionando en modo insert. Los atajos como `!`, `$`, `***` y `Ctrl+F` tambien.
```

# Find anything

`fdx <anything> or CTRL+F` to search for files or directories
`rgx <anything>` to search the text <anything> inside files
`<cmdWithResult> | rgx <anything>` to search the text <anything> in the result

# Transform any list into a fuzzySearchable list

`<cmd that returns a list> ***` to open the list in fzf

```sh
# lista | fzf
alias | fzf
docker ps | fzf
docker images | fzf
git branch --all | fzf
git diff --name-only | fzf
git log --oneline --all | fzf
gh issue list --limit 100 | fzf
gh pr list --limit 100 | fzf
history | fzf
```

# Navigation

`zi` to open a fzf-list with scored directories to cd
`cdx` to open TUI for ultimate cd navigation
`cdx <anything>` to navigate with zoxide or fallback to TUI

# Redireccion

`<cmd> file` Redirects the command-output to the file
`echo "(fdx file)" > file2` Redirects the command-output to the file
`echo "text" > file` Overwrites the file with text
`echo "text" >> file` Appends text (Insert in EOF)
`echo "$var" | <cmd>` Passes var as a stdin of the command
`<cmd> > /dev/null 2>&1` Redirects all to the black hole (Discards)
`<cmd> > file 2>&1` stdout + stderr -> File
`<cmd> 2>&1 | grep x` stdout + stderr -> Pipe
`<cmd> 2>&1 > file` Only stdout to file, stderr is printed 

# Prettify Output

`<cmdOutput> | cat` to see output with syntax highlighting
`<jsonOutput> | jq` Formats json
`curl -s URL | jq '.items[] | {name, id}'` to cherry pick
`gh repo view --json name,owner,url | jq`
`gh issue list --json number,title,state | jq`

# Others

`history` or `ffch` or `Ctrl+R` to see recent commands
`<cmdWithResult> | wl-copy` to copy result to clipboard
`snip <command>` to reduce verbosity like git log, docker build, mvn test
`sed text1 text2` to replace text1 with text2

# Some aliases & abbrvs
`gst` to see git status
`op` to open Opencode
`dkps` to docker ps
`dkexe` to execute sh inside a selected container
`dklogs` to see logs of a selected container
`dkrun` to run a selected container dettached
`vi` to open nvim
`..` to cd .., `..2` to cd ../..
`...` to cd ~
`lt` to do ls with eza in tree mode
