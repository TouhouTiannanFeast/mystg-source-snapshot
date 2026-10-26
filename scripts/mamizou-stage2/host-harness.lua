-- Implements only engine surface needed to run the actual callbacks.
setting={mamizou_test='timeout'};local images={};local objects={}
object={};img_class={};ball_big={size=1};GROUP_GHOST=0;GROUP_ENEMY_BULLET=1;GROUP_INDES=2;LAYER_TOP=10;LAYER_ENEMY_BULLET=5;COLOR_RED=1
function Class(base) local c={};for k,v in pairs(base or {}) do c[k]=v end;c.__index=c;return c end
function LoadTexture() end
function LoadImage(name) images[name]=true end
function Include() end
cos=function(a)return math.cos(a*math.pi/180)end;sin=function(a)return math.sin(a*math.pi/180)end
player={x=0,y=-150};function Angle(a,b)return -90 end
local seed=12345
ran={Float=function(_,a,b)seed=seed*16807%2147483647;return a+(b-a)*seed/2147483647 end}
bullet={init=function(o)o.img='mz.t18c1' end,skip_fade_in=function()end,del=function()end,kill=function()end}
function New(c,...) local o=setmetatable({valid=true},c);objects[o]=true;o:init(...);return o end
function IsValid(o)return o.valid end
function Del(o) if o.valid then o.valid=false;objects[o]=nil;if o.del then o:del() end end end
task={New=function(o,f)o.tasks=o.tasks or {};table.insert(o.tasks,coroutine.create(f))end,Wait=function(n)for i=1,n do coroutine.yield()end end}
boss={card={New=function()return {}end},init=function()end}
stage={group={New=function()end,AddStage=function()end,DefStageFunc=function()end},QuitGame=function()end}
stage_init={};FrameFunc=function()end;RenderFunc=function()end;lstg={};player_list={};default_stage_background={}
function MamizouHarnessRun()
 local api=MamizouTest;local logs={}
 for phase=1,5 do
  local o={x=0,y=112,hp=MamizouPattern.health[phase]};api.cards[phase].init(o)
  for t=0,MamizouPattern.durations[phase]-1 do
   for _,co in ipairs(o.tasks or {}) do if coroutine.status(co)~='dead' then local ok,err=coroutine.resume(co);assert(ok,err)end end
   local todo={};for s in pairs(objects)do todo[#todo+1]=s end
   for _,s in ipairs(todo) do
    if IsValid(s) then s:frame();assert(images[s.img], 'missing resource '..tostring(s.img));assert(s.x==s.x and s.y==s.y,'NaN trajectory') end
   end
   local capture=phase==1 and 200 or phase==3 and 500 or 650
   if MamizouFrameSink and t==capture then MamizouFrameSink(phase,t,objects,o) end
  end
  local s=api.state.stats[phase]
  if phase==1 then assert(s.shots==3990,'non1 source count '..s.shots)end
  if phase==3 then assert(s.shots==3960,'non2 source count '..s.shots)end
  if phase==2 then assert(s.bird==456 and s.frogseed==64 and not s.dog,'bird/frog source count')end
  if phase==4 then assert(s.randomKept==s.randomCandidates-math.floor(s.randomCandidates/4),'balanced transformation reduction')end
  if phase==5 then assert(s.radiusChecks>10000,'radius proof coverage')end
  api.cards[phase].del(o);assert(next(objects)==nil,'owned cleanup leak')
  logs[#logs+1]=string.format('{"phase":%d,"shots":%d,"radius_checks":%d,"random_candidates":%d,"random_kept":%d}',phase,s.shots,s.radiusChecks or 0,s.randomCandidates or 0,s.randomKept or 0)
 end
 return '['..table.concat(logs,',')..']'
end
