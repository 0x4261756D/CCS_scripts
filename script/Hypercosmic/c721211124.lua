-- Zrez the Hypercosmic Nexus

local s, id = GetID()

function s.initial_effect(c)
	-- Cannot be Normal Summoned/Set.
	c:EnableUnsummonable()
	-- Summonable after 3 monsters with different levels
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_HAND + LOCATION_REMOVED)
	e1:SetCondition(s.spcon)
	e1:SetCountLimit(1, {id, 1})
	c:RegisterEffect(e1)
	aux.GlobalCheck(s, function()
		s[0] = 0
		s[1] = {}
		local ge1 = Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1, 0)
		local ge2 = ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge2, 0)
		local ge3 = ge1:Clone()
		ge3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge3, 0)
		aux.AddValuesReset(function()
			s[0] = 0
			s[1] = {}
		end)
	end)
	-- ATK/DEF increase
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3 = e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- Add "Hypermatter" to hand
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 0))
	e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1, {id, 2})
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if s[0] >= 3 then return end
	local tc = eg:GetFirst()
	for tc in aux.Next(eg) do
		if s[0] < 3 and tc:IsFaceup() and not s[1][tc:GetLevel()] then
			s[1][tc:GetLevel()] = true
			s[0] = s[0] + 1
		end
	end
end

function s.spcon(e, c)
	return s[0] >= 3
end

function s.val(e, c)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(), LOCATION_DECK, 0) * 100
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK + LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK + LOCATION_GRAVE)
end

function s.thfilter(c)
	return c:IsCode(721211121) and c:IsAbleToHand()
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK + LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not (tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0) then return end
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleDeck(tp)
end
