--Dark Scorpion Base

local s, id = GetID()
function s.initial_effect(c)
	--Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--ATKup Scorpion
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1a))
	e2:SetValue(600)
	c:RegisterEffect(e2)
	--ATKup Don Zaloog
	local e3 = e2:Clone()
	e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,76922029))
	c:RegisterEffect(e3)
	--Banish Hand
	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_TO_HAND_REDIRECT)
	e4:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e4:SetTarget(s.rmtg)
	e4:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e4)
	--Banish GY
	e5 = Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(0, 0xff)
	e5:SetValue(LOCATION_REMOVED)
	e5:SetTarget(s.rmtg)
	c:RegisterEffect(e5)
	--Banish GY Zaloog
	e6 = e5:Clone()
	e6:SetTarget(s.rmdztg)
	c:RegisterEffect(e6)
	--to hand
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(25032004,0))
	e7:SetCategory(CATEGORY_TOHAND)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCode(EVENT_BATTLE_DAMAGE)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1)
	e7:SetCondition(s.thcon)
	e7:SetTarget(s.thtg)
	e7:SetOperation(s.thop)
	c:RegisterEffect(e7)
end

function s.rmtg(e, c)
	return c:IsReason(REASON_EFFECT) and c:GetReasonEffect():GetHandler():IsSetCard(0x1a) and c:GetOwner() ~= e:GetHandlerPlayer()
end
function s.rmdztg(e, c)
	return c:IsReason(REASON_EFFECT) and c:GetReasonEffect():GetHandler():IsCode(76922029) and c:GetOwner() ~= e:GetHandlerPlayer()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsControler(tp) and eg:GetFirst():IsSetCard(0x1a) or eg:GetFirst():IsCode(76922029)
end
function s.thfilter(c)
	return c:IsSetCard(0x1a) or c:IsCode(76922029) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end