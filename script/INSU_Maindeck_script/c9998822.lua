--Knochenschädel Grimper
function c9998822.initial_effect(c)
	aux.EnableGeminiAttribute(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c9998822.spcon)
	e1:SetTarget(c9998822.sptg)
	e1:SetOperation(c9998822.spop)
	c:RegisterEffect(e1)
	--spsummon 
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,9998822)
	e2:SetCondition(c9998822.spcondition)
	e2:SetTarget(c9998822.sptarget)
	e2:SetOperation(c9998822.spoperation)
	c:RegisterEffect(e2)
end
function c9998822.cfilter(c)
	return c:IsType(TYPE_NORMAL)
end
function c9998822.spcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.IsGeminiState(e) and eg:IsExists(c9998822.cfilter,1,nil)
end

function c9998822.filter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c9998822.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c9998822.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c9998822.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c9998822.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c9998822.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
	 	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c9998822.spfilter(c,e,tp)
	return  c:IsType(TYPE_Gemini) and c:GetLevel()==1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c9998822.spcondition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetPreviousLocation()==LOCATION_MZONE and
    e:GetHandler():GetPreviousTypeOnField()&TYPE_EFFECT>0
end
function c9998822.sptarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c9998822.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c9998822.spoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c9998822.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		tc:EnableGeminiState()
	end
end