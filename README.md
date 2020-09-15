<p align="center">  
<a href="https://github.com/xxh/xxh">xxh</a> entrypoint for <a href="https://osquery.io">osquery</a>. 
</p>

<p align="center">  
If you like the idea of xxh click ⭐ on the repo and stay tuned.
</p>

## Install
Install from xxh repo:
```
xxh +I xxh-shell-osquery
xxh myhost +s osquery
```
To avoid adding `+s` every time use xxh config in `~/.config/xxh/config.xxhc` (`$XDG_CONFIG_HOME`):
```
hosts:
  ".*":                     # Regex for all hosts
    +s: osquery
```
Connect:
```
xxh myhost +s osquery +if
```

## Thanks
* **alessandrogario**
