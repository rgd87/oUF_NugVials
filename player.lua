local addonName, ns = ...

local Redraw = function(self)
    if not self.model_path then return end

    self:SetModelScale(1)
    self:SetPosition(0,0,0)

    if type(self.model_path) == "number" then
        self:SetDisplayInfo(self.model_path)
    else
        self:SetModel(self.model_path)
    end
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

local vialSettings = {
    HEALTH = {
        color = {0.7, 0, 0},
        darkSmoke = "spells/7fx_nightmare_dustcloud_state.m2",
        ambientSmoke = "spells/7fx_ghost_red_state.m2",
        bigBubbles = "spells/acidburn_red.m2",
    },
    MANA = {
        color = {0.3, 0, 0.9},
        -- darkSmoke = "spells/7fx_nightmare_dustcloud_state.m2"
        ambientSmoke = "spells/7fx_ghost_blue_state.m2",
        bigBubbles = "spells/acidburn_blue.m2",
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

    if opts.darkSmoke then
        local darkSmoke = MakeModelRegion(f, width, height*0.7, opts.darkSmoke, -8.6, 0, -5.1 )
        darkSmoke:SetPoint("BOTTOM", f, "BOTTOM", 0,-15)
    end

    local ambientSmoke = MakeModelRegion(f, width-4, height*0.9, opts.ambientSmoke, 0,0,1 )
    ambientSmoke:SetPoint("TOP", f, "TOP", 0, 0)

    local smallBubbles1 = MakeModelRegion(f, width*0.8, height*0.5, "spells/algalonsparkles.m2", 0,0,0 )
    smallBubbles1:SetPoint("TOP", f, "TOP", 0, 0)

    local smallBubbles2 = MakeModelRegion(f, width*0.8, height*0.5, "spells/algalonsparkles.m2", 0,0,0 )
    smallBubbles2:SetPoint("TOP", f, "TOP", 0, -height*0.3)


    local bigBubbles1 = MakeModelRegion(f, width-2, height*0.8, opts.bigBubbles, -20, 0, -4.6 )
    bigBubbles1:SetPoint("TOP", f, "TOP", 0, -height*0.1)

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


    local colors = {
        green =  {"spells/enchantments/greenflame_low.m2", 1, 2.2,0,1 },
        blue =  {"spells/enchantments/blueflame_low.m2", 1, 2.2,0,1 },
        purple =  {"spells/enchantments/purpleflame_low.m2", 1, 2.2,0,1 },
        orange =  {"spells/enchantments/redflame_low.m2", 1, 2.2,0,1 },
        holy = { "spells/Holy_precast_med_hand_simple.m2", 1.6, 0, 0, 0 },
    }

    local indPoint = MakeModelRegion(fgf,35,35,"spells/enchantments/purpleflame_low.m2", 2.2,0,1, 1)
    -- indPoint.model_path = "spells/enchantments/redflame_low.m2"
    -- indPoint.model_path = "spells/enchantments/blueflame_low.m2"
    -- indPoint.model_path = "spells/enchantments/greenflame_low.m2"
    -- indPoint.model_path = "spells/enchantments/yellowflame_low.m2"
    -- indPoint:Redraw()

    indPoint.SetEffect = function(pmf, name)
        if name == pmf.currentEffect then return end
        assert(colors[name], "Effect doesn't exist")
        local model, scale, x, y, z = unpack(colors[name])
        pmf.model_scale = scale or 1
        pmf.ox = x
        pmf.oy = y
        pmf.oz = z
        pmf.model_path = model
        pmf:Redraw()
        pmf.currentEffect = name
    end
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


    indPoint.HideAnim = hag

    indPoint:SetScript("OnShow", function(self)
        self:Redraw()
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
    local IsResting = IsResting
    local restingEffect = "purple"


    local buffCheck = nil
    local buffEffect = "orange"

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
            for i=1, 100 do
                local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, auraSpellID = UnitAura("player", i, "HELPFUL")
                if name == nil then return nil end
                if auraSpellID == 8679 or auraSpellID == 2823 then return true end -- wound or deadly poison
            end
        end
        buffEffect = "green"
        indFrame:RegisterUnitEvent("UNIT_AURA", "player")
        indFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    end

    indFrame.Update = function(self, event, ...)
        if buffCheck and not buffCheck() then
            self.point:SetEffect(buffEffect)
            self.point:Show()
        elseif IsResting() then
            self.point:SetEffect(restingEffect)
            self.point:Show()
        else
            self.point:Hide()
        end
    end

    indFrame:SetScript("OnEvent", indFrame.Update)
    indFrame:Update()


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
    self.Health.frequentUpdates = true
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

