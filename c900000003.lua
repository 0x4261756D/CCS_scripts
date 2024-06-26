--Firebound Traitor
local s,id=GetID()
function s.initial_effect(c)
    --Destroy and destroy
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    --Add banished "Firebound" Ritual Monster to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

--Destroy and destroy target
function s.desfilter(c,e)
    return c:IsSetCard(0x4D2) and c:IsDestructable() and c~=e:GetHandler()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,e)
        and Duel.IsExistingTarget(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,e)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g2=Duel.SelectTarget(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,1,nil)
    e:SetLabelObject(g1:GetFirst())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc1=e:GetLabelObject()
    if tc1 and Duel.Destroy(tc1,REASON_EFFECT)>0 then
        local g2=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
        local tc2=g2:GetFirst()
        if tc2 and Duel.Destroy(tc2,REASON_EFFECT)>0 and tc1:IsType(TYPE_RITUAL) then
            local c=e:GetHandler()
            local atk=tc1:GetBaseAttack()
            local def=tc1:GetBaseDefense()
            if atk<0 then atk=0 end
            if def<0 then def=0 end
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
            c:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
            e2:SetValue(def)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
            c:RegisterEffect(e2)
        end
    end
end

--Condition for adding banished "Firebound" Ritual Monster to hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end

--Target for adding banished "Firebound" Ritual Monster to hand
function s.thfilter(c)
    return c:IsSetCard(0x4D2) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end

--Operation for adding banished "Firebound" Ritual Monster to hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
