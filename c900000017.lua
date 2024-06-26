--Firebound Candlelight of Curses
local s,id=GetID()
function s.initial_effect(c)
    --Negate activation and destroy
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    --Set from GY
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

--Condition to negate activation
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(s.fire_ritual_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.fire_ritual_filter(c)
    return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_FIRE)
end

--Target for negate activation
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end

--Operation for negate activation
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #g>0 then
            Duel.HintSelection(g)
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end

--Condition to set from GY
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT) and e:GetHandler():IsLocation(LOCATION_GRAVE)
end

--Filter for FIRE monsters in GY
function s.fire_filter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemove()
end

--Target for set from GY
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fire_filter,tp,LOCATION_GRAVE,0,2,nil)
        and e:GetHandler():IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_GRAVE)
end

--Operation for set from GY
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.fire_filter,tp,LOCATION_GRAVE,0,2,2,nil)
    if #g==2 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==2 then
        if c:IsRelateToEffect(e) and c:IsSSetable() then
            Duel.SSet(tp,c)
            --Banish it if it leaves the field
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3300)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1)
        end
    end
end
