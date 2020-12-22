--Meteorite Kicking Dinosaur
function c26694382.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,c26694382.matfilter,1,1)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,26694382)
	e1:SetCost(c26694382.cost)
	e1:SetCondition(c26694382.condition)
	e1:SetTarget(c26694382.target)
	e1:SetOperation(c26694382.operation)
	c:RegisterEffect(e1)
	--self destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c26694382.sdcon)
	e2:SetTarget(c26694382.destg)
	e2:SetOperation(c26694382.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function c26694382.matfilter(c,lc,sumtype,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DINOSAUR,lc,sumtype,tp)
end
function c26694382.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c26694382.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(c26694382.costchk1,1,nil,sg)
end
function c26694382.costchk1(c,sg)
	return c:IsRace(RACE_DINOSAUR) and sg:FilterCount(Card.IsAttribute,c,ATTRIBUTE_DARK)==1
end
function c26694382.costfilter1(c,race)
	return c:IsRace(race) and c:IsAbleToRemoveAsCost()
end
function c26694382.costfilter2(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemoveAsCost()
end
function c26694382.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rg1=Duel.GetMatchingGroup(c26694382.costfilter1,tp,LOCATION_DECK,0,nil,RACE_DINOSAUR)
	local rg2=Duel.GetMatchingGroup(c26694382.costfilter2,tp,LOCATION_DECK,0,nil,ATTRIBUTE_DARK)
	local rg=rg1:Clone()
	rg:Merge(rg2)
	if rg1:GetCount()>0 and rg2:GetCount()>0 
		and aux.SelectUnselectGroup(rg,e,tp,2,2,c26694382.rescon,0) then
		local g=aux.SelectUnselectGroup(rg,e,tp,2,2,c26694382.rescon,1,tp,HINTMSG_REMOVE)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function c26694382.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function c26694382.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function c26694382.sdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR)
end
function c26694382.sdcon(e)
	return Duel.IsExistingMatchingCard(c26694382.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function c26694382.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDestructable()
end
function c26694382.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c26694382.desfilter,tp,LOCATION_DECK,0,1,nil)
		and e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function c26694382.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c26694382.desfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end