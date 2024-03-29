Duel.LoadScript("customutility.lua")

STAGE_ROOKIE = 1
STAGE_CHAMPION = 2
STAGE_ULTIMATE = 3
STAGE_MEGA = 4
STAGE_ULTRA = 5

SET_DIGI = 0xC55
SET_DIGITATION = 0x1C55
SET_X_ANTIBODY = 0x1C56

CARD_X_ANTIBODY = 300006009
CARD_JOGRESS_EVOLUTION = 300006015

EFFECT_FLAG_DIGIVOLUTION = 0x20000000

if not Digimon then
	Digimon={}
end

function Digimon.AddProc(c,stage,additional_race,summon_restrictions,rookies,champions,ultimates,megas,ultras,antibody)
    if summon_restrictions == 1 or summon_restrictions == 2 or summon_restrictions == 3 then
        c:EnableUnsummonable()
        local e = Effect.CreateEffect(c)
        e:SetType(EFFECT_TYPE_SINGLE)
        e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e:SetCode(EFFECT_SPSUMMON_CONDITION)
        if summon_restrictions == 1 then
            e:SetValue(Digimon.DigitationLimit)
        elseif summon_restrictions == 2 then
            e:SetValue(Digimon.JogressLimit)
        else
            e:SetValue(Digimon.AntibodyLimit)
        end
        c:RegisterEffect(e)
    end
    if stage >= STAGE_MEGA then
	    c:EnableUnsummonable()
    end
    local digitations = {}
    local stage = stage or STAGE_ROOKIE
    local rookies = rookies or {}
    local champions = champions or {}
    local ultimates = ultimates or {}
    local megas = megas or {}
    local ultras = ultras or {}
    local antibody = antibody or 0
    table.insert(digitations,rookies)
    table.insert(digitations,champions)
    table.insert(digitations,ultimates)
    table.insert(digitations,megas)
    table.insert(digitations,ultras)
    local m = c:GetMetatable()
    m.digitations = digitations
    m.stage = stage
    m.antibody = antibody
    if additional_race then
        local e = Effect.CreateEffect(c)
        e:SetType(EFFECT_TYPE_SINGLE)
        e:SetCode(EFFECT_ADD_RACE)
        e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
        e:SetRange(LOCATION_ALL)
        e:SetValue(additional_race)
        c:RegisterEffect(e)
    end
end

function Digimon.DigitationLimit(e,se,sp,st)
	return se:IsHasProperty(EFFECT_FLAG_DIGIVOLUTION) or e:GetHandler():IsStatus(STATUS_PROC_COMPLETE)
end

function Digimon.JogressLimit(e,se,sp,st)
	local eff = Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT)
    	if eff then return ((se:GetHandler():IsCode(CARD_JOGRESS_EVOLUTION) or eff:GetHandler():IsCode(CARD_JOGRESS_EVOLUTION)) and st == SUMMON_TYPE_FUSION) or e:GetHandler():IsStatus(STATUS_PROC_COMPLETE) end
	return ((se:GetHandler():IsCode(CARD_JOGRESS_EVOLUTION)) and st == SUMMON_TYPE_FUSION) or e:GetHandler():IsStatus(STATUS_PROC_COMPLETE)
end

function Digimon.AntibodyLimit(e,se,sp,st)
	local eff = Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT)
    	if eff then return ((se:GetHandler():IsCode(CARD_X_ANTIBODY) or eff:GetHandler():IsCode(CARD_X_ANTIBODY)) and st == SUMMON_TYPE_XYZ) or e:GetHandler():IsStatus(STATUS_PROC_COMPLETE) end
	return ((se:GetHandler():IsCode(CARD_X_ANTIBODY)) and st == SUMMON_TYPE_XYZ) or e:GetHandler():IsStatus(STATUS_PROC_COMPLETE)
end

function Digimon.GetStage(c)
    local m = c:GetMetatable()
    return m.stage or 0
end

function Digimon.GetXAntibody(c)
    local m = c:GetMetatable()
    return m.antibody or 0
end

function Digimon.GetDigitations(c,stage)
    local m = c:GetMetatable()
    if not m.digitations then return {} end
    if stage then return m.digitations[stage] end
    return m.digitations
end

function Digimon.CanDigivolve(c,count)
    local stage = Digimon.GetStage(c)
    if count and Digimon.GetDigitations(c,stage + count) then return #(Digimon.GetDigitations(c,stage + count)) > 0 end
    for i = 1, STAGE_ULTRA - stage do
        if Digimon.CanDigivolve(c,i) then return true end
    end
    return false
end

function Digimon.CanDigivolveInto(c,code)
    if type(code) == "Card" then code = code:GetCode() end
    local digitations, stage = Digimon.GetDigitations(c), Digimon.GetStage(c)
    for i = 1, #digitations do
        if i > stage then
            if contains(digitations[i],code) then return true end
        end
    end
    return false
end

function Digimon.CanDigivolveFrom(c,code)
    if type(code) == "Card" then code = code:GetCode() end
    local digitations, stage = Digimon.GetDigitations(c), Digimon.GetStage(c)
    for i = 1, #digitations do
        if i < stage then
            if contains(digitations[i],code) then return true end
        end
    end
    return false
end

function Digimon.IsExistingDigitationToSummon(c,g,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    local count,st,ignore_conditions,ignore_limit,pos = count or 1, st or 0, ignore_conditions or false, ignore_limit or false, pos or POS_FACEUP
    local g = g or Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,loc,0,nil,e,st,tp,ignore_conditions,ignore_limit,pos)
    local ct = 0
    for _,code in ipairs(Digimon.GetDigitations(c,Digimon.GetStage(c) + count)) do
        if g:IsExists(Card.IsCode,1,nil,code) then
            ct = ct + 1
        end
    end
    return ct > 0
end

function Digimon.SelectDigitationToSummon(c,g,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    local count,st,ignore_conditions,ignore_limit,pos = count or 1, st or 0, ignore_conditions or false, ignore_limit or false, pos or POS_FACEUP
    if not Digimon.IsExistingDigitationToSummon(c,g,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos) then return end
    local g2
    if g then
        g2 = g:Filter(Card.IsCode,nil,table.unpack(Digimon.GetDigitations(c,Digimon.GetStage(c) + count)))
    else
        g2 = Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,loc,0,nil,e,st,tp,ignore_conditions,ignore_limit,pos):Filter(Card.IsCode,nil,table.unpack(Digimon.GetDigitations(c,Digimon.GetStage(c) + count)))
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    g2 = g2:Select(tp,1,1,nil)
    g2:KeepAlive()
    return g2
end

function Digimon.SummonDigitation(c,g,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    local count,st,ignore_conditions,ignore_limit,pos = count or 1, st or 0, ignore_conditions or false, ignore_limit or false, pos or POS_FACEUP
    local g = Digimon.SelectDigitationToSummon(c,g,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    if g and #g>0 then Duel.SpecialSummon(g,st,tp,tp,ignore_conditions,ignore_limit,pos) end
    g:DeleteGroup()
end

function Digimon.Digivolve(c,g,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    local count,st,ignore_conditions,ignore_limit,pos = count or 1,st or 0,ignore_conditions or false,ignore_limit or false,pos or POS_FACEUP
    if not Digimon.IsExistingDigitationToSummon(c,g,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos) or not Digimon.CanDigivolve(c,count) then return end
    Duel.SendtoGrave(c,REASON_EFFECT)
    Digimon.SummonDigitation(c,g,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
end

function Digimon.AddSingleTriggerDigivolution(c,count,loc,desc,forced,range,event,can_miss,cl,con,cost,st,ignore_conditions,ignore_limit,pos)
    local count,st,ignore_conditions,ignore_limit,pos = count or 1,st or 0,ignore_conditions or false,ignore_limit or false,pos or POS_FACEUP
    local e = Effect.CreateEffect(c)
    if desc then
	    e:SetDescription(desc)
    end
	e:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
    if forced then
	    e:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    else
        e:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    end
    if not can_miss then
	    e:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DIGIVOLUTION)
    else
        e:SetProperty(EFFECT_FLAG_DIGIVOLUTION)
    end
	e:SetCode(event)
    if cl then
        e:SetCountLimit(table.unpack(cl)) 
    end
    if range then
        e:SetRange(range)
    end
    if con then
        e:SetCondition(con)
    end
    if cost then
        e:SetCost(cost)
    end
	e:SetTarget(Digimon.DigivolutionTarget(c,count,loc,st,ignore_conditions,ignore_limit,pos))
	e:SetOperation(Digimon.DigivolutionOperation(c,count,loc,st,ignore_conditions,ignore_limit,pos))
	c:RegisterEffect(e)
    e:SetLabel(loc,count,st)
    return e
end

function Digimon.AddFieldTriggerDigivolution(c,count,loc,desc,forced,range,event,can_miss,cl,con,cost,st,ignore_conditions,ignore_limit,pos)
    local count,st,ignore_conditions,ignore_limit,pos = count or 1,st or 0,ignore_conditions or false,ignore_limit or false,pos or POS_FACEUP
    local e = Effect.CreateEffect(c)
    if desc then
	    e:SetDescription(desc)
    end
	e:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
    if forced then
	    e:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    else
        e:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    end
    if not can_miss then
	    e:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DIGIVOLUTION)
    else
        e:SetProperty(EFFECT_FLAG_DIGIVOLUTION)
    end
	e:SetCode(event)
    if cl then
        e:SetCountLimit(table.unpack(cl)) 
    end
    if range then
        e:SetRange(range)
    end
    if con then
        e:SetCondition(con)
    end
    if cost then
        e:SetCost(cost)
    end
	e:SetTarget(Digimon.DigivolutionTarget(c,count,loc,st,ignore_conditions,ignore_limit,pos))
	e:SetOperation(Digimon.DigivolutionOperation(c,count,loc,st,ignore_conditions,ignore_limit,pos))
	c:RegisterEffect(e)
    e:SetLabel(loc,count,st)
    return e
end

function Digimon.AddQuickDigivolution(c,count,loc,desc,forced,event,cl,con,cost,st,ignore_conditions,ignore_limit,pos)
    local count,st,ignore_conditions,ignore_limit,pos = count or 1,st or 0,ignore_conditions or false,ignore_limit or false,pos or POS_FACEUP
    local e = Effect.CreateEffect(c)
    if desc then
	    e:SetDescription(desc)
    end
	e:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
    e:SetProperty(EFFECT_FLAG_DIGIVOLUTION)
    if forced then
	    e:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_QUICK_F)
    else
        e:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_QUICK_O)
    end
	e:SetCode(event)
	if cl then
        e:SetCountLimit(table.unpack(cl)) 
    end
    if con then
        e:SetCondition(con)
    end
    if cost then
        e:SetCost(cost)
    end
	e:SetTarget(Digimon.DigivolutionTarget(c,count,loc,st,ignore_conditions,ignore_limit,pos))
	e:SetOperation(Digimon.DigivolutionOperation(c,count,loc,st,ignore_conditions,ignore_limit,pos))
	c:RegisterEffect(e)
    e:SetLabel(loc,count,st)
    return e
end

function Digimon.AddIgnitionDigivolution(c,count,loc,desc,cl,con,cost,st,ignore_conditions,ignore_limit,pos)
    local count,st,ignore_conditions,ignore_limit,pos = count or 1,st or 0,ignore_conditions or false,ignore_limit or false,pos or POS_FACEUP
    local e = Effect.CreateEffect(c)
    if desc then
	    e:SetDescription(desc)
    end
	e:SetCategory(CATEGORY_TOGRAVE + CATEGORY_SPECIAL_SUMMON)
    e:SetProperty(EFFECT_FLAG_DIGIVOLUTION)
    e:SetType(EFFECT_TYPE_IGNITION)
	e:SetRange(LOCATION_MZONE)
    if cl then
        e:SetCountLimit(table.unpack(cl)) 
    end
    if con then
        e:SetCondition(con)
    end
    if cost then
        e:SetCost(cost)
    end
	e:SetTarget(Digimon.DigivolutionTarget(c,count,loc,st,ignore_conditions,ignore_limit,pos))
	e:SetOperation(Digimon.DigivolutionOperation(c,count,loc,st,ignore_conditions,ignore_limit,pos))
	c:RegisterEffect(e)
    e:SetLabel(loc,count,st)
    return e
end

function Digimon.DigivolutionTarget(c,count,loc,st,ignore_conditions,ignore_limit,pos)
    return function(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk == 0 then return Digimon.IsExistingDigitationToSummon(c,nil,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos) and Digimon.CanDigivolve(c,count) end
	    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,c,1,tp,LOCATION_MZONE)
        Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
    end
end

function Digimon.DigivolutionOperation(c,count,loc,st,ignore_conditions,ignore_limit,pos)
    return function(e,tp,eg,ep,ev,re,r,rp)
        Digimon.Digivolve(c,nil,e,tp,loc,count,st,ignore_conditions,ignore_limit,pos)
    end
end

function Digimon.CostFilter(f,tc,e,g)
	return function(c,...)
        local params = {e:GetLabel()}
	    return f(c,...) and Digimon.IsExistingDigitationToSummon(tc,g-Group.FromCards(c),e,e:GetHandlerPlayer(),table.unpack(params))
	end
end
