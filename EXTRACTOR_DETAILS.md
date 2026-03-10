# Extractor Details - Complete Answers

## 1. Connect by Name (Not IP)

### Setup SSH Config

Add this to `~/.ssh/config`:

```bash
cat >> ~/.ssh/config << 'EOF'

# Ido-Esperanto Extractor EC2
Host ido-extractor
    HostName 54.220.110.151
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host extractor
    HostName 54.220.110.151
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF
```

### Now Connect by Name

```bash
# Use friendly name
ssh ido-extractor

# Or shorter
ssh extractor
```

### Test It

```bash
ssh ido-extractor "hostname && pwd"
```

---

## 2. Working Folder for run_extractor

### On EC2 Instance

**Working Directory:** `~/ido-esperanto-extractor/`  
**Full Path:** `/home/ubuntu/ido-esperanto-extractor/`

### Directory Structure

```
/home/ubuntu/ido-esperanto-extractor/
├── scripts/                      # Python extraction scripts
│   ├── regenerate-on-ec2.sh      # Main entry point
│   ├── download_dumps.sh         # Download Wiktionary
│   ├── export_apertium.py        # Export to .dix format
│   └── wiktionary_parser.py      # Parse Wiktionary XML
├── data/raw/                     # Wiktionary dumps (persistent)
│   ├── iowiki-latest-langlinks.sql.gz
│   ├── iowiki-latest-pages-articles.xml.bz2
│   ├── iowiktionary-latest-pages-articles.xml.bz2
│   └── eowiktionary-latest-pages-articles.xml.bz2
├── dumps/                        # Symlink to data/raw/
├── work/                         # Intermediate JSON files
│   ├── io_wiktionary_processed.json
│   ├── eo_wiktionary_processed.json
│   └── bilingual_normalized.json
├── dist/                         # ⭐ GENERATED DICTIONARIES (artifacts)
│   ├── apertium-ido.ido.dix
│   ├── apertium-ido-epo.ido-epo.dix
│   ├── ido_dictionary.json
│   ├── bidix_big.json
│   └── vortaro_dictionary.json
├── reports/                      # Statistics
│   └── stats_summary.md
└── logs/                         # Regeneration logs
    └── regeneration_*.log
```

### Key Paths

| Purpose | Path on EC2 |
|---------|-------------|
| **Working directory** | `~/ido-esperanto-extractor/` |
| **Artifacts (output)** | `~/ido-esperanto-extractor/dist/` |
| **Logs** | `~/ido-esperanto-extractor/logs/` |
| **Reports** | `~/ido-esperanto-extractor/reports/` |
| **Dumps (cached)** | `~/ido-esperanto-extractor/data/raw/` |

### Configuration Variables

You can override these in `run_extractor.sh`:

```bash
GITHUB_REPO="https://github.com/komapc/ido-esperanto-extractor.git"
EXTRACTOR_DIR="ido-esperanto-extractor"
EXTRACTOR_BRANCH="fix/extractor-script-references"
ENTRY_POINT="regenerate-on-ec2.sh"
RESULTS_DIR_INSTANCE="~/ido-esperanto-extractor/dist"
```

---

## 3. How to Copy Artifacts Back

### Automatic Copy (Recommended)

The `run_extractor.sh` script **automatically copies artifacts** when it completes:

```bash
cd ~/apertium-gemini/terraform
./run_extractor.sh
```

**What gets copied:**
- ✅ All files from `~/ido-esperanto-extractor/dist/` → `extractor-results/TIMESTAMP/`
- ✅ Reports from `~/ido-esperanto-extractor/reports/` → `extractor-results/TIMESTAMP/reports/`
- ✅ Logs from `~/ido-esperanto-extractor/logs/` → `extractor-results/TIMESTAMP/`

**Local destination:**
```
~/apertium-gemini/terraform/extractor-results/20251030-123456/
├── apertium-ido.ido.dix
├── apertium-ido-epo.ido-epo.dix
├── vortaro_dictionary.json
├── ido_dictionary.json
├── bidix_big.json
├── reports/
│   └── stats_summary.md
└── regeneration_*.log
```

### Manual Copy (If Needed)

If you need to copy artifacts manually:

#### Using SSH Config Name

```bash
# Copy all artifacts
scp -r ido-extractor:~/ido-esperanto-extractor/dist/* ~/apertium-gemini/terraform/extractor-results/manual/

# Copy specific file
scp ido-extractor:~/ido-esperanto-extractor/dist/apertium-ido.ido.dix ~/apertium-gemini/

# Copy reports
scp -r ido-extractor:~/ido-esperanto-extractor/reports ~/apertium-gemini/

# Copy logs
scp ido-extractor:~/ido-esperanto-extractor/logs/*.log ~/apertium-gemini/
```

#### Using IP (Old Way)

```bash
# Copy all artifacts
scp -i ~/.ssh/id_rsa -r ubuntu@54.220.110.151:~/ido-esperanto-extractor/dist/* ~/apertium-gemini/

# Copy specific file
scp -i ~/.ssh/id_rsa ubuntu@54.220.110.151:~/ido-esperanto-extractor/dist/apertium-ido.ido.dix ~/apertium-gemini/
```

### Copy from EC2 to Local (Step by Step)

```bash
# 1. Create local directory
mkdir -p ~/apertium-gemini/terraform/extractor-results/manual

# 2. Copy artifacts
scp -r ido-extractor:~/ido-esperanto-extractor/dist/* \
    ~/apertium-gemini/terraform/extractor-results/manual/

# 3. Copy reports
scp -r ido-extractor:~/ido-esperanto-extractor/reports \
    ~/apertium-gemini/terraform/extractor-results/manual/

# 4. Copy logs
scp ido-extractor:~/ido-esperanto-extractor/logs/*.log \
    ~/apertium-gemini/terraform/extractor-results/manual/

# 5. Verify
ls -lh ~/apertium-gemini/terraform/extractor-results/manual/
```

### Check Artifacts on EC2 Before Copying

```bash
# Connect to EC2
ssh ido-extractor

# Check what's available
cd ~/ido-esperanto-extractor
ls -lh dist/
ls -lh reports/
ls -lh logs/

# Check file sizes
du -sh dist/*

# Exit
exit
```

### Rsync Method (Alternative)

For faster copying with resume capability:

```bash
# Sync artifacts (preserves timestamps, resumes on failure)
rsync -avz --progress ido-extractor:~/ido-esperanto-extractor/dist/ \
    ~/apertium-gemini/terraform/extractor-results/manual/

# Sync everything
rsync -avz --progress \
    --include='dist/**' \
    --include='reports/**' \
    --include='logs/*.log' \
    --exclude='*' \
    ido-extractor:~/ido-esperanto-extractor/ \
    ~/apertium-gemini/terraform/extractor-results/manual/
```

---

## Complete Workflow with SSH Config

```bash
# 1. Setup SSH config (one-time)
cat >> ~/.ssh/config << 'EOF'
Host ido-extractor
    HostName 54.220.110.151
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
    ServerAliveInterval 60
EOF

# 2. Test connection
ssh ido-extractor "echo 'Connected!'"

# 3. Run extractor (auto-copies artifacts)
cd ~/apertium-gemini/terraform
./run_extractor.sh

# 4. Check results locally
ls -lh extractor-results/*/

# 5. Or manually copy if needed
scp -r ido-extractor:~/ido-esperanto-extractor/dist/* extractor-results/manual/
```

---

## Quick Reference

### Connect
```bash
ssh ido-extractor
```

### Working Folder
```bash
~/ido-esperanto-extractor/
```

### Artifacts Location
```bash
~/ido-esperanto-extractor/dist/
```

### Copy Artifacts
```bash
# Automatic (recommended)
cd terraform && ./run_extractor.sh

# Manual
scp -r ido-extractor:~/ido-esperanto-extractor/dist/* extractor-results/manual/
```

### Check Artifacts
```bash
ssh ido-extractor "ls -lh ~/ido-esperanto-extractor/dist/"
```

---

## Troubleshooting

### Can't connect by name?
```bash
# Check SSH config
cat ~/.ssh/config | grep -A 5 ido-extractor

# Test connection
ssh -v ido-extractor
```

### Artifacts not found?
```bash
# Check if extractor ran successfully
ssh ido-extractor "ls -la ~/ido-esperanto-extractor/dist/"

# Check logs
ssh ido-extractor "tail -50 ~/ido-esperanto-extractor/logs/*.log"
```

### Copy fails?
```bash
# Check disk space locally
df -h ~/apertium-gemini

# Check permissions
ls -la ~/apertium-gemini/terraform/extractor-results/

# Try with verbose output
scp -v -r ido-extractor:~/ido-esperanto-extractor/dist/* ~/apertium-gemini/
```

---

## Summary

1. **Connect by name:** `ssh ido-extractor` (after SSH config setup)
2. **Working folder:** `~/ido-esperanto-extractor/` on EC2
3. **Copy artifacts:** Automatic via `./run_extractor.sh` or manual via `scp -r ido-extractor:~/ido-esperanto-extractor/dist/* .`
