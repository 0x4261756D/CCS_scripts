--injection fun
function c64000155.initial_effect(c)
--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c64000155.condition)
	e1:SetCountLimit(1,64000155)
	e1:SetTarget(c64000155.target)
	e1:SetOperation(c64000155.activate)
	c:RegisterEffect(e1)
end
function c64000155.cfilter(c)
	return c:IsFaceup() and (c:IsCode(79575620) or c:IsCode(5519829))
end
function c64000155.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c64000155.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c64000155.filter(c)
	return (c:IsSetCard(0x14d) or c:IsSetCard(0x14e) or c:IsCode(79575620))  and c:IsAbleToHand() and not c:IsCode(64000155)
end
function c64000155.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_DECK and c64000155.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c64000155.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c64000155.filter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c64000155.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end