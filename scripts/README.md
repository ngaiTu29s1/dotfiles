# SOPS Environment File Encryption/Decryption

This folder contains `sops-env.py` and `.sops.yaml` for encrypting and decrypting `.env*` files using Mozilla SOPS and age keys.

## Features
- Encrypts and decrypts any `.env`, `.env.*`, `.env.*.*`, etc. (except files ending with `.enc`)
- Works recursively in the target directory
- Cross-platform: Windows 11 and Linux

---

## Prerequisites

1. **Python 3** installed and available in your PATH
2. **SOPS** installed and available in your PATH
3. **age** (optional, but recommended if using age keys)
4. Your age key(s) in a supported location (see below)

---

## Setup

### 1. Clone or copy this folder
Place `sops-env.py` and `.sops.yaml` in a folder (e.g., `scripts/`).


### 2. (Optional) Add to PATH or Set Alias for Global Use

#### Linux
1. **Add to PATH:**
	- Add the scripts folder to your PATH by editing your `~/.bashrc`, `~/.zshrc`, or equivalent:
	  ```sh
	  export PATH="$PATH:/path/to/scripts"
	  # Or move/copy sops-env.py to ~/bin and ensure ~/bin is in your PATH
	  ```
2. **Set an alias:**
	- Add this to your shell config file:
	  ```sh
	  alias sops-env='python /path/to/scripts/sops-env.py'
	  ```
3. **(Optional) Symlink for direct use:**
	```sh
	chmod +x /path/to/scripts/sops-env.py
	ln -s /path/to/scripts/sops-env.py ~/bin/sops-env
	```

#### Windows 11
1. **Add to PATH:**
	- Open System Properties → Advanced → Environment Variables.
	- Under "User variables" or "System variables", find and edit the `Path` variable.
	- Add the full path to your `scripts` folder (e.g., `Path to the scripts folder`).
	- Click OK and restart your terminal.
2. **Set an alias (PowerShell):**
	- Add this to your PowerShell profile (run `notepad $PROFILE`):
	  ```powershell
	  Set-Alias sops-env "python path to file .py" $args
	  ```
	- Save and restart your terminal.
3. **(Optional) Rename:**
	- Rename `sops-env.py` to `sops-env` for easier use (ensure `.py` files are associated with Python).

---

## Usage

### Basic Commands

**Encrypt all .env* files:**
```sh
# Linux
python /path/to/scripts/sops-env.py encrypt [target_dir]
# Windows
python C:\path\to\scripts\sops-env.py encrypt [target_dir]
```

**Decrypt all .env*.enc files:**
```sh
# Linux
python /path/to/scripts/sops-env.py decrypt [target_dir]
# Windows
python C:\path\to\scripts\sops-env.py decrypt [target_dir]
```

**[target_dir]** is optional. If omitted, the current directory is used. The script works recursively.

### Example
```sh
# Encrypt all .env* files in the current directory and subfolders
python sops-env.py encrypt

# Decrypt all .env*.enc files in a specific folder
python sops-env.py decrypt /path/to/project
```

---

## Configuration

- `.sops.yaml` must be in the same folder as `sops-env.py` (or set `CONFIG_FILE` env var)
- The regex in `.sops.yaml` matches all `.env*` and `.env*.enc` files, including multiple extensions
- Edit the `key_groups` in `.sops.yaml` to use your own age keys

---

## Key Management

- Place your age key in one of the following (Linux or Windows):
	- `$HOME/.config/sops/age/keys.txt`
	- `$HOME/.config/age/keys.txt`
- Or set the environment variable `SOPS_AGE_KEY_FILE` or `AGE_IDENTITIES` to the key file path

---

## Notes

- Only encrypted `.env*.enc` files should be committed to git. Add this to your `.gitignore`:
	```
	*.env*
	!*.env*.enc
	```
- The script will skip files that already have a corresponding `.enc` file when encrypting.
- The script will skip files that do not match the regex or are inside `.git` folders.

---

## Troubleshooting

- If you get `Config not found: .sops.yaml`, ensure the config file is in the same folder as the script or set `CONFIG_FILE`.
- If you get `no matching creation rules found`, check the `path_regex` in `.sops.yaml` matches your file paths (see the provided regex for multi-extension support).
- On Windows, ensure you use double backslashes `\\` or forward slashes `/` in paths if needed.

---

## Uninstall

Just remove the script and config file, and optionally remove any symlinks or PATH entries you added.
