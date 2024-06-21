--Firebound Eruption-Snake
local s,id=GetID()
function s.initial_effect(c)
    --Ritual Summon
    c:EnableReviveLimit()

    --Inflict damage when a "Firebound" card is destroyed
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.damcon1)
    e1:SetOperation(s.damop1)
    c:RegisterEffect(e1)
    
    --Inflict damage when banished
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.damtg2)
    e2:SetOperation(s.damop2)
    c:RegisterEffect(e2)
end

--Condition to inflict damage when a "Firebound" card is destroyed
function s.cfilter(c,tp)
    return c:IsSetCard(0x4D2) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end

function s.damcon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp) and e:GetHandler():IsFaceup()
end

function s.damop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_CARD,0,id)
    Duel.Damage(1-tp,800,REASON_EFFECT)
end

--Target and Operation to inflict damage when banished
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end

function s.damop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(1-tp,1500,REASON_EFFECT)
end
