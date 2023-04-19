--Messias Draconis - Savior Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Deck Stack + Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_DECK)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.stackcon)
	e1:SetTarget(s.stacktg)
	e1:SetOperation(s.stackop)
	c:RegisterEffect(e1)
	--Token on SS
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.tokencost)
	e2:SetTarget(s.tokentg)
	e2:SetOperation(s.tokenop)
	c:RegisterEffect(e2)
	--F -> O
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.efcon)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
	--Can be treated as non-tuner for a Synchro Summon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_NONTUNER)
	e4:SetValue(s.ntval)
	c:RegisterEffect(e4)
end

--Deck Stack + Draw

function s.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsSummonPlayer(tp)
end

function s.cfilter2(c,tp)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsSummonPlayer(tp) and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_MACHINE)) and c:IsLevelAbove(7)
end

function s.stackcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.tdfilter(c)
	return c:IsLevel(1) and c:IsRace(RACE_DRAGON)
end

function s.stacktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK)
end

function s.stackop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	Duel.ShuffleDeck(tp)
	Duel.MoveSequence(tc,SEQ_DECKTOP)
	Duel.ConfirmDecktop(tp,1)
	if eg:IsExists(s.cfilter2,1,nil,tp) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

--Token

function s.revfilter(c,e,tp)
	return c:IsSetCard(0x3f) and c:IsType(TYPE_SYNCHRO) and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,c,e) and not c:IsPublic()
end

function s.tgfilter(c,sc,e)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeEffectTarget(e) and sc:ListsCode(c:GetCode()) and sc:GetLevel()-c:GetLevel()>0
end

function s.tokencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local revc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	Duel.ConfirmCards(1-tp,revc)
	e:SetLabelObject(revc:GetFirst())
end

function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local revc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,revc,e) end
	if chk==0 then return
		Duel.GetMZoneCount(tp)>0
		and Duel.IsPlayerCanSpecialSummonCount(tp,1)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,0,RACE_DRAGON,ATTRIBUTE_LIGHT,POS_FACEUP,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,revc,e)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	e:SetLabel(revc:GetLevel()-tc:GetFirst():GetLevel()-1)
end

function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local c,tc,lv=e:GetHandler(),Duel.GetFirstTarget(),e:GetLabel()
	if not tc or lv<1 or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,lv,RACE_DRAGON,ATTRIBUTE_LIGHT,POS_FACEUP,tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local token=Duel.CreateToken(tp,id+1)
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1)
	Duel.SpecialSummonComplete()
end

--F -> O

function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsSetCard(0x3f)
end

function s.efcon2(c)
	return function(e)
		return not c:HasFlagEffect(id)
	end
end

function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local effs={rc:GetCardEffect()}
	for _,eff in ipairs(effs) do
		if eff:GetType()==EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_ACTIONS then
			local eff2=eff:Clone()
			eff2:SetDescription(aux.Stringid(id,0))
			eff2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			eff2:SetProperty(EFFECT_FLAG_CLIENT_HINT+eff:GetProperty())
			eff2:SetTarget(s.tedtg(eff:GetTarget(),rc))
			eff2:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(eff2)
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			eff:SetCondition(s.efcon2(rc))
		end
	end
end

function s.tedtg(f,c)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,c,e,tp) end
		if chk==0 then return f(e,tp,eg,ep,ev,re,r,rp,0) and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,c,e,tp) end
		f(e,tp,eg,ep,ev,re,r,rp,1)
	end
end

function s.spfilter(c,tc,e,tp)
	return tc:ListsCode(c:GetCode()) and not c:IsCode(21159309) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--Non-Tuner

function s.ntval(c,sc,tp)
	return sc and (sc:IsRace(RACE_DRAGON) or sc:IsRace(RACE_MACHINE))
end