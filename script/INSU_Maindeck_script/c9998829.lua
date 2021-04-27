--Territoriengrenze
local s, id = GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,9998829)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	--activate in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end

function s.hdfilter(c)
	return not (c:IsType(TYPE_Gemini) or c:IsSetCard(0x29A))
end
function s.handcon(e)
	local g=Duel.GetMatchingGroup(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()>0 and not g:IsExists(s.hdfilter,1,nil)
end

function s.cfilter2(c)
	return c:IsRace(RACE_FAIRY) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
	local ex1,tg1,tc1=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	local ex2,tg2,tc2=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	local ex3,tg3,tc3=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	local ex4,tg4,tc4=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	local ex5,tg5,tc5=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	return (ex1 and tg1~=nil and tc1+tg1:FilterCount(s.cfilter2,nil)-tg1:GetCount()>0)
		or (ex2 and tg2~=nil and tc2+tg2:FilterCount(s.cfilter2,nil)-tg2:GetCount()>0)
		or (ex3 and tg3~=nil and tc3+tg3:FilterCount(s.cfilter2,nil)-tg3:GetCount()>0)
		or (ex4 and tg4~=nil and tc4+tg4:FilterCount(s.cfilter2,nil)-tg4:GetCount()>0)
		or (ex5 and tg5~=nil and tc5+tg5:FilterCount(s.cfilter2,nil)-tg5:GetCount()>0)
end

function s.filter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToGrave()
end
function s.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_Gemini) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)		
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()	
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()	
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