--Skurrilist Noface
function c65000012.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c, aux.FilterBoolFunction(Card.IsRace, RACE_SPELLCASTER), 4, 2)
	c:EnableReviveLimit()
	--add
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE + CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(65000012, 0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c65000012.cost)
	e1:SetTarget(c65000012.target)
	e1:SetOperation(c65000012.operation)
	c:RegisterEffect(e1)
	--search
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65000012, 1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(c65000012.thtg)
	e2:SetOperation(c65000012.thop)
	c:RegisterEffect(e2)
	--cannot remove
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0, 1)
	e3:SetCondition(c65000012.oppremcon)
	c:RegisterEffect(e3)
	--opp
	local e4 = e3:Clone()
	e4:SetTargetRange(1, 0)
	e4:SetCondition(c65000012.ownremcon)
	c:RegisterEffect(e4)
end

function c65000012.rmfilter(c)
	return (c:IsType(TYPE_SPELL) and c:IsSetCard(0x800) and c:IsAbleToRemoveAsCost())
end
function c65000012.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST)
		and	Duel.IsExistingMatchingCard(c65000012.rmfilter, tp, LOCATION_DECK, 0, 1, nil) end
	e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectMatchingCard(tp, c65000012.rmfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	e:SetLabel(g:GetFirst():GetCode())
	if g:GetCount() > 0 then
		Duel.Remove(g, POS_FACEUP, REASON_COST)
	end
end
function c65000012.thfilter1(c,r)
	return c:IsAbleToHand() and not c:IsCode(r)
end
function c65000012.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(c65000012.thfilter1, tp, LOCATION_REMOVED, 0, 1, nil)
		and	Duel.GetFieldGroupCount(tp, LOCATION_ONFIELD, LOCATION_ONFIELD)>0 end
--	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
--	local g1 = Duel.SelectMatchingCard(tp, c65000012.thfilter1, tp, tp, LOCATION_REMOVED, 0, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_REMOVED)
end
function c65000012.operation(e, tp, eg, ep, ev, re, r, rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1 = Duel.SelectMatchingCard(tp, c65000012.thfilter1,tp,LOCATION_REMOVED, 0, 1, 1, nil, e:GetLabel())
	if g1:GetCount() > 0 then
		Duel.SendtoHand(g1, nil, REASON_EFFECT)
	 	Duel.ConfirmCards(1 - tp, g1)
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
		local g2 = Duel.SelectMatchingCard(tp, Card.IsDestructable, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
		if g2:GetCount() > 0 then
			Duel.Destroy(g2, REASON_EFFECT)
		end
	end
end

function c65000012.thfilter(c)
	return c:IsSetCard(0x800) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c65000012.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end
function c65000012.thop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, c65000012.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	if g:GetCount() > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end

function c65000012.ownremcon(e)
	if e:GetHandler():IsRace(RACE_SPELLCASTER) then
		return false
	else
		return not Duel.IsExistingMatchingCard(c65000012.remfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
	end
end

function c65000012.remfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end

function c65000012.oppremcon(e)
	return not Duel.IsExistingMatchingCard(c65000012.remfilter, e:GetHandlerPlayer(), 0, LOCATION_MZONE, 1, nil)
end
