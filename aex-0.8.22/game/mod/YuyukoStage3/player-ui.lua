-- Existing THlib UI copied locally with only Power-row draws omitted.
local function hiddenInfo1(self)
    local w = lstg.world
    local RenderImgList = {
        { "line_1", 109 + w.scrr, 419, 0, 1, 1 },
        { "line_2", 109 + w.scrr, 397, 0, 1, 1 },
        { "line_3", 109 + w.scrr, 349, 0, 1, 1 },
        { "line_4", 109 + w.scrr, 311, 0, 1, 1 },
        { "line_5", 109 + w.scrr, 247, 0, 1, 1 },
        { "line_6", 109 + w.scrr, 224, 0, 1, 1 },
        { "line_7", 109 + w.scrr, 202, 0, 1, 1 },
        { "hint.hiscore", 12 + w.scrr, 425, 0, 1, 1 },
        { "hint.score", 12 + w.scrr, 403, 0, 1, 1 },
        { "hint.Pnumber", 12 + w.scrr, 371, 0, 1, 1 },
        { "hint.Bnumber", 12 + w.scrr, 334, 0, 1, 1 },
        { "hint.Cnumber", 138 + w.scrr, 316, 0, 0.85, 0.85 },
        { "hint.Cnumber", 138 + w.scrr, 354, 0, 0.85, 0.85 },
        { "hint.point", 39 + w.scrr, 230, 0, 0.5, 0.5 },
        { "hint.graze", 54 + w.scrr, 208, 0, 0.5, 0.5 }
    }
    local s = stage.current_stage
    local timer = s.timer
    local alplat
    if (lstg.var.is_parctice or s.number == 1) and timer < 448 then
        local alpharate = 4
        local alphatrate = 1
        local timerrate = 3
        local y0 = 448 - timer * timerrate
        local dyt = max(300 - y0, 0)
        for i = 1, #RenderImgList do
            local p1, p2, p3, p4, p5, p6 = unpack(RenderImgList[i])
            local dy = max(p3 - y0, 0)
            local alpha = min(dy * alpharate, 255)
            local dw = 1
            if string.find(p1, "line_") then
                dw = alpha / 255
            end
            SetImageState(p1, "", Color(alpha, 255, 255, 255))
            Render(p1, p2, p3, p4, p5 * dw, p6)
        end
        alplat = min(dyt * alphatrate, 255)
    else
        for i = 1, #RenderImgList do
            local p1, p2, p3, p4, p5, p6 = unpack(RenderImgList[i])
            SetImageState(p1, "", Color(255, 255, 255, 255))
            Render(p1, p2, p3, p4, p5, p6)
        end
        alplat = 255
    end
    SetFontState("score3", "", Color(alplat, 173, 173, 173))
    RenderScore("score3", max(lstg.tmpvar.hiscore or 0, self.score or 0), 216 + w.scrr, 436, 0.43, "right")
    SetFontState("score3", "", Color(alplat, 255, 255, 255))
    RenderScore("score3", self.score or 0, 216 + w.scrr, 414, 0.43, "right")
    RenderText("score3", string.format("%d/5", lstg.var.chip), 214 + w.scrr, 361, 0.35, "right")
    RenderText("score3", string.format("%d/5", lstg.var.bombchip), 214 + w.scrr, 323, 0.35, "right")
    SetFontState("score1", "", Color(alplat, 205, 102, 0))
    SetFontState("score2", "", Color(alplat, 34, 216, 221))
    RenderScore("score2", lstg.var.pointrate, 204 + w.scrr, 239, 0.4, "right")
    SetFontState("score3", "", Color(alplat, 173, 173, 173))
    RenderText("score3", string.format("%d", lstg.var.graze), 204 + w.scrr, 216, 0.4, "right")
    SetImageState("hint.life", "", Color(alplat, 255, 255, 255))
    for i = 1, 8 do
        Render("hint.life", 89 + w.scrr + 13 * i, 371, 0, 1, 1)
    end
    SetImageState("hint.lifeleft", "", Color(alplat, 255, 255, 255))
    for i = 1, lstg.var.lifeleft do
        Render("hint.lifeleft", 89 + w.scrr + 13 * i, 371, 0, 1, 1)
    end
    SetImageState("hint.bomb", "", Color(alplat, 255, 255, 255))
    for i = 1, 8 do
        Render("hint.bomb", 89 + w.scrr + 13 * i, 334, 0, 1, 1)
    end
    SetImageState("hint.bombleft", "", Color(alplat, 255, 255, 255))
    for i = 1, lstg.var.bomb do
        Render("hint.bombleft", 89 + w.scrr + 13 * i, 334, 0, 1, 1)
    end
    local Lchip = lstg.var.chip
    if Lchip > 0 and Lchip < 5 and lstg.var.lifeleft < 8 then
        SetImageState("lifechip" .. Lchip, "", Color(alplat, 255, 255, 255))
        Render("lifechip" .. Lchip, 89 + w.scrr + 13 * (lstg.var.lifeleft + 1), 371, 0, 1, 1)
    end
    local Bchip = lstg.var.bombchip
    if Bchip > 0 and Bchip < 5 and lstg.var.bomb < 8 then
        SetImageState("bombchip" .. Bchip, "", Color(alplat, 255, 255, 255))
        Render("bombchip" .. Bchip, 89 + w.scrr + 13 * (lstg.var.bomb + 1), 334, 0, 1, 1)
    end
    SetFontState("score3", "", Color(alplat, 173, 173, 173))
    RenderScore("score3", max(lstg.tmpvar.hiscore or 0, self.score or 0), 216 + w.scrr, 436, 0.43, "right")
    SetFontState("score3", "", Color(alplat, 255, 255, 255))
    RenderScore("score3", self.score or 0, 216 + w.scrr, 414, 0.43, "right")
    RenderText("score3", string.format("%d/5", lstg.var.chip), 214 + w.scrr, 361, 0.35, "right")
    RenderText("score3", string.format("%d/5", lstg.var.bombchip), 214 + w.scrr, 323, 0.35, "right")
    SetFontState("score1", "", Color(alplat, 205, 102, 0))
    SetFontState("score2", "", Color(alplat, 34, 216, 221))
    RenderScore("score2", lstg.var.pointrate, 204 + w.scrr, 239, 0.4, "right")
    SetFontState("score3", "", Color(alplat, 255, 255, 255))
    RenderText("score3", string.format("%d", lstg.var.graze), 204 + w.scrr, 216, 0.4, "right")
end
local function hiddenInfo2(self)
    RenderText("score", "HiScore", 8, 520, 0.5, "left", "top")
    RenderText("score",
            string.format("%d", max(lstg.tmpvar.hiscore or 0, lstg.var.score)),
            190, 520, 0.5, "right", "top")
    RenderText("score", "Score", 206, 520, 0.5, "left", "top")
    RenderText("score",
            string.format("%d", lstg.var.score),
            388, 520, 0.5, "right", "top")
    SetFontState("score", "", Color(0xFFFF4040))

    SetFontState("score", "", Color(0xFF40FF40))
    RenderText("score",
            string.format("%d", lstg.var.faith),
            84, 496, 0.5, "left", "top")
    SetFontState("score", "", Color(0xFF4040FF))
    RenderText("score",
            string.format("%d", lstg.var.pointrate),
            160, 496, 0.5, "left", "top")
    SetFontState("score", "", Color(0xFFFFFFFF))
    RenderText("score",
            string.format("%d", lstg.var.graze),
            236, 496, 0.5, "left", "top")
    RenderText("score",
            string.rep("*", max(0, lstg.var.lifeleft)),
            388, 496, 0.5, "right", "top")
    RenderText("score",
            string.rep("*", max(0, lstg.var.bomb)),
            380, 490, 0.5, "right", "top")
end
local old1,old2=lstg.lstg_ui.drawInfo1,lstg.lstg_ui.drawInfo2
function lstg.lstg_ui:drawInfo1(...)
 if Y3Player.locked() then return hiddenInfo1(self) end
 return old1(self,...)
end
function lstg.lstg_ui:drawInfo2(...)
 if Y3Player.locked() then return hiddenInfo2(self) end
 return old2(self,...)
end
