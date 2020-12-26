--Bilighteral Control
Duel.LoadScript("bilightutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Act in za hando and on za fieldo
	Bilighteral.CreateActivation(c)
	--Spell Effect
	local e2=Bilighteral.AddSpellEffect({handler=c,cat=CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP,prop=EFFECT_FLAG_CARD_TARGET,tg=s.spelltg,op=s.spellop})
	c:RegisterEffect(e2)
	--Trap Effect
	local e3=Bilighteral.AddTrapEffect({handler=c,cat=CATEGORY_TOHAND+CATEGORY_SEARCH,prop=EFFECT_FLAG_CARD_TARGET,tg=s.traptg,op=s.trapop})
	c:RegisterEffect(e3)
end

--Spell Effect

function s.tgfilter(c,e,tp)
	return (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spelltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.tgfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,tc:GetFirst():GetLocation())
end

function s.eqlimit(e,c)
	return c:GetControler()==e:GetHandlerPlayer() and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
end

function s.spellop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetTargetCards(e):GetFirst()
	if not tc then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.Equip(tp,c,tc) then
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetValue(s.eqlimit)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e0)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetRange(LOCATION_MZONE)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetCountLimit(1)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return tc:IsAttribute(ATTRIBUTE_LIGHT) and c:GetEquipTarget()==tc end)
		e1:SetTarget(s.sptg)
		e1:SetOperation(s.spop)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_ATKCHANGE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return tc:IsAttribute(ATTRIBUTE_DARK) and c:GetEquipTarget()==tc end)
		e2:SetValue(2000)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCategory(CATEGORY_DEFCHANGE)
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_PIERCE)
		e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return tc:IsAttribute(ATTRIBUTE_DARK) and c:GetEquipTarget()==tc end)
		tc:RegisterEffect(e4)
		local e5=Effect.CreateEffect(c)
		e5:SetDescription(aux.Stringid(id,1))
		e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e5:SetCategory(CATEGORY_DESTROY)
		e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e5:SetCode(EVENT_BATTLE_DESTROYING)
		e5:SetTarget(s.destg)
		e5:SetOperation(s.desop)
		tc:RegisterEffect(e5)
		c:CancelToGrave()
	end
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.Destroy(tc,REASON_EFFECT)
end

--Trap Effect

function s.thfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x400)
end

function s.tgfilter2(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)
end

function s.traptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter2(chkc) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter2,tp,LOCATION_MZONE,0,1,nil) end
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetTargetCard(tc)
end

function s.trapop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetTargetCards(e):GetFirst()
	if not tc then return end
	if Duel.Equip(tp,c,tc) then
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetValue(s.eqlimit)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e0)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		e1:SetRange(LOCATION_MZONE)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetCountLimit(1)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return tc:IsAttribute(ATTRIBUTE_LIGHT) and c:GetEquipTarget()==tc end)
		e1:SetTarget(s.thtg)
		e1:SetOperation(s.thop)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return tc:IsAttribute(ATTRIBUTE_DARK) and c:GetEquipTarget()==tc end)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e3)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return tc:IsAttribute(ATTRIBUTE_DARK) and c:GetEquipTarget()==tc end)
		e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		tc:RegisterEffect(e4)
		c:CancelToGrave()
	end
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SetTargetCard(tc)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e)
	if not tc then return end
	Duel.SendtoHand(tc,REASON_EFFECT,tp)
	Duel.ConfirmCards(1-tp,tc)
end