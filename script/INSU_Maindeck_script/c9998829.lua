--Territoriengrenze
function c9998829.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,9998829)
	e1:SetCondition(c9998829.condition)
	e1:SetTarget(c9998829.target)
	e1:SetOperation(c9998829.activate)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	--activate in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c9998829.handcon)
	c:RegisterEffect(e2)
end
--function c9998829.hdfilter(c)
--	return c:IsType(TYPE_MONSTER) and (c:IsType(TYPE_DUAL) or c:IsSetCard(0x29A))
--end
--function c9998829.handcon(e)
--	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)>0 and
--	Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)==Duel.GetMatchingGroupCount(c9998829.hdfilter,tp,LOCATION_GRAVE,0,nil)
--end
function c9998829.hdfilter(c)
	return not (c:IsType(TYPE_DUAL) or c:IsSetCard(0x29A))
end
function c9998829.handcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()>0 and not g:IsExists(c9998829.hdfilter,1,nil)
end

function c9998829.cfilter2(c)
	return c:IsRace(RACE_FAIRY) and c:IsLocation(LOCATION_MZONE)
end
function c9998829.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
--	if re:IsHasCategory(CATEGORY_NEGATE)
--		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local ex1,tg1,tc1=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	local ex2,tg2,tc2=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	local ex3,tg3,tc3=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	local ex4,tg4,tc4=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	local ex5,tg5,tc5=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	return (ex1 and tg1~=nil and tc1+tg1:FilterCount(c9998829.cfilter2,nil)-tg1:GetCount()>0)
		or (ex2 and tg2~=nil and tc2+tg2:FilterCount(c9998829.cfilter2,nil)-tg2:GetCount()>0)
		or (ex3 and tg3~=nil and tc3+tg3:FilterCount(c9998829.cfilter2,nil)-tg3:GetCount()>0)
		or (ex4 and tg4~=nil and tc4+tg4:FilterCount(c9998829.cfilter2,nil)-tg4:GetCount()>0)
		or (ex5 and tg5~=nil and tc5+tg5:FilterCount(c9998829.cfilter2,nil)-tg5:GetCount()>0)
end

function c9998829.filter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGrave()
end
function c9998829.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and c:IsAbleToDeck()
end
function c9998829.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c9998829.filter,tp,LOCATION_DECK,0,1,nil) 
		and Duel.IsExistingMatchingCard(c9998829.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)		
	end
end
function c9998829.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g1=Duel.SelectMatchingCard(tp,c9998829.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()	
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g2=Duel.SelectMatchingCard(tp,c9998829.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()	
		if Duel.Destroy(eg,REASON_EFFECT)~=0 and Duel.SendtoGrave(g1,REASON_EFFECT)~=0
			and Duel.SendtoDeck(g2,nil,2,REASON_EFFECT)~=0 then
			Duel.BreakEffect()
			
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local h=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,nil)
			if h:GetCount()>0 then
				Duel.Destroy(h,REASON_EFFECT)
			end
		end			
	end
end