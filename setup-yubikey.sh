#!/usr/bin/env bash
set -e

echo "==> Setting up YubiKey (GPG + SSH)..."

# ── 1. Check dependencies ─────────────────────────────────────────────────────
for cmd in gpg gpgconf pinentry-mac; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' not found. Run install.sh first."
        exit 1
    fi
done

# ── 2. Configure ~/.gnupg ─────────────────────────────────────────────────────
GNUPGHOME="${GNUPGHOME:-$HOME/.gnupg}"
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

echo "==> Writing gpg-agent.conf..."
cat > "$GNUPGHOME/gpg-agent.conf" <<EOF
enable-ssh-support
pinentry-program $(command -v pinentry-mac)
default-cache-ttl 600
max-cache-ttl 7200
EOF

# ── 3. Restart gpg-agent ──────────────────────────────────────────────────────
echo "==> Restarting gpg-agent..."
gpgconf --kill gpg-agent
gpg-connect-agent /bye 2>/dev/null || true

# ── 4. Import public key from YubiKey ─────────────────────────────────────────
echo ""
echo "Insert your YubiKey and press Enter..."
read -r

echo "==> Fetching public key from card..."
# Tries the URL stored on the card (set via: gpg --edit-card → url)
if gpg --command-fd=0 --edit-card <<< $'fetch\nquit\n' 2>/dev/null; then
    echo "   Key fetched from card URL."
else
    # Fall back: show fingerprints so user can receive-keys manually
    echo ""
    echo "   Auto-fetch failed (no URL stored on card, or network issue)."
    echo "   Card contents:"
    gpg --card-status 2>/dev/null || true
    echo ""
    echo "   Import your public key manually, then re-run this script:"
    echo "     gpg --receive-keys <fingerprint>    # from keyserver"
    echo "     gpg --import /path/to/pubkey.asc    # from file"
    exit 1
fi

# ── 5. Set ultimate trust ─────────────────────────────────────────────────────
echo "==> Setting ultimate trust..."
gpg --list-secret-keys --with-colons 2>/dev/null \
    | awk -F: '/^fpr/{print $10}' \
    | while read -r fpr; do
        echo "   Trusting $fpr"
        printf '%s:6:\n' "$fpr" | gpg --import-ownertrust
    done

# ── 6. Verify SSH key is available ────────────────────────────────────────────
echo ""
echo "==> SSH keys served by gpg-agent:"
export SSH_AUTH_SOCK
SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
ssh_keys=$(ssh-add -L 2>/dev/null || true)
if [ -n "$ssh_keys" ]; then
    echo "$ssh_keys"
else
    echo "   None found — make sure your YubiKey has an [A]uth subkey."
fi

echo ""
echo "✅ Done! Test with:"
echo "   ssh -T git@github.com"
echo "   ssh -T git@bitbucket.org"
