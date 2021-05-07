--Black-to-Back Wave
Duel.LoadScript("bilightutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Act in za hando and on za fieldo
	Bilighteral.CreateActivation(c)
	--Spell Effect
	local e2=Bilighteral.AddSpellEffect({handler=c,cat=CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_DAMAGE,prop=EFFECT_FLAG_CARD_TARGET,cost=s.spellcost,tg=s.spelltg,op=s.spellop})
	c:RegisterEffect(e2)
	--Trap Effect
	local e3=Bilighteral.AddTrapEffect({handler=c,cat=CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER+CATEGORY_DISABLE,prop=EFFECT_FLAG_CARD_TARGET,cost=s.trapcost,tg=s.traptg,op=s.trapop})
	c:RegisterEffect(e3)
end

--Spell Effect

function s.tgfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:GetOverlayGroup():IsExists(s.detfilter,1,nil,tp)
end

function s.detfilter(c,tp)
	return (c:IsAttribute(ATTRIBUTE_LIGHT) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)) or (c:IsAttribute(ATTRIBUTE_DARK) and Duel.IsExistingTarget(s.dfilter,tp,0,LOCATION_MZONE,1,nil))
end

function s.thfilter(c)
	return c:IsSetCard(0x95) and c:IsAbleToHand()
end

function s.dfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDestructable()
end

function s.spellcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	tc=tc:GetOverlayGroup():FilterSelect(tp,s.detfilter,1,1,nil,tp):GetFirst()
	Duel.SendtoGrave(tc,REASON_EFFECT)
	e:SetLabelObject({tc,tc:GetAttribute()})
end

function s.spelltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc,att=table.unpack(e:GetLabelObject())
	local l,d=att&ATTRIBUTE_LIGHT==ATTRIBUTE_LIGHT,att&ATTRIBUTE_DARK==ATTRIBUTE_DARK
	local b=l and d
	local choice=aux.EffectCheck(tp,{l,d},{aux.Stringid(id,0),aux.Stringid(id,1)})(e,tp,eg,ep,ev,re,r,rp)
	if choice==1 then Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
		elseif choice==2 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE+CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
			else return
	end
	e:SetLabelObject({choice,b,tc})
end

function s.spellop(e,tp,eg,ep,ev,re,r,rp)
	local choice,additional,tc2=table.unpack(e:GetLabelObject())
	if (choice==1 and not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)) or (choice==2 and not Duel.IsExistingTarget(s.dfilter,tp,0,LOCATION_MZONE,1,nil)) then return end
	if choice==1 then
		local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		if additional and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			tc=Duel.SelectTarget(tp,s.dfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
			Duel.Destroy(tc,REASON_EFFECT)
			Duel.Damage(1-tp,(tc:GetTextAttack()+tc:GetTextDefense()+tc2:GetTextAttack()+tc2:GetTextDefense())/2,REASON_EFFECT)
		end
		elseif choice==2 then
			local tc=Duel.SelectTarget(tp,s.dfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
			Duel.Destroy(tc,REASON_EFFECT)
			Duel.Damage(1-tp,(tc:GetTextAttack()+tc:GetTextDefense()+tc2:GetTextAttack()+tc2:GetTextDefense())/2,REASON_EFFECT)
			if additional and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				Duel.SendtoHand(tc,tp,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			end
		else return
	end
end

--Trap Effect

function s.matfilter(c)
	return c:IsCanBeXyzMaterial() and c:IsSetCard(0x400)
end

function s.xyzfilter(c,mg)
	return c:IsXyzSummonable(nil,mg) and not c:IsPublic() and c:IsSetCard(0x400)
end

function s.trapcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then return #mg>1 and Duel.IsExistingMatchingCard(aux.spfilter(e,tp,SUMMON_TYPE_XYZ,false,false,s.xyzfilter,mg),tp,LOCATION_EXTRA,0,1,nil) end
	local tc=Duel.SelectMatchingCard(tp,aux.spfilter(e,tp,SUMMON_TYPE_XYZ,false,false,s.xyzfilter,mg),tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	mg:KeepAlive()
	e:SetLabelObject({tc,mg})
end

function s.traptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetLabelObject()[1],1,tp,LOCATION_EXTRA)
end

function s.trapop(e,tp,eg,ep,ev,re,r,rp)
	local tc,mg=table.unpack(e:GetLabelObject())
	if Duel.GetLocationCountFromEx(tp)==0 or not tc or not mg or not tc:IsXyzSummonable(nil,mg) then return end
	local mat=mg:Select(tp,tc.minxyzct,tc.maxxyzct,nil)
	Duel.Overlay(tc,mat)
	Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
	local l,d=mat:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT),mat:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK)
	local additional=l and d
	if (l or d) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.BreakEffect()
		local choice=aux.EffectCheck(tp,{aux.Stringid(id,2)},{aux.Stringid(id,3)})(e,tp,eg,ep,ev,re,r,rp)
		if choice==1 then
			local tc2=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			Duel.Overlay(tc,tc2)
			Duel.Recover(tp,(tc:GetTextAttack()+tc:GetTextDefense()+tc2:GetTextAttack()+tc2:GetTextDefense())/2,REASON_EFFECT)
			if additional and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsType,TYPE_EFFECT),tp,1,#mat,nil)
				for tc3 in ~g do
					Duel.NegateRelatedChain(tc3,RESET_TURN_SET)
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc3:RegisterEffect(e1)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetValue(RESET_TURN_SET)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc3:RegisterEffect(e2)
				end
			end
			elseif choice==2 then
				local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsType,TYPE_EFFECT),tp,1,#mat,nil)
				for tc3 in ~g do
					Duel.NegateRelatedChain(tc3,RESET_TURN_SET)
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc3:RegisterEffect(e1)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetValue(RESET_TURN_SET)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc3:RegisterEffect(e2)
				end
				if additional and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
					local tc2=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
					Duel.Overlay(tc,tc2)
					Duel.Recover(tp,(tc:GetTextAttack()+tc:GetTextDefense()+tc2:GetTextAttack()+tc2:GetTextDefense())/2,REASON_EFFECT)
				end
			else return 
		end
	end
end
