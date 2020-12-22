-- Look, Eye don't get it
function c55743217.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--splimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c55743217.spcondition)
	e2:SetTarget(c55743217.splimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	--e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c55743217.rmcond)
	e3:SetTarget(c55743217.rmtg)
	e3:SetOperation(c55743217.rmop)
	c:RegisterEffect(e3)
	--Destroy replace
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_DESTROY_REPLACE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(c55743217.desreptg)
	e4:SetValue(c55743217.desrepval)
   -- e4:SetOperation(c55743217.desrepop)
    c:RegisterEffect(e4)
end
function c55743217.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function c55743217.spcondition(e)
	return Duel.IsExistingMatchingCard(c55743217.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c55743217.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsType(TYPE_LINK)
end
function c55743217.rmfilter(c)
	return c:IsFaceup() and c:IsCode(80117527)
end
function c55743217.rmcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(c55743217.rmfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)==1
end
function c55743217.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,0,LOCATION_EXTRA)
end
function c55743217.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
	if g:GetCount()>1 then
		local rg=g:RandomSelect(tp,2)
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
function c55743217.desreptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
--	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c55743217.filter(chkc) end
--	local c=e:GetHandler()
--	if chk==0 then return not c:IsReason(REASON_REPLACE+REASON_RULE) and Duel.IsExistingTarget(c55743217.filter,tp,LOCATION_MZONE,0,1,nil) end
--	if Duel.SelectEffectYesNo(tp,c,96) then
--		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
--		Duel.SelectTarget(tp,c55743217.filter,tp,LOCATION_MZONE,0,1,1,nil)
--		return true
--		else return false
--    end
 	local c=e:GetHandler()
    if chk==0 then return  not c:IsReason(REASON_REPLACE+REASON_RULE) and Duel.IsExistingTarget(c55743217.filter,tp,LOCATION_MZONE,0,1,nil) end
    if Duel.SelectEffectYesNo(tp,c,96) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local tc=Duel.SelectTarget(tp,c55743217.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
        c:CancelToGrave()
        Duel.Overlay(tc,Group.FromCards(c))
        return true
    else return false
    end
end
--function c55743217.desrepop(e,tp,eg,ep,ev,re,r,rp)
-- local c=e:GetHandler()
--    local tc=Duel.GetFirstTarget()
--    c:CancelToGrave()
--    Duel.Overlay(tc,Group.FromCards(c))
--end
function c55743217.desrepval(e,c)
    return c==e:GetHandler()
end