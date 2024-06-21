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
        required_lvtype=RITPROC_LESS_EQUAL
    })
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Effect 2: Return from GY to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.ritual_filter(c)
    return c:IsSetCard(0x4D2) and c:IsLevelBelow(6)
end

function s.extrafil(e,tp,eg,ep,ev,re,r,rp,chk)
    return Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
    local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.thcostfilter(c)
    return c:IsSetCard(0x4D2) and c:IsType(TYPE_RITUAL) and not c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end
