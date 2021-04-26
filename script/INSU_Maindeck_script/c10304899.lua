--Errata Representative
local s, id = GetID()
function s.initial_effect(c)
    --change effect
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
	--e1:SetCountLimit(1)
	e1:SetCondition(s.chcon)
	e1:SetCost(s.chcost)
    e1:SetOperation(s.chop)
    c:RegisterEffect(e1)
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return --(re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
		--and
		 not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
    local che1=Duel.IsExistingMatchingCard(aux.TRUE,rp,0,LOCATION_ONFIELD,1,nil)
	local a1=nil
    if che1==false then a1=1
	
	else a1=Duel.SelectOption(1-tp,aux.Stringid(10304899,0),aux.Stringid(10304899,1))
	end
	if a1==1 then
		Debug.Message(tp)
		Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
        local g=Group.CreateGroup()
		--Debug.Message("Destruction Operation selected")
        Duel.ChangeTargetCard(ev,g)
        Duel.ChangeChainOperation(ev,s.repop1)
    elseif a1==0 then
        Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
		--Debug.Message("Attack change operation selected")
        local g=Group.CreateGroup()
        Duel.ChangeTargetCard(ev,g)
        Duel.ChangeChainOperation(ev,s.repop2)
	end
end
function s.repop1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.HintSelection(g)
        Duel.Destroy(g,REASON_EFFECT)
    end
end
function s.repop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()    
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
    if g:GetCount()>0 then
        Duel.HintSelection(g)
        local tc=g:GetFirst()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(2000)
        e1:SetReset(RESET_EVENT+0x1fe0000)
        tc:RegisterEffect(e1)
    end
end