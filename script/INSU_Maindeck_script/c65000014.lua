--Weirzard Protection Charm
<<<<<<< HEAD
local s, id = GetID()
=======
local s,id=GetID()
>>>>>>> 11abf45cf6a733c6158f29d8ea00c1fc3369b41c
function s.initial_effect(c)
	--immun
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
<<<<<<< HEAD
	e1:SetCountLimit(1,65000014)
=======
	e1:SetCountLimit(1,id)
>>>>>>> 11abf45cf6a733c6158f29d8ea00c1fc3369b41c
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--add
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
<<<<<<< HEAD
	e1:SetCountLimit(1,65000015)
=======
	e1:SetCountLimit(1,id+1)
>>>>>>> 11abf45cf6a733c6158f29d8ea00c1fc3369b41c
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
<<<<<<< HEAD
	e1:SetCountLimit(1,65000016)
=======
	e1:SetCountLimit(1,id+2)
>>>>>>> 11abf45cf6a733c6158f29d8ea00c1fc3369b41c
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	c:RegisterEffect(e3)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISEFFECT)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,65000014,RESET_PHASE+PHASE_END,0,1)
end
<<<<<<< HEAD
function s.efilter(e,re,ct)
=======
function s.efilter(e,ct)
>>>>>>> 11abf45cf6a733c6158f29d8ea00c1fc3369b41c
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	local tc=te:GetHandler()
	return te:IsActiveType(TYPE_MONSTER) and tc:IsSetCard(0x800)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x800)
end
function s.thfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
<<<<<<< HEAD
	if g:GetCount()>0 then
=======
	if #g>0 then
>>>>>>> 11abf45cf6a733c6158f29d8ea00c1fc3369b41c
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and c:IsSetCard(0x800) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
<<<<<<< HEAD
		local g=eg:Filter(s.repfilter,nil,tp)
		if g:GetCount()==1 then
=======
		local g=eg:Filter(a.repfilter,nil,tp)
		if #g==1 then
>>>>>>> 11abf45cf6a733c6158f29d8ea00c1fc3369b41c
			e:SetLabelObject(g:GetFirst())
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		return true
	else return false end
end
function s.repval(e,c)
	return c==e:GetLabelObject()
end
