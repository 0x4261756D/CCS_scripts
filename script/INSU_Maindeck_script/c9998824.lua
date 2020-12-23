--Knochenschädel Karreth
function c9998824.initial_effect(c)
	aux.EnableGeminiAttribute(c)
	--summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c9998824.sumcon)
	e1:SetTarget(c9998824.sumtg)
	e1:SetOperation(c9998824.sumop)
	c:RegisterEffect(e1)
	--add
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c9998824.thcondition)
	e2:SetTarget(c9998824.thtarget)
	e2:SetOperation(c9998824.thoperation)
	c:RegisterEffect(e2)
end

function c9998824.cfilter(c)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsRace(RACE_FAIRY) and c:IsControler(tp)
		and c:GetPreviousControler()==tp
end
function c9998824.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.IsGeminiState(e) and eg:IsExists(c9998824.cfilter,1,nil)
end

function c9998824.filter(c,e,tp)
	return c:IsSetCard(0x29A) and c:IsSummonable(true,nil)
end
function c9998824.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c9998824.filter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c9998824.sumop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c9998824.filter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end

function c9998824.thfilter(c)
	return c:IsRace(RACE_FAIRY) and c:GetLevel()==1 and c:IsAbleToHand()
end
function c9998824.thcondition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetPreviousLocation()==LOCATION_MZONE and
    e:GetHandler():GetPreviousTypeOnField()&TYPE_EFFECT>0
end
function c9998824.thtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chk==0 then return Duel.IsExistingMatchingCard(c9998824.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c9998824.thoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local h=Duel.SelectMatchingCard(tp,c9998824.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if h:GetCount()>0 then
		Duel.SendtoHand(h,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,h)
	end
end