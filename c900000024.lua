local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Filter for "Firebound" cards
function s.fireboundfilter(c)
    return c:IsSetCard(0x4D2) and not c:IsCode(id)
end

-- Filter for banished "Firebound" monsters
function s.banishfilter(c,e,tp)
    return c:IsSetCard(0x4D2) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end

-- Target function
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fireboundfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(s.banishfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end

-- Activate function
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectMatchingCard(tp,s.fireboundfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
    if #g1>0 and Duel.Destroy(g1,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        local g2=Duel.SelectMatchingCard(tp,s.banishfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
        local tc=g2:GetFirst()
        if tc then
            if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
                Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
            else
                Duel.SendtoHand(tc,nil,REASON_EFFECT)
            end
        end
    end
    -- Ensure the card goes to the GY after resolving its effect
    Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
end
