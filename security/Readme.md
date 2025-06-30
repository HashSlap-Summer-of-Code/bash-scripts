# 🔐 Folder Encryptor – Bash Script

A simple, secure, and beginner-friendly Bash script to **compress and encrypt any folder** using AES-256 encryption via OpenSSL.

---

## 💡 What This Script Does (Simple Explanation)

Imagine you have a private folder you don’t want others to access.

This script will:

1. 📦 Compress the folder into a `.tar` file
2. 🔒 Encrypt the `.tar` file using AES-256 encryption
3. 🔐 Ask you to set a password (hidden input)
4. 🧹 Delete the original `.tar` so only the encrypted version remains

Result: A single `.tar.enc` file that is useless without the correct password.

---

## 🧠 Technical Breakdown

- Archives the folder using `tar -cf`
- Encrypts the `.tar` file using `openssl enc -aes-256-cbc -pbkdf2 -salt`
- Prompts for password with `read -s`
- Automatically deletes the original `.tar` after encryption
- Output file is fully encrypted and unreadable without the password

---

## 🧪 Usage

### ✅ Encrypt a folder

```bash
bash folder-encryptor.sh <folder-path>
```

**Example:**

```bash
bash folder-encryptor.sh ~/Documents/secrets
```

You’ll be prompted to:
- Enter a password
- Confirm the password

After success, the output file will be:

```
secrets.tar.enc
```

---

## 🔓 How to Decrypt

To recover your folder:

```bash
openssl enc -d -aes-256-cbc -pbkdf2 -in secrets.tar.enc -out secrets.tar
tar -xf secrets.tar
```

(Then optionally delete the `.tar` file after extraction)

---

## 🛠 Requirements

| Tool      | Purpose            |
|-----------|--------------------|
| `tar`     | Archive folders    |
| `openssl` | Encrypt files      |
| `read -s` | Secure password entry |

> 💡 This script is designed to run in **Linux or WSL**.  
> It may not work properly in Git Bash or native Windows terminals.

Install tools on Ubuntu if missing:

```bash
sudo apt update
sudo apt install openssl tar
```

---

## 📄 Output Summary

| Input Folder | Output File        |
|--------------|--------------------|
| `myFolder/`  | `myFolder.tar.enc` |

---

## 🔐 Security Notes

- Uses AES-256-CBC encryption with PBKDF2 key strengthening
- Password input is never stored or logged
- The unencrypted `.tar` file is deleted for safety
- If the password is incorrect, decryption will fail or give unreadable data

---

## 📁 Script Location

```
security/folder-encryptor.sh
```

---

## ✍️ Author

[Surge77](https://github.com/Surge77)  — Contributed for HashSlap Summer of Code (HSSoC)


