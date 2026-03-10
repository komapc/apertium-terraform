#!/bin/bash
# Pull extraction results from EC2 and display statistics

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "Pull Extraction Results from EC2"
echo -e "==========================================${NC}"
echo ""

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULTS_DIR="extractor-results/$TIMESTAMP"

# Create results directory
mkdir -p "$RESULTS_DIR"

echo -e "${CYAN}📥 Pulling files from EC2...${NC}"
echo ""

# Pull output files (JSON format)
echo "Pulling output files..."
scp -q extractor:/tmp/ido-esperanto-extractor/output/* "$RESULTS_DIR/" 2>/dev/null || echo "⚠️  No output files"

# Pull dist files (.dix format for Apertium)
echo "Pulling dist files..."
scp -q extractor:/tmp/ido-esperanto-extractor/dist/* "$RESULTS_DIR/" 2>/dev/null || echo "⚠️  No dist files"

# Pull reports (statistics)
echo "Pulling reports..."
scp -qr extractor:/tmp/ido-esperanto-extractor/reports "$RESULTS_DIR/" 2>/dev/null || echo "⚠️  No reports"

# Pull sources (for detailed statistics)
echo "Pulling source files..."
scp -qr extractor:/tmp/ido-esperanto-extractor/sources "$RESULTS_DIR/" 2>/dev/null || echo "⚠️  No sources"

# Pull logs
echo "Pulling logs..."
scp -q extractor:/tmp/extraction.log "$RESULTS_DIR/extraction.log" 2>/dev/null || echo "⚠️  No extraction log"

echo ""
echo -e "${GREEN}✅ Files pulled to: $RESULTS_DIR${NC}"
echo ""

# Display file list
echo -e "${CYAN}📁 Files downloaded:${NC}"
ls -lh "$RESULTS_DIR" | tail -n +2
echo ""

# Generate statistics
echo -e "${BLUE}=========================================="
echo "📊 STATISTICS"
echo -e "==========================================${NC}"
echo ""

# Python script to analyze the data
export RESULTS_DIR_FULL="$PWD/$RESULTS_DIR"
python3 << 'EOPY'
import json
import os
import sys
from pathlib import Path

results_dir = Path(os.environ.get('RESULTS_DIR_FULL', '.'))

print("\033[1;36m=== Dictionary Statistics ===\033[0m\n")

# 1. Check .dix files (Apertium format)
print("\033[1;33m📖 Apertium Dictionaries (.dix files):\033[0m")
mono_dix = results_dir / "apertium-ido.ido.dix"
bidix_dix = results_dir / "apertium-ido-epo.ido-epo.dix"

if mono_dix.exists():
    with open(mono_dix) as f:
        content = f.read()
        count = content.count('<e>')
        print(f"  • Monolingual (ido.dix): {count:,} entries")
else:
    print("  • Monolingual: Not found")

if bidix_dix.exists():
    with open(bidix_dix) as f:
        content = f.read()
        count = content.count('<e>')
        print(f"  • Bilingual (ido-epo.dix): {count:,} entries")
else:
    print("  • Bilingual: Not found")

print()

# 2. Check JSON files
print("\033[1;33m📦 JSON Dictionaries:\033[0m")

# Vortaro
vortaro_file = results_dir / "vortaro.json"
if vortaro_file.exists():
    with open(vortaro_file) as f:
        data = json.load(f)
        if isinstance(data, dict):
            if 'entries' in data:
                count = len(data['entries'])
            elif 'metadata' in data and 'total_words' in data['metadata']:
                count = data['metadata']['total_words']
            else:
                count = len(data)
        else:
            count = len(data)
        print(f"  • Vortaro: {count:,} words")
else:
    print("  • Vortaro: Not found")

# BIG_BIDIX
bidix_file = results_dir / "BIG_BIDIX.json"
if bidix_file.exists():
    with open(bidix_file) as f:
        data = json.load(f)
        count = len(data) if isinstance(data, list) else len(data.get('entries', []))
        print(f"  • Bilingual JSON: {count:,} entries")
else:
    print("  • Bilingual JSON: Not found")

# MONO_IDO
mono_file = results_dir / "MONO_IDO.json"
if mono_file.exists():
    with open(mono_file) as f:
        data = json.load(f)
        count = len(data) if isinstance(data, list) else len(data.get('entries', []))
        print(f"  • Monolingual JSON: {count:,} entries")
else:
    print("  • Monolingual JSON: Not found")

print()

# 3. Check metadata
print("\033[1;33m📋 Metadata:\033[0m")
metadata_file = results_dir / "metadata.json"
if metadata_file.exists():
    with open(metadata_file) as f:
        meta = json.load(f)
        for key, value in meta.items():
            print(f"  • {key}: {value}")
else:
    print("  • No metadata file")

print()

# 4. Check source files for detailed statistics
print("\033[1;33m🔍 Words per Source:\033[0m")
sources_dir = results_dir / "sources"

if sources_dir.exists():
    source_files = {
        'source_io_wiktionary.json': 'Ido Wiktionary',
        'source_eo_wiktionary.json': 'Esperanto Wiktionary',
        'source_fr_wiktionary.json': 'French Wiktionary',
        'source_en_wiktionary.json': 'English Wiktionary',
        'source_io_wikipedia.json': 'Ido Wikipedia'
    }
    
    total_by_source = {}
    
    for filename, source_name in source_files.items():
        filepath = sources_dir / filename
        if filepath.exists():
            try:
                with open(filepath) as f:
                    data = json.load(f)
                    if isinstance(data, list):
                        count = len(data)
                    elif isinstance(data, dict):
                        count = len(data.get('entries', data))
                    else:
                        count = 0
                    
                    if count > 0:
                        total_by_source[source_name] = count
                        print(f"  • {source_name}: {count:,} entries")
            except Exception as e:
                print(f"  • {source_name}: Error reading file")
    
    if total_by_source:
        print(f"\n  \033[1;32mTotal from all sources: {sum(total_by_source.values()):,} entries\033[0m")
    else:
        print("  • No source files with data found")
else:
    print("  • Source files not available")
    print("  • (Run with sources directory for detailed breakdown)")

print()

# 5. Check reports
print("\033[1;33m📈 Reports:\033[0m")
reports_dir = results_dir / "reports"
if reports_dir.exists():
    report_files = list(reports_dir.glob("*.md"))
    if report_files:
        for report in sorted(report_files):
            print(f"  • {report.name}")
    else:
        print("  • No report files found")
else:
    print("  • No reports directory")

print()

EOPY

# Display extraction log summary
if [ -f "$RESULTS_DIR/extraction.log" ]; then
    echo -e "${CYAN}📝 Extraction Log Summary:${NC}"
    echo ""
    
    # Check for completion
    if grep -q "PIPELINE COMPLETE" "$RESULTS_DIR/extraction.log"; then
        echo -e "  ${GREEN}✅ Pipeline completed successfully${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Pipeline may not have completed${NC}"
    fi
    
    # Check for errors
    ERROR_COUNT=$(grep -c "Error\|ERROR\|Failed" "$RESULTS_DIR/extraction.log" 2>/dev/null || echo "0")
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "  ${YELLOW}⚠️  Found $ERROR_COUNT error messages in log${NC}"
    fi
    
    # Check for warnings
    WARNING_COUNT=$(grep -c "Warning\|WARNING" "$RESULTS_DIR/extraction.log" 2>/dev/null || echo "0")
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo -e "  ${YELLOW}⚠️  Found $WARNING_COUNT warnings in log${NC}"
    fi
    
    echo ""
fi

# Summary
echo -e "${BLUE}=========================================="
echo "✅ COMPLETE"
echo -e "==========================================${NC}"
echo ""
echo -e "Results saved to: ${GREEN}$RESULTS_DIR${NC}"
echo ""
echo "Next steps:"
echo "  1. Review statistics above"
echo "  2. Deploy to vortaro: ./deploy_dictionaries.sh"
echo "  3. Or deploy manually: cp $RESULTS_DIR/vortaro.json ~/apertium-gemini/vortaro/dictionary.json"
echo ""
