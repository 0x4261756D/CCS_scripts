local s,id=GetID()
function s.initial_effect(c)
    -- Activate (Continuous Spell)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    -- Effect 1: Destroy 1 other "Firebound" card to draw 1 card during Main Phase
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.mainphasecon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    
    -- Effect 2: If destroyed by a card effect, draw 2 and reveal
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
end

-- Effect 1: Main Phase Condition
function s.mainphasecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

-- Effect 1: Destroy 1 other "Firebound" card to draw 1 card
function s.filter(c)
    return c:IsSetCard(0x4D2) and c:IsDestructable()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler()) and Duel.IsPlayerCanDraw(tp,1) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler())
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc then
        if tc:IsLocation(LOCATION_HAND) then
            Duel.ConfirmCards(1-tp,tc)
        end
        if Duel.Destroy(tc,REASON_EFFECT)~=0 then
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end

-- Effect 2: If destroyed by a card effect, draw 2 and reveal
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return r&REASON_EFFECT~=0
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,2,REASON_EFFECT)==2 then
        Duel.ConfirmCards(1-tp,Duel.GetOperatedGroup())
        local g=Duel.GetOperatedGroup()
        if g:IsExists(Card.IsSetCard,1,nil,0x4D2) then
            Duel.ShuffleHand(tp)
        else
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end
