"""Build the bounded stage candidate and audit the actual exported binary."""
import argparse
import json
import hashlib
import re
import shutil
import subprocess
from pathlib import Path

OPTIONS = argparse.ArgumentParser()
OPTIONS.add_argument('--release', action='store_true')
ARGS = OPTIONS.parse_args()
VERSION = '2.0.0' if ARGS.release else '2.0.0-rc1'
PREFIX = 'release_v2_0_0_' if ARGS.release else ''
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'tests/artifacts'
PACKAGE = ROOT / ('builds/releases/v2.0.0/Windows/runtime' if ARGS.release else 'builds/stage-v145/Windows')
PACKAGE.mkdir(parents=True, exist_ok=True)
ENGINE = ROOT / '.tools/godot/Godot_v4.5.1-stable_win64.exe'
EXE = PACKAGE / 'CUHKSZ-MicroWorld.exe'
CLEAN = PACKAGE.parent / 'clean-cwd'
CLEAN.mkdir(exist_ok=True)
STARTUP = subprocess.STARTUPINFO()
STARTUP.dwFlags |= subprocess.STARTF_USESHOWWINDOW
STARTUP.wShowWindow = 0


def run(args, name, cwd):
    path = OUT / ((name if name.startswith(PREFIX) else PREFIX+name) + '.log')
    with path.open('w', encoding='utf-8') as log:
        result = subprocess.run(args, cwd=cwd, stdout=log,
                                stderr=subprocess.STDOUT, startupinfo=STARTUP, timeout=600)
    lines = path.read_text('utf-8').splitlines()
    errors = [line for line in lines if line.startswith(('ERROR:', 'SCRIPT ERROR:'))]
    print(name, 'exit', result.returncode, 'engine errors', len(errors), flush=True)
    if errors:
        print('\n'.join(errors[:12]), flush=True)
    assert result.returncode == 0 and not errors, path


def resource_closure():
    roots = ['world/product/CampusProduct.tscn']
    roots += re.findall(r'=\"\*res://([^\"]+)\"', (ROOT / 'project.godot').read_text('utf-8'))
    pending, found = list(roots), set()
    while pending:
        path = pending.pop()
        if path in found:
            continue
        assert (ROOT / path).is_file(), path
        found.add(path)
        if (ROOT / path).suffix in ['.gd', '.tscn', '.tres', '.gdshader', '.json']:
            for dependency in re.findall(r'res://([^\"\s\)]+)', (ROOT / path).read_text('utf-8-sig')):
                if (ROOT / dependency).is_file():
                    pending.append(dependency)
    assert not any(p.startswith(('references/', 'tests/')) for p in found)
    preset = ROOT / 'export_presets.cfg'
    text = preset.read_text('utf-8')
    line = 'export_files=PackedStringArray(' + ', '.join(
        json.dumps('res://' + p, ensure_ascii=False) for p in sorted(found)) + ')'
    text = re.sub(r'export_files=PackedStringArray\([^\n]+\)', lambda _: line, text)
    preset.write_text(text, encoding='utf-8')
    (OUT / 'export_resource_closure_v145.json').write_text(json.dumps(
        {'roots': roots, 'files': sorted(found), 'scope': 'Static resource references plus autoloads; packed startup separately verified.'},
        indent=2) + '\n', encoding='utf-8')


resource_closure()
run([str(ENGINE), '--headless', '--path', str(ROOT), '--export-release',
     'Windows Stage', str(EXE)], 'windows_export_v145_final', ROOT)
for mode in ['human', 'agent-demo']:
    name = PREFIX + 'export_smoke_v145_' + mode
    run([str(EXE), '--script', str(ROOT / 'tests/ExportSmokeV145.gd'),
         '--fixed-fps', '60', '--resolution', '1440x900', '--position', '-1600,0',
         '--', '--' + mode, '--product-version='+VERSION, '--report=' + str(OUT / (name + '.json'))], name, CLEAN)
    report = json.loads((OUT / (name + '.json')).read_text('utf-8'))
    assert report['valid'], report
    # Also launch the normal native main entry, with no external audit script.
    run([str(EXE), '--headless', '--quit-after', '60', '--', '--' + mode],
        'export_native_v145_' + mode, CLEAN)

(PACKAGE / 'licenses').mkdir(exist_ok=True)
shutil.copy2(ROOT / 'assets/fonts/OFL.txt', PACKAGE / 'licenses/NotoSansSC-OFL.txt')
(PACKAGE / 'README.txt').write_text(
    f'CUHKSZ MicroWorld {VERSION} / V145 stage build\n'
    'Player and Agent showcase share the same campus model.\n'
    'Run CUHKSZ-MicroWorld.exe for the two-entry menu.\n'
    'WASD: move; Shift: run; right mouse: camera; wheel: zoom; Esc: menu.\n'
    'Agent showcase is a scripted 15-chapter tour with explicit chapter cuts.\n'
    'This fitted model is not surveyed geometry or an official university product.\n'
    'Source and research references: https://github.com/jasperjlou/CUHKSZ-MicroWorld\n'
    'Project rights reserved unless otherwise stated. Third-party notices: licenses/.\n', encoding='utf-8')
manifest = {'model': 'official-visual-build-145-zhixin-crossing',
            'product': VERSION, 'formal_release': ARGS.release, 'files': {}}
for p in sorted(PACKAGE.rglob('*')):
    if p.is_file() and p.name != 'build-manifest.json':
        manifest['files'][p.relative_to(PACKAGE).as_posix()] = {
            'bytes': p.stat().st_size, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
(PACKAGE / 'build-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n', 'utf-8')
print(VERSION, 'built; both packed modes and native main entries passed.', flush=True)
