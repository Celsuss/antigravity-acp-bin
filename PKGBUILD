# Maintainer: Jens Lordén <jenslorden@gmail.com>

pkgname=antigravity-acp-bin
pkgver=1.3.0
pkgrel=1
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
sha256sums_x86_64=('9fb60956af0a9d76220a4db91ca9ac88e2a2372ad68f985ab5fceace6b825b96')
sha256sums_aarch64=('500b0bc0fb858e88f4df404d4cedf80bf9298c178291e39e383d6c50b111cbdf')

package() {
  # Install main binary and companion harness to /usr/lib/antigravity-acp
  install -Dm755 "${srcdir}/agy_acp_server.par" "${pkgdir}/usr/lib/antigravity-acp/agy_acp_server.par"
  if [[ -f "${srcdir}/localharness_external" ]]; then
    install -Dm755 "${srcdir}/localharness_external" "${pkgdir}/usr/lib/antigravity-acp/localharness_external"
  fi

  # Create symlinks in /usr/bin/
  install -d "${pkgdir}/usr/bin"
  ln -sf /usr/lib/antigravity-acp/agy_acp_server.par "${pkgdir}/usr/bin/agy_acp_server.par"
  ln -sf /usr/lib/antigravity-acp/agy_acp_server.par "${pkgdir}/usr/bin/agy-acp-server"

  # Install license notice
  install -d "${pkgdir}/usr/share/licenses/${pkgname}"
  cat << 'EOF' > "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
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
