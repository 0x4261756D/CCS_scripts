function Auxiliary.VentusCon(con)
  return function(e,tp,eg,ep,ev,re,r,rp)
		if not re or r&REASON_COST>0 then return false end 
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and (re:GetHandler():IsAttribute(ATTRIBUTE_WIND) or re:GetHandler():IsCode(65000040))
	end
end

function hypercosmic_op(tc, tp, e)
	if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2 = e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2)
		local e3 = Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK)
		e3:SetReset(RESET_EVENT + RESETS_STANDARD)
		e3:SetValue(0)
		tc:RegisterEffect(e3)
		local e4 = e3:Clone()
		e4:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e4)
		--Cannot activate its effects
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetDescription(3302)
		e5:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_CANNOT_TRIGGER)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e5)
		Duel.SpecialSummonComplete()
		if tc:IsAbleToRemove() and tc:IsFaceup() then
			Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)
		end
	end
end
