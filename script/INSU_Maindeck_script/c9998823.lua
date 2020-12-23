--Knochenschaedel Heatad 
function c9998823.initial_effect(c)
	aux.EnableGeminiAttribute(c)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_TO_DECK)
	e1:SetCondition(c9998823.condition)
	e1:SetTarget(c9998823.target)
	e1:SetOperation(c9998823.operation)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c9998823.spcondition)
	e2:SetTarget(c9998823.sptarget)
	e2:SetOperation(c9998823.spoperation)
	c:RegisterEffect(e2)
end

function c9998823.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE)
		and (c:IsType(TYPE_Gemini) or c:IsType(TYPE_NORMAL))
		--
end
function c9998823.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.IsGeminiState(e) and eg:IsExists(c9998823.cfilter,1,nil,tp)
end
function c9998823.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function c9998823.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.Remove(g,nil,2,REASON_EFFECT)
end

function c9998823.spcondition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetPreviousLocation()==LOCATION_MZONE and
    e:GetHandler():GetPreviousTypeOnField()&TYPE_EFFECT>0
end
function c9998823.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c9998823.sptarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c9998823.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end

function c9998823.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsFaceup() and c:IsAbleToDeck()
end
function c9998823.spoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c9998823.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 
		and Duel.IsExistingMatchingCard(c9998823.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) then
		local h=Duel.SelectMatchingCard(tp,c9998823.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SendtoDeck(h,nil,2,REASON_EFFECT)
	end
end