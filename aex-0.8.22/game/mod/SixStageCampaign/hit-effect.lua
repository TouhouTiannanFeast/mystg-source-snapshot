-- Campaign-only reproduction of the original player-shot hit reactions.
-- The campaign's main/piercing player is TH10 Reimu B (Stage12Normal and the
-- Yuyuko/HSoB copies all load TH10 pl00.png and TH10 Reimu B rows), while the
-- high-speed homing option is the TH13 ofuda. Needles and ofuda therefore use
-- different source effects:
--   main shot   TH10 pl00.anm script6, sprites25..27, row144, 30 frames
--   needle      TH10 pl00.anm script12, the needle sprite itself, 20 frames
--   ofuda       TH13 pl00.anm script12/13, sprites32..34, row160, 30 frames
-- The campaign PNGs are byte-identical crops of the original atlases; source
-- mods are loaded and used unchanged.
SixStageCampaignHit = { active = {}, count = 0 }
local H = SixStageCampaignHit
local C = SixStageCampaign

local function loadFileSet(prefix, files)
    local images = {}
    for i, file in ipairs(files) do
        local image = prefix .. (i - 1)
        LoadTexture(image, 'mod/SixStageCampaign/art/' .. file)
        LoadImage(image, image, 0, 0, 16, 16, 8, 8)
        SetImageState(image, '', Color(255, 255, 255, 255))
        images[i] = image
    end
    return images
end
local function loadAtlasSet(prefix, texture, columns)
    local images = {}
    for i, x in ipairs(columns) do
        local image = prefix .. (i - 1)
        LoadImage(image, texture, x, 144, 16, 16, 8, 8)
        SetImageState(image, '', Color(255, 255, 255, 255))
        images[i] = image
    end
    return images
end

local hit10Main = loadFileSet('six.hit10.', {
    'th10-hit-0.png', 'th10-hit-1.png', 'th10-hit-2.png'
})
local hit13Ofuda = loadFileSet('six.hit13.', {
    'th13-hit-0.png', 'th13-hit-1.png', 'th13-hit-2.png'
})
LoadTexture('six.th13atlas', 'mod/YuyukoStage3/art/player/th13-pl00.png')
local hit13Main = loadAtlasSet('six.hit13m.', 'six.th13atlas', { 16, 32, 48 })
LoadTexture('six.needle', 'mod/SixStageCampaign/art/th10-needle.png')
LoadImage('six.needle', 'six.needle', 0, 0, 64, 8, 32, 4)
SetImageState('six.needle', '', Color(192, 255, 255, 255))
H.mainImages = hit10Main
H.ofudaImages = hit13Ofuda

local function track(o)
    H.active[o] = true
    H.count = H.count + 1
end
local function untrack(o)
    if H.active[o] then
        H.active[o] = nil
        H.count = H.count - 1
    end
end

local ImageSpark = Class(object)
function ImageSpark:init(x, y, vx, vy, images)
    self.x, self.y = x, y
    self.vx, self.vy = vx or 0, vy or 0
    self.images = images
    self.group, self.layer, self.bound, self.colli = GROUP_GHOST, LAYER_PLAYER_BULLET + 1, false, false
    self.life = 30
    track(self)
end
function ImageSpark:frame()
    if self.timer >= self.life then Del(self) end
end
function ImageSpark:render()
    local image = self.images[math.min(3, math.floor(self.timer / 10) + 1)]
    SetImageState(image, '', Color(255, 255, 255, 255))
    Render(image, self.x, self.y, 0, 1, 1)
end
function ImageSpark:del()
    untrack(self)
end

-- A short contact flash, rather than an opaque stationary30f tile. The original
-- three TH13 sprites are retained; timing/fade are a campaign presentation edit.
local OfudaSpark = Class(object)
function OfudaSpark:init(x,y,rot)
    self.x,self.y,self.rot=x,y,rot or 0
    self.vx,self.vy=0,0
    self.group,self.layer,self.bound,self.colli=GROUP_GHOST,LAYER_PLAYER_BULLET+1,false,false
    self.images,self.life=hit13Ofuda,12
    track(self)
end
function OfudaSpark:frame()
    if self.timer>=self.life then Del(self)end
end
function OfudaSpark:render()
    local t=math.min(1,self.timer/self.life)
    local image=self.images[math.min(3,math.floor(self.timer/4)+1)]
    local alpha=math.floor(224*(1-t)*(1-t))
    local scale=.75+.35*t
    SetImageState(image,'mul+add',Color(alpha,255,224,240))
    Render(image,self.x,self.y,self.rot,scale,scale)
end
function OfudaSpark:del()untrack(self)end

local NeedleSpark = Class(object)
function NeedleSpark:init(x, y, vx, vy, rot)
    self.x, self.y = x, y
    self.vx, self.vy = vx or 0, vy or 0
    self.rot = rot or 0
    self.group, self.layer, self.bound, self.colli = GROUP_GHOST, LAYER_PLAYER_BULLET + 1, false, false
    self.life = 20
    track(self)
end
function NeedleSpark:frame()
    if self.timer >= self.life then Del(self) end
end
function NeedleSpark:render()
    local alpha = 192
    if self.timer >= 10 then
        alpha = math.max(0, math.floor(192 * (1 - (self.timer - 10) / 10)))
    end
    -- Use the campaign's own needle image. Never touch stage12.pierce /
    -- y3.player.pierce: those names are shared with the live needle bullets,
    -- and changing their global image state made later needles invisible.
    SetImageState('six.needle', '', Color(alpha, 255, 255, 255))
    Render('six.needle', self.x, self.y, self.rot, 1, 1)
end
function NeedleSpark:del()
    untrack(self)
end

local function isProtected(enemy)
    if enemy.protect == true then return true end
    if type(enemy.protect) == 'number' and enemy.protect > 0 then return true end
    if type(enemy.invuln) == 'number' and enemy.invuln > 0 then return true end
    if enemy.dmg_factor == 0 then return true end
    if enemy.data and (enemy.data.dead or enemy.data.visible == false) then return true end
    return false
end

local function hitMode(shot)
    if shot.img == 'hs5.player.charm' then return 'ofuda' end
    if shot.y3Piercing or shot.stage12Piercing or shot.killflag then return 'needle' end
    if type(shot.img) == 'string' and shot.img:match('%.pierce$') then return 'needle' end
    return 'main'
end

local function shouldSpark(enemy, shot)
    if not shot or shot.group ~= GROUP_PLAYER_BULLET then return nil end
    if not shot.dmg or shot.dmg <= 0 then return nil end
    if not enemy or (enemy.group ~= GROUP_ENEMY and enemy.group ~= GROUP_NONTJT) then return nil end
    if not enemy.hp or enemy.hp <= 0 then return nil end
    -- MarisaMixed already owns its source hit spark/mask; do not double it.
    if enemy.mmPhaseAge ~= nil then return nil end
    if isProtected(enemy) then return nil end
    local hits = shot.sixHitSparks
    if not hits then
        hits = setmetatable({}, { __mode = 'k' })
        shot.sixHitSparks = hits
    end
    if hits[enemy] then return nil end
    hits[enemy] = true
    return hitMode(shot)
end

local function spawn(mode, shot)
    if H.count >= 96 then return end
    local vx, vy = (shot.vx or 0) * 0.125, (shot.vy or 0) * 0.125
    if mode == 'needle' then
        New(NeedleSpark, shot.x, shot.y, vx, vy, shot.rot)
    elseif mode == 'ofuda' then
        New(OfudaSpark, shot.x, shot.y, shot.rot)
    else
        New(ImageSpark, shot.x, shot.y, vx, vy, H.mainImages)
    end
end

local function wrap(class)
    local original = rawget(class, 'colli')
    if type(original) ~= 'function' then return end
    class.colli = function(self, other)
        local mode = shouldSpark(self, other)
        if mode then spawn(mode, other) end
        return original(self, other)
    end
end

-- The source homing bullet owns a pink TH13 charm effect. Replace only that
-- hit effect: campaign ofuda sparks are drawn by the collision wrapper.
local function suppressHomingEffect()
    local P = Y3Player
    local Homing = P and P.Homing
    if Homing and not Homing.sixHitEffectReplaced then
        Homing.sixHitEffectReplaced = true
        Homing.kill = function() end
    end
end

function H.clear()
    for o in pairs(H.active) do
        if IsValid(o) then Del(o) end
    end
    H.active = {}
    H.count = 0
end

function H.install(i, classes)
    H.clear()
    H.mainImages = (i == nil or i <= 2) and hit10Main or hit13Main
    H.ofudaImages = hit13Ofuda
    if i and i >= 3 then suppressHomingEffect() end
    local seen = {}
    local function add(class)
        if class and not seen[class] then
            seen[class] = true
            wrap(class)
        end
    end
    add(enemybase)
    add(enemy)
    add(boss)
    for _, class in ipairs(classes or {}) do
        local base, enemyClass = class, false
        while base do
            if base == enemybase or base == enemy or base == boss then
                enemyClass = true
                break
            end
            base = base.base
        end
        if enemyClass then add(class) end
    end
end

local install = C.install
function C.install(i, classes)
    install(i, classes)
    H.install(i, classes)
end
