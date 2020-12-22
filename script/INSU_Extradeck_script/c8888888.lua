
function c8888888.initial_effect(c)
	c:EnableReviveLimit()
	--link summon
	Link.AddProcedure(c,c8888888.matfilter,1,1)
	--reveal
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(c8888888.revtg)
    e1:SetOperation(c8888888.revop)
    c:RegisterEffect(e1)
end
function c8888888.matfilter(c,lc,sumtype,tp)
	return not c:IsType(TYPE_TOKEN,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end
function c8888888.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetTargetPlayer(tp)
end
function c8888888.revop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil,tp)
    local sg=g:RandomSelect(tp,1)
    local tc=sg:GetFirst()
    if tc then
        Duel.ConfirmCards(tp,tc)
        Duel.ShuffleHand(1-tp)
    end
end
