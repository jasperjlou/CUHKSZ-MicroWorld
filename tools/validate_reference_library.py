"""Check provenance gates, reference links and original integrity."""
import argparse,hashlib,json,pathlib,re,subprocess

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--metadata-only',action='store_true',help='Allow checkout without ignored originals');args=parser.parse_args()
 root=pathlib.Path(__file__).resolve().parents[1];ref=root/'references';checks=0
 def read(p):return json.loads((root/p).read_text('utf8'))
 def check(ok,msg):
  nonlocal checks
  checks+=1
  if not ok:raise AssertionError(msg)
 index=read('references/index.json');rows=index['references'];vr=read('references/vr/scene_catalog.json');allrows=rows+vr['references'];ids={r['reference_id'] for r in allrows}
 check(len(ids)==len(allrows),'duplicate IDs')
 required={'reference_id','subject','region','location','view_direction','source_type','source_url','source_owner','date_accessed','license_status','reuse_status','confidence','notes','review_status'}
 types={'USER_PROVIDED','OFFICIAL','OFFICIAL_VR','LEGACY_MODEL','ARCHITECTURAL_DOCUMENT','PUBLIC_VIDEO','SECONDARY_REFERENCE'}
 levels={'GROUND_TRUTH_REFERENCE','STRONG_REFERENCE','SUPPORTING_REFERENCE','VISUAL_INSPIRATION_ONLY','UNKNOWN'}
 originals=0
 for r in allrows:
  check(required<=r.keys(),'missing fields '+r['reference_id']);check(r['source_type'] in types and r['confidence'] in levels,'invalid enums')
  check(r['reuse_status']=='ASSET_REUSE_ALLOWED' or not r.get('asset_imported',False),'unknown-license import')
  if r.get('parent_reference'):check(r['parent_reference'] in ids,'unknown parent')
  if r.get('local_path'):
   p=(root/r['local_path']).resolve();check(p.is_relative_to(ref.resolve()),'path escapes references')
   if not args.metadata_only:
    check(p.is_file(),'missing original '+str(p));check(hashlib.sha256(p.read_bytes()).hexdigest()==r['sha256'],'original hash mismatch '+r['reference_id']);originals+=1
 for folder in ['upper_campus','fairy_lake','lower_campus']:
  pack=read('references/regions/'+folder+'/pack.json');check(len(pack['slots'])==12 and len({s['slot'] for s in pack['slots']})==12,'pack slot coverage')
  for s in pack['slots']:check(set(s['reference_ids'])<=ids and bool(s['notes']),'bad pack links')
 skeleton=read('references/spatial_skeleton.json');nodes={n['id'] for n in skeleton['nodes']}
 for e in skeleton['edges']:
  check(e['from_id'] in nodes and e['to_id'] in nodes and set(e['reference_ids'])<=ids,'bad topology edge');check(not e['game_connector_enabled'],'reference connector enabled')
 panoids={r['pano_id'] for r in vr['references']}
 for e in vr['edges']:check(e['from_pano_id'] in panoids and e['to_pano_id'] in panoids,'dangling panorama')
 for gap in read('references/unresolved/gaps.json')['gaps']:check(set(gap['searched_reference_ids'])<=ids,'gap source missing')
 check((ref/'.gdignore').exists(),'Godot exclusion missing')
 ignored=subprocess.run(['git','check-ignore','references/user/originals/walk-without-phone.jpg','references/architecture/originals/courtyard-as-agent.pdf'],cwd=root,capture_output=True,text=True)
 check(ignored.returncode==0 and len(ignored.stdout.splitlines())==2,'Git exclusion missing')
 plaque=read('references/user/plaque_analysis.json');check(hashlib.sha256((root/plaque['derived_asset']).read_bytes()).hexdigest()==plaque['derived_sha256'],'derived hash mismatch')
 source=(root/'world/CampusIdentity.gd').read_text('utf8');check(plaque['derived_asset'] in source and 'USER_PLAQUE_001' in source,'game provenance missing')
 legacy=read('references/legacy_models/spatial_skeleton.json');check(len(legacy['files'])==4,'legacy coverage')
 lake_source=(root/'world/FairyLakeLayout.gd').read_text('utf8')
 lake_refs=set(re.findall(r'"((?:VR_|LAKE_)\d+)"',lake_source))
 check(bool(lake_refs) and lake_refs<=ids,'lake geometry source links missing')
 for rid in ['VR_42078153','VR_42078154']:
  record=next(r for r in vr['references'] if r['reference_id']==rid)
  check(record['review_status']=='PARTIALLY_VISUALLY_REVIEWED','lake source review missing')
 for f in legacy['files']:
  for n in f['nodes']:check(all(x>=0 for x in n['span']) and len(n['world_matrix'])==16 and len(n['projected_convex_hull_xz'])>0,'invalid legacy geometry')
 if (root/'assets/campus/environment_catalog.json').exists():
  catalog=read('assets/campus/environment_catalog.json')
  check(set(catalog['categories'])=={'Architecture','Road','Path','Terrain','Vegetation','StreetFurniture','Signage','Lake','Shuttle','Landmark','Background'},'environment categories')
  check(len({a['asset_id'] for a in catalog['assets']})==len(catalog['assets']),'duplicate asset ID')
  for a in catalog['assets']:
   check((root/a['path']).is_file() and a['category'] in catalog['categories'],'asset path/category')
   check(set(a['source_reference_ids'])<=ids and bool(a['license']) and bool(a['provenance']),'asset provenance')
   check(set(a['confidence'].values())<={'verified','inferred','placeholder','unknown'},'asset confidence')
  entrance=read('references/regions/fairy_lake/v10_entrance_evidence.json')
  check({s['reference_id'] for s in entrance['sources']}<=ids,'entrance evidence sources')
  check(not entrance['legacy_models']['used_for_geometry'],'unverified legacy geometry import')
  embedded=re.search(r'<script[^>]*id="data"[^>]*>(.*?)</script>',(ref/'viewer.html').read_text('utf8'),re.S)
  check(embedded is not None and json.loads(embedded.group(1))==rows,'reference viewer stale')
 if (ref/'regions/fairy_lake/v10b_connector_evidence.json').exists():
  phase_b=read('references/regions/fairy_lake/v10b_connector_evidence.json')
  check(set(phase_b['sources'])<=ids,'Phase B source links')
  check(not phase_b['assets_imported'] and not phase_b['legacy_models']['used_for_placement'],'Phase B evidence reuse gates')
  check(all(not c['continuous_walk_verified'] for c in phase_b['candidate_connections']),'candidate connector became geographic truth')
  check(bool(phase_b['unknown']) and bool(phase_b['missing_evidence']),'Phase B missing-evidence coverage')
 if (ref/'regions/fairy_lake/v10c_frontier_evidence.json').exists():
  c=read('references/regions/fairy_lake/v10c_frontier_evidence.json');frozen=read(c['frontier_manifest'])
  check(frozen['frontier_id']=='FRONTIER_CONNECTOR_B' and frozen['game_position']==[1,3.05,111],'frozen frontier moved')
  check(frozen['confidence']=='unknown' and not c['extension_enabled'] and c['added_path_game_units']==0,'unjustified geography upgrade')
  for r in c['matrix']:
   check({'element','sources','interpretation','confidence','conflict','missing_evidence','scope'}<=r.keys(),'matrix missing fields')
   check(set(r['sources'])<=ids and r['confidence'] in {'verified','inferred','placeholder','unknown'},'invalid evidence reference/level')
  for a in c['reference_landmarks']:
   check(a['reference_id'] in ids and a['game_position'] is None and not a['game_registered'],'reference anchor promoted to game position')
  check(not c['legacy']['used_for_placement'] and not c['assets_imported'],'Phase C import gate')
  check('id="frontier-review"' in (ref/'viewer.html').read_text('utf8'),'frontier review missing from viewer')
 if (ref/'regions/fairy_lake/v10d_ground_evidence.json').exists():
  d=read('references/regions/fairy_lake/v10d_ground_evidence.json');baseline=read(d['frozen_baseline']);runtime=read('systems/data/ground_survey.json')
  check(not d['gate']['new_main_path_enabled'] and not d['junction']['game_instantiated'],'unproven ground bridge enabled')
  check(d['segments']==runtime['segments'] and d['coverage']==runtime['coverage'],'runtime ground evidence stale')
  for path,expected in baseline['geometry_sha256'].items():
   if (ref/'regions/fairy_lake/phase_e_construction.json').exists():
    current=read('references/regions/fairy_lake/phase_e_construction.json')
    override=current['geometry_freeze_superseded'].get(path)
    if override:
     check(path in {'world/ForestConnectorBuilder.gd','world/ForestConnectorLayout.gd'} and override['before']==expected,'unauthorized freeze override')
     expected=override['after']
   check(hashlib.sha256((root/path).read_bytes()).hexdigest()==expected,'frozen geometry changed '+path)
  for s in d['segments']:
   check(set(s['evidence'])<=ids and s['game_position'] is None and s['geographic_registration']=='unknown','ground segment provenance/registration')
   check(not s['new_walkable'] and not s['game_instantiated'],'reference-only segment promoted')
  check(sum(s['confidence']=='verified' for s in d['segments'])==2 and sum(s['confidence']=='unknown' for s in d['segments'])==2,'coverage count mismatch')
  for chain in d['panorama_chains']:
   check(set(chain['nodes'])<=ids and not chain['continuous_ground'],'metadata chain promoted to walking chain')
  g=read(d['dae_analysis']);old_hash={f['source_path']:f['sha256'] for f in legacy['files']}
  check(g['summary']['instances']==123 and g['summary']['geographically_matched_segments']==0,'ground audit coverage')
  for f in g['files']:
   check(f['sha256']==old_hash[f['source_path']],'DAE source identity changed')
   for n in f['nodes']:
    check(not n['unsupported_primitives'] and n['low_slope_candidate_triangles']<=n['triangles'],'triangle extraction incomplete')
    check(n['low_slope_connectivity']['components']<=n['low_slope_candidate_triangles'] and not n['lake_to_junction_match'],'invalid mesh connectivity claim')
  check('id="ground-review"' in (ref/'viewer.html').read_text('utf8'),'ground matrix absent from viewer')
 if (ref/'regions/fairy_lake/v10d2_gap_closure.json').exists():
  d2=read('references/regions/fairy_lake/v10d2_gap_closure.json');runtime=read('systems/data/ground_survey.json')
  check(d2['gaps']==runtime['gap_review'] and runtime['version']==d2['version'],'D2 runtime gap review stale')
  check(not d2['phase_e_ready'] and not runtime['phase_e_ready'] and not d2['new_semantic_objects'],'D2 research promoted to navigation')
  check(d2['coverage']=={'verified':2,'strong_inferred':0,'unknown':2,'closed_gaps':0,'game_registered_segments':0},'D2 unsupported coverage upgrade')
  check(d2['unknown_gap_change']['measurable_reduction'] is None,'D2 invented unknown-distance reduction')
  check({s['id'] for s in d2['segment_reviews']}=={s['id'] for s in d['segments']},'D2 renumbered existing segments')
  for s in d2['segment_reviews']:
   prior=next(p for p in d['segments'] if p['id']==s['id'])
   check(s['confidence']==prior['confidence']==s['previous_confidence'] and not s['new_walkable'],'D2 unsubstantiated confidence change')
   check(s['game_position'] is None and s['geographic_registration']=='unknown','D2 invented registration')
  for gap in d2['gaps']:
   check(not gap['closed'] and gap['status']=='unknown' and gap['matched_chain_links']==0,'D2 unsupported gap closure')
   check(gap['evidence_count']==len(set(gap['reviewed_references'])) and gap['source_family_count']==1,'D2 count inflates independence')
   check(set(gap['reviewed_references'])<=ids and bool(gap['required_evidence']),'D2 missing bounded evidence request')
  for pair in d2['reverse_view_checks']:
   check({pair['from_reference'],pair['to_reference']}<=ids and pair['continuity']=='unknown' and not pair['matched_unique_ground_cues'],'D2 phantom cross-view match')
  check(len(d2['roundabout_options'])==6 and all(not o['selected'] and o['route_status']=='unknown' for o in d2['roundabout_options']),'D2 guessed pedestrian-access option')
  relevant=read(d2['dae_analysis']);parent=root/relevant['parent_audit']
  check(hashlib.sha256(parent.read_bytes()).hexdigest()==relevant['parent_audit_sha256'],'D2 parent triangle audit changed')
  check(relevant['matched_candidates']==0 and relevant['new_triangles_audited']==0 and not relevant['used_for_geometry'],'D2 audit overstated')
  old_nodes={(f['source_path'],n['source_node_id']):n for f in g['files'] for n in f['nodes']}
  check(len(relevant['candidates'])==13,'D2 road candidate inventory incomplete')
  for candidate in relevant['candidates']:
   original=old_nodes[(candidate['source_path'],candidate['node_id'])]
   check(candidate['triangles']==original['triangles'] and candidate['low_slope_connectivity']==original['low_slope_connectivity'],'D2 invented triangle result')
   check(candidate['source_sha256']==old_hash[candidate['source_path']] and not candidate['eligible_for_targeted_triangle_reaudit'],'D2 unanchored subset selection')
  check('id="gap-review"' in (ref/'viewer.html').read_text('utf8'),'D2 gap options missing from viewer')
 if (ref/'regions/fairy_lake/phase_e_construction.json').exists():
  current=read('references/regions/fairy_lake/phase_e_construction.json');world=read(current['world_definition'])
  check(hashlib.sha256((root/current['world_definition']).read_bytes()).hexdigest()==current['world_definition_sha256'],'Phase E world manifest drift')
  check(current['blocking_unknowns']==0 and not current['evidence_fully_verified'],'construction confused with verification')
  check(world['segments']==current['segments'] and world['branches']==current['branches'],'construction records diverge')
  check(world['selected_access_option']=='B' and current['chosen_option']['confidence']=='placeholder','untracked access decision')
  node_ids={n['id'] for n in world['nodes']}
  check(len(node_ids)==len(world['nodes']),'duplicate graph node')
  for segment in world['segments']:
   check(segment['confidence'] in {'inferred','placeholder'} and segment['replaceable'] and bool(segment['inference_basis']),'unmarked inferred geometry')
   check(set(segment['nodes'])<=node_ids and len(segment['nodes'])>=2,'broken semantic graph link')
  check(len(world['branches'])==5 and sum(b['walkable'] for b in world['branches'])==4,'branch direction coverage')
 print(json.dumps({'checks':checks,'failures':0,'main_references':len(rows),'vr_scenes':len(vr['references']),'vr_edges':len(vr['edges']),'verified_originals':originals,'legacy_instances':sum(len(f['nodes']) for f in legacy['files'])}))
if __name__=='__main__':main()
