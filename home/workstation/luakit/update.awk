/fetchurl {/ {
    fetch = 1
    print
}

fetch && match($0, /url = "(.*)";/, cap) {
    print
    "nix-prefetch-url " cap[1] " 2>/dev/null" | getline newhash
}

fetch && match($0, /sha256 = "(.*)";/, cap) {
    sub(cap[1], newhash)
    print
}

fetch && /};/ {
    fetch = 0
}

!fetch {
    print
}
