"""Read-only product link, size and credential-pattern release checks."""
from pathlib import Path
import json, re, subprocess
ROOT = Path(__file__).resolve().parents[1]
DOCS = ['README.md', 'CONTRIBUTING.md', 'docs/INDEX.md', 'docs/UNIFIED_CAMPUS_V6.md',
        'docs/MAIN_PRODUCT_V6_RELEASE.md', 'docs/HUMAN_AGENT_WORLD_PARITY.md',
        'docs/V6_AGENT_MIGRATION_AUDIT.md']

def check():
    broken = []
    for name in DOCS:
        p = ROOT / name
        if not p.is_file():
            broken.append(name); continue
        text = p.read_text(encoding='utf-8')
        for link in re.findall(r'\]\(([^)]+)\)', text):
            if link.startswith(('https://', 'http://', '#')): continue
            target = link.split('#', 1)[0]
            if re.match(r'[A-Za-z]:', target) or not (p.parent / target).exists():
                broken.append(name + ': ' + link)
    files = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode('utf-8').split('\0')
    large = []; secrets = []
    patterns = [r'gh[pousr]_[A-Za-z0-9]{30,}', r'github_pat_[A-Za-z0-9_]{40,}',
                r'sk-(?:proj-)?[A-Za-z0-9_-]{32,}', r'-----BEGIN (?:RSA |OPENSSH )?PRIVATE KEY-----']
    for name in filter(None, files):
        p = ROOT / name
        if not p.is_file(): continue
        if p.stat().st_size > 10 * 1024 * 1024:
            large.append({'path': name, 'bytes': p.stat().st_size})
        if p.suffix.lower() in ['.gd','.py','.json','.md','.ps1','.cmd','.godot','.yml','.yaml','.tscn']:
            text = p.read_text(encoding='utf-8', errors='replace')
            if any(re.search(pattern, text) for pattern in patterns): secrets.append(name)
    result = {'product_documents': len(DOCS), 'broken_links': broken,
              'over_10_mb': large, 'credential_pattern_files': secrets,
              'note': 'Pattern scan is not proof of absence of all possible secrets.'}
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if broken or secrets: raise SystemExit(1)
    return result

if __name__ == '__main__': check()
