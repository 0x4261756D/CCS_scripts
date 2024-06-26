local s,id=GetID()
function s.initial_effect(c)
    -- Ritual Summon Clause
    c:EnableReviveLimit()

    -- Quick Effect: Destroy cards in column and draw
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- GY Effect: Shuffle into Deck and banish from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_REMOVED)
    e2:SetCountLimit(1,{id,2})
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

-- Filter for FIRE monsters
function s.firefilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE)
end

-- Target for quick effect
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local col=e:GetHandler():GetColumnGroup()
        return #col>0
    end
    local g=e:GetHandler():GetColumnGroup()
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,g:FilterCount(s.firefilter,nil))
end

-- Operation for quick effect
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=c:GetColumnGroup()
    local fireCount = g:FilterCount(s.firefilter,nil)
    if #g>0 then
        local ct=Duel.Destroy(g,REASON_EFFECT)
        if ct>0 and fireCount>0 then
            Duel.BreakEffect()
            Duel.Draw(tp,fireCount,REASON_EFFECT)
        end
    end
end

-- Target for GY effect
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeck()
        and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end

-- Operation for GY effect
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        end
    end
end
