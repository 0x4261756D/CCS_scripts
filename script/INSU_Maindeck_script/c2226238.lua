--Mask of Emunity
--Aubertin
function c2226238.initial_effect(c)
         aux.AddEquipProcedure(c)
         --unaffected
         local e2=Effect.CreateEffect(c)
         e2:SetType(EFFECT_TYPE_EQUIP)
	     e2:SetCode(EFFECT_IMMUNE_EFFECT)
      	 e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	     e2:SetRange(LOCATION_MZONE)
	     e2:SetValue(c2226238.efilter)
         c:RegisterEffect(e2)
         --cannot attack directly
         local e3=Effect.CreateEffect(c)
	     e3:SetType(EFFECT_TYPE_EQUIP)
	     e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
         c:RegisterEffect(e3)
	     --immune to spells
	     local e4=Effect.CreateEffect(c)
	     e4:SetType(EFFECT_TYPE_SINGLE)
	     e4:SetCode(EFFECT_IMMUNE_EFFECT)
	     e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	     e4:SetRange(LOCATION_SZONE)
	     e4:SetValue(c2226238.filter)
         c:RegisterEffect(e4)
         --add to hand
         local e5=Effect.CreateEffect(c)
	     e5:SetDescription(aux.Stringid(2226238,0))
	     e5:SetCategory(CATEGORY_TOHAND)
	     e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	     e5:SetCode(EVENT_TO_GRAVE)
	     e5:SetCountLimit(1,2226238+EFFECT_COUNT_CODE_DUEL)
	     e5:SetTarget(c2226238.target)
	     e5:SetOperation(c2226238.operation)
	     c:RegisterEffect(e5)
end
function c2226238.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c2226238.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,2,REASON_EFFECT)
		end       
end
    function c2226238.efilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
function c2226238.filter(e,te)
	return te:IsActiveType(TYPE_SPELL) and te:GetOwner()~=e:GetOwner()
end