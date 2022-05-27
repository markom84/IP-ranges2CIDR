# Convert IP ranges to CIDR notation
# awk, gawk, mawk compatible

function range2cidr(ipStart, ipEnd, result, bits, mask, newip) {
    bits = 1
    mask = 1
    while (bits < 32) {
        newip = bit_or(ipStart, mask)
        if ((newip > ipEnd) || ((bit_lshift(bit_rshift(ipStart,bits),bits)) != ipStart)) {
            bits--
            mask = bit_rshift(mask,1)
            break
        }
        bits++
        mask = bit_lshift(mask,1)+1
    }
    newip = bit_or(ipStart, mask)
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

# Bitwise OR of var1 and var2
function bit_or(a, b, r, i, c) {
    for (r=i=0;i<32;i++) {
        c = 2 ^ i
        if ((int(a/c) % 2) || (int(b/c) % 2)) r += c
    }
    return r
}

# Rotate bytevalue left x times
function bit_lshift(var, x) {
    while(x--) var*=2;
    return var;
}

# Rotate bytevalue right x times
function bit_rshift(var, x) {
    while(x--) var=int(var/2);
    return var;
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
