function c63946129.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63946129,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,63946130)
	e1:SetTarget(c63946129.sptg)
	e1:SetOperation(c63946129.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--effect gain
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(63946129,1))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,63946129)
    e4:SetCost(c63946129.cost)
    e4:SetTarget(c63946129.tg)
    e4:SetOperation(c63946129.op)
    c:RegisterEffect(e4)
end
function c63946129.filter(c,e,tp)
	return c:IsSetCard(0x15d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c63946129.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c63946129.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c63946129.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c63946129.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c63946129.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function c63946129.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x15d)
end
function c63946129.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc~=e:GetHandler() and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c63946129.cfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c63946129.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
   	Duel.SelectTarget(tp,c63946129.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function c63946129.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetValue(aux.tgoval)
    e1:SetReset(RESET_EVENT+0x1fe0000)
    tc:RegisterEffect(e1)
	tc:RegisterFlagEffect(0,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(63946129,2))
end