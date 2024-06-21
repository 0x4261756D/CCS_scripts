-- Firebound Token
local s,id=GetID()
function s.initial_effect(c)
    -- token cannot attack
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    c:RegisterEffect(e1)
end
