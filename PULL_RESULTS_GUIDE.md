# Pull Results Guide

## Quick Start

```bash
cd ~/apertium-gemini/terraform
./pull_results.sh
```

This will:
1. ✅ Pull all files from EC2
2. ✅ Display comprehensive statistics
3. ✅ Show words per source
4. ✅ Save everything locally

---

## What It Does

### Files Pulled

From EC2 `/tmp/ido-esperanto-extractor/`:

**Output files:**
- `vortaro.json` - For vortaro website
- `BIG_BIDIX.json` - Bilingual dictionary (JSON)
- `MONO_IDO.json` - Monolingual dictionary (JSON)
- `metadata.json` - Statistics

**Dist files:**
- `apertium-ido.ido.dix` - Monolingual (Apertium format)
- `apertium-ido-epo.ido-epo.dix` - Bilingual (Apertium format)

**Reports:**
- Statistics and analysis reports

**Sources:**
- Individual source files for detailed breakdown

**Logs:**
- `extraction.log` - Full extraction log

### Statistics Displayed

1. **Apertium Dictionaries (.dix)**
   - Monolingual entry count
   - Bilingual entry count

2. **JSON Dictionaries**
   - Vortaro word count
   - Bilingual JSON entries
   - Monolingual JSON entries

3. **Metadata**
   - All metadata fields

4. **Words per Source** ⭐
   - Ido Wiktionary
   - Esperanto Wiktionary
   - French Wiktionary
   - English Wiktionary
   - Ido Wikipedia
   - **Total from all sources**

5. **Reports**
   - List of available reports

6. **Log Summary**
   - Completion status
   - Error count
   - Warning count

---

## Example Output

```
==========================================
Pull Extraction Results from EC2
==========================================

📥 Pulling files from EC2...

Pulling output files...
Pulling dist files...
Pulling reports...
Pulling source files...
Pulling logs...

✅ Files pulled to: extractor-results/20251031-003045

📁 Files downloaded:
-rw-rw-r-- 1 mark mark 972K Oct 31 00:30 apertium-ido-epo.ido-epo.dix
-rw-rw-r-- 1 mark mark 546K Oct 31 00:30 apertium-ido.ido.dix
-rw-rw-r-- 1 mark mark 1.1M Oct 31 00:30 BIG_BIDIX.json
-rw-rw-r-- 1 mark mark 896K Oct 31 00:30 vortaro.json
...

==========================================
📊 STATISTICS
==========================================

=== Dictionary Statistics ===

📖 Apertium Dictionaries (.dix files):
  • Monolingual (ido.dix): 12 entries
  • Bilingual (ido-epo.dix): 7,044 entries

📦 JSON Dictionaries:
  • Vortaro: 7,242 words
  • Bilingual JSON: 1,038 entries
  • Monolingual JSON: 1,245 entries

📋 Metadata:
  • extraction_date: 2025-10-31
  • total_entries: 7242

🔍 Words per Source:
  • Ido Wiktionary: 7,242 entries
  • Esperanto Wiktionary: 189 entries
  • French Wiktionary: 1,001 entries
  • English Wiktionary: 523 entries

  Total from all sources: 8,955 entries

📈 Reports:
  • stats_summary.md
  • bidix_conflicts.md

📝 Extraction Log Summary:
  ✅ Pipeline completed successfully
  ⚠️  Found 1 warnings in log

==========================================
✅ COMPLETE
==========================================

Results saved to: extractor-results/20251031-003045

Next steps:
  1. Review statistics above
  2. Deploy to vortaro: ./deploy_dictionaries.sh
  3. Or deploy manually
```

---

## After Pulling

### Option 1: Deploy with Script
```bash
cd ~/apertium-gemini/terraform
./deploy_dictionaries.sh
```

### Option 2: Deploy Manually to Vortaro
```bash
# Use the latest results
LATEST=$(ls -td extractor-results/*/ | head -1)

# Copy to vortaro
cd ~/apertium-gemini/vortaro
git checkout -b dictionary-update-$(date +%Y%m%d)
cp "$LATEST/vortaro.json" dictionary.json
git add dictionary.json
git commit -m "feat: Update dictionary"
git push origin dictionary-update-$(date +%Y%m%d)
```

### Option 3: Stage for Translator
```bash
# Use the latest results
LATEST=$(ls -td extractor-results/*/ | head -1)

# Copy .dix files
mkdir -p ~/apertium-gemini/translator-staging
cp "$LATEST"/*.dix ~/apertium-gemini/translator-staging/
```

---

## Troubleshooting

### No files pulled
```bash
# Check if extraction completed on EC2
ssh extractor 'ls -la /tmp/ido-esperanto-extractor/output/'

# Check if process is still running
ssh extractor 'ps aux | grep python3'
```

### Statistics show 0 entries
```bash
# Check file format
python3 -c "import json; print(json.load(open('extractor-results/latest/vortaro.json')))" | head -20
```

### Missing source files
```bash
# Source files are optional
# Statistics will still show .dix and JSON counts
```

---

## Advanced Usage

### Pull specific files only
```bash
# Just vortaro
scp extractor:/tmp/ido-esperanto-extractor/output/vortaro.json .

# Just .dix files
scp extractor:/tmp/ido-esperanto-extractor/dist/*.dix .
```

### Compare with previous run
```bash
# List all results
ls -lh extractor-results/

# Compare entry counts
for dir in extractor-results/*/; do
    echo "$dir:"
    grep -c '<e>' "$dir"/*.dix 2>/dev/null || echo "No .dix files"
done
```

---

## What the Statistics Mean

### Words per Source

Shows where each word came from:

- **Ido Wiktionary**: Primary source, most comprehensive
- **Esperanto Wiktionary**: Eo→Io translations
- **French Wiktionary**: Fr→Io and Fr→Eo translations
- **English Wiktionary**: En→Io translations
- **Ido Wikipedia**: Additional vocabulary from articles

**Total**: Sum of all unique words from all sources

### Entry Counts

- **Monolingual (.dix)**: Ido words with morphology
- **Bilingual (.dix)**: Ido↔Esperanto translation pairs
- **Vortaro**: Words for website display
- **JSON files**: Source data before export

---

## Files Location

After running, files are in:
```
~/apertium-gemini/terraform/extractor-results/YYYYMMDD-HHMMSS/
```

Latest results:
```bash
ls -td ~/apertium-gemini/terraform/extractor-results/*/ | head -1
```

---

## Summary

**One command to:**
- ✅ Pull all results from EC2
- ✅ Display comprehensive statistics
- ✅ Show words per source breakdown
- ✅ Save everything locally
- ✅ Ready for deployment

```bash
cd ~/apertium-gemini/terraform
./pull_results.sh
```

Simple and complete! 🚀
