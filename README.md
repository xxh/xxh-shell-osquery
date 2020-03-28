[Xxh](https://github.com/xxh/xxh) entrypoint for [osquery](https://osquery.io). 

## Install
Install from xxh repo:
```
xxh +I xxh-shell-osquery
xxh myhost +s xxh-shell-osquery
```
To avoid adding `+s` every time use xxh config in `~/.config/xxh/config.xxhc` (`$XDG_CONFIG_HOME`):
```
hosts:
  ".*":                     # Regex for all hosts
    +s: xxh-shell-osquery
```
Connect:
```
xxh myhost +s xxh-shell-osquery +if
```

## Thanks
* **alessandrogario**
