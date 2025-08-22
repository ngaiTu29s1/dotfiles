#!/usr/bin/env python3
import os, sys, re, subprocess
from pathlib import Path
from shutil import which

CONFIG_FILE = os.environ.get("CONFIG_FILE", ".sops.yaml")
ROOT = Path.cwd()

ENV_REGEX = re.compile(
    r"^\.env(?:\.[A-Za-z0-9_-]+)?$"
)  # .env, .env.local, .env.prod ...
ENC_SUFFIX = ".enc"


def die(msg: str, code: int = 1):
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(code)


# --- thêm vào đầu file (sau import) ---
from os import path


def find_keyfile():
    # Ưu tiên biến môi trường nếu user đã set
    env_key = os.environ.get("SOPS_AGE_KEY_FILE") or os.environ.get("AGE_IDENTITIES")
    if env_key and Path(env_key).is_file():
        return env_key

    home = Path.home()
    candidates = [
        home / ".config" / "sops" / "age" / "keys.txt",  # Linux/macOS chuẩn SOPS
        home / ".config" / "age" / "keys.txt",  # vị trí phổ biến khác
        # Windows (PowerShell dùng $HOME)
        home / ".config" / "sops" / "age" / "keys.txt",
        home / ".config" / "age" / "keys.txt",
    ]
    for p in candidates:
        if p.is_file():
            return str(p)
    return None


# --- thay thế nguyên hàm check_tools() bằng bản mới ---
def check_tools():
    if which("sops") is None:
        die("Missing 'sops' in PATH")
    # age không bắt buộc nếu dùng KMS khác, nên chỉ cảnh báo
    if which("age") is None:
        print("WARN: 'age' not found in PATH (sops may still work if using other KMS)")
    if not Path(CONFIG_FILE).is_file():
        die(f"Config not found: {CONFIG_FILE}")

    keyfile = find_keyfile()
    if keyfile:
        # đặt biến môi trường cho tiến trình con (sops) dùng ngay
        os.environ["SOPS_AGE_KEY_FILE"] = keyfile
        os.environ["AGE_IDENTITIES"] = keyfile
    else:
        print(
            "NOTE: No age key found in common locations; set SOPS_AGE_KEY_FILE/AGE_IDENTITIES if needed"
        )


def is_in_git(path: Path) -> bool:
    # skip .git or any hidden VCS folder
    return any(part.startswith(".git") for part in path.parts)


def list_env_files():
    files = []
    for p in ROOT.rglob("*"):
        if p.is_file() and not is_in_git(p):
            name = p.name
            if ENV_REGEX.match(name) and not name.endswith(ENC_SUFFIX):
                files.append(p)
    return files


def list_env_enc_files():
    return [p for p in ROOT.rglob("*.env.enc") if p.is_file() and not is_in_git(p)]


def run_sops(args, inp_path: Path):
    # capture stdout text; never write via shell redirection to avoid CRLF
    cmd = (
        [
            "sops",
            "--config",
            CONFIG_FILE,
            "--input-type",
            "dotenv",
            "--output-type",
            "dotenv",
        ]
        + args
        + [str(inp_path)]
    )
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        die(f"sops failed for {inp_path}:\n{r.stderr.strip()}")
    # normalize to LF no matter the platform
    return r.stdout.replace("\r\n", "\n").replace("\r", "\n")


def write_lf(path: Path, text: str):
    # Write UTF-8 (no BOM) with LF
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def encrypt():
    targets = list_env_files()
    if not targets:
        print("Nothing to encrypt.")
        return
    print("🔒 Encrypting *.env → *.env.enc ...")
    for f in targets:
        out = Path(str(f) + ENC_SUFFIX)
        if out.exists():
            print(f"⏭️  Skip {f} → {out} (already exists)")
            continue
        print(f"→ {f}  →  {out}")
        text = run_sops(["-e"], f)
        write_lf(out, text)
    print("✅ Done. Commit only *.env.enc")



def decrypt():
    targets = list_env_enc_files()
    if not targets:
        print("Nothing to decrypt.")
        return
    print("🔓 Decrypting *.env.enc → *.env ...")
    for f in targets:
        out = Path(str(f).removesuffix(ENC_SUFFIX))
        print(f"→ {f}  ⇒  {out}")
        text = run_sops(["-d"], f)
        write_lf(out, text)
    print("✅ Done.")


def fix_newlines():
    # Optional helper to force LF in-place for existing files that might have CRLF
    fixed = 0
    for coll in (
        list_env_files(),
        list_env_enc_files(),
        [Path(CONFIG_FILE)] if Path(CONFIG_FILE).exists() else [],
    ):
        for p in coll:
            try:
                raw = p.read_bytes()
                # If binary-ish (contains null), skip
                if b"\x00" in raw:
                    continue
                txt = (
                    raw.decode("utf-8", errors="ignore")
                    .replace("\r\n", "\n")
                    .replace("\r", "\n")
                )
                write_lf(p, txt)
                fixed += 1
            except Exception:
                pass
    print(f"👍 Normalized newlines to LF in ~{fixed} files.")


def usage():
    print("Usage:")
    print("  python sops_env.py encrypt   # .env -> .env.enc")
    print("  python sops_env.py decrypt   # .env.enc -> .env")
    print("  python sops_env.py fix-lf    # normalize CRLF -> LF in configs/envs")
    print("\nEnv vars:")
    print("  CONFIG_FILE            (default .sops.yaml)")
    print("  SOPS_AGE_KEY_FILE / AGE_IDENTITIES  (path to age keys)")


if __name__ == "__main__":
    if len(sys.argv) != 2 or sys.argv[1] not in {"encrypt", "decrypt", "fix-lf"}:
        usage()
        sys.exit(2)
    check_tools()
    cmd = sys.argv[1]
    if cmd == "encrypt":
        encrypt()
    elif cmd == "decrypt":
        decrypt()
    else:
        fix_newlines()
