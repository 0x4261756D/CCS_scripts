--Injection Mona
--Aubertin
function c1033315.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,c1033315.lcheck)
	c:EnableReviveLimit()
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1033315,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,1033315)
	e1:SetTarget(c1033315.tg)
	e1:SetOperation(c1033315.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--special
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1033315,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCountLimit(1,1033316)
	e4:SetCost(c1033315.cost)
	e4:SetCondition(c1033315.condition)
	e4:SetTarget(c1033315.target)
	e4:SetOperation(c1033315.operation)
	c:RegisterEffect(e4)
end
function c1033315.lcheck(g,lc)
	return g:IsExists(Card.IsRace,1,nil,RACE_SPELLCASTER)
	and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH)
	end
function c1033315.filter(c)
	return c:IsSetCard(0x19d) and c:IsAbleToHand()
end
function c1033315.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1033315.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c1033315.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c1033315.filter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c1033315.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c1033315.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function c1033315.filterf(c,e,tp)
	return c:IsCode(5519829) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c1033315.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c1033315.filterf,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function c1033315.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c1033315.filterf,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end