function c29652790.initial_effect(c)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c29652790.atkval)
	c:RegisterEffect(e1)
	--effect gain
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(29652790,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,29652790)
    e2:SetCost(c29652790.cost)
    e2:SetTarget(c29652790.tg)
    e2:SetOperation(c29652790.op)
    c:RegisterEffect(e2)
end
function c29652790.filter(c)
	return c:IsSetCard(0x15d) and c:IsType(TYPE_MONSTER)
end
function c29652790.atkval(e,c)
	return Duel.GetMatchingGroupCount(c29652790.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*250
end
function c29652790.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function c29652790.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x15d)
end
function c29652790.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc~=e:GetHandler() and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c29652790.cfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c29652790.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
   	Duel.SelectTarget(tp,c29652790.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function c29652790.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(29652790,5))
    e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c29652790.destg)
	e1:SetOperation(c29652790.desop)
    e1:SetReset(RESET_EVENT+0x1fe0000)
    tc:RegisterEffect(e1)
	tc:RegisterFlagEffect(0,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(29652790,2))
end
function c29652790.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c29652790.desop(e)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end