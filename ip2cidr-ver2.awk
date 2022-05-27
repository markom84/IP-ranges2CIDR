#!/bin/sh

# Library with various ip manipulation functions
# convert ip ranges to CIDR notation

function range2cidr(ipStart, ipEnd,  bits, mask, newip) {
    bits = 1
    mask = 1
    while (bits < 32) {
        newip = or(ipStart, mask)
        if ((newip>ipEnd) || ((lshift(rshift(ipStart,bits),bits)) != ipStart)) {
           bits--
           mask = rshift(mask,1)
           break
        }
        bits++
        mask = lshift(mask,1)+1
    }
    newip = or(ipStart, mask)
    bits = 32 - bits
    result = dec2ip(ipStart) "/" bits
    if (newip < ipEnd) result = range2cidr(newip + 1, ipEnd)
    return result
}

# convert dotted quads to long decimal ip
#	int ip2dec("192.168.0.15")
#
function ip2dec(ip,   slice) {
	split(ip, slice, ".")
	return (slice[1] * 2^24) + (slice[2] * 2^16) + (slice[3] * 2^8) + slice[4]
}

# convert decimal long ip to dotted quads
#	str dec2ip(1171259392)
#
function dec2ip(dec,    ip, quad) {
	for (i=3; i>=1; i--) {
		quad = 256^i
		ip = ip int(dec/quad) "."
		dec = dec%quad
	}
	return ip dec
}

function sanitize(ip) {
	split(ip, slice, ".")
	return slice[1]/1 "." slice[2]/1 "." slice[3]/1 "." slice[4]/1
}


BEGIN{
	FS=" , | - "
}

# sanitize ip's
{$1 = sanitize($1); $2 = sanitize($2)}

# range with a single IP
$1==$2 {printf "%s\n", $1}

# ranges with multiple IP's
$1!=$2{print range2cidr(ip2dec($1), ip2dec($2))}

# footer
END {print "COMMIT\n"}
