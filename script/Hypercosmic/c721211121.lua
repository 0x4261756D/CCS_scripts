-- Hypermatter
Duel.LoadScript("customutility.lua")
local s, id = GetID()

function s.initial_effect(c)
	-- Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	-- Add from GY to hand
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION + EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.handtg)
	e2:SetOperation(s.handop)
	c:RegisterEffect(e2)
	-- Add from banished to hand
	local e3 = e2:Clone()
	e3:SetRange(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end

s.should_banish = false

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then 
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_HAND, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local tc = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp):GetFirst()
	hypercosmic_op(tc, tp, e)
	if s.should_banish then
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCondition(s.banfilter)
		e1:SetValue(LOCATION_REMOVED)
		e:GetHandler():RegisterEffect(e1)
	end
	s.should_banish = not s.should_banish
end

function s.banfilter(e)
	return e:GetHandler():IsFaceup()
end

function s.filter(c, e, tp)
	return c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.handtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.handop(e,tp,eg,ep,ev,re,r,rp)
	local tc = e:GetHandler()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc, nil, REASON_EFFECT)
		if tc:IsPreviousLocation(LOCATION_REMOVED) then
			local e1=Effect.CreateEffect(tc)
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e1:SetCode(EFFECT_CANNOT_ACTIVATE)
            e1:SetTargetRange(1, 0)
            e1:SetValue(s.aclimit)
            e1:SetReset(RESET_PHASE + PHASE_END)
            Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.aclimit(e,re,tp)
    return re:GetHandler():IsCode(e:GetHandler():GetCode())
end