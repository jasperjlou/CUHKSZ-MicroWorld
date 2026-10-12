"""Package the already verified runtime and publish bounded, hash-backed local receipts."""
import hashlib
import json
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REL = ROOT / 'builds/releases/v2.1.1'
WIN = REL / 'Windows'
ART = ROOT / 'tests/artifacts'
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
def write(path, value):
    path.write_bytes((json.dumps(value, ensure_ascii=False, indent=2) + '\n').encode())
manifest = json.loads((WIN / 'runtime/build-manifest.json').read_text('utf-8'))
assert manifest['product'] == '2.1.1' and manifest['formal_release']
for name, item in manifest['files'].items():
    assert sha(WIN / 'runtime' / name) == item['sha256'], name
for name, mode in [('玩家游玩', 'human'), ('Agent自动展示', 'agent-demo')]:
    (WIN / f'{name}.cmd').write_bytes(f'@echo off\r\nstart "" "%~dp0runtime\\CUHKSZ-MicroWorld.exe" -- --{mode}\r\n'.encode('ascii'))
(WIN / '使用说明.txt').write_bytes(('港中深微型世界 v2.1.1 / 模型 V188 + V189 体验优化\r\n'
    '完整解压后选择：玩家游玩.cmd 或 Agent自动展示.cmd。无需安装 Godot。\r\n'
    '保留整个 runtime 文件夹；程序未代码签名。\r\n'
    'WASD 移动，Shift 跑步，右键拖动镜头，滚轮缩放，小地图设目标。\r\n'
    'F1 坐标依据，F2 俯视，R 回东门，Esc 返回两入口菜单。\r\n'
    'Agent 为 17 章编排导览；空格暂停，左右键切章。\r\n'
    '尺寸按资料拟合，真实北向未校准；仍在持续精修，并非校方官方产品。\r\n'
    '发布与源码：https://github.com/jasperjlou/CUHKSZ-MicroWorld/releases/tag/v2.1.1\r\n').encode('utf-8-sig'))
zip_path = REL / 'CUHKSZ-MicroWorld-v2.1.1-Windows-x86_64.zip'
assert not zip_path.exists(), 'Fixed archive already exists; do not overwrite.'
with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
    for p in sorted(WIN.rglob('*')):
        if p.is_file():
            assert 'clean-cwd' not in p.parts
            z.write(p, p.relative_to(WIN).as_posix())
with zipfile.ZipFile(zip_path) as z:
    assert z.testzip() is None
    for name in manifest['files']:
        assert hashlib.sha256(z.read('runtime/' + name)).hexdigest() == manifest['files'][name]['sha256']
(REL / 'SHA256SUMS.txt').write_bytes((sha(zip_path) + '  ' + zip_path.name + '\n').encode())
closure = json.loads((ART / 'export_resource_closure_v189.json').read_text('utf-8'))['files']
validation = {'version': '2.1.1', 'model': manifest['model'], 'showcase_chapters': 17,
              'current_library_chapters': 4, 'current_library_legs': 40, 'previous_baseline': 'v2.1.0', 'unchanged_other_chapters_reused': 13,
              'source_experience': 'docs/LIBRARY_PRODUCT_CLOSEOUT_V189.md', 'export_checks': {},
              'native_modes_passed': ['human', 'agent-demo'], 'export_images_reviewed': True,
              'images': {}, 'source_files': {}, 'scope': 'V187/V188 model and V189 experience delta:4 library chapters tested40legs/20checks;unchanged13 chapters reusev2.1.0 evidence. Not a fresh17chapter run or full-campus fidelity/performance acceptance.'}
for mode in ['human', 'agent-demo']:
    n = 'release_v2_1_1_export_smoke_v189_' + mode
    data = json.loads((ART / (n + '.json')).read_text('utf-8'))
    assert data['valid']
    validation['export_checks'][mode] = data['checks']
    validation['images'][n + '.png'] = sha(ART / (n + '.png'))
for p in closure + ['project.godot', 'export_presets.cfg']:
    validation['source_files'][p] = sha(ROOT / p)
write(ROOT / 'docs/releases/v2.1.1-validation.json', validation)
write(ROOT / 'docs/releases/v2.1.1-build.json', {
    'version': '2.1.1', 'model': manifest['model'], 'artifact': zip_path.name,
    'bytes': zip_path.stat().st_size, 'sha256': sha(zip_path), 'runtime_manifest': manifest,
    'publication': 'Verified local package; actual GitHub publication recorded separately.'})
print('ZIP integrity/runtime hashes passed;', zip_path.stat().st_size, 'bytes; receipts saved.')
