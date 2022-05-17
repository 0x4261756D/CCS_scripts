--D/D Savant Schwarzschild
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c) 
	--Broken
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.revcon)
	e1:SetTarget(s.revtg)
	e1:SetOperation(s.revop)
	c:RegisterEffect(e1)
	--Workaround to have e1 trigger with "D/D/D Abyss King Gilgamesh"
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCondition(s.revcon2)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
	--Discard + Foolish + Search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Level/Tuner
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.lvcon)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
end

--Broken

function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==tp and (r&REASON_EFFECT)>0 and re:GetHandler():IsSetCard(0xaf)) then return false end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	if Duel.GetFlagEffect(tp,id)>0 then Duel.ResetFlagEffect(tp,id) end
	return true
end

function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local effs={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_SPECIAL_SUMMON)}
	if chk==0 then
		for _,eff in ipairs(effs) do
			if eff:GetOwner():IsCode(9024198,72181263,19808608) then
				return true
			end
		end
		return false
	end
end

function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local effs={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_SPECIAL_SUMMON)}
	for _,eff in ipairs(effs) do
		if eff:GetOwner():IsCode(9024198,72181263,19808608) then
			eff:Reset()
		end
	end
end

function s.revcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)>0 then
		c:ResetFlagEffect(id)
		return false
	end
	if Duel.GetFlagEffect(tp,id)==0 then return false end
	Duel.ResetFlagEffect(tp,id)
	return Duel.CheckEvent(EVENT_DAMAGE)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if (r&REASON_EFFECT)~=0 then
		Duel.RegisterFlagEffect(ep,id,RESET_CHAIN,0,1)
	end
end

--Discard + Foolish + Search

function s.tgfilter(c,e,tp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode(),e,tp) and c:IsSetCard(0xaf) and c:IsAbleToGraveAsCost() and c:IsMonster()
end

function s.spfilter(c,code,e,tp)
	return c:IsSetCard(0xaf) and not c:IsCode(code) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.thfilter(c)
	return c:IsSetCard(0xae) and c:IsAbleToHand()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroup(tp,LOCATION_HAND,0):FilterCount(Card.IsDiscardable,nil)>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	Duel.SendtoGrave(tc,REASON_COST)
	e:SetLabel(tc:GetCode())
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and c:IsAbleToExtra() and Duel.GetMZoneCount(tp,c)>0
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c,code=e:GetHandler(),e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,code,e,tp)
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc and Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,tc)
			Duel.SendtoExtraP(c,tp,REASON_EFFECT)
		end
	end
end

--Level/Tuner

function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xaf) or e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) and (Duel.GetFieldCard(tp,LOCATION_PZONE,0):IsSetCard(0xaf) or Duel.GetFieldCard(tp,LOCATION_PZONE,1):IsSetCard(0xaf))
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsLevel(6) or not c:IsType(TYPE_TUNER) end
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv,tuner={not c:IsLevel(6),aux.Stringid(id,3)},{not c:IsType(TYPE_TUNER),aux.Stringid(id,4)}
	local choice=aux.SelectEffect(tp,lv,tuner)
	if choice==1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(6)
		c:RegisterEffect(e1)
	elseif choice==2 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(TYPE_TUNER)
		c:RegisterEffect(e2)
	end
end