-- Hypercosmic Hypermatter Gate

local s, id = GetID()

function s.initial_effect(c)
	-- Cannot be Normal Summoned/Set.
	c:EnableUnsummonable()
	-- If you Summoned 1+ monster this turn, while this card is in your hand or banished: You can Special Summon this card (This effect cannot be negated).
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_HAND + LOCATION_REMOVED)
	e1:SetCondition(s.spcon)
	e1:SetCountLimit(1, {id, 1})
	c:RegisterEffect(e1)
	-- You can send 1 "Hypermatter" from your hand or Deck to the GY; Special Summon 1 monster from your Deck or GY, but its ATK/DEF become 0 and its effects become negated, then, immediately after this effect resolves, banish that monster
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, {id, 2})
	e2:SetCost(s.cost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end

function s.spcon(e, c)
	if c == nil then return true end
	return (Duel.GetActivityCount(e:GetHandlerPlayer(), ACTIVITY_SUMMON) > 0) or 
		(Duel.GetActivityCount(e:GetHandlerPlayer(), ACTIVITY_SPSUMMON) > 0)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_HAND, 0, 1, e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_HAND, 1, 0, 1, 1)
	Duel.SendtoGrave(g, REASON_COST)
end

function s.filter(c)
	return c:IsAbleToGraveAsCost() and c:IsCode(721211121)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then 
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and 
			Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) 
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local tc = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2 = e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		local e3 = Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK)
		e3:SetReset(RESET_EVENT + RESETS_STANDARD)
		e3:SetValue(0)
		tc:RegisterEffect(e3)
		local e4 = e3:Clone()
		e4:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e4)
	end
	Duel.SpecialSummonComplete()
	if tc:IsAbleToRemove() and tc:IsFaceup() then
		Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)
	end
end

function s.spfilter(c, e, tp)
	return c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end