--Weirzard Segal
function c65000017.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,c65000017.matfilter,1,1)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,65000017)
	e1:SetTarget(c65000017.rmtg)
	e1:SetOperation(c65000017.rmop)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,65000018)
	e2:SetTarget(c65000017.reptg)
	e2:SetValue(1)
	e2:SetOperation(c65000017.repop)
	c:RegisterEffect(e2)
end
function c65000017.matfilter(c,lc,sumtype,tp)
	return c:IsLevel(4) and c:IsRace(RACE_SPELLCASTER,lc,sumtype,tp)
end
function c65000017.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
function c65000017.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c65000017.rmfilter,tp,LOCATION_DECK,0,1,nil) and
		Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function c65000017.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsPlayerCanDraw(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c65000017.rmfilter,tp,LOCATION_DECK,0,1,1,nil)	
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function c65000017.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0x800) and not c:IsReason(REASON_REPLACE)
end
function c65000017.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local tc=eg:GetFirst()
		return eg:GetCount()==1 and c65000017.filter(tc,tp)
	end
	e:SetLabelObject(eg:GetFirst())
	return true
end
function c65000017.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT+REASON_REPLACE)
	Duel.BreakEffect()
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
