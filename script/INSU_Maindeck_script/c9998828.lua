--Verstecktes Potential
function c9998828.initial_effect(c)
	c:SetUniqueOnField(1,0,9998828)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--additional summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCondition(c9998828.sumcon)
	e2:SetTarget(c9998828.sumtg)
	e2:SetOperation(c9998828.sumop)
	c:RegisterEffect(e2)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c9998828.drcon)
	e3:SetTarget(c9998828.drtg)
	e3:SetOperation(c9998828.drop)
	c:RegisterEffect(e3)
end
function c9998828.cfilter(c,tp)
	return (c:IsPreviousLocation(LOCATION_ONFIELD) or c:IsPreviousLocation(LOCATION_GRAVE))
	 and ((c:IsRace(RACE_FAIRY)	and c:IsAttribute(ATTRIBUTE_DARK) and c:GetLevel()==1) or c:IsSetCard(0x29A))
		and c:IsControler(tp) and c:GetPreviousControler()==tp
end
function c9998828.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c9998828.cfilter,1,nil,tp)
	--and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end

function c9998828.filter(c,e,tp)
	return c:IsSetCard(0x29A) and c:IsSummonable(true,nil)
end
function c9998828.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c9998828.filter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c9998828.sumop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c9998828.filter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		if g:GetFirst():IsLocation(LOCATION_MZONE) then
			g:GetFirst():EnableGeminiState()
		end
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end
function c9998828.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
function c9998828.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c9998828.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end