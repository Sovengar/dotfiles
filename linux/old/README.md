# .dotfiles
My dotfile configurations

## Prerequisites:
- [curl](https://curl.se/docs/manpage.html)

### Pre-Installation
```bash
curl -sL https://github.com/sovengar/.dotfiles-linux/raw/main/pre_install.sh | bash
```
To install yadm temporarily, then clone the .dotfiles repo and bootstrap the system, run the following command:

```bash
curl -sL https://github.com/sovengar/.dotfiles-linux/raw/main/install.sh | bash
```

### Update plugins with submodules
```bash
yadm submodule update --remote
```
