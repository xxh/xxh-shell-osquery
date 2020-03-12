#!/usr/bin/env xonsh

import sys
from sys import exit
from shutil import which

portable_url = 'https://pkg.osquery.io/linux/osquery-4.2.0_1.linux_x86_64.tar.gz'
tarname = portable_url.split('/')[-1]

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

script_dir = pf"{__file__}".absolute().parent
build_dir = script_dir / 'build'
rm -rf @(build_dir)/
mkdir -p @(build_dir)

cp @(script_dir / 'entrypoint.sh') @(build_dir)/

cd @(build_dir)

if not p'etc'.exists():
    eprint(f'Download from {portable_url}')
    if which('wget'):
        r =![wget -q --show-progress @(portable_url) -O @(tarname)]
        if r.returncode != 0:
            eprint(f'Error while download appimage using wget: {r}')
            exit(1)
    elif which('curl'):
        r =![curl -L @(portable_url) -o @(tarname)]
        if r.returncode != 0:
            eprint(f'Error while download appimage using curl: {r}')
            exit(1)
    else:
        eprint('Please install wget or curl and try again. Howto: https://duckduckgo.com/?q=how+to+install+wget+in+linux')
        exit(1)

    tar -xzf @(tarname)
    rm @(tarname)
else:
    eprint(f'File {tarname} exists. Skip downloading')
