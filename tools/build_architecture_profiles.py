"""Authored V2 feature records; preserve the V1 spatial database byte for byte."""
import json
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
source = ROOT / 'systems/data/campus_masterplan.json'
m = json.loads(source.read_text(encoding='utf-8'))
buildings = [o for o in m['objects'] if o['category'] == 'building']
tier_a = {'library', 'administration', 'student_centre', 'shaw_west', 'shaw_east',
          'ling', 'muse', 'diligentia', 'harmonia', 'duan', 'music', 'eighth',
          'sports_hall', 'conference', 'teaching_a', 'teaching_b'}
sources = dict(m['sources'])
sources['LIBRARY_OFFICIAL'] = {'source_url': 'https://www.cuhk.edu.cn/en/article/6130', 'role': 'architecture description; two interlocking three-floor C volumes', 'raw_asset_imported': False}
sources['MUSIC_OFFICIAL'] = {'source_url': 'https://www.cuhk.edu.cn/en/article/15580', 'role': 'new music campus identity; guide controls placement', 'raw_asset_imported': False}
sources['STUDENT_DESIGNER'] = {'source_url': 'https://www.arch.hku.hk/secondary_category/weijen-wang/', 'role': 'courtyard and horizontal corridor typology', 'raw_asset_imported': False}
profiles = []
for i, o in enumerate(buildings):
    family = 'conference' if o['id'].startswith('conference') else 'academic_court' if o['region']=='lower' and o['massing']=='courtyard' and not o['id'].startswith('shaw') else o['massing']
    tier = 'A' if o['id'] in tier_a else 'C' if o['confidence'] == 'placeholder' else 'B'
    refs = list(o['source_refs'])
    if o['id'] == 'library': refs += ['LIBRARY_OFFICIAL']
    if o['id'] == 'music': refs += ['MUSIC_OFFICIAL']
    if o['id'] == 'student_centre': refs += ['STUDENT_DESIGNER']
    confidence = 'SUPPORTED' if tier == 'A' else 'APPROXIMATED'
    if o['id'] in ('library', 'sports_hall'): confidence = 'STRONG_REFERENCE'
    if tier == 'C': confidence = 'PLACEHOLDER'
    signatures = {
        'library': ['two interlocking C volumes', 'recessed veranda', 'open reading court'],
        'admin': ['paired stone wings', 'elevated bridging volume', 'glass entrance'],
        'student': ['terraced horizontal courtyards', 'open ground arcade', 'warm vertical screens'],
        'college': ['tower and open podium', 'enclosed courtyard', 'college-specific accent and roof screen'],
        'courtyard': ['perimeter residential wings', 'open pedestrian entrance', 'courtyard planting'],
        'music': ['three faceted elliptical volumes', 'stepped curved roof silhouette', 'glazed lobby'],
        'sports': ['white large-span hall', 'clerestory ribbon', 'fine vertical fins'],
        'academic': ['stone teaching bars', 'warm screened base', 'recessed glazed bay'],
        'tower': ['slim gridded tower', 'lower podium', 'roof screen'],
        'bell': ['slender stone shaft', 'open belfry', 'roof cap'],
        'conference': ['broad glazed foyer', 'large auditorium volume', 'low side wings and canopy'],
        'academic_court': ['horizontal stone teaching wings', 'glazed bands', 'open arcade and warm courtyard screen'],
    }.get(family, ['layered podium', 'window rhythm', 'recessed entrance'])
    profiles.append(dict(id=o['id'], tier=tier, style_family=family,
        signature_features=signatures, facade_primary='warm_white' if o['region']=='upper' else 'light_stone',
        facade_secondary=o['accent'], glass_ratio=.23 if family in ('college','tower') else .34,
        window_rhythm='residential_grid' if o['region']=='upper' else 'academic_bays',
        roof_character='flat_parapet' if family=='academic_court' else 'parapet_and_screen', podium_type='open_arcade',
        tower_type=('split_four' if o['id'] in ('muse','harmonia') else 'three_part' if o['id']=='diligentia' else 'paired') if family=='college' else 'stepped', corridor_type='open_colonnade',
        courtyard_type='open_planted' if family in ('college','courtyard','student','library') else 'entry_forecourt',
        entrance_type='clear_ground_opening', reference_ids=refs, architecture_confidence=confidence,
        current_stage='LANDMARK' if tier=='A' else 'ARCHITECTURAL_SHELL',
        variation=i, replaceable=True,
        inference_basis='Existing guide envelope and regional official photos; facade dimensions and unseen elevations are inferred, not survey data.',
        unresolved='Exact facade grid, floor elevations and individual rear elevations remain unmeasured.'))
frozen = dict(baseline_commit='faa437023719a8d08ba720e079a695955c645bc7',
              masterplan_sha256=hashlib.sha256(source.read_bytes().replace(b'\r\n', b'\n')).hexdigest(),
              spatial_records=[{k:o[k] for k in ('id','category','center','yaw_deg','footprint_width','footprint_depth','estimated_height','confidence')} for o in m['objects']])
(ROOT/'systems/data/campus_masterplan_v1_frozen.json').write_text(json.dumps(frozen,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(ROOT/'systems/data/building_architecture_profiles.json').write_text(json.dumps(dict(version='campus-architecture-v2',sources=sources,buildings=profiles),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
out = ROOT/'references/architecture'; out.mkdir(parents=True,exist_ok=True)
for p in profiles:
    if p['tier']!='A': continue
    record=dict(p, silhouette=p['signature_features'], floor_count='Estimated from V1 height; not measured',
        materials='Restrained procedural stone/white concrete/glass palette',
        ground_relationship='Existing V1 plateau; no spatial relocation',
        evidence_limit='Regional photos establish architectural vocabulary, not a verified facade for each named site.')
    (out/(p['id']+'.json')).write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'{len(profiles)} profiles; {len(tier_a)} Tier A; V1 snapshot written')
