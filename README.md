
# 🐚 Bash Scripts Collection

Welcome to the **Bash Scripts** repository under **HashSlap Summer of Code (HSSoC)**!  
This repository is a collection of handy, modular, and reusable Bash scripts built for system automation, productivity, and quick CLI-based solutions.

<p align="center">
  <img src="https://img.shields.io/github/license/HashSlap-Summer-of-Code/bash-scripts?style=flat-square&color=brightgreen" />
  <img src="https://img.shields.io/github/forks/HashSlap-Summer-of-Code/bash-scripts?style=flat-square&color=gray" />
  <img src="https://img.shields.io/github/stars/HashSlap-Summer-of-Code/bash-scripts?style=flat-square&color=blue" />
  <img src="https://img.shields.io/github/issues/HashSlap-Summer-of-Code/bash-scripts?style=flat-square&color=green" />
  <img src="https://img.shields.io/github/issues-pr/HashSlap-Summer-of-Code/bash-scripts?style=flat-square&color=gold" />
</p>

---

## 🚀 What's Inside?

This repository will feature scripts for:

- 🧹 System Cleanup & Maintenance
- 🌐 Network Tools & Connectivity Checkers
- 📂 File Management Helpers
- 🔐 Security & Permissions
- 📊 System Monitoring

Whether you’re a beginner learning shell scripting or a power user automating workflows, this is the place for you!

---

## 📂 Folder Structure

```bash
.
├── cleanup/
│   └── clear-cache.sh
├── network/
│   └── ping-check.sh
├── monitor/
│   └── cpu-usage.sh
├── file-tools/
│   └── batch-rename.sh
└── README.md
```

---

## 🧑‍💻 Contribution Guidelines

We welcome contributions of all levels! You can:

* Add new useful scripts
* Optimize existing ones
* Improve readability and reusability

📌 **Naming Convention:** Use `kebab-case.sh`
📌 **Add a comment block** at the top describing the script’s purpose and usage

---

## 🤝 Getting Started

1. **Fork** this repo 🍴
2. **Clone** to your machine

   ```bash
   git clone https://github.com/your-username/bash-scripts.git
   ```
3. Create your script inside the right folder
4. Commit & push
5. Open a Pull Request ✅

---

## 📄 License

This repository is licensed under the [MIT License](LICENSE).

---

# Step 1: Add your hosts to a file
echo -e "google.com\n192.168.1.1" > hosts.txt

# Step 2: Run the script manually
bash network/uptime-watcher.sh -f hosts.txt -i 5 --log

# Step 3: OR add it as a cron job for continuous background monitoring
crontab -e
# Add:
*/5 * * * * /path/to/uptime-watcher.sh -f /path/to/hosts.txt --silent --log

