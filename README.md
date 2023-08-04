# SBL - Simple Bash Library


## Description

SBL is a very simple set of functions that I use in bash scripts.



## Usage

To use SBL sorced it in script. You can add the `SBL_DIR` path to your profile (`~/.profile`).


```bash
[ -z "${SBL_DIR-}" ] && SBL_DIR="$HOME/bin/sbl"


. "${SBL_DIR}"/sbl.bash
```



## License

[MIT](./LICENSE).
