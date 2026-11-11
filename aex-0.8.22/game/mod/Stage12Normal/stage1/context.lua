local G=dofile('mod/Stage12Normal/stage1/context-geometry.lua')
CopyImage('abyss.context.line','white')
local A={owned={},impacts={},tick=-1,phase=0,local_tick=0,finished=false,stats={}}
local function valid(o) return IsValid(o) end
local function count_owned()
    local n=0; for o in pairs(A.owned) do if valid(o) then n=n+1 end end; return n
end
local function clear()
    for o in pairs(A.owned) do if valid(o) then Del(o) end end
    A.owned={}
end
local echo_speed_scale=2/3
local field
local Shot=Class(bullet)
local styles={arrow=arrow_small,rice=grain_b,round=ball_small,big=ball_huge,scale=grain_a}
local function emit(x,y,speed,angle,style,color,mode,options)
    return New(Shot,x,y,speed,angle,style or 'rice',color or COLOR_BLUE,mode or 'linear',options or {})
end
function Shot:init(x,y,speed,angle,style,color,mode,opt)
    Stage12FireSound('tan00',x)
    bullet.init(self,styles[style],color,false,true); bullet.skip_fade_in(self)
    Stage12Art.bullet(self,'arrow',color)
    self.x,self.y,self.rot=x,y,angle
    self.travel_x,self.travel_y=speed*cos(angle),speed*sin(angle)
    self.mode,self.opt,self.age=mode,opt,0
    self.bound=false; self.colli=opt.colli~=false
    A.owned[self]=true; A.stats.spawned=A.stats.spawned+1;self.serial=A.stats.spawned
end
function Shot:frame()
    local nx,ny
    if self.opt.echo and self.age<120 then
        self.echo_speed=self.echo_speed+echo_speed_scale/60
        local a=math.atan2(self.travel_y,self.travel_x)
        self.travel_x,self.travel_y=self.echo_speed*math.cos(a),self.echo_speed*math.sin(a)
    end
    if self.mode=='linear' then
        self.vx,self.vy=self.travel_x,self.travel_y
    elseif self.mode=='echo' then
        local ct=(A.local_tick-G.echo_start)%G.echo_period
        if ct>=G.echo_capture then
            self.mode='linear'; Stage12Art.bullet(self,'arrow',COLOR_CYAN)
            self._index,self.index=COLOR_CYAN,4
            self.vx,self.vy=self.travel_x,self.travel_y
        else
            local r=field(A.local_tick)
            local hits
            nx,ny,self.travel_x,self.travel_y,hits=G.bounce(self.x,self.y,self.travel_x,self.travel_y,r)
            self.vx,self.vy=nx-self.x,ny-self.y
            self.rot=math.atan2(self.travel_y,self.travel_x)*180/math.pi
            A.stats.bounces=A.stats.bounces+hits
            if hits>0 then
                Stage12Art.bullet(self,'arrow',COLOR_PURPLE)
                self._index,self.index=COLOR_PURPLE,2
                if #A.impacts<64 then A.impacts[#A.impacts+1]={x=nx,y=ny,t=A.local_tick} end
            end
            if setting.abyss_test then assert(nx>=r.l and nx<=r.r and ny>=r.b and ny<=r.t,'echo outside shrinking field') end
        end
    end
    self.age=self.age+1
    if self.mode~='whale' and self.mode~='boundary' then
        if ((not self.opt.echo or self.mode=='echo') and self.age>(self.opt.life or 480)) or (self.age>30 and (math.abs(self.x)>250 or self.y>280 or self.y< -280)) then Del(self) end
    end
end
function Shot:del() A.owned[self]=nil; A.stats.deleted=A.stats.deleted+1; bullet.del(self) end
function Shot:kill() A.owned[self]=nil; A.stats.killed=A.stats.killed+1; bullet.kill(self) end
local function start_context()
    A.impacts={}
end
field=function(t)
 return G.echo_rect(math.max(0,t-G.echo_start))
end
local function release(r)
    local count=0
    for b in pairs(A.owned) do
        if valid(b) and b.mode=='echo' then
            b.mode='linear';Stage12Art.bullet(b,'arrow',COLOR_CYAN)
            b._index,b.index=COLOR_CYAN,4
            b.rot=math.atan2(b.travel_y,b.travel_x)*180/math.pi
            count=count+1
        end
    end
    if count>0 then Stage12FireSound('tan01',0) end
    A.stats.release_count=count
end
local function context(o,t)
    -- BossCard1: movePosTime(60,4,0,144), then hold the emitter at the boss.
    if t<60 then
        local u=1-(1-(t+1)/60)^2
        o.x=A.originX*(1-u);o.y=A.originY+(80-A.originY)*u
    else o.x,o.y=0,80 end
    A.emitterX,A.emitterY=o.x,o.y
    if t<G.echo_start then return end
    local ct=(t-G.echo_start)%G.echo_period
    local cycle=math.floor((t-G.echo_start)/G.echo_period)
    if ct==0 then
        A.impacts={};A.stats.echo_cycles=A.stats.echo_cycles+1
        print('ABYSS ECHO CYCLE '..cycle..' tick='..A.tick)
    end
    for i=#A.impacts,1,-1 do if t-A.impacts[i].t>16 then table.remove(A.impacts,i) end end
    if ct>=40 and ct<=220 and (ct-40)%30==0 then
        local wave=(ct-40)/30
        local r=field(t)
        for i=0,G.echo_count-1 do
            local b=emit(o.x,o.y,(1.2+0.3*wave)*echo_speed_scale,G.echo_angle(cycle,wave,i),'arrow',COLOR_BLUE,'echo',{life=400,echo=true})
            b.echo_speed=(1.2+0.3*wave)*echo_speed_scale
        end
        A.stats.echo_arcs=A.stats.echo_arcs+1
        print('ABYSS ECHO ARC cycle='..cycle..' wave='..wave..' count='..G.echo_count..' tick='..A.tick)
    end
    if ct==G.echo_capture then
        release(field(t))
        A.stats.echo_releases=A.stats.echo_releases+1
        print('ABYSS ECHO RELEASE cycle='..cycle..' tick='..A.tick)
    end
end
local function render_context()
    if A.phase~=3 or A.local_tick<G.echo_start then return end
    local ct=(A.local_tick-G.echo_start)%G.echo_period
    if ct>=G.echo_capture then return end
    local r=field(A.local_tick)
    local u=math.min(ct/G.echo_capture,1)
    local alpha=255
    local function border(p,a,thickness)
        SetImageState('abyss.context.line','',Color(a,185,245,255))
        RenderRect('abyss.context.line',p.l-thickness,p.r+thickness,p.b-thickness,p.b+thickness)
        RenderRect('abyss.context.line',p.l-thickness,p.r+thickness,p.t-thickness,p.t+thickness)
        RenderRect('abyss.context.line',p.l-thickness,p.l+thickness,p.b,p.t)
        RenderRect('abyss.context.line',p.r-thickness,p.r+thickness,p.b,p.t)
    end
    -- Two faint data rails are decoration; only the central edge reflects shots.
    for _,offset in ipairs({6,12}) do border({l=r.l-offset,r=r.r+offset,b=r.b-offset,t=r.t+offset},math.floor(alpha*0.22),0.55) end
    border(r,80,5.5) -- Soft outer glow, without changing collision bounds.
    border(r,alpha,2.8) -- Bright core, 5.6 pixels thick.
    SetImageState('abyss.context.line','',Color(alpha,120,220,255))
    for _,x in ipairs({r.l,r.r}) do
        for _,y in ipairs({r.b,r.t}) do
            RenderRect('abyss.context.line',x-4,x+4,y-4,y+4)
        end
    end
    for _,p in ipairs(A.impacts) do
        local age=A.local_tick-p.t
        if age>=0 and age<=16 then
            local size=3+age*0.3
            SetImageState('abyss.context.line','',Color(math.floor(220*(1-age/17)),170,235,255))
            RenderRect('abyss.context.line',p.x-size,p.x+size,p.y-1.4,p.y+1.4)
            RenderRect('abyss.context.line',p.x-1.4,p.x+1.4,p.y-size,p.y+size)
        end
    end
    RenderText('menu',ct<G.echo_capture and 'CONTRACT / ECHO' or 'RELEASE',r.l+4,r.t+12,0.22,'left')
end

local function reset()
 clear();A.phase=3;A.local_tick=0;A.tick=0;A.impacts={};A.carrier=nil
 A.stats={spawned=0,deleted=0,killed=0,bounces=0,echo_cycles=0,echo_arcs=0,echo_releases=0}
end
Stage1Context={Shot=Shot,clean=function() clear();A.phase=0;A.impacts={} end,render=render_context,state=A}
function Stage1Context.card()
 local c=boss.card.New('长上下文结界',1,2,40,1000,{5,5,0},false)
 c.stage12TransitionY=80
 c.init=function(o)
  th14.clean_bullets();th14.clean_actors();reset();o.stage12ContextReward=false;A.originX,A.originY=o.x,o.y;th14.stats.phases=th14.stats.phases+1
  th14.label='Long Context Barrier';o.th14_phase='context'
  print('TH14 PHASE START context frame='..th14.stage_frames)
  task.New(o,function()
   for t=0,2399 do A.local_tick=t;A.tick=t;context(o,t);task.Wait(1) end
  end)
 end
 c.del=function(o)
  Stage1Context.clean();if not o.stage12ContextReward then o.stage12ContextReward=true;New(item_bomb,o.x,o.y)end;th14.stats.ended=th14.stats.ended+1
  print('TH14 PHASE END context frame='..th14.stage_frames..' arcs='..A.stats.echo_arcs..' releases='..A.stats.echo_releases)
 end
 return c
end

if setting.stage12_context_probe then
 local after=AfterFrame;local finished=false
 AfterFrame=function(...)
  after(...)
  if not finished and A.phase==3 and A.local_tick>=416 then
   finished=true;print('CONTEXT NATIVE FOLLOW/RELEASE PASS count='..(A.stats.release_count or 0));stage.Set('stage.quit')
  end
 end
 local render=RenderFunc;local seen={}
 RenderFunc=function()
  render()
  if A.phase~=3 then return end
  for _,t in ipairs({300,320,360,400})do
   if A.local_tick>=t and not seen[t]then seen[t]=true;lstg.Snapshot('userdata/snapshot/context-follow-'..t..'.jpg')end
  end
 end
end
