# Scripts

The `scripts` Stow package links `~/.scripts/` and `~/.local/bin/`.

## 2FA (YubiKey OATH)

Wrapper scripts for `ykman` (YubiKey Manager) to manage and retrieve 2FA codes.

### `2fa [query]`
Retrieve a TOTP code from your YubiKey.
- **Interactive Selection**: If no query is provided, or if multiple accounts match the query, an `fzf` picker will open.
- **Automatic Copy**: The 6-digit code is automatically copied to your clipboard.
- **Touch Prompt**: If the account requires a physical touch, a prompt will appear: `👉 Touch your YubiKey...`.
- **Validity**: Displays the code and the remaining seconds before it expires.

#### Examples:
```bash
# Open interactive picker for all accounts
2fa

# Filter for "github" and open picker if multiple matches
2fa github
```

### `2fa-add`
Interactively add a new OATH account to your YubiKey.
- Prompts for Account Name (e.g., `Issuer:AccountName`) and Secret Key.
- Option to require physical touch for code generation.

#### Examples:
```bash
# Start the interactive addition process
2fa-add
# -> Account Name (e.g. Issuer:AccountName): GitHub:my-user
# -> Secret Key: <paste secret here>
# -> Require Touch? (y/N): y
```

---

## pass (password store)

Interactive password picker using fzf.

### Ctrl+P
The `pass` command is password-store itself. Ctrl+P opens the fzf picker:
- Fuzzy search through `.gpg` files in `~/.password-store`
- Preview shows metadata (account name, URL, notes) — never the password
- Press `Enter` to copy password to clipboard

#### Usage
```
Ctrl+P          # Open password picker
Enter           # Copy selected password to clipboard
```

#### How it works
1. Finds all `.gpg` files in `~/.password-store`
2. Strips path and extension for clean display
3. Opens fzf with preview showing metadata only
4. On selection, uses `pass -c` to copy the password (45s clipboard timeout)

---

## Clipboard and pinentry

`~/.local/bin/clipboard-copy` and `clipboard-paste` use `pbcopy` and `pbpaste` on macOS, and `wl-copy` and `wl-paste` on Linux. The shell, tmux, 2FA, and pass picker call them.

`~/.local/bin/pinentry-auto` chooses `pinentry-mac` on macOS and a Qt, GNOME, or curses pinentry on Linux. `setup-yubikey.sh` points `gpg-agent` at it.
