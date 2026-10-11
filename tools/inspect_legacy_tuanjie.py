"""Read-only geometry reference extraction for the user's local 2022.3.62t7 build.

Never writes to the original build. The Tuanjie mesh extension is validated against
the complete object tail, submesh bounds, decoded vertices and triangle indices.
This is a geometry study, not a recovered editor project or a surveyed campus map.
"""
import json
import struct
import sys
import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools/unity-inspect'))
import numpy as np
import UnityPy
from UnityPy.streams import EndianBinaryReader
from UnityPy.helpers.TypeTreeHelper import read_typetree
from UnityPy.helpers.MeshHelper import MeshHandler

SOURCE = Path('A:/项目/港中深GTA旧资产/My project (2)_Data')
OUT = ROOT / 'references/legacy-gta-20261011'


def read_mesh(obj):
    node = obj._get_typetree_node()
    raw = obj.get_raw_data()
    reader = EndianBinaryReader(raw, endian='<')
    for child in node.m_Children:
        read_typetree(child, reader, as_dict=True, check_read=False, assetsfile=obj.assets_file)
        if child.m_Name == 'm_VariableBoneCountWeights':
            break
    pos = reader.Position
    # Observed Tuanjie extension; not a generic Unity version workaround.
    adapted = raw[:pos] + raw[pos + 92:]
    reader = EndianBinaryReader(adapted, endian='<')
    mesh = read_typetree(node, reader, as_dict=False, check_read=False, assetsfile=obj.assets_file)
    if adapted[reader.Position:] != b'\0\0':
        raise ValueError('Unrecognized Tuanjie mesh tail; refuse speculative export')
    mesh.set_object_reader(obj)
    return mesh


def transform_matrix(t):
    x, y, z, w = (t['m_LocalRotation'][a] for a in 'xyzw')
    r = np.array([[1-2*(y*y+z*z), 2*(x*y-z*w), 2*(x*z+y*w)],
                  [2*(x*y+z*w), 1-2*(x*x+z*z), 2*(y*z-x*w)],
                  [2*(x*z-y*w), 2*(y*z+x*w), 1-2*(x*x+y*y)]])
    m = np.eye(4)
    m[:3, :3] = r @ np.diag([t['m_LocalScale'][a] for a in 'xyz'])
    m[:3, 3] = [t['m_LocalPosition'][a] for a in 'xyz']
    return m


def write_glb(path, vertices, normals, indices, note):
    arrays = [vertices.astype('<f4'), normals.astype('<f4'), indices.astype('<u4')]
    chunks = [a.tobytes() for a in arrays]
    views = []
    offset = 0
    for i, chunk in enumerate(chunks):
        views.append({'buffer': 0, 'byteOffset': offset, 'byteLength': len(chunk),
                      'target': 34963 if i == 2 else 34962})
        offset += len(chunk)
    doc = {'asset': {'version': '2.0', 'generator': 'Read-only local Tuanjie geometry study'},
           'scene': 0, 'scenes': [{'nodes': [0]}], 'nodes': [{'mesh': 0, 'name': path.stem}],
           'meshes': [{'primitives': [{'attributes': {'POSITION': 0, 'NORMAL': 1}, 'indices': 2, 'material': 0}]}],
           'materials': [{'name': 'neutral-reference-clay', 'doubleSided': True,
                          'pbrMetallicRoughness': {'baseColorFactor': [.64, .67, .65, 1], 'metallicFactor': 0, 'roughnessFactor': .9}}],
           'accessors': [
               {'bufferView': 0, 'componentType': 5126, 'count': len(vertices), 'type': 'VEC3',
                'min': vertices.min(axis=0).tolist(), 'max': vertices.max(axis=0).tolist()},
               {'bufferView': 1, 'componentType': 5126, 'count': len(normals), 'type': 'VEC3'},
               {'bufferView': 2, 'componentType': 5125, 'count': indices.size, 'type': 'SCALAR'}],
           'bufferViews': views, 'buffers': [{'byteLength': offset}], 'extras': note}
    header = json.dumps(doc, separators=(',', ':')).encode()
    header += b' ' * (-len(header) % 4)
    total = 12 + 8 + len(header) + 8 + offset
    with path.open('wb') as f:
        f.write(struct.pack('<4sII', b'glTF', 2, total))
        f.write(struct.pack('<I4s', len(header), b'JSON')); f.write(header)
        f.write(struct.pack('<I4s', offset, b'BIN\0'))
        for chunk in chunks:
            f.write(chunk)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--scene', default='level12')
    parser.add_argument('--root', type=int, default=21385)
    parser.add_argument('--asset', default='sharedassets0.assets')
    parser.add_argument('--file-id', type=int, default=3)
    parser.add_argument('--prefix', default='lower-campus')
    args = parser.parse_args()
    OUT.mkdir(exist_ok=True, parents=True)
    (OUT / '.gdignore').touch()
    scene = json.loads((OUT / (args.scene+'-geometry-index.json')).read_text(encoding='utf-8'))
    transforms = scene['transforms']
    go_to_transform = {t['m_GameObject']['m_PathID']: int(k) for k, t in transforms.items()}
    cache = {}

    def world(tid):
        if tid not in cache:
            t = transforms[str(tid)]
            parent = t['m_Father']['m_PathID']
            cache[tid] = (world(parent) if parent else np.eye(4)) @ transform_matrix(t)
        return cache[tid]

    def under(tid, root=args.root):
        while tid:
            if tid == root:
                return True
            if str(tid) not in transforms:
                return False  # RectTransform UI ancestor outside geometry inventory.
            tid = transforms[str(tid)]['m_Father']['m_PathID']
        return False

    env = UnityPy.load(str(SOURCE / args.asset))
    objects = {o.path_id: o for o in env.objects if o.type.name == 'Mesh'}
    selected = []
    for f in scene['mesh_filters']:
        tid = go_to_transform.get(f['m_GameObject']['m_PathID'])
        ref = f['m_Mesh']
        if tid and under(tid) and ref['m_FileID'] == args.file_id and ref['m_PathID'] in objects:
            selected.append((tid, ref['m_PathID']))
    verts, norms, faces, inventory, errors = [], [], [], [], []
    vertex_offset = 0
    for i, (tid, mid) in enumerate(selected):
        try:
            mesh = read_mesh(objects[mid]); handler = MeshHandler(mesh); handler.process()
            v = np.asarray(handler.m_Vertices, dtype=np.float32)
            n = np.asarray(handler.m_Normals, dtype=np.float32)[:, :3]
            triangles = np.concatenate([np.asarray(t, dtype=np.uint32).reshape(-1, 3) for t in handler.get_triangles()])
            if not np.isfinite(v).all() or not np.isfinite(n).all() or triangles.max() >= len(v):
                raise ValueError('Invalid geometry')
            m = world(tid)
            v = v @ m[:3, :3].T + m[:3, 3]
            n = n @ np.linalg.inv(m[:3, :3])
            n /= np.maximum(np.linalg.norm(n, axis=1, keepdims=True), 1e-12)
            # Unity left-handed to glTF right-handed, without changing the source units.
            v[:, 2] *= -1; n[:, 2] *= -1
            triangles = triangles[:, [0, 2, 1]]
            inventory.append({'transform_id': tid, 'mesh_id': mid, 'name': mesh.m_Name,
                              'vertices': len(v), 'triangles': len(triangles),
                              'min': v.min(axis=0).tolist(), 'max': v.max(axis=0).tolist()})
            verts.append(v.astype(np.float32)); norms.append(n.astype(np.float32))
            faces.append(triangles + vertex_offset); vertex_offset += len(v)
        except Exception as exc:
            errors.append({'transform_id': tid, 'mesh_id': mid, 'error': str(exc)[:180]})
        if i % 500 == 0:
            print('processed', i, '/', len(selected), 'errors', len(errors), flush=True)
    v = np.concatenate(verts); n = np.concatenate(norms); tri = np.concatenate(faces)
    bounds = [v.min(axis=0), v.max(axis=0)]
    origin = (bounds[0] + bounds[1]) / 2; origin[1] = bounds[0][1]
    v -= origin
    report = {'source_scene': args.scene, 'source_root': args.root, 'asset': args.asset,
              'parser': 'UnityPy1.25.4 with strictly validated local Tuanjie mesh extension',
              'selected_mesh_instances': len(selected), 'exported_mesh_instances': len(inventory),
              'vertices': len(v), 'triangles': len(tri), 'errors': errors,
              'coordinate_conversion': 'world affine hierarchy, then negate Z; no metric scaling',
              'removed_origin_after_z_flip': origin.tolist(), 'size_in_original_unity_units': (bounds[1]-bounds[0]).tolist(),
              'materials': 'neutral clay, original material/texture recovery pending',
              'date': '2026-10-11 extraction; source model/capture date unknown', 'instances': inventory}
    (OUT / (args.prefix+'-extraction.json')).write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
    write_glb(OUT / (args.prefix+'-reference.glb'), v, n, tri, {'metric_registration': 'unverified', 'source': str(SOURCE)})
    print('EXPORTED', len(inventory), 'instances', len(tri), 'triangles', 'errors', len(errors), flush=True)


if __name__ == '__main__':
    main()
