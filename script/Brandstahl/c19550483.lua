--Burning Steel Crocodile
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c,false)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.drcon)
	e3:SetCost(s.drcost)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	--cannot attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetValue(s.atktg)
	c:RegisterEffect(e4)
	--damage
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(s.dmgcon)
	e5:SetTarget(s.dmgtg)
	e5:SetOperation(s.dmgop)
	c:RegisterEffect(e5)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(400)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
--
function s.cfilter(c,e,tp)
	return c:IsSetCard(0x478) and c:GetSummonPlayer()==tp and c:IsSummonType(SUMMON_TYPE_PENDULUM)
		and (not e or c:IsRelateToEffect(e))
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,nil,tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
--
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
--
function s.atktg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x478) and not c:IsCode(id)
end
--
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end