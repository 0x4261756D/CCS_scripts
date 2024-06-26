local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Can be used as the entire requirement for a Ritual Summon
    Ritual.AddWholeLevelTribute(c,aux.FilterBoolFunction(Card.IsSetCard,0x4D2))

    -- Effect 2: Special Summon itself when destroyed by a card effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)
    
    -- Banish when it leaves the field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCondition(s.rmcon)
    e2:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return (r&REASON_EFFECT)~=0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
            c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
        end
    end
end

function s.rmcon(e)
    return e:GetHandler():GetFlagEffect(id)~=0
end
