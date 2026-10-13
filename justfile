# Task runner for antigravity-acp-bin Arch Linux package

default:
    @just --list

# Build the package locally using makepkg
build:
    makepkg -s

# Build and install the package locally using makepkg/pacman
install:
    makepkg -si

# Update source checksums using updpkgsums
checksums:
    updpkgsums

# Generate .SRCINFO metadata for AUR
srcinfo:
    makepkg --printsrcinfo > .SRCINFO

# Lint the PKGBUILD and any built packages using namcap
lint:
    namcap PKGBUILD
    @for pkg in *.pkg.tar.zst; do \
        if [ -f "$pkg" ]; then namcap "$pkg"; fi; \
    done

# Clean build artifacts, downloaded archives, and pkg/src dirs
clean:
    rm -rf pkg/ src/ *.pkg.tar.zst *.pkg.tar.xz *.pkg.tar.gz *.zip *.tar.gz *.par

# Run a 1-line JSON-RPC initialization test via stdin
probe *flags:
    #!/usr/bin/env bash
    set -euo pipefail
    EXTRA_FLAGS=""
    # Auto-detect if IPv6 loopback is missing (common with disabled IPv6) to avoid abseil abort
    if ! grep -q "^00000000000000000000000000000001" /proc/net/if_inet6 2>/dev/null; then
        EXTRA_FLAGS="--enforce_kernel_ipv6_support=false"
    fi
    echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":1,"clientCapabilities":{"fs":{"readTextFile":true,"writeTextFile":true}}}}' | agy_acp_server.par --uid= $EXTRA_FLAGS {{flags}}
