--Kashtira the Runick Savior
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,{SET_RUNICK,SET_KASHTIRA}),2)
	--Search up to 2 "Kashtira" or "Runick" cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_EXTRA) end)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Being fucking busted
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.effcon)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end

--Search up to 2 "Kashtira" or "Runick" cards

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
    if Duel.GetOperatedGroup():GetFirst():IsSetCard({SET_KASHTIRA,SET_RUNICK}) then
        e:SetLabelObject({Duel.GetOperatedGroup():GetFirst(),2})
    else
        e:SetLabelObject({Duel.GetOperatedGroup():GetFirst(),1})
    end
end

function s.thfilter(c)
	return c:IsSetCard({SET_KASHTIRA,SET_RUNICK}) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,e:GetLabelObject()[2],e:GetLabelObject()[1])
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g:Filter(Card.IsLocation,nil,LOCATION_HAND))
	end
end

--Being fucking busted

function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	return r==REASON_SYNCHRO and rc:GetMaterial():IsExists(Card.IsSetCard,1,c,SET_KASHTIRA)
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.FALSE)
	e1:SetTarget(s.reptg)
	e1:SetOperation(s.repop)
	rc:RegisterEffect(e1)
end

function s.repfilter(c,tp)
	return c:IsControler(1-tp) and c:GetDestination()==LOCATION_REMOVED
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (r&REASON_EFFECT)~=0 and re and re:GetHandler():IsSetCard(SET_RUNICK) and eg:IsExists(s.repfilter,1,nil,tp) end
	local g=eg:Filter(s.repfilter,nil,tp)
	return #g > 0
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.repfilter,nil,tp)
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end