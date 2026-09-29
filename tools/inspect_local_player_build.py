"""Read only serialized metadata; never execute the player or export its assets."""
import collections
import gc
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools/unity-inspector'))
import UnityPy

source = Path(sys.argv[1]).resolve()
files = sorted(p for p in source.rglob('*') if p.is_file())
report = {'source': str(source), 'file_count': len(files), 'bytes': sum(p.stat().st_size for p in files),
          'method': 'UnityPy serialized metadata only, one file at a time; no resource stream decoding',
          'license': 'unknown', 'exported_assets': 0, 'executed_player': False, 'files': []}
data = source / 'My project (2)_Data'
selected = sorted(p for p in data.iterdir() if p.is_file() and
                  (p.suffix == '.assets' or p.name == 'globalgamemanagers' or
                   (p.name.startswith('level') and p.name[5:].isdigit())))
for path in selected:
    with path.open('rb') as stream:
        digest = hashlib.file_digest(stream, 'sha256').hexdigest()
    entry = {'file': str(path.relative_to(source)), 'bytes': path.stat().st_size, 'sha256': digest}
    try:
        env = UnityPy.load(str(path))
        counts = collections.Counter()
        names = collections.defaultdict(list)
        errors = 0
        no_names = collections.Counter()
        for obj in env.objects:
            kind = obj.type.name
            counts[kind] += 1
            if kind in {'GameObject', 'Mesh', 'Material', 'Texture2D', 'Shader'}:
                try:
                    name = obj.peek_name()
                    if name:
                        names[kind].append({'path_id': obj.path_id, 'name': name})
                    else:
                        no_names[kind] += 1
                except Exception:
                    errors += 1
            elif kind == 'BuildSettings':
                try:
                    entry['build_settings'] = obj.read_typetree()
                except Exception as exc:
                    entry['build_settings_error'] = str(exc)
        entry.update(types=dict(counts), names=dict(names), name_errors=errors, names_unavailable=dict(no_names))
        del env
        gc.collect()
    except Exception as exc:
        entry['error'] = str(exc)
    report['files'].append(entry)
    print(path.name, entry.get('types', entry.get('error')), flush=True)
out = ROOT / 'references/regions/fairy_lake/originals/local_player_metadata/inventory.json'
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(report, ensure_ascii=False, indent=2, default=str), encoding='utf8')
summary = {k: v for k, v in report.items() if k != 'files'}
summary['metadata_files_inspected'] = len(report['files'])
summary['detailed_inventory'] = out.relative_to(ROOT).as_posix()
summary['engine_header'] = '2022.3.62t7'
summary['limits'] = ['Counts are serialized records, not unique reusable assets.',
                     'GameObject name peeking returned no names; sampled full parsing failed a byte-size check.',
                     'BuildSettings parsing failed read_str out of bounds; scene identities are not confirmed.',
                     'No model has been localized to the supplied lake or Ling College photos.',
                     'No resource streams, mesh vertices, images or player executables were decoded or run.']
summary['files'] = [{k: v for k, v in f.items() if k != 'names'} for f in report['files']]
summary['totals'] = dict(sum((collections.Counter(f.get('types', {})) for f in report['files']), collections.Counter()))
(ROOT / 'references/regions/fairy_lake/local_player_build_inventory.json').write_text(json.dumps(summary, ensure_ascii=False, indent=2, default=str), 'utf8')
print('Saved', out)
