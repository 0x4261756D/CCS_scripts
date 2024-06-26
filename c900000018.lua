--Strike of the Firebound
local s,id=GetID()
function s.initial_effect(c)
    --Activate and Continuous Spell
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    --Destroy 1 "Firebound" card to target 1 card and negate its effects, reduce ATK to 0 if it's a monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
    
    --If this card is destroyed by a card effect: additional Normal Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.nscon)
    e3:SetOperation(s.nsop)
    c:RegisterEffect(e3)
end

--Filter for "Firebound" cards
function s.firebound_filter(c)
    return c:IsSetCard(0x4D2) and c:IsDestructable()
end

--Cost function for negation effect
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.firebound_filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.firebound_filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
    Duel.Destroy(g,REASON_COST)
end

--Target function for negation effect
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
    if g:GetFirst():IsType(TYPE_MONSTER) then
        Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
    end
end

--Operation function for negation effect
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        if tc:IsType(TYPE_MONSTER) then
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetCode(EFFECT_SET_ATTACK_FINAL)
            e2:SetValue(0)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
end

--Condition for additional Normal Summon
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end

--Operation for additional Normal Summon
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4D2))
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
