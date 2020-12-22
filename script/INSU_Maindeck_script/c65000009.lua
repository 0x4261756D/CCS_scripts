--Weirzard Maxer
function c65000009.initial_effect(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65000009,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	--e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,65000009)
	e1:SetCondition(c65000009.negcon)
	e1:SetCost(c65000009.negcost)
	e1:SetTarget(c65000009.negtg)
	e1:SetOperation(c65000009.negop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65000009,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,65000010)
	e2:SetTarget(c65000009.sptg)
	e2:SetOperation(c65000009.spop)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,65000011)
	e3:SetTarget(c65000009.reptg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function c65000009.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and re:GetOperation() and (not re:GetHandler():IsCode(65000009) or ep~=tp)
end
function c65000009.costfilter(c)
	return c:IsSetCard(0x800)
end
function c65000009.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not e:GetHandler():IsPublic() and 
		Duel.IsExistingMatchingCard(c65000009.costfilter,tp,LOCATION_HAND,0,1,c) end
	local g=Duel.SelectMatchingCard(tp,c65000009.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.ConfirmCards(1-tp,g,REASON_COST)
end
function c65000009.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c65000009.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		Duel.ShuffleHand(tp)
	end
end
function c65000009.spfilter(c,e,tp)
	return c:IsSetCard(0x800) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(65000009)
end
function c65000009.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c65000009.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c65000009.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c65000009.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c65000009.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c65000009.remfilter(c)
return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function c65000009.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		--if eg:GetCount()~=1 then return false end
		local tc=eg:GetFirst()
		return tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and tc:IsSetCard(0x800) 
			and tc:IsReason(REASON_BATTLE+REASON_EFFECT) and not tc:IsReason(REASON_REPLACE)
			and Duel.IsExistingMatchingCard(c65000009.remfilter,tp,LOCATION_DECK,0,1,nil)
	end	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c65000009.remfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	return true
end