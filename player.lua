local addonName, ns = ...

local Redraw = function(self)
    if not self.model_path then return end

    self:SetModelScale(1)
    self:SetPosition(0,0,0)

    self:SetModel(self.model_path)

    self:SetModelScale(self.model_scale)
    self:SetPosition(self.ox, self.oy, self.oz)
end

local ResetTransformations = function(self)
    -- print(self:GetName(), "hiding", self:GetCameraDistance(), self:GetCameraPosition())
    self:SetModelScale(1)
    self:SetPosition(0,0,0)
end

local MakeModelRegion = function(parent,w,h,model_path, x,y,z, scale)
    local pmf = CreateFrame("PlayerModel", nil, parent )
    pmf:SetSize(w,h)

    pmf.model_scale = scale or 1
    pmf.ox = x
    pmf.oy = y
    pmf.oz = z
    pmf.model_path = model_path

    pmf:SetScript("OnHide", ResetTransformations)
    pmf:SetScript("OnShow", Redraw)
    pmf.Redraw = Redraw
    pmf.ResetTransformations = ResetTransformations
    pmf:Redraw()

    -- local pmf = CreateFrame("Frame", nil, self )
    -- pmf:SetSize(w,h)

    -- local t = pmf:CreateTexture(nil, "ARTWORK", 2)
    -- t:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    -- t:SetVertexColor(0,0,0,0.2)
    -- t:SetAllPoints(pmf)

    return pmf
end

-- [1329848] = "spells/7fx_nightmare_dustcloud_state.m2"
-- [1249924] = "spells/7fx_ghost_red_state.m2"
-- [165539] = "spells/acidburn_red.m2"
-- [1249985] = "spells/7fx_ghost_blue_state.m2"
-- [165535] = "spells/acidburn_blue.m2"
-- [1495845] = "spells/algalonsparkles.m2"
-- [166003] = "spells/enchantments/greenflame_low.m2"
-- [165995] = "spells/enchantments/blueflame_low.m2"
-- [166008] = "spells/enchantments/purpleflame_low.m2"
-- [166011] = "spells/enchantments/redflame_low.m2"
-- [654832] = "spells/Holy_precast_med_hand_simple.m2"

local vialSettings = {
    HEALTH = {
        color = {0.5, 0, 0},
        darkSmoke = 1329848,
        ambientSmoke = 1249924,
        ambientSmoke2 = 166692,
        bigBubbles = 165539,
    },
    MANA = {
        color = {0.2, 0, 0.7},
        -- darkSmoke = 1329848
        ambientSmoke = 1249985,
        ambientSmoke2 = 166672,
        bigBubbles = 165535,
        -- lightSmoke = 166808,-- "spells/shadow_precast_med_base.m2",
    },
}

local function MakeVial(parent, width, height, powerType)
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(height)
    f:SetWidth(width)

    local t = f:CreateTexture(nil, "ARTWORK", 0)
    t:SetTexture([[Interface\AddOns\oUF_NugVials\vialLiquid.tga]])
    t:SetAllPoints(f)

    local opts = vialSettings[powerType]
    if not opts then return end
    t:SetVertexColor(unpack(opts.color))

    -- I found out that only the first PlayerModel child will be clipped by scroll frame

    -- if opts.lightSmoke then
    --     local lightSmoke = MakeModelRegion(f, width, height*0.7, opts.lightSmoke, 0,0,0 )
    --     lightSmoke:SetPoint("BOTTOM", f, "BOTTOM", 0,-15)
    -- end

    if opts.darkSmoke then
        local darkSmoke = MakeModelRegion(f, width, height*0.7, opts.darkSmoke, -8.6, 0, -5.1 )
        darkSmoke:SetPoint("BOTTOM", f, "BOTTOM", 0,-15)
    end

    local ambientSmoke = MakeModelRegion(f, width-4, height*0.9, opts.ambientSmoke, 0,0,1 )
    ambientSmoke:SetPoint("TOP", f, "TOP", 0, 0)

    if opts.ambientSmoke2 then
        local ambientSmoke2 = MakeModelRegion(f, width-4, height*1.3, opts.ambientSmoke2, 0,0,0 )
        ambientSmoke2:SetPoint("TOP", f, "TOP", 0, 0)
    end

    local smallBubbles1 = MakeModelRegion(f, width*0.8, height*0.5, 1495845, 0,0,0 )
    smallBubbles1:SetPoint("TOP", f, "TOP", 0, 0)

    local smallBubbles2 = MakeModelRegion(f, width*0.8, height*0.5, 1495845, 0,0,0 )
    smallBubbles2:SetPoint("TOP", f, "TOP", 0, -height*0.3)


    -- local bigBubbles1 = MakeModelRegion(f, width-2, height*0.8, opts.bigBubbles, -20, 0, -4.6 )
    -- bigBubbles1:SetPoint("TOP", f, "TOP", 0, -height*0.1)

    local bigBubbles2 = MakeModelRegion(f, width-2, height*0.8, opts.bigBubbles, -20, 0, -4.6 )
    bigBubbles2:SetPoint("TOP", f, "TOP", 0, height*0.2)


    local spark = f:CreateTexture(nil, "ARTWORK", 4)
    spark:SetBlendMode("ADD")
    spark:SetTexture([[Interface\AddOns\oUF_NugVials\vialSpark.tga]])
    spark:SetSize(width, width)

    spark:SetPoint("CENTER", f, "TOP",0,0)
    spark:SetVertexColor(unpack(opts.color))

    return f
end

local ScrollFrameSetValue = function(self, cur)
    local max = self._max
    local min = self._min
    self._cur = cur
    local total = (max - min)
    local v = 0
    if total ~= 0 then
        v = (cur - min) / total
    end
    if v > 1 then v = 1 end
    if v <= 0 then v = 0.001 end
    local H = self._height
    v = 1 - v
    local h = v*H
    -- print(h, 1-h, -(1-h))
    self:SetVerticalScroll(-h)
    -- self:SetHeight(h)
end

local ScrollFrameSetMinMaxValues = function(self, min, max)
    self._min = min
    self._max = max
end

local ScrollFrameGetMinMaxValues = function(self)
    return self._min, self._max
end
local ScrollFrameGetValue = function(self)
    return self._cur or 0
end
local ScrollFrameSetStatusBarTexture = function() end

local function MakeVialBar(root)
    -- The root is the top level frame object
    local m = 0.45

    root:SetWidth(170*m)
    root:SetHeight(110*m)


    local bg = root:CreateTexture(nil, "BACKGROUND")
    bg:SetWidth(256*m)
    bg:SetHeight(128*m)
    bg:SetTexture([[Interface\AddOns\oUF_NugVials\vialTreeBG.tga]])
    bg:SetPoint("BOTTOM", root, "BOTTOM",0,0)

    local healthWidth = 36
    local manaWidth = 26
    local healthHeight = 154

	local scrollframeHealth = CreateFrame("ScrollFrame", "oUF_NugVialsHealthScroll", root)

    scrollframeHealth._height = healthHeight
    scrollframeHealth.SetValue = ScrollFrameSetValue
    scrollframeHealth.SetMinMaxValues = ScrollFrameSetMinMaxValues
    scrollframeHealth.GetMinMaxValues = ScrollFrameGetMinMaxValues
    scrollframeHealth.GetValue = ScrollFrameGetValue
    scrollframeHealth.SetStatusBarTexture = ScrollFrameSetStatusBarTexture

    local health = MakeVial(scrollframeHealth, healthWidth, healthHeight, "HEALTH")
    scrollframeHealth:SetScrollChild(health)
    scrollframeHealth:SetSize(healthWidth, healthHeight)
    scrollframeHealth:SetPoint("BOTTOM", root , "BOTTOM", -15, 10)


    local scrollframeMana = CreateFrame("ScrollFrame", nil, root)

    scrollframeMana._height = healthHeight
    scrollframeMana.SetValue = ScrollFrameSetValue
    scrollframeMana.SetMinMaxValues = ScrollFrameSetMinMaxValues
    scrollframeMana.GetMinMaxValues = ScrollFrameGetMinMaxValues
    scrollframeMana.GetValue = ScrollFrameGetValue
    scrollframeMana.SetStatusBarTexture = ScrollFrameSetStatusBarTexture

    local mana = MakeVial(scrollframeMana, manaWidth, healthHeight, "MANA")
    scrollframeMana:SetScrollChild(mana)
    scrollframeMana:SetSize(manaWidth, healthHeight)
    scrollframeMana:SetPoint("BOTTOM", root , "BOTTOM", 16, 10)

    local fgf = CreateFrame("Frame", nil, root)
    fgf:SetWidth(256*m)
    fgf:SetHeight(512*m)
    fgf:SetPoint("BOTTOM",root, "BOTTOM",0,0)
    fgf:SetFrameLevel(root:GetFrameLevel() + 3)

    local fg = fgf:CreateTexture(nil, "ARTWORK",nil, 4)
    -- fg:SetWidth(256*m)
    -- fg:SetHeight(512*m)
    fg:SetTexture([[Interface\AddOns\oUF_NugVials\vialTreeFG.tga]])
    fg:SetAllPoints()
    -- fg:SetPoint("BOTTOM",root, "BOTTOM",0,0)

    local indicator = ns.CreateIndicator(fgf)

    local vialGlass1 = fgf:CreateTexture(nil, "BORDER",1)
    vialGlass1:SetBlendMode("ADD")
    vialGlass1:SetTexture([[Interface\AddOns\oUF_NugVials\vial.tga]])
    vialGlass1:SetAllPoints(scrollframeHealth)

    local vialGlass2 = fgf:CreateTexture(nil, "BORDER",1)
    vialGlass2:SetBlendMode("ADD")
    vialGlass2:SetTexture([[Interface\AddOns\oUF_NugVials\vial.tga]])
    vialGlass2:SetAllPoints(scrollframeMana)


    root.Health = scrollframeHealth
    root.Power = scrollframeMana


    return root
end


function ns.CreateIndicator(fgf)
    local indBG = fgf:CreateTexture(nil, "ARTWORK", nil, 5)
    indBG:SetTexture([[Interface\AddOns\oUF_NugVials\vialIndicator.tga]])
    indBG:SetSize(40, 40)
    indBG:SetPoint("BOTTOM", fgf, "BOTTOM", 5,-7)

    local restingTex = [[Interface\AddOns\oUF_NugVials\redflame_tex.tga]]

    local indPoint = CreateFrame("Frame", nil, fgf)
    indPoint:SetSize(25, 25)
    local pt = indPoint:CreateTexture(nil, "ARTWORK", nil, 6)
    pt:SetTexture([[Interface\AddOns\oUF_NugVials\vialIndicator.tga]])
    pt:SetAllPoints()
    pt:SetBlendMode("ADD")
    indPoint.tex = pt
    indPoint:SetPoint("CENTER", indBG, "CENTER",0,-3)
    indPoint:Hide()


    indPoint.Hide1 = indPoint.Hide

    local hag = indPoint:CreateAnimationGroup()
    local h1 = hag:CreateAnimation("Alpha")
    h1:SetFromAlpha(1)
    h1:SetToAlpha(0)
    h1:SetDuration(0.3)
    h1:SetOrder(1)
    hag:SetScript("OnFinished", function(self)
        local frame = self:GetParent()
        frame:Hide1()
        frame:SetAlpha(1)
    end)

    local pag = indPoint:CreateAnimationGroup()
    local pa1 = pag:CreateAnimation("Alpha")
    pa1:SetFromAlpha(1)
    pa1:SetToAlpha(0.3)
    pa1:SetDuration(0.15)
    pa1:SetOrder(1)
    local pa2 = pag:CreateAnimation("Alpha")
    pa2:SetFromAlpha(0.3)
    pa2:SetToAlpha(1)
    pa2:SetDuration(0.15)
    pa2:SetOrder(2)
    pag.a2 = pa2
    pag:SetLooping("REPEAT")
    indPoint.pulse = pag



    indPoint.HideAnim = hag

    indPoint:SetScript("OnShow", function(self)
        if self.HideAnim:IsPlaying() then
            self.HideAnim:Stop()
            self:SetAlpha(1)
        end
    end)
    indPoint.Hide = function(self)
        self.HideAnim:Play()
    end

    local function FindAura(unit, spellID, filter)
        for i=1, 100 do
            local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, auraSpellID = UnitAura(unit, i, filter)
            if not name then return nil end
            if spellID == auraSpellID then
                return name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, auraSpellID
            end
        end
    end

    local MakeBuffCheck = function(spellID)
        return function()
            return FindAura("player", spellID, "HELPFUL")
        end
    end


    local indFrame = CreateFrame("Frame", nil, fgf)
    -- indFrame:SetScript("OnEvent", function(self, event, ...)
    --     return self[event](self, event, ...)
    -- end)
    indFrame.point = indPoint

    indFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
    indFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    local IsResting = IsResting


    local showMissingSelfBuffIndicator = false
    local buffCheck = nil
    local buffEffect = "orange"

    if showMissingSelfBuffIndicator then
        local _, playerClass = UnitClass("player")
        if playerClass == "PRIEST" then
            buffCheck = MakeBuffCheck(21562) --fort
            -- buffEffect = "holy"
            indFrame:RegisterUnitEvent("UNIT_AURA", "player")
        elseif playerClass == "WARRIOR" then
            buffCheck = MakeBuffCheck(6673) --shout
            -- buffEffect = "orange"
            indFrame:RegisterUnitEvent("UNIT_AURA", "player")
        elseif playerClass == "MAGE" then
            buffCheck = MakeBuffCheck(1459) --arcane int
            -- buffEffect = "blue"
            indFrame:RegisterUnitEvent("UNIT_AURA", "player")
        elseif playerClass == "ROGUE" then
            local GetSpecialization = GetSpecialization
            buffCheck = function()
                if GetSpecialization() ~= 1 then return true end
                local deadly
                local crippling
                for i=1, 100 do
                    local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, auraSpellID = UnitAura("player", i, "HELPFUL")
                    if name == nil then return crippling and deadly end
                    if auraSpellID == 8679 or auraSpellID == 2823 then deadly = true end -- wound or deadly poison
                    if auraSpellID == 3408 then crippling = true end
                end
            end
            buffEffect = "green"
            indFrame:RegisterUnitEvent("UNIT_AURA", "player")
            indFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
        end
    end

    indFrame.Update = function(self, event, ...)
        -- if buffCheck and not buffCheck() then
        --     self.point:SetEffect(buffEffect)
        --     self.point:Show()
        --     if not self.point.pulse:IsPlaying() then self.point.pulse:Play() end
        -- else
        if IsResting() then
            self.point.tex:SetTexture(restingTex)
            if self.point.pulse:IsPlaying() then self.point.pulse:Stop() end
            self.point:Show()
        else
            self.point.pulse:Stop()
            self.point:Hide()
        end
    end

    indFrame:SetScript("OnEvent", indFrame.Update)

    return indFrame
end



local PlayerVials = function(self, unit)
    -- local width = 157
    -- local height = 217

    MakeVialBar(self)

	self:RegisterForClicks"anyup"


    -- self.colors = colors

    -- self.Health.colorTapping = true
    -- self.Health.colorDisconnected = true
    -- self.Health.frequentUpdates = true
    self.Health.Smooth = true

    -- self.Health.bg = hpbg
    -- self.Health.bg.multiplier = 0.5

    -- self.Health.colorHealth = true

    -- self.Health = hp

    -- self.Power.bg = mbbg
    -- self.Power.bg.multiplier = 0.5

    -- self.Power.colorPower = true
    -- self.Power.colorDisconnec0ted = true
    -- self.Power.colorTapping = true
    self.Power.frequentUpdates = true
    self.Power.Smooth = true
end


oUF:RegisterStyle("PlayerVials", PlayerVials)
oUF:SetActiveStyle"PlayerVials"

local player = oUF:Spawn("player","oUF_Player")
player:SetFrameLevel(7)
player:SetFrameStrata("HIGH")
player:SetPoint("BOTTOM",150,0)

