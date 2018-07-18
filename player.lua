
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

local MakeModelRegion = function(parent,w,h,model_path, x,y,z)
    local pmf = CreateFrame("PlayerModel", nil, parent )
    pmf:SetSize(w,h)

    pmf.model_scale = 1
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
    
    local fg = fgf:CreateTexture(nil, "ARTWORK", 4)
    -- fg:SetWidth(256*m)
    -- fg:SetHeight(512*m)
    fg:SetTexture([[Interface\AddOns\oUF_NugVials\vialTreeFG.tga]])   
    fg:SetAllPoints()
    -- fg:SetPoint("BOTTOM",root, "BOTTOM",0,0)

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

