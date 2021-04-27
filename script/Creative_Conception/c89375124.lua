-- Creative Conception Prison Breaker
function c89375124.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89375124,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c89375124.sumcon)
	c:RegisterEffect(e1)
	--summon success
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89375124,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c89375124.sumtg)
	e2:SetOperation(c89375124.sumop)
	c:RegisterEffect(e2)
	--effect gain
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(c89375124.cost)
    e3:SetTarget(c89375124.tg)
    e3:SetOperation(c89375124.op)
    c:RegisterEffect(e3)
end
function c89375124.sumcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c89375124.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsSetCard(0x15d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c89375124.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c89375124.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function c89375124.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c89375124.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c89375124.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function c89375124.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x15d)
end
function c89375124.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc~=e:GetHandler() and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c89375124.cfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(c89375124.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
   	Duel.SelectTarget(tp,c89375124.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function c89375124.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(89375124,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	e1:SetCost(c89375124.descost)
	e1:SetTarget(c89375124.destg)
	e1:SetOperation(c89375124.desop)
	tc:RegisterEffect(e1)
	tc:RegisterFlagEffect(0,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(89375124,2))
	--Revive
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_REMOVED)
	--e2:SetReset(RESET_EVENT+0x1fe0000)
	e2:SetCountLimit(1)
	e2:SetTarget(c89375124.sptg)
	e2:SetOperation(c89375124.spop)
	tc:RegisterEffect(e2)
	
end
function c89375124.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
--	if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
--		local e2=Effect.CreateEffect(c)
--		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
--		e2:SetCode(EVENT_PHASE+PHASE_END)
--		e2:SetReset(RESET_PHASE+PHASE_END)
--		e2:SetLabelObject(c)
--		e2:SetCountLimit(1)
--		e2:SetOperation(c89375124.retop)
--		Duel.RegisterEffect(e2,tp)
--	end
end
function c89375124.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function c89375124.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(sg,REASON_EFFECT)
	e:GetHandler():RegisterFlagEffect(89375124,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,0)
end
--function c89375124.retop(e,tp,eg,ep,ev,re,r,rp)
--	Duel.ReturnToField(e:GetLabelObject())
--end
function c89375124.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	Debug.Message(Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(89375124)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c89375124.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end