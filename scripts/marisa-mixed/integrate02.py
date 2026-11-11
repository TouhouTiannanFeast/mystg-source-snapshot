"""The exact, private delta over the frozen TH08 host; no gameplay retuning."""
def host02(s):
 changes={
  'self.speed,self.angle=speed,angle; self.age=0':'self.speed,self.angle=speed,angle; self.age=0\n    self.sourceType,self.sourceColor=typ,color',
  'function T.Bullet:del()':'''function T.Bullet:render()
    if TH08Visual02 and TH08Visual02.renderStar(self)then return end
    bullet.render(self)
end
function T.Bullet:del()''',
  'function T.Beam:kill() T.owned[self]=nil; T.phase_objects[self]=nil; laser.kill(self) end':'''function T.Beam:kill() T.owned[self]=nil; T.phase_objects[self]=nil; laser.kill(self) end
function T.Beam:render()
    if self.track_player and TH08Visual02 then TH08Visual02.renderSpark(self);return end
    laser.render(self)
end''',
  'self.x,self.y=owner.x,owner.y; self.protect=true':'self.x,self.y=owner.x,owner.y; self.protect=true; self.homingExcluded=true',
  'self.protect=self.timer<200':'self.protect=true; self.homingExcluded=true',
 }
 for old,new in changes.items():
  assert s.count(old)==1,old
  s=s.replace(old,new)
 return s
