--Venom Viper
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--sp sum
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
--	--search
--	local e3=Effect.CreateEffect(c)
--	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
--	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
--	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
--	e3:SetCountLimit(1)
--	e3:SetRange(LOCATION_MZONE)
--	e3:SetCost(c39991177.thcost)
--	e3:SetTarget(c39991177.thtg)
--	e3:SetOperation(c39991177.thop)
--	c:RegisterEffect(e3)
	--add counter
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.ccondition)
	e4:SetTarget(s.ctarget)
	e4:SetOperation(s.coperation)
	c:RegisterEffect(e4)
end
s.listed_series={0x50}
s.listed_names={id}
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x50)
	end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return (Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0 
		or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
--
function s.costfilter(c,e,tp)
	return c:IsSetCard(0x50) and c:IsType(TYPE_MONSTER) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),e,tp)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,e,tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,e,tp)
	e:SetLabel(sg:GetFirst():GetLevel())
	Duel.Release(sg,REASON_COST)
end
function s.spfilter(c,lv,e,tp)
	return c:IsSetCard(0x50) and c:IsLevel(lv+1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel(),e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--
--function c39991177.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
--	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1009,2,REASON_COST) end
--	Duel.RemoveCounter(tp,1,1,0x1009,2,REASON_COST)
--end
--function c39991177.thfilter(c)
--	return c:IsSetCard(0x50) and not c:IsCode(39991177) and c:IsAbleToHand()
--end
--function c39991177.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
--	if chk==0 then return Duel.IsExistingMatchingCard(c39991177.thfilter,tp,LOCATION_DECK,0,1,nil) end
--	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
--end
--function c39991177.thop(e,tp,eg,ep,ev,re,r,rp)
--	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
--	local g=Duel.SelectMatchingCard(tp,c39991177.thfilter,tp,LOCATION_DECK,0,1,1,nil)
--	if g:GetCount()>0 then
--		Duel.SendtoHand(g,nil,REASON_EFFECT)
--		Duel.ConfirmCards(1-tp,g)
--	end
--end
--
function s.chkfilter(c,tp)
	return c:IsSetCard(0x50) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.ccondition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.chkfilter,1,nil,tp)
end
function s.ctarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsCanAddCounter(0x1009,2) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1009,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1009,1)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0)
end
function s.coperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1009,2) then
		local atk=tc:GetAttack()
		tc:AddCounter(0x1009,2)
		if atk>0 and tc:GetAttack()==0 then
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end