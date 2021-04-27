function c73036400.initial_effect(c)
	--Cannot be Summoned/Set
	c:EnableReviveLimit()
	--special summon rule
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c73036400.spcon)
--	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2 = e1:Clone()
	e2:SetRange(LOCATION_GRAVE)
	c:RegisterEffect(e2)
	--Cannot remove
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetProperty(EFFECT_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	--cannot add
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_TO_HAND)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_DECK)
	c:RegisterEffect(e4)
	--cannot draw
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_DRAW)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetCondition(c73036400.con)
	c:RegisterEffect(e5)
	--no Extra
	local e9 = Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e9:SetRange(LOCATION_MZONE)
	e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e9:SetTargetRange(0,1)
	e9:SetTarget(c73036400.noextralimit)
	c:RegisterEffect(e9)
end

function c73036400.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15d)
end
function c73036400.spcon(e, c)
	if c == nil then return true end
	local tp = c:GetControler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	local g=Duel.GetMatchingGroup(c73036400.spfilter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>3
end

function c73036400.con(e)
	return Duel.GetCurrentPhase()~=PHASE_DRAW
end

function c73036400.noextralimit(e, c)
	return c:IsLocation(LOCATION_EXTRA)
end