shader_type spatial;
render_mode diffuse_burley;
uniform vec4 base_color : source_color = vec4(.55,.58,.55,1.0);
uniform int surface_kind = 0;
uniform vec2 tile_size = vec2(.9,.45);
uniform float variation = .045;
uniform float joint_width = .004;
varying vec3 world_point;
varying vec3 world_normal;
varying vec4 instance_tint;

float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 cell=floor(p), f=fract(p);f=f*f*(3.0-2.0*f);
    return mix(mix(hash(cell),hash(cell+vec2(1,0)),f.x),mix(hash(cell+vec2(0,1)),hash(cell+vec2(1,1)),f.x),f.y);
}
void vertex() {
    world_point=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
    world_normal=normalize(transpose(inverse(mat3(MODEL_MATRIX)))*NORMAL);
    instance_tint=COLOR;
}
void fragment() {
    vec3 n=abs(world_normal);
    vec2 p=n.y>.7 ? world_point.xz : (n.x>n.z ? world_point.zy : world_point.xy);
    float footprint=max(length(dFdx(p)),length(dFdy(p)));
    float near_detail=1.0-smoothstep(.02,.28,footprint);
    vec3 color=base_color.rgb;
    ROUGHNESS=.86;SPECULAR=.20;
    if (surface_kind==57) {
        // Outside the researched build bounds only. Neutral context, not a paving claim.
        float context_edge=mix(-220.0,-169.0,1.0-smoothstep(-975.0,-955.0,world_point.z));
        float outside=max(max(context_edge-world_point.x,world_point.x-245.0),max(-1150.0-world_point.z,world_point.z-100.0));
        vec3 edge_ground=mix(vec3(.42,.49,.35),vec3(.32,.35,.25),smoothstep(150.0,245.0,world_point.x));
        float wooded=smoothstep(180.0,260.0,world_point.x)*(1.0-smoothstep(60.0,170.0,world_point.z))*smoothstep(-1240.0,-1130.0,world_point.z);
        color=mix(edge_ground,base_color.rgb,smoothstep(0.0,28.0,outside)*(1.0-wooded));
        color*=.985+(noise(p*.12)-.5)*.025;
        ROUGHNESS=1.0;SPECULAR=.05;
    } else if (surface_kind==55) {
        // Old library2025 maintenance photograph: grey carpet with fine yellow-green traces.
        float fibre=(noise(p*95.0)-.5)*.11*near_detail;
        vec2 weave=p*7.0+vec2(noise(p*2.3),noise(p*2.1+11.0))*.85;
        float line=abs(sin(weave.x+weave.y*1.6))*abs(sin(weave.y-weave.x*.7));
        float thread=(1.0-smoothstep(.025,.10,line))*.24*near_detail;
        color=mix(vec3(.42,.45,.42),vec3(.64,.66,.40),thread)+fibre;
        ROUGHNESS=1.0;SPECULAR=.05;
    } else if (surface_kind==56) {
        // Fine task-chair weave, not the much coarser architectural screen aperture.
        vec2 cell=abs(fract(p/.008)-.5);
        float resolved=1.0-smoothstep(.0008,.0028,footprint);
        if(max(cell.x,cell.y)<.27*resolved) discard;
        color*=.95+(noise(p*80.0)-.5)*.05*resolved;
        ROUGHNESS=.94;SPECULAR=.08;
    } else if (surface_kind==54) {
        // Red perforated screen: real near-view apertures, filtered opaque red at distant subpixels.
        vec2 rotated=vec2(p.x+p.y,p.y-p.x)*.70710678;
        vec2 cell=abs(fract(rotated/.035)-.5);
        float visible_hole=1.0-smoothstep(.004,.010,footprint);
        if(max(cell.x,cell.y)<.29*visible_hole) discard;
        color*=.96+(noise(p*5.0)-.5)*.045;
        ROUGHNESS=.85;SPECULAR=.13;
    } else if (surface_kind==52) {
        // Student court mosaic: filter in continuous metres, before fract folds derivatives.
        // No high-frequency per-cell hash; distant yellow stays quiet rather than hatching.
        vec2 unit=vec2(.045), edge=min(fract(p/unit),1.0-fract(p/unit))*unit;
        vec2 aa=max(fwidth(p)*.65,vec2(.00035));
        vec2 lines=vec2(1.0)-smoothstep(vec2(.0008)-aa,vec2(.0008)+aa,edge);
        float seam=max(lines.x,lines.y);
        float detail=1.0-smoothstep(.004,.014,footprint);
        color*=.995-mix(.07,seam,detail)*.10;
        ROUGHNESS=.80;SPECULAR=.16;
    } else if (surface_kind==50) {
        // 2025-09 published6F photo: sparse small flecks in a pale partition band.
        vec2 cell=floor(p/.065),q=fract(p/.065);
        vec2 centre=vec2(.2+.6*hash(cell),.2+.6*hash(cell+13.7));
        float radius=mix(.025,.070,hash(cell+4.3));
        float mark=(1.0-smoothstep(radius,radius+.035,length(q-centre)))*step(.35,hash(cell+7.9));
        color*=1.0-mark*.48*near_detail;
        ROUGHNESS=.87;SPECULAR=.12;
    } else if (surface_kind==51) {
        // Cloth grain stays below high-contrast weave frequencies that caused moire.
        float grain=noise(p*40.0)-.5;
        color*=.96+grain*.055*(1.0-smoothstep(.003,.012,footprint));
        ROUGHNESS=.91;SPECULAR=.13;
    } else if (surface_kind==49) {
        // Gift-shop entrance cube 25308214: aligned rectangular grey stone with fine riven grain.
        // Module is a visual fit; restrained per-tile variation, no checkerboard or high gloss.
        vec2 unit=vec2(.60,.90),q=p/unit;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0005);
        float joint=1.0-smoothstep(.0018-aa,.0018+aa,gap);
        float detail=1.0-smoothstep(.025,.18,footprint);
        float grain=noise(p*vec2(91.0,12.0))*.65+noise(p*vec2(153.0,31.0))*.35;
        color*=.985+(hash(floor(q))-.5)*.035*detail+(grain-.5)*.048*near_detail-joint*.23*detail;
        ROUGHNESS=.81;SPECULAR=.17;
    } else if (surface_kind==47) {
        // ICC panorama: small rectangular stone modules, not storey-high panels.
        vec2 unit=vec2(.64,.32),q=p/unit;
        q.x+=mod(floor(q.y),2.0)*.5;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0005);
        float joint=1.0-smoothstep(.003-aa,.003+aa,gap);
        float detail=1.0-smoothstep(.035,.16,footprint);
        color*=.985+(hash(floor(q))-.5)*.045*detail;
        color*=1.0-joint*.21*detail+(noise(p*51.0)-.5)*.027*near_detail;
        ROUGHNESS=.88;SPECULAR=.13;
    } else if (surface_kind==44) {
        // Fine perforated metal/mesh, resolved only when it is larger than a pixel.
        vec2 cell=fract(p/.018)-.5;
        float aa=max(footprint/.018,.015);
        float perforation=1.0-smoothstep(.13-aa,.13+aa,length(cell));
        float detail=1.0-smoothstep(.006,.020,footprint);
        color*=.975-perforation*.14*detail;
        ROUGHNESS=.87;SPECULAR=.10;
    } else if (surface_kind==43) {
        // Interior pale timber veneer: fine matte grain without metre-wide zebra stripes.
        float grain=noise(p*vec2(78.0,2.3))-.5;
        float pore=noise(p*vec2(157.0,14.0))-.5;
        color*=.99+(grain*.055+pore*.025)*near_detail;
        ROUGHNESS=.82;SPECULAR=.12;
    } else if (surface_kind==42) {
        // Gate lawn promenade: quiet rectangular granite, not high-contrast checkerboard.
        vec2 unit=vec2(.40,.80),q=p/unit;
        q.y+=mod(floor(q.x),2.0)*.5;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0006);
        float joint=1.0-smoothstep(.002-aa,.002+aa,gap);
        float detail=1.0-smoothstep(.025,.20,footprint);
        color*=.98+(hash(floor(q))-.5)*.035*detail+(noise(p*24.0)-.5)*.045*near_detail-joint*.20*detail;
        ROUGHNESS=.89;SPECULAR=.12;
    } else if (surface_kind==41) {
        // Teaching A arcade: grey square stone slabs, subtle mineral grain and subdued reflection.
        // 800mm module is photo-fitted, not surveyed. Derivatives suppress distant seam shimmer.
        vec2 unit=vec2(.8),q=p/unit;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0006);
        float joint=1.0-smoothstep(.0015-aa,.0015+aa,gap);
        float detail=1.0-smoothstep(.025,.14,footprint);
        color*=.96+(hash(floor(q))-.5)*.045+(noise(p*18.0)-.5)*.035*near_detail-joint*.16*detail;
        ROUGHNESS=.78;SPECULAR=.14;
    } else if (surface_kind==40) {
        // Photo mall: grey rectangular stone, slight stagger and varied mineral grain.
        vec2 unit=vec2(.40,.80);vec2 q=p/unit;
        q.y+=mod(floor(q.x),2.0)*.5;
        vec2 edge=min(fract(q),1.0-fract(q))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.0006);
        float joint=1.0-smoothstep(.0025-aa,.0025+aa,gap);
        float detail=1.0-smoothstep(.025,.14,footprint);
        float mineral=noise(p*vec2(8.0,19.0))*.6+noise(p*42.0)*.4;
        // Keep a coherent grey stone field; the former 16% random block
        // contrast read as a checkerboard from the mall/colonnade cameras.
        color*=.97+hash(floor(q))*.055+(mineral-.5)*.065*near_detail-joint*.18*detail;
        ROUGHNESS=.89;SPECULAR=.14;
    } else if (surface_kind==39) {
        // Old-library render: subdued broad weathering, fine plaster at close range.
        // World-space scale prevents stretched streaks on differently sized facade pieces.
        float stain=noise(p*vec2(.65,.43))*.65+noise(p*vec2(2.2,.78))*.35;
        float streak=smoothstep(.53,.77,noise(p*vec2(3.1,.32)));
        color*=.92+stain*.13-streak*.10;
        color*=1.0+(noise(p*67.0)-.5)*.045*near_detail;
        ROUGHNESS=.97;SPECULAR=.08;
    } else if (surface_kind==38) {
        // Pavilion stair landings: small square setts separated by grass joints.
        vec2 unit=vec2(.24);vec2 q=p/unit;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float edge=min(e.x,e.y),aa=max(fwidth(edge),.0006);
        float joint=1.0-smoothstep(.012-aa,.012+aa,edge);
        float detail=1.0-smoothstep(.03,.14,footprint);
        color*=.90+(hash(floor(q))-.5)*.17+(noise(p*49.0)-.5)*.09*near_detail;
        color=mix(color,base_color.rgb*vec3(.46,.59,.35),joint*.82*detail);
        ROUGHNESS=.98;SPECULAR=.08;
    } else if (surface_kind==37) {
        // Irregular grey stepping stones with dark grass joints, fitted from user photos.
        vec2 q=p*2.1,cell=floor(q),local=fract(q);
        float first=10.0,second=10.0,stone=0.0;
        for(int x=-1;x<=1;x++)for(int y=-1;y<=1;y++) {
            vec2 offset=vec2(float(x),float(y));
            vec2 seed=vec2(hash(cell+offset),hash(cell+offset+vec2(51,19)));
            float dist=length(offset+vec2(.25)+seed*.5-local);
            if(dist<first){second=first;first=dist;stone=hash(cell+offset+vec2(17,7));}
            else if(dist<second){second=dist;}
        }
        float edge=second-first,aa=max(fwidth(edge),.001);
        float gap=1.0-smoothstep(.035-aa,.035+aa,edge);
        float detail=1.0-smoothstep(.09,.35,footprint);
        color*=.88+stone*.20+(noise(p*47.0)-.5)*.08*near_detail;
        color=mix(color,base_color.rgb*vec3(.40,.48,.31),gap*.8*detail);
        ROUGHNESS=.98;SPECULAR=.09;
    } else if (surface_kind==36) {
        // Older Zhixin/Daoyuan roofs: broad weathering and pale construction joints.
        // Fitted 4 m modules; keep high-frequency aggregate below the pixel footprint.
        vec2 unit=vec2(4.0);vec2 edge=min(fract(p/unit),1.0-fract(p/unit))*unit;
        float gap=min(edge.x,edge.y),aa=max(fwidth(gap),.001);
        float joint=1.0-smoothstep(.017-aa,.017+aa,gap);
        float stain=noise(p*.27)*.6+noise(p*.83)*.4;
        color*=.78+stain*.39+(noise(p*29.0)-.5)*.10*near_detail;
        color=mix(color,color*1.22,joint*.60);
        ROUGHNESS=.98;SPECULAR=.08;
    } else if (surface_kind==35) {
        // Weathered narrow outdoor boards from Zhiren garden; fitted module and grain.
        vec2 unit=vec2(2.4,.14);vec2 q=(p-vec2(45,-751))/unit;
        q.x+=mod(floor(q.y),3.0)/3.0;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0005);
        float seam=1.0-smoothstep(.002-aa,.002+aa,gap);
        float detail=1.0-smoothstep(.025,.14,footprint);
        float grain=noise(vec2(p.x*1.6,p.y*95.0))-.5;
        float worn=noise(p*vec2(.4,2.0));
        color*=.96+(hash(floor(q))-.5)*.16*detail+grain*.13*near_detail-seam*.23*detail;
        color=mix(color,vec3(dot(color,vec3(.3,.59,.11))),worn*.22);
        ROUGHNESS=.93;SPECULAR=.11;
    } else if (surface_kind==34) {
        // Main Square ochre narrow bricks: long axis runs away from the road curb.
        // 300 x 100 mm is a visual fit, not a measured specification.
        vec2 unit=vec2(.30,.10);vec2 q=(p-vec2(0,-733))/unit;
        q.x+=mod(floor(q.y),2.0)*.5;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0005);
        float seam=1.0-smoothstep(.0018-aa,.0018+aa,gap);
        float detail=1.0-smoothstep(.015,.10,footprint);
        color*=.98+(hash(floor(q))-.5)*.11*detail-seam*.22*detail;
        color*=1.0+(noise(p*65.0)-.5)*.07*near_detail;
        ROUGHNESS=.94;SPECULAR=.10;
    } else if (surface_kind==33) {
        // Shaw outer walk: staggered rectangular pavers with scattered darker units.
        // Module size is fitted from panorama, not a measured paving schedule.
        vec2 q=(p-vec2(42.0,-500.0))/vec2(.40,.20);
        q.x+=mod(floor(q.y),2.0)*.5;
        vec2 e=min(fract(q),1.0-fract(q))*vec2(.40,.20);
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0007);
        float seam=1.0-smoothstep(.002-aa,.002+aa,gap);
        float detail=1.0-smoothstep(.025,.15,footprint);
        float unit=hash(floor(q));
        color*=.96+(unit-.5)*.18*detail-(1.0-step(.17,unit))*.10*detail;
        color*=1.0-seam*.25*detail+(noise((p-vec2(42,-500))*48.0)-.5)*.065*near_detail;
        ROUGHNESS=.91;SPECULAR=.12;
    } else if (surface_kind==32) {
        // Library service apron: small exposed aggregate, fading before aliasing.
        float detail=1.0-smoothstep(.009,.065,footprint);
        float aggregate=noise((p-vec2(120.0,-290.0))*85.0)-.5;
        float wear=noise(p*.20)-.5;
        color*=.99+aggregate*.24*detail+wear*.035;
        ROUGHNESS=clamp(.95+aggregate*.05*detail,.90,1.0);SPECULAR=.09;
    } else if (surface_kind==31) {
        // East Gate granite: square modules observed in the official pavement faces.
        // 600 mm is fitted from the image, not a measured dimension.
        vec2 unit=vec2(.6);vec2 q=p/unit;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0006);
        float seam=1.0-smoothstep(.0015-aa,.0015+aa,gap);
        float detail=1.0-smoothstep(.028,.18,footprint);
        float mineral=noise(p*52.0)-.5;
        color*=.98+(hash(floor(q))-.5)*.048*detail+mineral*.07*near_detail;
        color=mix(color,color*.66,seam*.34*detail);
        ROUGHNESS=clamp(.82+mineral*.08*near_detail,.76,.92);SPECULAR=.18;
    } else if (surface_kind==30) {
        // Indoor sports parquet: short staggered boards, not broad continuous timber bands.
        vec2 unit=vec2(.09,.60);vec2 q=p/unit;
        q.y+=mod(floor(q.x),4.0)*.25;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0005);
        float seam=1.0-smoothstep(.0007-aa,.0007+aa,gap);
        float detail=1.0-smoothstep(.018,.09,footprint);
        float grain=noise(vec2(p.x*130.0,p.y*7.0))-.5;
        color*=.98+(hash(floor(q))-.5)*.14*detail+grain*.055*near_detail-seam*.075*detail;
        ROUGHNESS=.50;SPECULAR=.32;
    } else if (surface_kind==29) {
        // Grey indoor porcelain, 600 mm square modules and restrained fine grout.
        vec2 unit=vec2(.6);vec2 q=p/unit;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float gap=min(e.x,e.y),aa=max(fwidth(gap),.0006);
        float seam=1.0-smoothstep(.001-aa,.001+aa,gap);
        float detail=1.0-smoothstep(.025,.16,footprint);
        color*=.995+(hash(floor(q))-.5)*.035+(noise(p*14.0)-.5)*.02*near_detail-seam*.10*detail;
        ROUGHNESS=.57;SPECULAR=.27;
    } else if (surface_kind==28) {
        // Natural granite boulder: multi-scale mineral grain, no paving/mortar grid.
        float mineral=noise(p*35.0)-.5;
        float vein=noise(p*.9+vec2(noise(p*2.0)))-.5;
        color*=.94+vein*.20+mineral*.26*near_detail;
        ROUGHNESS=.97;SPECULAR=.10;
    } else if (surface_kind==27) {
        // Dark green structural-glass floor panels at ICC; no blue facade-glass override.
        color*=.985+noise(p*1.6)*.025;
        ROUGHNESS=.54;SPECULAR=.12;METALLIC=0.0;
    } else if (surface_kind==46) {
        // Library G public carpet replaced in June2025 (official article1203).
        // Pale mottled modular textile, with cloudy grey streaks and sparse warm fibres.
        // Module size and colour are fitted; world projection joins adjacent floor pieces.
        vec2 cell=floor(p/.60);
        vec2 grain_p=p+vec2(hash(cell)*1.7,hash(cell+vec2(13.0))*2.3);
        float drift=noise(grain_p*vec2(1.4,4.0));
        float cloud=noise(grain_p*vec2(3.8,12.0)+vec2(drift*1.8,0));
        float fibre=noise(grain_p*vec2(115.0,170.0))-.5;
        float warm=smoothstep(.68,.87,noise(grain_p*vec2(7.0,18.0)))*.065;
        color*=.89+cloud*.18+(hash(cell)-.5)*.018+fibre*.05*near_detail;
        color=mix(color,color*vec3(1.07,1.025,.88),warm);
        ROUGHNESS=.99;SPECULAR=.06;METALLIC=0.0;
    } else if (surface_kind==45) {
        // 4F September 2024 photos: alternating grey carpet modules with subdued fibres.
        // Separate from ICC glass (27); avoid the previously unreachable duplicate branch.
        vec2 cell=floor(p/.60);
        float checker=mod(cell.x+cell.y,2.0);
        float fibre=noise(p*96.0)-.5;
        color*=.98+checker*.025+(hash(cell)-.5)*.024+fibre*.045*near_detail;
        ROUGHNESS=.98;SPECULAR=.08;METALLIC=0.0;
    } else if (surface_kind==26 || surface_kind==53) {
        // Flamed granite paving: metric modules, shallow seams and matte mineral grain.
        // World-space projection keeps adjacent regional meshes on the same tile grid.
        vec2 q=p/tile_size;
        vec2 edge=min(fract(q),1.0-fract(q))*tile_size;
        float width=min(edge.x,edge.y), aa=max(fwidth(width),.001);
        float seam=1.0-smoothstep(.004-aa,.004+aa,width);
        seam*=1.0-smoothstep(.06,.4,footprint);
        float mineral=noise(p*46.0)-.5;
        color*=.97+(hash(floor(q))-.5)*(surface_kind==53 ? .04 : .075)+mineral*.075*near_detail;
        color=mix(color,color*.55,seam*.42);
        ROUGHNESS=clamp(.88+mineral*.09*near_detail,.8,.97);SPECULAR=.13;
    } else if (surface_kind==0 || surface_kind==1 || surface_kind==6 || surface_kind==7) {
        vec2 q=p/tile_size;
        if (surface_kind==1 || surface_kind==7) q.x+=mod(floor(q.y),2.0)*.5;
        vec2 tile=floor(q), edge=min(fract(q),1.0-fract(q))*tile_size;
        float width=min(edge.x,edge.y);
        float aa=max(fwidth(width),.0008);
        float joint=1.0-smoothstep(joint_width-aa,joint_width+aa,width);
        float bevel=1.0-smoothstep(joint_width+.003-aa,joint_width+.003+aa,width);
        float tile_detail=1.0-smoothstep(min(tile_size.x,tile_size.y)*.20,min(tile_size.x,tile_size.y)*.80,footprint);
        joint*=tile_detail;bevel*=tile_detail;
        float grain=noise(p*34.0)-.5;
        color*=1.0+(hash(tile)-.5)*variation+grain*.035*near_detail;
        color=mix(color,color*.76,bevel*.16);
        color=mix(color,color*.56,joint*.48);
        if (surface_kind!=0) {
            color*=.86;
            // Low contrast mineral flecks and broad wear; detail fades with pixel footprint.
            color*=.97+noise(p*.12)*.05;
            ROUGHNESS=clamp(.89+grain*.04*near_detail,.84,.98);SPECULAR=.12;
        }
    } else if (surface_kind==2) {
        color*=.94+(noise(p*27.0)-.5)*.13*near_detail+noise(p*.1)*.025;
        ROUGHNESS=.96;SPECULAR=.10;
    } else if (surface_kind==3) {
        color=mix(color,vec3(dot(color,vec3(.2126,.7152,.0722))),.16);
        color*=.78+noise(p*.11)*.14+(noise(p*5.0)-.5)*.055*near_detail;
        ROUGHNESS=1.0;SPECULAR=.08;
    } else if (surface_kind==4) {
        color*=.83+noise(vec2(p.x*11.0,p.y*.45))*.24;
        ROUGHNESS=.77;
    } else if (surface_kind==5) {
        color*=.86+.10*noise(p*.13);
        ROUGHNESS=.28;METALLIC=.20;SPECULAR=.60;
    } else if (surface_kind==8) {
        color*=.92+(noise(p*30.0)-.5)*.09*near_detail;
        ROUGHNESS=.96;SPECULAR=.08;
    } else if (surface_kind==10) {
        color*=.68+.05*sin(p.x*.65+TIME*.6)*sin(p.y*.45-TIME*.3);
        NORMAL_MAP=vec3(.5+.025*sin(p.x*2.0+TIME*.5),.5+.02*cos(p.y*2.6-TIME*.35),1.0);
        NORMAL_MAP_DEPTH=.35;
        ROUGHNESS=.14;METALLIC=.38;SPECULAR=.70;
    } else if (surface_kind==11) {
        float rib=1.0-smoothstep(.01,.03,min(fract(p.x/.5),1.0-fract(p.x/.5))*.5);
        color*=1.0-rib*.07;ROUGHNESS=.72;METALLIC=.06;SPECULAR=.25;
    } else if (surface_kind==12) {
        // Polished interior slabs: broad joints and restrained mineral variation.
        vec2 q=p/vec2(1.8,1.2);
        vec2 edge=min(fract(q),1.0-fract(q))*vec2(1.8,1.2);
        float width=min(edge.x,edge.y);
        float joint=1.0-smoothstep(.002,max(.005,fwidth(width)*1.5),width);
        color*=.98+(noise(p*2.0)-.5)*.025-joint*.09;
        ROUGHNESS=.48;SPECULAR=.36;
    } else if (surface_kind==13) {
        // Large dark facade panels avoid miniature masonry on the metal shell.
        vec2 q=p/vec2(1.5,3.8);
        vec2 edge=min(fract(q),1.0-fract(q))*vec2(1.5,3.8);
        float width=min(edge.x,edge.y);
        float joint=1.0-smoothstep(.003,max(.008,fwidth(width)*1.5),width);
        color*=1.0-joint*.14+(noise(p*.8)-.5)*.02;
        ROUGHNESS=.65;METALLIC=.08;
    } else if (surface_kind==14) {
        color*=instance_tint.rgb*(.89+noise(world_point.xz*7.0+world_point.y)*.16);
        ROUGHNESS=.96;SPECULAR=.10;
    } else if (surface_kind==15) {
        // Large warm stone/concrete panels, not miniature brickwork across the facade.
        vec2 q=p/vec2(2.4,3.7);
        vec2 e=min(fract(q),1.0-fract(q))*vec2(2.4,3.7);
        float edge=min(e.x,e.y);
        float seam=1.0-smoothstep(.002,max(.006,fwidth(edge)*1.4),edge);
        float mineral=noise(p*.8)-.5;
        float streak=noise(vec2(p.x*7.0,p.y*.19))-.5;
        color*=1.0+mineral*.025+streak*.018-seam*.075;
        ROUGHNESS=.84;SPECULAR=.16;
    } else if (surface_kind==16) {
        vec2 lattice=fract(p/.035)-.5;
        float hole=1.0-smoothstep(.24,.39,length(lattice));
        float mesh_detail=1.0-smoothstep(.009,.05,footprint);
        color*=1.0-hole*.50*mesh_detail;
        ROUGHNESS=.72;METALLIC=.08;
    } else if (surface_kind==17) {
        EMISSION=color*.65;
        ROUGHNESS=.68;SPECULAR=.12;
    } else if (surface_kind==18) {
        // Weathered roof membrane: low reflection and fine aggregate, not reflective metal.
        color*=.93+(noise(p*8.0)-.5)*.05*near_detail+noise(p*.13)*.025;
        ROUGHNESS=.96;SPECULAR=.10;
    } else if (surface_kind==20) {
        // Administration rear: broad rectangular metal panels, not continuous ribs.
        vec2 unit=vec2(1.4,1.85);
        vec2 edge=min(fract(p/unit),1.0-fract(p/unit))*unit;
        float width=min(edge.x,edge.y);
        float seam=1.0-smoothstep(.002,max(.007,fwidth(width)*1.5),width);
        color*=1.0-seam*.10+(hash(floor(p/unit))-.5)*.016;
        ROUGHNESS=.64;METALLIC=.08;SPECULAR=.24;
    } else if (surface_kind==21) {
        // Canteen yellow mosaic: millimetre joints fade before the pattern aliases at distance.
        vec2 unit=vec2(.045);
        vec2 cell=floor(p/unit);
        vec2 edge=min(fract(p/unit),1.0-fract(p/unit))*unit;
        float width=min(edge.x,edge.y);
        float seam=1.0-smoothstep(.001,max(.0018,fwidth(width)*1.25),width);
        float detail=1.0-smoothstep(.003,.026,footprint);
        color*=1.0+((hash(cell)-.5)*.055-seam*.18)*detail;
        ROUGHNESS=.76;SPECULAR=.20;
    } else if (surface_kind==22) {
        // Start-zone painted render: broad tone variation, no masonry-grid overlay.
        color*=.985+noise(p*.18)*.025+(noise(p*24.0)-.5)*.015*near_detail;
        ROUGHNESS=.91;SPECULAR=.10;
    } else if (surface_kind==23) {
        // Long gray wood-look floor strips in the Teaching C official arcade panorama.
        vec2 unit=vec2(.18,1.2);vec2 q=p/unit;
        q.y+=mod(floor(q.x),3.0)*.3333;
        vec2 e=min(fract(q),1.0-fract(q))*unit;
        float seam=1.0-smoothstep(.001,max(.004,fwidth(min(e.x,e.y))*1.4),min(e.x,e.y));
        float detail=1.0-smoothstep(.028,.16,footprint);
        float grain=noise(vec2(p.x*65.0,p.y*1.7))-.5;
        color*=.94+(hash(floor(q))-.5)*.12+grain*.10*near_detail-seam*.14*detail;
        ROUGHNESS=.65;SPECULAR=.22;
    } else if (surface_kind==24) {
        // Warm pressed-wood wall: short irregular strands, not long timber stripes.
        float strands=noise(vec2(p.x*53.0+p.y*24.0,p.y*8.0-p.x*3.0))-.5;
        float crossgrain=noise(vec2(p.y*41.0-p.x*18.0,p.x*7.0+p.y*2.0))-.5;
        color*=.98+(strands*.17+crossgrain*.10)*near_detail;
        ROUGHNESS=.93;SPECULAR=.10;
    } else if (surface_kind==25) {
        // Dense neutral carpet in the G collaborative room, without stone joints.
        color*=.95+(noise(p*64.0)-.5)*.12*near_detail+noise(p*.5)*.04;
        ROUGHNESS=1.0;SPECULAR=.06;
    }
    ALBEDO=color;
}
