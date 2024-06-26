--Firebound Candlelight of Curses
local s,id=GetID()
function s.initial_effect(c)
    --Activate and perform Ritual Summon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,1})
    e1:SetTarget(s.rstg)
    e1:SetOperation(s.rsop)
    c:RegisterEffect(e1)

    --Shuffle and draw
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
end

--Filter for "Firebound" Ritual Monsters
function s.ritual_filter(c,e,tp)
    return c:IsSetCard(0x4D2) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end

--Filter for monsters with level
function s.monster_filter(c)
    return c:IsLevelAbove(1) and c:IsDestructable()
end

--Target for Ritual Summon
function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.monster_filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(s.ritual_filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

--Operation for Ritual Summon
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.ritual_filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if not tc then return end
    local lv=tc:GetLevel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.monster_filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,99,nil)
    local lv_total=g:GetSum(Card.GetLevel)
    while lv_total~=lv do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        g=Duel.SelectMatchingCard(tp,s.monster_filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,99,nil)
        lv_total=g:GetSum(Card.GetLevel)
    end
    if Duel.Destroy(g,REASON_EFFECT)~=0 then
        Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
        tc:CompleteProcedure()
    end
end

--Condition for shuffle and draw
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end

--Target for shuffle and draw
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,nil)
        and Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

--Operation for shuffle and draw
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,5,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
        Duel.Draw(tp,2,REASON_EFFECT)
    end
end
