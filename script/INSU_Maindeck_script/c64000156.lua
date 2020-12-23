function c64000156.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,1,aux.NonTunerEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,99)
	c:EnableReviveLimit()
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64000156,0))
	e1:SetCountLimit(1,64000156)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,64000156)
	e1:SetTarget(c64000156.thtg)
	e1:SetOperation(c64000156.thop)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64000156,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c64000156.negcon)
	e3:SetCost(c64000156.negcost)
	e3:SetTarget(c64000156.negtg)
	e3:SetOperation(c64000156.negop)
	c:RegisterEffect(e3)
	--Battle damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c64000156.gtcon)
	e4:SetTarget(c64000156.gttarget)
	e4:SetOperation(c64000156.gtoperation)
	c:RegisterEffect(e4)
end
function c64000156.thfilter(c)
	return c:IsCode(64000152) and c:IsAbleToHand()
end
function c64000156.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c64000156.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c64000156.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c64000156.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c64000156.negfilter(c)
	return c:IsOnField() and c:IsType(TYPE_MONSTER) and (c:IsCode(79575620) or c:IsSetCard(0x19d))
end
function c64000156.negcon(e,tp,eg,ep,ev,re,r,rp)
	if e==re or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if not (re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)) then return false end
	local ex1,tg1,tc1=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	local ex2,tg2,tc2=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	local ex3,tg3,tc3=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	local ex4,tg4,tc4=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	local ex5,tg5,tc5=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	if (ex1 and tg1~=nil and tc1+tg1:FilterCount(c64000156.negfilter,nil)-tg1:GetCount()>0)
		or (ex2 and tg2~=nil and tc2+tg2:FilterCount(c64000156.negfilter,nil)-tg2:GetCount()>0)
		or (ex3 and tg3~=nil and tc3+tg3:FilterCount(c64000156.negfilter,nil)-tg3:GetCount()>0)
		or (ex4 and tg4~=nil and tc4+tg4:FilterCount(c64000156.negfilter,nil)-tg4:GetCount()>0)
		or (ex5 and tg5~=nil and tc5+tg5:FilterCount(c64000156.negfilter,nil)-tg5:GetCount()>0)
		then return true
	end
	return false
end
function c64000156.negfilterc(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x19e)
	 and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function c64000156.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c64000156.negfilterc,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c64000156.negfilterc,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c64000156.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c64000156.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function c64000156.gtcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsControler(tp) and (tc:IsCode(79575620) or tc:IsSetCard(0x19d)) and tc~=e:GetHandler()
end
function c64000156.filterf(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable() and c:IsCode(64000153) or c:IsCode(64000161)
end
function c64000156.gttarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c64000156.filter,tp,LOCATION_DECK,0,1,nil) end
end
function c64000156.gtoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,c64000156.filterf,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
		Duel.ConfirmCards(1-tp,tc)
	end
end