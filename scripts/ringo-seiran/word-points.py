from pathlib import Path
from PIL import ImageFont
root=Path('G:/MySTG')
font=ImageFont.truetype(str(root/'aex-0.8.22/game/packages/thlib-scripts/assets/font/wqy-microhei-mono.ttf'),160)
rows=['-- Procedural native point-sprite glyphs; no generated raster assets.','RingoSeiranWordPoints={',' texts={"씨","발"},']
for idx,text in enumerate(('씨','발'),1):
    # Sample the font's coverage into a slanted point grid, then color edges.
    mask=font.getmask(text,mode='L');width,height=mask.size
    occupied=set()
    for y in range(3,height,8):
        for x in range(3,width,8):
            if mask[y*width+x]>=96:occupied.add((x//8,y//8))
    outline={}
    for x,y in occupied:
        if (x+1,y) not in occupied:outline.setdefault((x+1,y),16)
        if (x-1,y) not in occupied:outline[(x-1,y)]=12
        if (x,y+1) not in occupied:outline[(x,y+1)]=12
    colored=[(x,y,c) for (x,y),c in sorted(outline.items())]
    colored.extend((x,y,2) for x,y in sorted(occupied))
    points=[]
    for x,y,color in colored:
        # 4.5px spacing, italic lean similar to supplied screenshots.
        points.append((round((x-width/16)*4.5+(height/8-y)*1.1,2),round((height/16-y)*4.5,2),color))
    # Center the final point bounding box, independent of font bearings.
    cx=(min(p[0] for p in points)+max(p[0] for p in points))/2
    cy=(min(p[1] for p in points)+max(p[1] for p in points))/2
    rows.append(' [%d]={%s},'%(idx,','.join('{%.2f,%.2f,%d}'%(x-cx,y-cy,c) for x,y,c in points)))
    print('glyph',idx,len(points),'points')
rows.append('}')
(root/'aex-0.8.22/game/mod/RingoSeiran/word-points.lua').write_text('\n'.join(rows)+'\n',encoding='utf-8')
