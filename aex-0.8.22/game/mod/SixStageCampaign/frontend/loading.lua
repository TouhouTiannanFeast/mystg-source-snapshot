-- TH10 ascii.anm scripts3..6: original two-line loading art and drifting stars.
local C=SixStageCampaign
local L=stage.New('SixStageLoading',false,true)
function C.load(index,entry)
 C.loadTarget={index=index,entry=entry}
 stage.Set('SixStageLoading','none')
end
function L:init()
 self.age=0;self.presented=0;self.started=os.clock();self.stars={};self.seed=104729
 self.target=assert(C.loadTarget);C.loadTarget=nil;C.frontLoading=self
 C.index=0;C.select=false
 print('SIX LOADING enter')
end
local function random(s)
 s.seed=s.seed*16807%2147483647;return(s.seed-1)/2147483646
end
function L:frame()
 self.age=self.age+1
 if self.age%2==1 then
  local x=(random(self)*2-1)*96+16
  self.stars[#self.stars+1]={age=0,x=x,y=(random(self)*2-1)*16-32,
   dx=(random(self)*2-1)*32,ey=(random(self)*2-1)*16+48,
   size=.2+random(self)*.8,rotation=random(self)*360,spin=(random(self)*2-1)*32,
   grey=63+math.floor(random(self)*193)}
 end
 for i=#self.stars,1,-1 do
  local p=self.stars[i];p.age=p.age+1;if p.age>=60 then table.remove(self.stars,i)end
 end
 -- A short visibility floor is intentional; the already presented loading image
 -- stays on screen while the real source's synchronous resource import executes.
 if self.age>=60 and self.presented>=2 and os.clock()-self.started>=1 then
  print(string.format('SIX LOADING dispatch frames=%d presented=%d elapsed=%.3f',self.age,self.presented,os.clock()-self.started))
  C.begin(self.target.index,self.target.entry)
 end
end
local function ease(t)t=math.max(0,math.min(1,t));return 1-(1-t)^2 end
local function draw(name,x,y,alpha,grey,scale,rotation)
 SetImageState(name,'',Color(math.floor(alpha),grey or 255,grey or 255,grey or 255))
 Render(name,x,480-y,rotation or 0,scale or 1,scale or 1)
end
function L:render()
 SetViewMode('ui');RenderClear(Color(255,0,0,0))
 local x,y=512,416
 for _,p in ipairs(self.stars)do
  local u=p.age/60
  local alpha=255*math.min(1,p.age/10,(60-p.age)/10)
  draw('six.loading.star',x+p.x+p.dx*u,y+p.y+(p.ey-p.y)*u,alpha,p.grey,p.size,p.rotation+p.spin*p.age)
 end
 local age=self.age
 local jp=age<20 and 255*math.min(1,age/8)or 128+127*(1-math.cos(((age-20)%40)*math.pi/20))/2
 local en=255*math.max(0,math.min(1,(age-8)/8))
 if age>=38 then en=128+127*(1-math.cos(((age-38)%60)*math.pi/30))/2 end
 draw('six.loading.jp',x,y,jp)
 draw('six.loading.en',x+128-80*ease((age-8)/4),y+16,en)
 self.presented=self.presented+1
end
