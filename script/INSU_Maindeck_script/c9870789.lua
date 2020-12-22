--Banish Grepher
function c9870789.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9870789,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c9870789.spcon)
	e1:SetOperation(c9870789.spop)
	c:RegisterEffect(e1)
	--banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9870789,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c9870789.sgcost)
	e2:SetTarget(c9870789.sgtg)
	e2:SetOperation(c9870789.sgop)
	c:RegisterEffect(e2)
end
function c9870789.spfilter(c)
	return c:GetLevel()>=5
end
function c9870789.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(c9870789.spfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
function c9870789.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c9870789.spfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c9870789.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c9870789.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c9870789.costfilter,tp,LOCATION_HAND,0,1,nil) end
	local h=Duel.SelectMatchingCard(tp,c9870789.costfilter,tp,LOCATION_HAND,0,1,1,c)
	if h:GetCount()>0 then
		Duel.Remove(h,POS_FACEUP,REASON_COST)
	end
end
function c9870789.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function c9870789.sgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c9870789.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function c9870789.sgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local i=Duel.SelectMatchingCard(tp,c9870789.filter,tp,LOCATION_DECK,0,1,1,nil)
	if i:GetCount()>0 then 
		Duel.Remove(i,POS_FACEUP,REASON_EFFECT)
	end
end