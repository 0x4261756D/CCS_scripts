local s,id=GetID()
function s.initial_effect(c)
    -- Effect 1: Ritual Summon
    local e1=Ritual.CreateProc({
        handler=c,
        lvtype=RITPROC_EQUAL,
        filter=s.ritual_filter,
        extrafil=s.extrafil,
        location=LOCATION_HAND+LOCATION_MZONE,
        required_level=aux.FilterBoolFunction(Card.IsSetCard,0x4D2),
        required_lvtype=RITPROC_GREATER_EQUAL
    })
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Effect 2: Double Battle Damage from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.damcost)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)
end

function s.ritual_filter(c)
    return c:IsSetCard(0x4D2) and c:IsLevelAbove(8)
end

function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
    return Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
end

function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.damcostfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) and e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.damcostfilter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
    if g:GetCount()>0 then
        g:AddCard(e:GetHandler())
        Duel.Remove(g,POS_FACEUP,REASON_COST)
    end
end

function s.damcostfilter(c,exclude)
    return c:IsSetCard(0x4D2) and c:IsType(TYPE_RITUAL) and c:IsAbleToRemoveAsCost() and c~=exclude
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetValue(s.damval)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(e2,tp)
end

function s.damval(e,re,val,r,rp,rc)
    if r&REASON_BATTLE~=0 and rc and rc:IsType(TYPE_RITUAL) and rc:IsAttribute(ATTRIBUTE_FIRE) then
        return val*2
    else
        return val
    end
end
