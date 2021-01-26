function c64000110.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,64000110)
	e1:SetCondition(c64000110.spcon)
	e1:SetOperation(c64000110.spop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64000110,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,64000111)
	e2:SetTarget(c64000110.thtg)
	e2:SetOperation(c64000110.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--summon limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c64000110.regop)
	c:RegisterEffect(e4)
	end
	function c64000110.spcon(e,c)
	if c==nil then return Duel.IsExistingMatchingCard(c64000110.sanctfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) or  Duel.IsEnvironment(56433456) end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c64000110.regop(e,tp,eg,ep,ev,re,r,rp,c)
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c64000110.sumlimit)
	Duel.RegisterEffect(e1,tp)
end
function c64000110.sumlimit(e,c)
	return not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY))
end

function c64000110.filter(c)
	return c:IsSetCard(0xf10) or c:IsCode(18378582) or c:IsCode(59509952) and c:IsType(TYPE_MONSTER) 
		and c:IsAbleToHand()
end
function c64000110.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c64000110.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c64000110.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c64000110.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c64000110.sanctfilter(c)
	return c:IsFaceup() and c:IsCode(56433456)
end