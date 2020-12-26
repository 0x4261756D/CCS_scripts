--Akademie
local s,id=GetID()
function s.initial_effect(c)
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
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	--summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(2)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCondition(s.shcon)
	e4:SetTarget(s.shtg)
	e4:SetOperation(s.shop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
	--shuffle
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTarget(s.target)
	e7:SetOperation(s.operation)
	c:RegisterEffect(e7)
end
function s.nevtgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x800) and c:IsType(TYPE_MONSTER)
end
function s.limcon(e)
	return Duel.GetMatchingGroupCount(s.nevtgfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,nil)>0
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x800)
end
function s.shfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x800) and c:IsType(TYPE_MONSTER) and c:GetSummonPlayer()==tp
end
function c65000013.shcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.shfilter,1,nil,tp)
end
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end
function s.filter1(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeck() and not c:IsPublic()
end
function s.filter2(c)
	return c:IsSetCard(0x800) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck() and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and #g>0 and aux.SelectUnselectGroup(g,e,p,1,#g,s.rescon,0) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_HAND,0,nil)
	g=aux.SelectUnselectGroup(g,e,p,1,#g,s.rescon,1,p,HINTMSG_TODECK)
	if #g>0 then
		Duel.ConfirmCards(1-p,g)
		local ct=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		Duel.ShuffleDeck(p)
		Duel.BreakEffect()
		Duel.Draw(p,ct,REASON_EFFECT)
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(s.filter2,nil)>0
end