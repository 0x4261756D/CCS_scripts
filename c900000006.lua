local s,id=GetID()
function s.initial_effect(c)
    -- Ritual Summon
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Shuffle from GY to Deck and destroy
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- Ritual Summon any "Firebound" Ritual Monster
function s.filter(c,e,tp,m1,m2,ft)
    if not c:IsSetCard(0x4D2) or bit.band(c:GetType(),0x81)~=0x81
        or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
    local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
    mg:Merge(m2)
    mg:RemoveCard(c)
    if c.mat_filter then
        mg=mg:Filter(c.mat_filter,nil)
    end
    return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c)
end

function s.matfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg1=Duel.GetRitualMaterial(tp)
        local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND,0,nil)
        return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,mg1,mg2)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local mg1=Duel.GetRitualMaterial(tp)
    local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,mg1,mg2)
    local tc=tg:GetFirst()
    if tc then
        local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
        mg:Merge(mg2)
        mg:RemoveCard(tc)
        if tc.mat_filter then
            mg=mg:Filter(tc.mat_filter,nil)
        end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
        tc:SetMaterial(mat)
        Duel.ReleaseRitualMaterial(mat)
        Duel.BreakEffect()
        Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
        tc:CompleteProcedure()
    end
end

-- Effect 2: Shuffle from GY to Deck and destroy
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and e:GetHandler():IsAbleToDeck() end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
            Duel.Destroy(tc,REASON_EFFECT)
        end
    end
end
