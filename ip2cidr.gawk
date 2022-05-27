# Convert IP ranges to CIDR notation
# gawk compatible

function range2cidr(ipStart, ipEnd, result, bits, mask, newip) {
    bits = 1
    mask = 1
    while (bits < 32) {
        newip = or(ipStart, mask)
        if ((newip > ipEnd) || ((lshift(rshift(ipStart,bits),bits)) != ipStart)) {
            bits--
            mask = rshift(mask,1)
            break
        }
        bits++
        mask = lshift(mask,1)+1
    }
    newip = or(ipStart, mask)
    bits = 32 - bits
    result = (result)?result ORS dec2ip(ipStart) "/" bits : dec2ip(ipStart) "/" bits
    if (newip < ipEnd) result = range2cidr(newip + 1, ipEnd,result)
    return result
}

# convert dotted quads to long decimal ip
# int ip2dec("192.168.0.15")
#
function ip2dec(ip, slice) {
    split(ip, slice, /[.]/)
    return (slice[1] * 2^24) + (slice[2] * 2^16) + (slice[3] * 2^8) + slice[4]
}

# convert decimal long ip to dotted quads
# str dec2ip(1171259392)
#
function dec2ip(dec, ip, quad) {
    for (i=3; i>=1; i--) {
        quad = 256^i
        ip = ip int(dec/quad) "."
        dec = dec%quad
    }
    return ip dec
}

function sanitize(ip) {
    split(ip, slice, /[.]/)
    return slice[1]/1 "." slice[2]/1 "." slice[3]/1 "." slice[4]/1
}

BEGIN{
    FS=" - |-|:"
}

# sanitize ip's
!/^#/ && NF {
    f1 = sanitize($(NF-1))
    f2 = sanitize($NF)
    print range2cidr(ip2dec(f1), ip2dec(f2))
}

END {print ""}
