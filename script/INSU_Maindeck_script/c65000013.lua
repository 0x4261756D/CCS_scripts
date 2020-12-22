--Akademie
function c65000013.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c65000013.limcon)
	e2:SetValue(c65000013.atlimit)
	c:RegisterEffect(e2)
	--cannot be effect target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IMMEDIATELY_APPLY+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c65000013.limcon)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x800))
	e3:SetValue(aux.tgoval)
	--e3:SetValue(1)
	c:RegisterEffect(e3)
	--summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(65000013,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(2)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCondition(c65000013.shcon)
	e4:SetTarget(c65000013.shtg)
	e4:SetOperation(c65000013.shop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(65000013,0))
	e7:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCountLimit(1,65000013)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTarget(c65000013.target)
	e7:SetOperation(c65000013.operation)
	c:RegisterEffect(e7)
end
function c65000013.nevtgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x800) and c:IsType(TYPE_MONSTER)
end
function c65000013.limcon(e)
	return Duel.GetMatchingGroupCount(c65000013.nevtgfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)>0
end
function c65000013.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x800)
end
function c65000013.shfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x800) and c:IsType(TYPE_MONSTER) and c:GetSummonPlayer()==tp
end
function c65000013.shcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65000013.shfilter,1,nil,tp)
end
function c65000013.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
function c65000013.shtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c65000013.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c65000013.cfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c65000013.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function c65000013.shop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)                  
	end
end
function c65000013.filter1(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck() and not c:IsPublic()
end
function c65000013.filter2(c)
	return c:IsSetCard(0x800)
end
function c65000013.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c65000013.filter1,tp,LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and g:GetCount()>0 and g:IsExists(c65000013.filter2,1,nil) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function c65000013.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(p,c65000013.filter1,p,LOCATION_HAND,0,1,99,nil)
	if g:GetCount()>0 then
		Duel.ConfirmCards(1-p,g)
		local ct=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		Duel.ShuffleDeck(p)
		Duel.BreakEffect()
		Duel.Draw(p,ct,REASON_EFFECT)
		Duel.ShuffleHand(p)
	end
end