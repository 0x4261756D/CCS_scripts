--Hungry Cola
function c92899882.initial_effect(c)
	c:EnableReviveLimit()
    --equip
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(92899882,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(c92899882.eqtg)
    e1:SetOperation(c92899882.eqop)
    c:RegisterEffect(e1,false,1)
    aux.AddEREquipLimit(c,nil,c92899882.eqval,c92899882.equipop,e1)
    --immune
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetCondition(c92899882.eqcon)
	e2:SetValue(c92899882.efilter)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92899882,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c92899882.cost)
	e3:SetTarget(c92899882.target)
	e3:SetOperation(c92899882.operation)
	c:RegisterEffect(e3)
end
function c92899882.eqval(ec,c,tp)
    return ec:IsControler(1-tp) and ec:IsLocation(LOCATION_HAND)
end
function c92899882.filter(c,tp)
    return c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function c92899882.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(c92899882.filter,tp,0,LOCATION_HAND,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND)
end
function c92899882.equipop(c,e,tp,tc)
    if not aux.EquipByEffectAndLimitRegister(c,e,tp,tc,nil,true) then return end
end
function c92899882.eqop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or e:GetHandler():IsFacedown() or not e:GetHandler():IsRelateToEffect(e) then return end
         local g=Duel.GetMatchingGroup(c92899882.filter,tp,0,LOCATION_HAND,nil,tp)
         local sg=g:RandomSelect(tp,1)
    local tc=sg:GetFirst()
    if tc then
        c92899882.equipop(e:GetHandler(),e,tp,tc)
    end
end
function c92899882.eqlimit(e,c)
    return e:GetOwner()==c
end
--die nächsten zwei Funktionen funktionieren auch (Filterfunktion weglassen)
--function c92899882.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
--    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
--        and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
--    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND)
--end
--function c92899882.eqop(e,tp,eg,ep,ev,re,r,rp)
--    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or e:GetHandler():IsFacedown() or not e:GetHandler():IsRelateToEffect(e) then return end
--    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
--    local sg=g:RandomSelect(tp,1)
--    local tc=sg:GetFirst()
--    if tc then
--        c92899882.equipop(e:GetHandler(),e,tp,tc)
--    end
--end
function c92899882.eqcon(e)
	local eg=e:GetHandler():GetEquipGroup()
	return eg:GetCount()>0
end
function c92899882.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function c92899882.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function c92899882.thfilter(c)	
	return c:GetType()==0x82 and c:IsAbleToHand()
end

function c92899882.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c92899882.rmfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c92899882.rmfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c92899882.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c92899882.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c92899882.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c92899882.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end