-- The Core of Time and Space
Duel.LoadScript("customutility.lua")
local s, id = GetID()

function s.initial_effect(c)
	c:EnableUnsummonable()
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_HAND + LOCATION_REMOVED)
	e1:SetCondition(s.spcon)
	e1:SetCountLimit(1, {id, 1})
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	e1:SetCountLimit(1, {id, 2})
	c:RegisterEffect(e2)
end

function s.spcon(e, c)
	if c == nil then return true end
	return Duel.IsExistingMatchingCard(s.spfilter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
end

function s.spfilter(c)
	return c:IsFaceup() and
		(c:IsSetCard(0x4879) and c:IsLocation(LOCATION_MZONE)) or
		(c:IsCode(721211123) and c:IsLocation(LOCATION_FZONE))
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.filter(c)
    return c:IsSetCard(0x4879) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end