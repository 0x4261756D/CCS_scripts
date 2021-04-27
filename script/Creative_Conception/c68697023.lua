function c68697023.initial_effect(c)
    --spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68697023,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,68697023)
	e1:SetTarget(c68697023.sptg)
	e1:SetOperation(c68697023.spop)
	c:RegisterEffect(e1)
	--def
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68697023,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,68697022)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c68697023.cond)
	e2:SetTarget(c68697023.target)
	e2:SetOperation(c68697023.activate)
	c:RegisterEffect(e2)
	--effect gain
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(68697023,1))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,68697021)
    e4:SetCost(c68697023.cost)
    e4:SetTarget(c68697023.tg)
    e4:SetOperation(c68697023.op)
    c:RegisterEffect(e4)
end
function c68697023.filter(c,e,tp)
	return c:IsSetCard(0x15d) or c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c68697023.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c68697023.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c68697023.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c68697023.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
------------
function c68697023.cond(e)
	return e:GetHandler():IsDefensePos()
end
function c68697023.tgfilter(c)
	return c:IsSetCard(0x15d) or c:IsSetCard(0x26) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c68697023.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68697023.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c68697023.tgfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectTarget(tp,c68697023.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
function c68697023.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
----------------
function c68697023.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function c68697023.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x15d)
end
function c68697023.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc~=e:GetHandler() and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c68697023.cfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c68697023.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
   	Duel.SelectTarget(tp,c68697023.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function c68697023.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(68697023,5))
    e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c68697023.destg)
	e1:SetOperation(c68697023.desop)
    e1:SetReset(RESET_EVENT+0x1fe0000)
    tc:RegisterEffect(e1)
	tc:RegisterFlagEffect(0,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(68697023,2))
end
function c68697023.zfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c68697023.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c68697023.zfilter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(c68697023.zfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c68697023.zfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c68697023.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
