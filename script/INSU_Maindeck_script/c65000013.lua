--Weirzard Akademie (bitte keine Zahlen mittendrin weglassen ffs)
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
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(2)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.shcon)
	e3:SetTarget(s.shtg)
	e3:SetOperation(s.shop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--shuffle
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTarget(s.target)
	e6:SetOperation(s.operation)
	c:RegisterEffect(e6)
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
function s.shcon(e,tp,eg,ep,ev,re,r,rp)
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
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,e)
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