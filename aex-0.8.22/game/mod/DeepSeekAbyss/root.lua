-- Independent THlib card. All hazards use native bullet collision/graze/clear behavior.
Include('THlib.lua')
local old_path=package.path
package.path='mod/DeepSeekAbyss/?.lua;'..old_path
local G=require('geometry'); package.path=old_path
CopyImage('abyss.context.line','white')
local points=G.whale_points()
local A={owned={},impacts={},tick=-1,phase=0,local_tick=0,finished=false,stats={}}
local labels={'SONAR RINGS','QUERY TRACKING','CONTEXT / POWER RESONANCE','ABYSSAL MIGRATION'}
local function valid(o) return IsValid(o) end
local function count_owned()
    local n=0; for o in pairs(A.owned) do if valid(o) then n=n+1 end end; return n
end
local function clear()
    for o in pairs(A.owned) do if valid(o) then Del(o) end end
    A.owned={}
end
local Shot=Class(bullet)
local styles={arrow=arrow_small,rice=grain_b,round=ball_small,big=ball_huge,scale=grain_a}
local function emit(x,y,speed,angle,style,color,mode,options)
    return New(Shot,x,y,speed,angle,style or 'rice',color or COLOR_BLUE,mode or 'linear',options or {})
end
function Shot:init(x,y,speed,angle,style,color,mode,opt)
    bullet.init(self,styles[style],color,false,true); bullet.skip_fade_in(self)
    self.x,self.y,self.rot=x,y,angle
    self.travel_x,self.travel_y=speed*cos(angle),speed*sin(angle)
    self.mode,self.opt,self.age=mode,opt,0
    self.bound=false; self.colli=opt.colli~=false
    A.owned[self]=true; A.stats.spawned=A.stats.spawned+1
end
function Shot:frame()
    local nx,ny
    if self.opt.echo and self.age<120 then
        self.echo_speed=self.echo_speed+1/60
        local a=math.atan2(self.travel_y,self.travel_x)
        self.travel_x,self.travel_y=self.echo_speed*math.cos(a),self.echo_speed*math.sin(a)
    end
    if self.mode=='linear' then
        self.vx,self.vy=self.travel_x,self.travel_y
    elseif self.mode=='wall' then
        local k=math.min(self.age,240)*0.20
        nx,ny=self.opt.x-self.opt.side*k,self.opt.y
        self.vx,self.vy=nx-self.x,ny-self.y
    elseif self.mode=='echo' then
        local ct=A.local_tick%G.echo_period
        if ct>=G.echo_capture then
            self.mode='linear'; self.img='arrow_small'..COLOR_CYAN
            self._index,self.index=COLOR_CYAN,4
            self.vx,self.vy=self.travel_x,self.travel_y
        else
            local r=G.echo_rect(A.local_tick)
            local hits
            nx,ny,self.travel_x,self.travel_y,hits=G.bounce(self.x,self.y,self.travel_x,self.travel_y,r)
            self.vx,self.vy=nx-self.x,ny-self.y
            self.rot=math.atan2(self.travel_y,self.travel_x)*180/math.pi
            A.stats.bounces=A.stats.bounces+hits
            if hits>0 then
                self.img='arrow_small'..COLOR_PURPLE
                self._index,self.index=COLOR_PURPLE,2
                if #A.impacts<64 then A.impacts[#A.impacts+1]={x=nx,y=ny,t=A.local_tick} end
            end
            if setting.abyss_test then assert(nx>=r.l and nx<=r.r and ny>=r.b and ny<=r.t,'echo outside shrinking field') end
        end
    elseif self.mode=='whale' then
        local cx,cy=G.pose(A.local_tick)
        local tx,ty=cx+self.opt.u,cy+self.opt.v
        if A.local_tick<120 then
            local k=(A.local_tick+1)/120; k=k*k*(3-2*k)
            nx,ny=self.opt.sx+(tx-self.opt.sx)*k,self.opt.sy+(ty-self.opt.sy)*k
            self.colli=false
        else
            nx,ny=tx,ty; self.colli=true
        end
        self.vx,self.vy=nx-self.x,ny-self.y
        self.rot=180
        if setting.abyss_test then assert(math.abs(self.opt.v-G.seam(self.opt.u))>=G.seam_half,'body filled belly seam') end
    end
    self.age=self.age+1
    if self.mode~='whale' and self.mode~='boundary' then
        if self.age>(self.opt.life or 480) or (self.age>30 and (math.abs(self.x)>250 or self.y>280 or self.y< -280)) then Del(self) end
    end
end
function Shot:del() A.owned[self]=nil; A.stats.deleted=A.stats.deleted+1; bullet.del(self) end
function Shot:kill() A.owned[self]=nil; A.stats.killed=A.stats.killed+1; bullet.kill(self) end
local Mark=Class(object)
function Mark:init(x,y,index)
    self.x,self.y,self.index=x,y,index
    self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_ENEMY_BULLET+1,false,false
    self.age=0; self.created=A.local_tick
    A.owned[self]=true; A.stats.queries=A.stats.queries+1
end
function Mark:frame()
    if self.age==60 then
        assert(A.local_tick-self.created==60,'query warning is not 60 frames')
        for spoke=0,4 do
            for layer=0,2 do emit(self.x,self.y,1.45+0.40*layer,-90+self.index*17+spoke*72,'round',COLOR_BLUE,'linear',{life=360}) end
        end
        A.stats.bursts=A.stats.bursts+1
        print('ABYSS QUERY burst='..A.stats.bursts..' delay=60 tick='..A.tick)
        Del(self); return
    end
    self.age=self.age+1
end
function Mark:render()
    RenderText('menu','?',self.x,self.y,0.55,'centerpoint')
    RenderText('menu',string.format('%.1f',(60-self.age)/60),self.x,self.y-16,0.20,'centerpoint')
end
function Mark:del() A.owned[self]=nil end
function Mark:kill() A.owned[self]=nil end
local function sonar(o,t)
    if t%48==0 then
        local wave=t/48
        for i=0,119 do
            local a=i*3
            if not G.sonar_open(a,wave) then
                emit(o.x,o.y,1.55+0.18*cos(a*2),a,'rice',wave%2==0 and COLOR_BLUE or COLOR_CYAN)
            end
        end
        A.stats.rings=A.stats.rings+1
    end
end
local function boxes(index)
    for _,side in ipairs({-1,1}) do
        local cx=side*174; local left,right=cx-24,cx+24
        local bottom,top=-190,140
        local opening=-115+20*sin(index*60)
        for y=bottom,top,16 do
            for _,x in ipairs({left,right}) do
                local inner=(side==1 and x==left) or (side==-1 and x==right)
                if not inner or math.abs(y-opening)>34 then
                    emit(x,y,0,90,'rice',COLOR_CYAN,'wall',{x=x,y=y,side=side,life=270})
                end
            end
        end
        for x=left+16,right-1,16 do
            for _,y in ipairs({bottom,top}) do emit(x,y,0,0,'rice',COLOR_CYAN,'wall',{x=x,y=y,side=side,life=270}) end
        end
    end
    A.stats.walls=A.stats.walls+1
end
local function query(o,t)
    if t%300==0 then boxes(t/300) end
    if t>=60 and (t-60)%120==0 then New(Mark,player.x,player.y,(t-60)/120) end
end
local function start_context()
    A.impacts={}
end
local function context(o,t)
    local ct=t%G.echo_period
    local cycle=math.floor(t/G.echo_period)
    if ct==0 then
        clear(); A.impacts={}; A.stats.echo_cycles=A.stats.echo_cycles+1
        print('ABYSS ECHO CYCLE '..cycle..' tick='..A.tick)
    end
    for i=#A.impacts,1,-1 do if t-A.impacts[i].t>16 then table.remove(A.impacts,i) end end
    if ct>=40 and ct<=220 and (ct-40)%30==0 then
        local wave=(ct-40)/30
        local r=G.echo_rect(t)
        for i=0,17 do
            local b=emit(o.x,math.min(o.y,r.t-8),1.2+0.3*wave,G.echo_angle(cycle,wave,i),'arrow',COLOR_BLUE,'echo',{life=400,echo=true})
            b.echo_speed=1.2+0.3*wave
        end
        A.stats.echo_arcs=A.stats.echo_arcs+1
        print('ABYSS ECHO ARC cycle='..cycle..' wave='..wave..' count=18 tick='..A.tick)
    end
    if ct==G.echo_capture then
        A.stats.echo_releases=A.stats.echo_releases+1
        print('ABYSS ECHO RELEASE cycle='..cycle..' tick='..A.tick)
    end
end
local function render_context()
    if A.phase~=3 then return end
    local ct=A.local_tick%G.echo_period
    local r=G.echo_rect(A.local_tick)
    local u=math.min(ct/G.echo_capture,1)
    local alpha=ct<G.echo_capture and 155 or math.floor(155*(400-ct)/80)
    local function border(p,a,thickness)
        SetImageState('abyss.context.line','',Color(a,65+math.floor(70*u),170-math.floor(65*u),255))
        RenderRect('abyss.context.line',p.l-thickness,p.r+thickness,p.b-thickness,p.b+thickness)
        RenderRect('abyss.context.line',p.l-thickness,p.r+thickness,p.t-thickness,p.t+thickness)
        RenderRect('abyss.context.line',p.l-thickness,p.l+thickness,p.b,p.t)
        RenderRect('abyss.context.line',p.r-thickness,p.r+thickness,p.b,p.t)
    end
    -- Two faint data rails are decoration; only the central edge reflects shots.
    for _,offset in ipairs({6,12}) do border({l=r.l-offset,r=r.r+offset,b=r.b-offset,t=r.t+offset},math.floor(alpha*0.22),0.55) end
    border(r,alpha,1.1)
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
local function set_whale(o,p)
    o.mode='whale'; o.opt={u=p.u,v=p.v,sx=o.x,sy=o.y}
    o.age=0; o.vx,o.vy=0,0; o.colli=false
    o.imgclass=grain_b; o.img='grain_b'..COLOR_BLUE
    o._index,o.index=COLOR_BLUE,math.floor((COLOR_BLUE+1)/2)
    o.a,o.b,o.rect=2.5,2.5,false
end
local function start_whale(o)
    -- Reuse every surviving context hazard; fill additional body points from Boss.
    local survivors={}
    for b in pairs(A.owned) do if valid(b) then survivors[#survivors+1]=b end end
    table.sort(survivors,function(a,b) return a.id_for_sort<b.id_for_sort end)
    assert(#survivors<=#points,'body capacity exceeded')
    for i,p in ipairs(points) do
        local b=survivors[i] or emit(o.x,o.y,0,0,'rice',COLOR_BLUE,'linear',{colli=false})
        set_whale(b,p)
    end
    A.stats.gathered=#survivors; A.stats.body=#points
    print('ABYSS WHALE gathered='..#survivors..' body='..#points..' seam_half='..G.seam_half)
end
local function whale(o,t)
    if t>=240 and t<=660 and t%60==0 then
        local x,y=G.pose(t)
        for _,sign in ipairs({-1,1}) do
            for i=0,3 do emit(x+170,y+sign*103,1.35+0.16*(i%2),180-sign*(8+i*5),'big',COLOR_BLUE,'linear',{life=240}) end
            for i=0,11 do emit(x+170,y+sign*99,2.10+0.10*(i%3),180-sign*(5+i*2),'scale',COLOR_CYAN,'linear',{life=260}) end
        end
        A.stats.tail=A.stats.tail+1
    end
end
local phase_functions={sonar,query,context,whale}
local selected=tonumber(setting.abyss_phase) or 0
assert(selected>=0 and selected<=4 and selected%1==0,'invalid practice phase')
local first=selected>0 and selected or 1
local duration=selected>0 and 900 or 3600
local card=boss.card.New('鲸符「Deep Seek 深渊回游」',0,0,duration/60,1000000,{0,0,0},false)
card.init=function(o)
    task.New(o,function()
        for elapsed=0,duration-1 do
            local p=selected>0 and selected or math.floor(elapsed/900)+1
            local t=elapsed%900
            A.tick=(p-1)*900+t; A.phase,A.local_tick=p,t
            if t==0 then
                if p~=4 then clear() end
                A.stats.phases=A.stats.phases+1
                print('ABYSS PHASE START '..p..' tick='..A.tick)
                if p==3 then start_context() elseif p==4 then start_whale(o) end
            end
            phase_functions[p](o,t)
            if setting.abyss_test and t==899 then
                if p==1 then assert(A.stats.rings==19,'sonar ring count')
                elseif p==2 then assert(A.stats.queries==7 and A.stats.bursts==7 and A.stats.walls==3,'query/wall counts')
                elseif p==3 then assert(A.stats.bounces>100 and A.stats.echo_arcs==16 and A.stats.echo_releases==2 and A.stats.echo_cycles==3,'echo cycle counts/reflection')
                elseif p==4 then assert(A.stats.body==#points and A.stats.tail==8,'whale body/tail counts') end
                print('ABYSS PHASE PASS '..p..' live='..count_owned()..' bounces='..A.stats.bounces)
            end
            task.Wait(1)
        end
    end)
end
card.del=function()
    clear(); A.finished=true
    assert(next(A.owned)==nil,'card cleanup leaked objects')
    print('ABYSS COMPLETE phases='..A.stats.phases..' rings='..A.stats.rings..' queries='..A.stats.bursts..' bounces='..A.stats.bounces..' body='..A.stats.body..' tail='..A.stats.tail..' killed='..A.stats.killed..' arcs='..A.stats.echo_arcs..' releases='..A.stats.echo_releases..' tick='..A.tick)
end
local Boss=Class(boss)
function Boss:init() boss.init(self,0,140,'DeepSeek',{card},nil,'Lunatic'); self.a,self.b=18,18 end
function Boss:render() self._bosssys:render(); Render('enemy7_'..(math.floor(self.ani/8)%4+1),self.x,self.y) end
local Hud=Class(object)
function Hud:init() self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_TOP,false,false end
function Hud:render()
    render_context()
    RenderText('menu',labels[A.phase] or 'DEEP SEEK / LUNATIC',0,-190,0.27,'centerpoint')
    RenderText('menu','Arrows move / Shift slow / Z shoot / X bomb / Esc retry',0,-208,0.21,'centerpoint')
    if A.phase==4 and A.local_tick<180 then RenderText('menu','BELLY GAP: enter from right, follow left',0,-171,0.25,'centerpoint') end
end
local serial=0
local shot_init=Shot.init
function Shot:init(...)
    shot_init(self,...); serial=serial+1; self.id_for_sort=serial
end
stage.group.New('Lunatic','menu',{lifeleft=8,power=100,bomb=3},true,2)
stage.group.AddStage('Lunatic','Deep Seek@Lunatic',nil,true)
stage.group.DefStageFunc('Deep Seek@Lunatic','init',function(s)
    clear(); A.finished=false; A.tick=-1; A.phase=0; A.local_tick=0; serial=0
    A.stats={spawned=0,deleted=0,killed=0,rings=0,queries=0,bursts=0,walls=0,bounces=0,gathered=0,body=0,tail=0,phases=0,maxlive=0,echo_arcs=0,echo_releases=0,echo_cycles=0}
    if setting.abyss_test then print('ABYSS GEOMETRY PASS points='..G.selftest()) end
    stage.group.initTask(s,function()
        New(default_stage_background); New(Hud); task.Wait(60)
        if setting.abyss_probe then
            player.x,player.y=18,-100; player.protect=1000; player.death=0
            local graze=lstg.var.graze or 0
            emit(0,-100,0,0,'round',COLOR_BLUE,'linear',{life=600})
            task.Wait(3)
            assert((lstg.var.graze or 0)>graze,'native graze missing')
            player.x,player.y=0,-100; player.protect=0; player.death=0
            task.Wait(3)
            assert(player.death>0,'native hit missing')
            print('ABYSS REAL GRAZE/HIT PASS')
            clear(); player.death=0; player.protect=1000
            player.x,player.y=0,-150; player.slow=1
            for i=1,12 do emit(i*5-30,-130,0,0,'rice',COLOR_BLUE,'linear',{life=600}) end
            local killed=A.stats.killed; local bombs=lstg.var.bomb
            player._playersys:spell()
            assert(lstg.var.bomb==bombs-1,'bomb did not consume resource')
            task.Wait(180)
            assert(A.stats.killed>killed,'bomb did not clear owned bullets')
            clear()
            emit(0,-150,0,0,'rice',COLOR_BLUE,'linear',{life=600})
            New(bullet_deleter,0,-150,true)
            task.Wait(120)
            assert(count_owned()==0,'native direct-delete left owned hazards')
            print('ABYSS COMBAT PROBES PASS')
            for key in pairs(A.stats) do A.stats[key]=0 end
            lstg.var.bomb=3; player.x,player.y=0,-176; player.death=0; player.protect=1000
        end
        local b=New(Boss)
        while valid(b) do
            if setting.abyss_test then player.protect=1000 end
            task.Wait(1)
        end
        clear(); task.Wait(120)
    end)
end)
stage.group.DefStageFunc('Deep Seek@Lunatic','del',function() clear(); print('ABYSS STAGE CLEANUP live='..count_owned()) end)
stage_init.frame=function(s)
    if s.timer==30 then
        lstg.var.player_name,lstg.var.rep_player=player_list[1][2],player_list[1][3]
        stage.group.Start('Lunatic')
    end
end
if setting.abyss_test then
    local old_after=AfterFrame
    AfterFrame=function()
        old_after()
        -- Scripted QA evades locked Query locations so the emerging five-way pattern survives.
        -- Manual play has no automatic player movement.
        if A.phase==2 and A.local_tick%120==90 then
            player.x,player.y=(math.floor(A.local_tick/120)%2==0 and 100 or -100),-160
        end
        if A.phase>0 and not A.finished then
            local n=count_owned(); A.stats.maxlive=math.max(A.stats.maxlive,n)
            assert(n<1600,'native object budget exceeded')
        end
    end
    local old_menu=stage_menu.frame
    stage_menu.frame=function(s) old_menu(s); if A.finished and s.timer>=30 then stage.Set('stage.quit') end end
    local captured={}; local old_render=RenderFunc
    RenderFunc=function()
        old_render()
        if A.phase==3 then
            for _,tick in ipairs({210,310,355}) do
                local key='echo-'..tick
                if A.local_tick>=tick and not captured[key] then
                    captured[key]=true
                    local path='userdata/snapshot/abyss-'..selected..'-'..key..'.jpg'
                    lstg.Snapshot(path); print('ABYSS SNAPSHOT '..path)
                end
            end
        end
        local threshold=({400,400,650,420})[A.phase]
        if threshold and A.local_tick>=threshold and not captured[A.phase] then
            captured[A.phase]=true
            local path='userdata/snapshot/abyss-'..selected..'-phase'..A.phase..'.jpg'
            lstg.Snapshot(path); print('ABYSS SNAPSHOT '..path)
        end
    end
    if setting.abyss_fast then
        local old_frame=DoFrame
        DoFrame=function(...) for i=1,4 do old_frame(...) end end
    end
end
