local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon Effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Banished Effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,2})
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end

-- Filter for "Firebound" cards
function s.fireboundfilter(c)
    return c:IsSetCard(0x4D2) and not c:IsCode(id)
end

-- Filter for "Firebound" Ritual Monsters
function s.ritualfilter(c)
    return c:IsSetCard(0x4D2) and c:IsType(TYPE_RITUAL)
end

-- Special Summon Effect target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fireboundfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingMatchingCard(s.ritualfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Special Summon Effect operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.fireboundfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local tg=Duel.SelectMatchingCard(tp,s.ritualfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #tg>0 then
                Duel.SendtoGrave(tg,REASON_EFFECT)
            end
        end
    end
end

-- Banished Effect target
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fireboundfilter,tp,LOCATION_MZONE,0,1,nil) end
end

-- Banished Effect operation
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,s.fireboundfilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end
