-- Trickstar Fanemona
local s, id = GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x1)
	c:EnableReviveLimit()
	--add counter
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_BATTLE_DAMAGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(s.accon1)
	e0:SetOperation(s.acop)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(s.accon2)
	c:RegisterEffect(e1)
	--spsummon from hand
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetCountLimit(1,{id, 1})
	e2:SetCondition(s.hspcon)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2,false,2)
	--burn + draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id, 2})
	e3:SetCost(s.dmgcost)
	e3:SetTarget(s.dmgtg)
	e3:SetOperation(s.dmgop)
	c:RegisterEffect(e3)
end
function s.accon1(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsSetCard(0xfb)
end
function s.accon2(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r&REASON_BATTLE==0 and re and re:GetHandler():IsSetCard(0xfb)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
function s.hspfilter(c)
	return c:IsSetCard(0xfb) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and rg:GetCount()>1 and aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),0)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.dmgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)>7 and e:GetHandler():IsReleasable() end
	local val=e:GetHandler():GetCounter(0x1)
	e:SetLabel(val)
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	local ct=e:GetLabel()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ct*100)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*100)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
	Duel.Draw(1-p,2,REASON_EFFECT)
end