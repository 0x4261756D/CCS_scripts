--Skurrilist Hilien
function c65000007.initial_effect(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65000007,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c65000007.cost)
	e1:SetTarget(c65000007.target)
	e1:SetOperation(c65000007.operation)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65000007,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c65000007.con)
	e2:SetTarget(c65000007.tg)
	e2:SetOperation(c65000007.op)
	c:RegisterEffect(e2)	
end
function c65000007.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function c65000007.filter(c)
	return c:IsSetCard(0x800) and c:IsAbleToHand()
end
function c65000007.filter2(c)
	return c:IsSetCard(0x800) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c65000007.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
function c65000007.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c65000007.rmfilter,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(c65000007.filter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c65000007.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,c65000007.rmfilter,tp,LOCATION_DECK,0,1,1,nil)	
	if Duel.Remove(g1,POS_FACEUP,REASON_EFFECT) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,c65000007.filter2,tp,LOCATION_DECK,0,1,1,nil)
		if g2:GetCount()>0 then
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end

function c65000007.con(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_BATTLE)
end
function c65000007.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c65000007.filter,tp,LOCATION_GRAVE,0,1,nil)
						or Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end

end
function c65000007.op(e,tp,eg,ep,ev,re,r,rp)
	local op=0	
	if Duel.IsExistingMatchingCard(c65000007.filter,tp,LOCATION_GRAVE,0,1,nil)
	and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	then op=(Duel.SelectOption(tp,aux.Stringid(65000007,1),aux.Stringid(65000007,2))+1)
	elseif Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	and not Duel.IsExistingMatchingCard(c65000007.filter,tp,LOCATION_GRAVE,0,1,nil)
	then op=1
	elseif Duel.IsExistingMatchingCard(c65000007.filter,tp,LOCATION_GRAVE,0,1,nil)
	and not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	then op=2
	end	
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,0)
		local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g1:GetCount()>0 then
			Duel.Destroy(g1,REASON_EFFECT)	
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,c65000007.filter,tp,LOCATION_GRAVE,0,1,1,nil)
		if g2:GetCount()>0 then
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end		
	end
end
