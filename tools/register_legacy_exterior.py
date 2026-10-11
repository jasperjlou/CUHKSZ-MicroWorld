"""Reproduce exterior image correspondences; never writes source assets/game geometry.

Pixel picks are approximate roof/bridge centres, not surveyed control points.
The architect plan and old scene may depict different project revisions.
"""
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'references/visual_build_20261008/legacy_exterior_registration_v122.json'


def fit(points, targets):
    mx = [sum(p[k] for p in points)/len(points) for k in range(2)]
    my = [sum(p[k] for p in targets)/len(targets) for k in range(2)]
    u = [[p[k]-mx[k] for k in range(2)] for p in points]
    v = [[p[k]-my[k] for k in range(2)] for p in targets]
    den = sum(x*x+y*y for x, y in u)
    a = sum(p[0]*q[0]+p[1]*q[1] for p,q in zip(u,v))/den
    b = sum(p[0]*q[1]-p[1]*q[0] for p,q in zip(u,v))/den
    t = [my[0]-a*mx[0]+b*mx[1],my[1]-b*mx[0]-a*mx[1]]
    def convert(p):
        return [a*p[0]-b*p[1]+t[0],b*p[0]+a*p[1]+t[1]]
    errors = [math.dist(convert(p),q) for p,q in zip(points,targets)]
    return {'matrix':[[a,-b],[b,a]],'translation':t,
            'rotation_deg':math.degrees(math.atan2(b,a)),
            'scale':math.hypot(a,b),'reflection':False,
            'residuals':errors,'rms':math.sqrt(sum(e*e for e in errors)/len(errors))}


anchors = [
    {'id':'east_gate_overhead_link_centre','legacy_pixel':[546,325],
     'architect_pixel':[1562,344], 'current_candidate_xz':[0,0],
     'limit':'Roof bridge centre; actual pedestrian threshold offset not measured.'},
    {'id':'teaching_a_rectilinear_group_centre','legacy_pixel':[864,158],
     'architect_pixel':[1381,449], 'current_candidate_xz':[-79.5,-115],
     'limit':'Approximate roof envelope centre; current root not guaranteed same point.'},
    {'id':'icc_main_roof_group_centre','legacy_pixel':[694,575],
     'architect_pixel':[1476,220], 'current_candidate_xz':[78,-80],
     'limit':'Main roof group excludes gate assembly hall/CxII; exact CAD axis unresolved.'},
]
points = [a['legacy_pixel'] for a in anchors]
report = {
    'reviewed':'2026-10-11', 'status':'image_topology_correspondence_only_not_metric_site_registration',
    'legacy_view':'references/legacy-gta-20261011/legacy-anchor-wide-v122.png',
    'legacy_camera':{'eye':[-900,2200,40.1],'target':[-900,0,40],
                     'orthographic_size':700,'viewport':[1440,900]},
    'architect_view':'references/visual_build_20261008/originals/start-registration-v82/architect-masterplan.jpg',
    'architect_url':'https://oss.gooood.cn/uploads/2025/12/043-the-chinese-university-of-hong-kong-shenzhen-phase-ii-by-wang-weijen-architecture.jpg',
    'publication_date':'2025-12-24','drawing_date':'unknown',
    'identity_crosscheck':'references/visual_build_20261008/originals/official-campus-map-20260512.jpg; May 2026 edition',
    'anchors':anchors,
    'architect_image_fit':fit(points,[a['architect_pixel'] for a in anchors]),
    'current_root_diagnostic_fit':fit(points,[a['current_candidate_xz'] for a in anchors]),
    'limits':[
        'Small residual on three approximate centres cannot certify corners, scale or identity of entrances.',
        'Current roots are diagnostic candidates, not accepted control points. Do not apply their transform to buildings.',
        'No physical metre scale, height scale or true north is established.',
        'ICC apparent site rotation differs from current CAD fit; corner correspondence needed before rotating.',
    ],
    'actionable_shape_finding':{
        'building':'zhang_lingbin (former Teaching D)',
        'evidence':'Old scene, architect ground/roof plan and May2026 guide show the third oblique deep court; current 45m fitted depth flattens it relative to B/C at94m.',
        'action':'Extend D rearward while retaining user-photo front gallery/bridge positions; depth is fitted pending metric registration.'
    }
}
OUT.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:report[k] for k in ['architect_image_fit','current_root_diagnostic_fit']},ensure_ascii=False))
