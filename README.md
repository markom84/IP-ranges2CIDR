# IP-ranges2CIDR
Convert list of IP ranges to CIDR

awk-gawk compatible scripts to convert IP ranges into CIDR notation

Original source: https://www.unix.com/shell-programming-and-scripting/280541-convert-ip-ranges-cidr-netblock.html

## Usage
```bash
awk -f ip2cidr.awk ipranges.txt > cidr.txt
gawk -f ip2cidr.awk ipranges.txt > cidr.txt
mawk -f ip2cidr.awk ipranges.txt > cidr.txt
```

Files should be formatted like this:
```
192.168.0.0-192.168.1.255
8.8.8.0-8.8.8.127
```
