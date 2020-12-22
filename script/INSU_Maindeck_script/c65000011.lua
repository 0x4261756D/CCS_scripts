--Skurrilist Wogian
function c65000011.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65000011,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,65000011)
	e1:SetCost(c65000011.cost)
	e1:SetTarget(c65000011.target)
	e1:SetOperation(c65000011.operation)
	c:RegisterEffect(e1)
	--spsummon                            triggered sich noch nicht
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65000011,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	--e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,65000012)
	e2:SetCost(c65000011.spcost)
	e2:SetTarget(c65000011.sptg)
	e2:SetOperation(c65000011.spop)
	c:RegisterEffect(e2)
end
function c65000011.bdfilter1(c,tp)
	return c:IsAbleToDeckAsCost() and c:IsType(TYPE_SPELL)
		and Duel.IsExistingMatchingCard(c65000011.rmfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function c65000011.rmfilter(c,r)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
	and not c:IsCode(r)
end
function c65000011.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c65000011.bdfilter1,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c65000011.bdfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetCode())
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function c65000011.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function c65000011.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,c65000011.rmfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())	
	Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
end
function c65000011.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,nil)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	--local g=Duel.SelectMatchingCard(tp,c65000011.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	--e:SetLabel(g:GetFirst():GetCode())
	Duel.SendtoDeck(sg,nil,2,REASON_COST)
end
function c65000011.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x800)
end
function c65000011.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c65000011.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

	
function c65000011.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c65000011.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()	
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
		end
	--end	
		--Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end