# Quick Path Reference

## EC2 Instance: 54.220.110.151

### Translator (Always Running)
```
Path:    /opt/ido-epo-translator/
Tech:    Docker + Apertium
Port:    2737
Status:  Always on
```

### Extractor (On-Demand)
```
Path:    ~/ido-esperanto-extractor/
Tech:    Python 3
Port:    None
Status:  Run manually
```

## SSH Access
```bash
ssh -i ~/.ssh/id_rsa ubuntu@54.220.110.151
```

## Quick Commands

### Run Extractor
```bash
cd terraform
./run_extractor.sh
```

### Monitor Extractor
```bash
cd terraform
./monitor_extractor.sh
```

### Deploy Dictionaries
```bash
cd terraform
./deploy_dictionaries.sh
```

### Check Translator
```bash
curl http://54.220.110.151:2737/translate?langpair=ido|epo&q=hundo
```

## Remember
- **Translator:** `/opt/ido-epo-translator/` - DO NOT TOUCH
- **Extractor:** `~/ido-esperanto-extractor/` - Safe to delete/recreate
