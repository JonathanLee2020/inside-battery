"""Prepare Chimchar and isolate only the dancing Yoshi from its egg/background."""
from pathlib import Path
from collections import deque
from PIL import Image, ImageSequence
from theme_gif import transparent_frames, save_animation

project = Path(__file__).resolve().parent.parent
frames, durations, loop = transparent_frames(project / "assets/chimchar/chimchar-sprite.gif")
save_animation(project / "Resources/ChimcharTheme.gif", frames, durations, loop)

original = Image.open(project / "assets/yoshi/yoshi-tv-yoshi-bailando.gif")
frames = [frame.convert("RGBA") for frame in ImageSequence.Iterator(original)]
durations = [frame.info["duration"] for frame in ImageSequence.Iterator(original)]
# Flood only the source's muted background greens; keep saturated Yoshi greens.
bg = {pixel[:3] for f in frames for pixel in f.get_flattened_data()
      if 60 <= pixel[0] <= 120 and 120 <= pixel[1] <= 185
      and pixel[1] - pixel[0] >= 25 and pixel[0]-25 <= pixel[2] <= pixel[0]+10}
clean=[]
for i,f in enumerate(frames):
 f=f.copy();p=f.load();w,h=f.size;seen=set();q=deque([(x,y) for x in range(w) for y in [0,h-1]]+[(x,y) for y in range(h) for x in [0,w-1]])
 while q:
  x,y=q.popleft()
  if (x,y) in seen or not(0<=x<w and 0<=y<h):continue
  seen.add((x,y));r,g,b,a=p[x,y]
  if a and (r,g,b) not in bg:continue
  p[x,y]=(r,g,b,0)
  q.extend((x+dx,y+dy) for dx in [-1,0,1] for dy in [-1,0,1] if dx or dy)
 seen=set();components=[]
 for y in range(h):
  for x in range(w):
   if (x,y) in seen or not p[x,y][3]:continue
   q=deque([(x,y)]);points=[]
   while q:
    xx,yy=q.popleft()
    if (xx,yy) in seen or not(0<=xx<w and 0<=yy<h) or not p[xx,yy][3]:continue
    seen.add((xx,yy));points.append((xx,yy));q.extend((xx+dx,yy+dy) for dx in [-1,0,1] for dy in [-1,0,1] if dx or dy)
   components.append(points)
 keep=max(components,key=len);keep=set(keep)
 for y in range(h):
  for x in range(w):
   if (x,y) not in keep:p[x,y]=(*p[x,y][:3],0)
 assert f.getbbox()[2] < 140, "Egg must be absent from every frame"
 assert f.getbbox()[3] - f.getbbox()[1] > 150, "Keep the complete Yoshi character"
 clean.append(f)

bounds = (min(f.getbbox()[0] for f in clean), min(f.getbbox()[1] for f in clean),
          max(f.getbbox()[2] for f in clean), max(f.getbbox()[3] for f in clean))
# A common canvas prevents the character from shifting when animation frames change.
clean = [frame.crop(bounds) for frame in clean]
save_animation(project / "Resources/YoshiTheme.gif", clean, durations, original.info.get("loop", 0))
print("PASS: all Yoshi frames retain the complete character and exclude the egg")
