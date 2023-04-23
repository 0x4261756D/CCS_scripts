--Messias Draconis - Savior Dragon
Duel.LoadScript("customutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Deck Stack + Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_DECK+LOCATION_HAND)
	e1:SetCondition(s.stackcon)
	e1:SetCost(s.stackcost)
	e1:SetTarget(s.stacktg)
	e1:SetOperation(s.stackop)
	c:RegisterEffect(e1)
	--SS on Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Token on SS
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(function(e,tp,eg,ep,ev,re) return re:GetHandler()==e:GetHandler() end)
	e3:SetCost(s.tokencost)
	e3:SetTarget(s.tokentg)
	e3:SetOperation(s.tokenop)
	c:RegisterEffect(e3)
	--F -> O and Effect Change
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCondition(s.efcon)
	e4:SetOperation(s.efop)
	c:RegisterEffect(e4)
	--Can be treated as non-tuner for a Synchro Summon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_NONTUNER)
	e5:SetValue(s.ntval)
	c:RegisterEffect(e5)
end

--Deck Stack + Draw

function s.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsSummonPlayer(tp) and Duel.GetFlagEffect(tp,c:GetCode())==0
end

function s.cfilter2(c,tp)
	return s.cfilter(c,tp) and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_MACHINE)) and c:IsLevelAbove(7)
end

function s.tdfilter(c)
	return c:IsLevel(1) and c:IsRace(RACE_DRAGON) and (c:IsAbleToDeck() or c:IsLocation(LOCATION_DECK))
end

function s.revfilter(c,e,eg)
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x3f) and s.namecheck(eg,c) and not c:IsPublic()
end

function s.namecheck(g,c)
	for tc in g:Iter() do
		if c:ListsCode(tc:GetCode()) then return true end
	end
	return false
end

function s.stackcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.stackcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_EXTRA,0,1,nil,e,eg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,eg):GetFirst()
	if tc then Duel.ConfirmCards(tp,tc) end
	for c in eg:Iter() do
		Duel.RegisterFlagEffect(tp,c:GetCode()+id,RESET_PHASE+PHASE_END,0,1)
	end
end

function s.stacktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end

function s.stackop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
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

--SS on Draw

function s.synfilter(c,tp)
	local res=false
	for tc in Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_EXTRA,0,nil,0x3f):Iter() do
		if tc:ListsCode(c:GetCode()) then res=true end
	end
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and res
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end

--Token on SS

function s.revfilter2(c,e,tp)
	return c:IsSetCard(0x3f) and c:IsType(TYPE_SYNCHRO) and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,c,e) and not c:IsPublic()
end

function s.tgfilter(c,sc,e)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeEffectTarget(e) and sc:ListsCode(c:GetCode()) and sc:GetLevel()-c:GetLevel()>0
end

function s.tokencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local revc=Duel.SelectMatchingCard(tp,s.revfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
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

--F -> O and Effect Change

function s.spfilter(c,tc,e,tp)
	return tc:ListsCode(c:GetCode()) and not c:IsCode(21159309) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

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
	s.effchangeop(effs,rc)(e,tp,eg,ep,ev,re,r,rp)
end

function s.tedtg(f,c)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,c,e,tp) end
		if chk==0 then return f(e,tp,eg,ep,ev,re,r,rp,0) and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,c,e,tp) end
		f(e,tp,eg,ep,ev,re,r,rp,1)
	end
end

function s.effchangeop(effs,c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local code=c:GetCode()
		--Star
		if code==7841112 then
			for _,eff in ipairs(effs) do
				if (eff:GetType()&EFFECT_TYPE_QUICK_O)>0 then
					local eff2=eff:Clone()
					eff2:SetCost(s.alteredstarcost)
					eff2:SetReset(RESET_EVENT+RESETS_STANDARD)
					c:RegisterEffect(eff2)
					c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
					eff:SetCondition(aux.AND(s.efcon2(c),eff:GetCondition()))
				end
			end
		end
		--Red
		if code==67030233 or code==513000078 then
			for _,eff in ipairs(effs) do
				if (eff:GetCode()&EVENT_BATTLED)>0 then
					local eff2=eff:Clone()
					eff2:SetTarget(s.alteredredtg)
					eff2:SetOperation(s.alteredredop)
					eff2:SetReset(RESET_EVENT+RESETS_STANDARD)
					c:RegisterEffect(eff2)
					c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
					eff:SetCondition(aux.AND(s.efcon2(c),eff:GetCondition()))
				end
			end
		end
		--Rose
		
		--Feather
		
		--Fairy
		
		--Tool
	end
end

function s.alteredstarcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsReleasable,Card.IsMonster),tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsReleasable,Card.IsMonster),tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	Duel.Release(g,REASON_COST)
end

function s.alteredredtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_MZONE)
end

function s.alteredredop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(g,REASON_EFFECT)
end

--Non-Tuner

function s.ntval(c,sc,tp)
	return sc and (sc:IsRace(RACE_DRAGON) or sc:IsRace(RACE_MACHINE))
end