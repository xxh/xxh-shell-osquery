[Xxh](https://github.com/xxh/xxh) entrypoint for [osquery](https://osquery.io). 

## Install
Install from xxh repo:
```
xxhp i xxh-shell-osquery
```
Install from any repo:
```
cd ~/.xxh/xxh/shells/
git clone https://github.com/xxh/xxh-shell-osquery
./xxh-shell-osquery/build.xsh
xxh myhost +s xxh-shell-osquery
```
To avoid adding `+s` every time use xxh config in `~/.xxh/.xxhc`:
```
hosts:
  ".*":                     # Regex for all hosts
    +s: xxh-shell-osquery
```

## Thanks
* **alessandrogario**
