-- Original, short encounter informed by TH10's distinct bullet-action and
-- hit/graze paths. No TH10 stage script or asset is used here.

local wind_enemy = Class(enemybase)

function wind_enemy:init(x, y, drift)
    enemybase.init(self, 32)
    self.x, self.y = x, y
    self.img = "enemy1_1"
    self.a, self.b = 8, 8
    self.bound = false

    task.New(self, function()
        -- Enter, fire four readable fans, then leave the playfield.
        for _ = 1, 55 do
            self.x = self.x + drift * 0.35
            self.y = self.y - 1.2
            task.Wait(1)
        end
        for volley = 1, 4 do
            if IsValid(player) then
                local aimed = Angle(self, player)
                for spoke = -2, 2 do
                    New(straight, grain_b, 3, false,
                        self.x, self.y, 1.35 + volley * 0.12,
                        aimed + spoke * 12)
                end
            end
            task.Wait(42)
        end
        for _ = 1, 85 do
            self.x = self.x + drift * 0.5
            self.y = self.y + 2.2
            task.Wait(1)
        end
        Del(self)
    end)
end

function wind_enemy:frame()
    enemybase.frame(self)
end

function wind_enemy:render()
    Render(self.img, self.x, self.y)
end

stage.group.New("Normal", "menu", { lifeleft = 2, power = 0, bomb = 3 }, true, 2)
stage.group.AddStage("Normal", "Stage 1@Normal", nil, true)

stage.group.DefStageFunc("Stage 1@Normal", "init", function(self)
    stage.group.initTask(self, function()
        New(default_stage_background)
        task.Wait(60)
        New(wind_enemy, -110, 195, 1)
        New(wind_enemy, 110, 195, -1)
        task.Wait(390)
        New(wind_enemy, -140, 195, 1)
        New(wind_enemy, 140, 195, -1)
        task.Wait(390)
        New(wind_enemy, 0, 195, 0)
        -- Allow the final bullets to pass before the stage fades out.
        task.Wait(720)
    end)
end)
