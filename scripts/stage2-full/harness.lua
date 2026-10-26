-- Minimal engine contract for executing the integrated route, not native parity.
setting={};local images={};local textures={};local objects={};local prints={};local cards={};Stage2HarnessObjects=objects;Stage2HarnessImages=images
Stage2HarnessObjects=objects;Stage2HarnessImages=images
object={};img_class={};ball_big={size=1};ball_small={size=1};enemybase={};bullet={}
GROUP_GHOST=0;GROUP_ENEMY_BULLET=1;GROUP_INDES=2;GROUP_ENEMY=3;GROUP_NONTJT=3;LAYER_TOP=10;LAYER_ENEMY_BULLET=5;LAYER_ENEMY=4
COLOR_RED=1;COLOR_ORANGE=2;COLOR_YELLOW=3;COLOR_BLUE=4
cos=function(a)return math.cos(a*math.pi/180)end;sin=function(a)return math.sin(a*math.pi/180)end
math.atan2=math.atan2 or function(y,x)return math.atan(y,x)end
-- AEX inherits lifecycle callbacks only; object data does not resolve class helpers.
function Class(base)
 local c={base=base or object}
 for _,k in ipairs({'init','del','frame','render','colli','kill'})do c[k]=(base or object)[k] end
 return c
end
function LoadTexture(name,path) assert(Stage2FileExists(path),'texture missing '..path);textures[name]=path end
function LoadImage(name,tex,x,y,w,h)assert(textures[tex]);images[name]={path=textures[tex],rect={x,y,w,h}}end
function SetImageState()end
function Render(name,x,y,rot,sx,sy)assert(images[name],'render missing '..tostring(name));if Stage2RenderSink then Stage2RenderSink(name,x,y,rot,sx,sy)end end
function RenderText()end
function Color()return 0 end
function DefaultRenderFunc(o) Render(o.img,o.x,o.y,o.rot,o.hscale,o.vscale)end
player={x=0,y=-150,valid=true};player_list={};lstg={var={}};stage_init={};FrameFunc=function()end;RenderFunc=function()end
function Angle(a,b) assert(a and b and a.valid and b.valid,'invalid lstg object');return math.atan2(b.y-a.y,b.x-a.x)*180/math.pi end
local seed=12345;ran={Float=function(_,a,b)seed=seed*16807%2147483647;return a+(b-a)*seed/2147483647 end}
function print(s)prints[#prints+1]=s end
function IsValid(o)return o and o.valid end
function New(c,...) local o=setmetatable({class=c,valid=true,x=0,y=0,vx=0,vy=0,ani=0,rot=0},{__index=function(t,k)if k=='img' then return rawget(t,'_img') end end,__newindex=function(t,k,v)if k=='img' then rawset(t,'_img',v);rawset(t,'a',0);rawset(t,'b',0)else rawset(t,k,v)end end});objects[o]=true;if c.init then c.init(o,...)end;return o end
function Del(o)if o.valid then o.valid=false;objects[o]=nil;if o.class.del then o.class.del(o)end end end
function Kill(o)if o.valid then o.valid=false;objects[o]=nil;if o.kill then o:kill()elseif o.class.del then o.class.del(o)end end end
bullet.init=function(o,img,col)img.init(o,col)end;bullet.skip_fade_in=function()end;bullet.del=function()end;bullet.kill=function()end;bullet.render=DefaultRenderFunc
task={New=function(o,f)o.tasks=o.tasks or {};o.tasks[#o.tasks+1]=coroutine.create(f)end,Wait=function(n)for i=1,n do coroutine.yield()end end}
function task.Do(o)
 for _,co in ipairs(o.tasks or {})do if coroutine.status(co)~='dead' then local ok,err=coroutine.resume(co);assert(ok,err)end end
end
enemybase.init=function(o,hp)o.hp=hp end;enemybase.del=function()end
enemybase.frame=function(o)if o.hp<=0 then Kill(o)end;task.Do(o)end
enemybase.colli=function(o,other)if other.dmg then Damage(o,other.dmg)end end
enemy=Class(enemybase)
-- Native enemy callbacks require EnemyWalkImageSystem from enemy.init.
function enemy:render() assert(self._wisys,'enemy render requires _wisys');self._wisys:render(self.dmgt,self.dmgmaxt) end
function enemy:frame() enemybase.frame(self);assert(self._wisys,'enemy frame requires _wisys');self._wisys:frame() end
function enemy:take_damage(dmg)if not self.protect then self.hp=self.hp-dmg end end
function Damage(o,dmg)if o.class.base.take_damage then o.class.base.take_damage(o,dmg)end end
item={DropItem=function()end}
boss={base=enemybase,colli=enemybase.colli,take_damage=function(o,dmg)if not o.protect then o.hp=o.hp-dmg end end,card={New=function(name,a,b,duration,hp)return {name=name,duration=duration*60,hp=hp}end}}
function boss.init(o,x,y,name,list)
 o.x,o.y=x,y;o.name=name;o.cards=list;o.cardIndex=1;o.cardTick=0;o._bosssys={render=function()end}
 local card=list[1];o.hp=card.hp;card.init(o)
end
function boss.frame(o)
 o.a,o.b=o.A or 0,o.B or 0
 task.Do(o);o.cardTick=o.cardTick+1
 local card=o.cards[o.cardIndex]
 if o.cardTick>=card.duration or o.hp<=0 then
  card.del(o);o.tasks={};o.cardIndex=o.cardIndex+1;o.cardTick=0
  card=o.cards[o.cardIndex]
  if card then o.hp=card.hp;card.init(o)else Del(o)end
 end
end
stage={group={New=function()end,AddStage=function()end,DefStageFunc=function()end,initTask=task.New},QuitGame=function()end}
default_stage_background=Class(object)
function Stage2HarnessRun(mode)
 local s={};task.New(s,function()Stage2FullRun(s)end)
 local shots,marketUpright=0,0;local snapshots={};local seen={};local t=0;local phaseFrames=0;local lastPhase='';local mystiaShots
 while not Stage2Route.finished and t<50000 do
  task.Do(s)
  local phase=Stage2Route.phase
  if phase~=lastPhase then phaseFrames=0;lastPhase=phase;if phase=='Mystia' then mystiaShots=Stage2Route.shots end end
  phaseFrames=phaseFrames+1
  local todo={};for o in pairs(objects)do todo[#todo+1]=o end
  for _,o in ipairs(todo)do
   if IsValid(o) then
    if mode=='kill' and o.cards and o.cardTick==650 then o.hp=0 end
    if o.class.frame then o.class.frame(o)end
    if IsValid(o)then
     o.x=o.x+(o.vx or 0);o.y=o.y+(o.vy or 0);o.ani=o.ani+1
     assert(o.x==o.x and o.y==o.y,'NaN')
     if o.img then assert(images[o.img],'image missing '..o.img)end
     if o.kind=='market' and o.age>80 then assert(o.rot==0,'market humanoid rotated');marketUpright=marketUpright+1 end
     if o.e or o.cards or o.class==Stage2Route.Seed then assert(o.a>0 and o.b>0,'enemy hitbox lost')end
     if o.class.render then o.class.render(o)end
    end
   end
  end
  if phase=='Mystia' then
   for o in pairs(Stage2Route.enemies)do assert(o.noShot and o.e.t>=5164,'firing enemy during Mystia')end
   assert(Stage2Route.shots==mystiaShots,'fairies fired during Mystia')
  end
  if Stage2FrameSink and phase=='Patchouli passage' and phaseFrames==1000 then Stage2FrameSink('Books and lasers',t,objects,images)end
  if Stage2FrameSink and phaseFrames==200 and not seen[phase] then seen[phase]=true;Stage2FrameSink(phase,t,objects,images)end
  t=t+1
 end
 assert(Stage2Route.finished,'route hung '..Stage2Route.phase..' '..t)
 assert(Stage2Route.human==55 and Stage2Route.sunflowers==14,'substitution count')
 assert(Stage2Route.tailFairies==38 and Stage2Route.tailHumans==19,'tail fairy selection/count')
 assert(Stage2Route.mystiaOverlap>0,'fairies did not overlap Mystia')
 assert(Stage2Route.circleSeeds==20 and Stage2Route.laserRounds==15,'extended circle/corner round count')
 assert(Stage2Route.lasers==45,'three laser burst coverage '..tostring(Stage2Route.lasers))
 assert(Stage2Route.spawns==158,'source spawn count '..Stage2Route.spawns)
 assert(Stage2Route.tangentChecks>1000,'rice tangent coverage')
 assert(marketUpright>1000,'market upright coverage')
 assert(Stage2HarnessMusic['s2.dark-road'].state=='playing','stage BGM not playing')
 Stage2FullAPI.clean()
 assert(Stage2HarnessMusic['s2.dark-road'].state=='stopped','BGM leaked after cleanup')
 for o in pairs(objects)do assert(not o.cards and not o.kind,'attack leaked after cleanup')end
 return string.format('{"mode":"%s","frames":%d,"route_spawns":%d,"human_fairies":%d,"sunflowers":%d,"route_shots":%d,"rice_tangent_checks":%d,"market_upright_checks":%d}',mode,t,Stage2Route.spawns,Stage2Route.human,Stage2Route.sunflowers,Stage2Route.shots,Stage2Route.tangentChecks,marketUpright),table.concat(prints,'\n')
end

Stage2HarnessMusic={}
function LoadMusic(name,path,ending,length)
 assert(Stage2FileExists(path) and ending>length and length>0)
 Stage2HarnessMusic[name]={state='stopped',ending=ending,length=length}
end
function PlayMusic(name,volume)assert(Stage2HarnessMusic[name]);Stage2HarnessMusic[name].state='playing'end
function StopMusic(name)assert(Stage2HarnessMusic[name]);Stage2HarnessMusic[name].state='stopped'end
function EnumRes(kind)local names={};if kind=='bgm'then for name in pairs(Stage2HarnessMusic)do names[#names+1]=name end end;return {},names end

function GetMusicState(name)return Stage2HarnessMusic[name].state end
function PauseMusic(name)Stage2HarnessMusic[name].state='paused'end
function ResumeMusic(name)Stage2HarnessMusic[name].state='playing'end
ext=ext or {};ext.pausemenu={PauseSound=function(self)self.bgmlist={}end,ResumeSound=function()end}
