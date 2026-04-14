# Scripts

Custom quality-of-life scripts symlinked to `~/.scripts/` via GNU Stow.

## 2FA (YubiKey OATH)

Wrapper scripts for `ykman` (YubiKey Manager) to manage and retrieve 2FA codes.

### `2fa [query]`
Retrieve a TOTP code from your YubiKey.
- **Interactive Selection**: If no query is provided, or if multiple accounts match the query, an `fzf` picker will open.
- **Automatic Copy**: The 6-digit code is automatically copied to your clipboard (`pbcopy`).
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

