--Firebound Outrage-Gargoyle
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Ritual Summon procedure
    --Battle effect: attack again
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_BATTLE_DESTROYING)
    e1:SetCondition(aux.bdocon)
    e1:SetOperation(s.atop)
    c:RegisterEffect(e1)
    --GY effect: banish opponent's card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_REMOVE)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
end

-- Attack again if destroy monster by battle
function s.atop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToBattle() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EXTRA_ATTACK)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
        c:RegisterEffect(e1)
        --Cannot attack directly this turn
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
        c:RegisterEffect(e2)
    end
end

-- Banish opponent's card if this card in GY is banished
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end
