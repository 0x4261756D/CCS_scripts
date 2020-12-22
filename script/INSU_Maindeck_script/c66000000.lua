function c66000000.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66000000,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c66000000.cost)
	e2:SetTarget(c66000000.target)
	e2:SetOperation(c66000000.operation)
	c:RegisterEffect(e2)
	--to grave
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66000000,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,66000001)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(c66000000.effcon)
	e3:SetTarget(c66000000.target2)
	e3:SetOperation(c66000000.activate)
	c:RegisterEffect(e3)
	--draw
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(66000000,2))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,66000000)
	e4:SetHintTiming(TIMING_BATTLE_START)
	e4:SetCondition(c66000000.effcon2)
	e4:SetTarget(c66000000.target3)
	e4:SetOperation(c66000000.activate2)
	c:RegisterEffect(e4)
	--atk&def
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(c66000000.effcondition)
	e5:SetValue(500)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x39))
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6)
	--untargetable
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e7:SetRange(LOCATION_FZONE)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetCondition(c66000000.effcon4)
	e7:SetTarget(c66000000.tgtg)
	e7:SetValue(aux.tgoval)
	c:RegisterEffect(e7)
	--immune
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCode(EFFECT_IMMUNE_EFFECT)
	e8:SetValue(c66000000.efilter)
	e8:SetCondition(c66000000.effcon5)
	c:RegisterEffect(e8)
	end
function c66000000.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x39) and c:IsAbleToGraveAsCost()
end
function c66000000.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c66000000.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c66000000.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c66000000.filterf(c)
	return c:IsSetCard(0x39) or c:IsCode(86690572) or c:IsCode(37436476) or c:IsCode(38049934) or c:IsCode(47658964) or c:IsCode(72142276) or c:IsCode(32394623) or c:IsCode(74025495) and c:IsAbleToHand()
end
function c66000000.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c66000000.filterf,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c66000000.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c66000000.filterf,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c66000000.cfilter(c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER)
end
function c66000000.effcon(e,tp,eg,ep,ev,re,r,rp)
return Duel.IsExistingMatchingCard(c66000000.cfilter,tp,LOCATION_GRAVE,0,2,nil) and tp==Duel.GetTurnPlayer()
end
function c66000000.filter(c)
	return c:IsFaceup()
end
function c66000000.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c66000000.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c66000000.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(66000000,0))
	local g=Duel.SelectTarget(tp,c66000000.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function c66000000.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
function c66000000.kfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x39) and (c:IsType(TYPE_XYZ) or c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_FUSION) or c:IsType(TYPE_LINK))
end
function c66000000.effcon2(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and not Duel.CheckPhaseActivity() and Duel.GetCurrentPhase()==PHASE_BATTLE_START 
		and Duel.IsExistingMatchingCard(c66000000.kfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c66000000.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c66000000.activate2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c66000000.cfilterk(c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER)
end
function c66000000.effcondition(e,tp,eg,ep,ev,re,r,rp)
return Duel.IsExistingMatchingCard(c66000000.cfilterk,tp,LOCATION_GRAVE,0,4,nil)
end
function c66000000.tgtg(e,c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER)
end
function c66000000.cfilter3(c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER)
end
function c66000000.effcon4(e,tp,eg,ep,ev,re,r,rp)
return Duel.IsExistingMatchingCard(c66000000.cfilter3,tp,LOCATION_GRAVE,0,5,nil)
end
function c66000000.efilter(e,te)
	return e:GetOwnerPlayer()~=te:GetOwnerPlayer()
end
function c66000000.cfilter4(c)
	return c:IsSetCard(0x39) and c:IsType(TYPE_MONSTER)
end
function c66000000.effcon5(e,tp,eg,ep,ev,re,r,rp)
return Duel.IsExistingMatchingCard(c66000000.cfilter4,tp,LOCATION_GRAVE,0,7,nil)
end