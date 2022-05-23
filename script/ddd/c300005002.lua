--Dark Contract with Scrolls
local s,id=GetID()
function s.initial_effect(c)
	--Abolute Jank
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--SS
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_series={0xaf}

--Abolute Jank

function s.tgfilter(c)
	return c:IsSetCard(0xaf) and c:IsMonster() and c:IsAbleToGraveAsCost()
end

function s.cfilter(c,sc,tpe)
	return c:IsSetCard(sc) and c:IsType(tpe)
end

function s.rescon(stc,pzc,g1,g2)
	return function(sg,e,tp,mg)
		return #(sg&g1)<=pzc and #(sg&g2)<=stc
	end
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local stc=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local pzc=0
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then pzc=pzc+1 end
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then pzc=pzc+1 end
	local g1,g2=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil,0xaf,TYPE_PENDULUM),Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil,0xae,TYPE_CONTINUOUS)
	if chk==0 then return aux.SelectUnselectGroup(g1+g2,e,tp,2,2,s.rescon(stc,pzc,g1,g2),0) end
	local con1,con2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil),Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	local tg1,tg2
	if (con1 or con2) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		if con1 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			tg1=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
			Duel.SendtoGrave(tg1,REASON_COST)
		end
		if con2 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			tg2=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
			Duel.SendtoGrave(tg2,REASON_COST)
		end
	end
	if not tg1 or not tg2 or (tg1+tg2):GetClassCount(Card.GetCode)<2 then
		e:SetLabel(2000)
	else
		e:SetLabel(1000)
	end
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local stc=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local pzc=0
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) then pzc=pzc+1 end
	if Duel.CheckLocation(tp,LOCATION_PZONE,1) then pzc=pzc+1 end
	local g1,g2=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil,0xaf,TYPE_PENDULUM),Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil,0xae,TYPE_CONTINUOUS)
	if not aux.SelectUnselectGroup(g1+g2,e,tp,2,2,s.rescon(stc,pzc,g1,g2),0) then return end
	local tf=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,s.rescon(stc,pzc,g1,g2),1,tp,HINTMSG_TOFIELD)
	local zone=2^1|2^2|2^3
	for tc in tf:Iter() do
		if tc:IsType(TYPE_PENDULUM) then
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true,zone)
		end
	end
	Duel.Damage(tp,e:GetLabel(),REASON_EFFECT)
end

--SS

function s.spfilter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,LOCATION_GRAVE)
	if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0xaf) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetValue(s.matlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
end

function s.matlimit(e,c)
	return not c:IsSetCard(0x10af)
end