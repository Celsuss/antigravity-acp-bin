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
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v namcap >/dev/null 2>&1; then
        echo "Warning: namcap is not installed. Install with 'sudo pacman -S namcap' to lint packages." >&2
        exit 1
    fi
    namcap PKGBUILD
    for pkg in *.pkg.tar.zst; do
        if [ -f "$pkg" ]; then namcap "$pkg"; fi
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
    SERVER_BIN=""
    if command -v agy_acp_server.par >/dev/null 2>&1; then
        SERVER_BIN="agy_acp_server.par"
    elif [ -x "pkg/antigravity-acp-bin/usr/bin/agy_acp_server.par" ]; then
        SERVER_BIN="pkg/antigravity-acp-bin/usr/bin/agy_acp_server.par"
    elif [ -x "src/agy_acp_server.par" ]; then
        SERVER_BIN="src/agy_acp_server.par"
    else
        echo "Error: agy_acp_server.par not found in PATH or local build dirs (pkg/, src/)." >&2
        echo "Build the package with 'just build' or install it with 'just install' first." >&2
        exit 1
    fi
    echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":1,"clientCapabilities":{"fs":{"readTextFile":true,"writeTextFile":true}}}}' | "$SERVER_BIN" --uid= $EXTRA_FLAGS {{flags}}
