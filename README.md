# antigravity-acp-bin

Production-ready Arch Linux PKGBUILD repository for **`antigravity-acp-bin`**, packaging the prebuilt **Agent Client Protocol (ACP) server** for Google Antigravity.

The package provides:
- `/usr/lib/antigravity-acp/agy_acp_server.par`: The ACP server Python archive binary.
- `/usr/lib/antigravity-acp/localharness_external`: The static companion local harness binary.
- `/usr/bin/agy_acp_server.par`: Symlink required by Emacs `agent-shell`.
- `/usr/bin/agy-acp-server`: Convenience CLI symlink.
- `/usr/share/licenses/antigravity-acp-bin/LICENSE`: Terms of service and license notice.

---

## Prerequisites

Ensure you have Arch Linux development utilities installed:

```bash
sudo pacman -S --needed base-devel git
```

Optional (recommended task runner):

```bash
sudo pacman -S --needed just
```

---

## Building and Installing Locally

### Using `makepkg` directly

1. Clone or navigate to this repository:
   ```bash
   cd antigravity-acp-bin
   ```

2. Build and install the package with pacman:
   ```bash
   makepkg -si
   ```

3. To build the `.pkg.tar.zst` without installing:
   ```bash
   makepkg -s
   ```

### Using `just` (Task Runner)

This repository includes a [`justfile`](justfile) with common packaging tasks:

```bash
# Build the package (.pkg.tar.zst) locally
just build

# Build and install via pacman
just install

# Clean up build directories (pkg/, src/) and downloaded archives
just clean
```

---

## Editor Integrations

The ACP server communicates over stdin/stdout using JSON-RPC, exposing Antigravity agentic capabilities to any ACP-compatible client.

### 1. Emacs (`agent-shell`)

Emacs [agent-shell](https://github.com/xenodium/agent-shell) natively detects `agy_acp_server.par` in your `$PATH`.

Example `init.el` / `use-package` configuration:

```elisp
(use-package agent-shell
  :ensure t
  :config
  ;; agent-shell will automatically discover /usr/bin/agy_acp_server.par
  ;; Alternatively, explicitly configure the command if desired:
  (setq agent-shell-google-binary "agy_acp_server.par"))
```

### 2. Zed Editor

Zed supports external agent servers implementing ACP. In your Zed `settings.json`:

```json
{
  "assistant": {
    "version": "2",
    "provider": {
      "name": "agent_client_protocol",
      "command": "agy-acp-server"
    }
  }
}
```

You can point to either `agy-acp-server` or `agy_acp_server.par`.

### 3. JetBrains IDEs

For JetBrains IDEs (IntelliJ IDEA, PyCharm, WebStorm, etc.):
1. Install the official Google Antigravity extension or ACP plugin.
2. Under **Settings / Preferences > Tools > Antigravity / ACP Server**, select **Custom Executable**.
3. Point the path to `/usr/bin/agy-acp-server` or `/usr/bin/agy_acp_server.par`.

---

## Verification & Diagnostics

### Initializing Probe Test

You can test that the ACP server responds correctly to a JSON-RPC `initialize` handshake:

```bash
# Using just:
just probe

# Or using shell directly:
echo '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":1,"clientCapabilities":{"fs":{"readTextFile":true,"writeTextFile":true}}}}' | agy_acp_server.par --uid=
```

A healthy server will reply on stdout with JSON containing `agentCapabilities` and `agentInfo`:

```json
{"jsonrpc":"2.0","id":0,"result":{"protocolVersion":1,"agentCapabilities":{...},"agentInfo":{"name":"antigravity-acp","title":"Google Antigravity","version":"1.3.0"}}}
```

### Checking Third-Party Notices

To display all bundled third-party open-source software notices:

```bash
agy_acp_server.par --notices
```

### IPv6 Loopback Troubleshooting

If IPv6 is disabled system-wide (e.g. `net.ipv6.conf.all.disable_ipv6 = 1`), Google Abseil binaries may abort on startup with:
```
Check failed: loopback6_ok || !loopback4_ok This machine does not have an IPv6 loopback (::1) interface.
```

To bypass this check on machines where IPv6 is disabled, pass the flag:
```bash
agy_acp_server.par --enforce_kernel_ipv6_support=false
```
*(The `just probe` recipe detects this condition automatically and includes the bypass flag if IPv6 loopback is absent.)*

---

## Task Runner Reference (`justfile`)

| Command | Action |
| :--- | :--- |
| `just build` | Builds package `.pkg.tar.zst` using `makepkg -s` |
| `just install` | Builds and installs package via `makepkg -si` |
| `just checksums` | Updates SHA-256 checksums in `PKGBUILD` using `updpkgsums` |
| `just srcinfo` | Regenerates `.SRCINFO` with `makepkg --printsrcinfo > .SRCINFO` |
| `just lint` | Runs `namcap PKGBUILD` and `namcap *.pkg.tar.zst` |
| `just clean` | Cleans `src/`, `pkg/`, `*.pkg.tar.zst`, and `*.zip` archives |
| `just probe` | Sends standard 1-line JSON-RPC initialization payload via stdin |

---

## AUR Maintenance Workflow

When a new upstream release is published, update the package using the following steps:

1. **Update Version**:
   Edit [`PKGBUILD`](PKGBUILD) and increment `pkgver` (and reset `pkgrel=1`):
   ```bash
   pkgver=1.4.0
   pkgrel=1
   ```

2. **Update Checksums**:
   Run `updpkgsums` to fetch upstream archives and calculate new SHA-256 sums:
   ```bash
   just checksums
   ```

3. **Regenerate `.SRCINFO`**:
   The AUR relies on `.SRCINFO` for package indexing. Always regenerate it after editing `PKGBUILD`:
   ```bash
   just srcinfo
   ```

4. **Lint Packaging**:
   ```bash
   just lint
   ```

5. **Test Build**:
   ```bash
   just build
   ```

6. **Publish to AUR**:
   Once your AUR account and SSH key are set up:
   ```bash
   # If AUR remote is configured:
   git add PKGBUILD .SRCINFO .gitignore README.md justfile
   git commit -m "chore: release 1.4.0-1"
   git push origin main
   git push aur main:master
   ```

---

## Upstream & Legal

- **Upstream Documentation**: [https://antigravity.google/docs/ide/extensions](https://antigravity.google/docs/ide/extensions)
- **License**: `custom:proprietary` (Subject to [Google Terms of Service](https://policies.google.com/terms))