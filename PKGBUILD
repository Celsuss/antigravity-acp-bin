# Maintainer: Jens Lordén <jenslorden@gmail.com>

pkgname=antigravity-acp-bin
pkgver=1.4.0
pkgrel=2
pkgdesc="Agent Client Protocol (ACP) server for Google Antigravity (prebuilt binary)"
arch=('x86_64' 'aarch64')
url="https://antigravity.google/docs/ide/extensions"
license=('LicenseRef-Proprietary')
depends=('glibc')
provides=("antigravity-acp=${pkgver}" "agy-acp-server=${pkgver}")
conflicts=('antigravity-acp' 'agy-acp-server')
options=('!strip' '!debug')

source_x86_64=("https://dl.google.com/agy-extensions/releases/linux/agy-acp-server-${pkgver}-linux-x86_64.zip")
source_aarch64=("https://dl.google.com/agy-extensions/releases/linux/agy-acp-server-${pkgver}-linux-arm64.zip")
sha256sums_x86_64=('fbb2d54dd94fb897845308d3b6b46187c627f1c60078ded81adeeaf8b90c5d7a')
sha256sums_aarch64=('3dc43a21f5402b23a4dba7b320a6745e9dbf4b6ead912ce9fc76011ea3a08a7e')

package() {
  # Install main binary and companion harness to /usr/lib/antigravity-acp
  install -Dm755 "${srcdir}/agy_acp_server.par" "${pkgdir}/usr/lib/antigravity-acp/agy_acp_server.par"
  install -Dm755 "${srcdir}/localharness_external" "${pkgdir}/usr/lib/antigravity-acp/localharness_external"

  # Install launcher wrapper in /usr/bin/
  install -d "${pkgdir}/usr/bin"
  cat << 'EOF' > "${pkgdir}/usr/bin/agy-acp-server"
#!/usr/bin/env bash
set -e
if [ -z "$ANTIGRAVITY_HARNESS_PATH" ]; then
  export ANTIGRAVITY_HARNESS_PATH="/usr/lib/antigravity-acp/localharness_external"
elif [ -d "$ANTIGRAVITY_HARNESS_PATH" ]; then
  export ANTIGRAVITY_HARNESS_PATH="${ANTIGRAVITY_HARNESS_PATH%/}/localharness_external"
fi
EXTRA_FLAGS=()
if [ ! -f /proc/net/if_inet6 ] || ! grep -q "^00000000000000000000000000000001" /proc/net/if_inet6 2>/dev/null; then
  EXTRA_FLAGS+=("--enforce_kernel_ipv6_support=false")
fi
exec /usr/lib/antigravity-acp/agy_acp_server.par "${EXTRA_FLAGS[@]}" "$@"
EOF
  chmod 755 "${pkgdir}/usr/bin/agy-acp-server"

  # Compatibility symlink for tools expecting agy_acp_server.par (e.g. Emacs agent-shell)
  ln -sfr "${pkgdir}/usr/bin/agy-acp-server" "${pkgdir}/usr/bin/agy_acp_server.par"

  # Install license notice
  install -Dm644 /dev/stdin "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE" << 'EOF'
Google Antigravity Terms of Service & Software License Notice
==============================================================

This package distributes prebuilt binary distributions of the Agent Client
Protocol (ACP) server for Google Antigravity provided by Google LLC.

Use of Google Antigravity and the Agent Client Protocol server is subject to
Google Terms of Service and Google Antigravity terms:
- Google Terms of Service: https://policies.google.com/terms
- Google Privacy Policy: https://policies.google.com/privacy
- Google Antigravity Documentation: https://antigravity.google/docs/ide/extensions

Third-Party Software Notices:
This binary includes third-party open-source software components.
Detailed notices and license texts for third-party components can be displayed
by running:
    agy_acp_server.par --notices
EOF
}
