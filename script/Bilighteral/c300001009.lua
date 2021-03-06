--RCM－Bilighteral Spark Force
Duel.LoadScript("bilightutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Act in za hando and on za fieldo
	Bilighteral.CreateActivation(c)
	--Spell Effect
	local e2=Bilighteral.AddSpellEffect({handler=c,cat=CATEGORY_SPECIAL_SUMMON,prop=EFFECT_FLAG_CARD_TARGET,tg=s.spelltg,op=s.spellop})
	c:RegisterEffect(e2)
	--Trap Effect
	local e3=Bilighteral.AddTrapEffect({handler=c,cat=CATEGORY_SPECIAL_SUMMON,prop=EFFECT_FLAG_CARD_TARGET,cost=s.trapcost,tg=s.traptg,op=s.trapop})
	c:RegisterEffect(e3)
	--Attach + reset
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1,id+101)
	e4:SetCost(s.cost)
	e4:SetTarget(s.tg(c))
	e4:SetOperation(s.op(c))
	c:RegisterEffect(e4)
end

--Spell Effect

function s.filter1(c,e,tp)
	local rk=c:GetRank()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and (c:GetAttribute()&ATTRIBUTE_LIGHT==ATTRIBUTE_LIGHT or c:GetAttribute()&ATTRIBUTE_DARK==ATTRIBUTE_DARK) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk,pg,att) and c:IsSetCard(0x400)
end

function s.filter2(c,e,tp,mc,rk,pg)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and (c:IsRank(rk+1) or c:IsRank(rk-1)) and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

function s.spelltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spellop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank(),pg,tc:GetAttribute()):GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if #mg>0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(1)
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return sc:GetAttribute()&ATTRIBUTE_LIGHT==ATTRIBUTE_LIGHT end)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return sc:GetAttribute()&ATTRIBUTE_DARK==ATTRIBUTE_DARK end)
		sc:RegisterEffect(e2)
		sc:CompleteProcedure()
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Overlay(sc,c)
			c:CancelToGrave()
		end
	end
end

--Trap Effect

function s.tfilter(c,tp,g)
	return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_EXTRA,0,1,nil,c,g) and c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsSetCard(0x400)
end

function s.rfilter(c,tc,g)
	return c:GetRank()~=tc:GetRank() and not c:IsPublic() and #g>=math.abs(tc:GetRank()-c:GetRank()) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x400)
end

function s.remfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x400)
end

function s.trapcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.remfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil,tp,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc1=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,g):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc2=Duel.SelectMatchingCard(tp,aux.spfilter(e,tp,SUMMON_TYPE_XYZ,s.rfilter,tc1,g),tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc2)
	local ct=math.abs(tc1:GetRank()-tc2:GetRank())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rem=Duel.SelectMatchingCard(tp,s.remfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,ct,ct,nil)
	Duel.Remove(rem,POS_FACEUP,REASON_COST)
	e:SetLabelObject({tc1,tc2})
end

function s.traptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.trapop(e,tp,eg,ep,ev,re,r,rp)
	local c,tc1,tc2=e:GetHandler(),table.unpack(e:GetLabelObject())
	Duel.Overlay(tc2,Group.FromCards(tc1)+tc1:GetOverlayGroup())
	Duel.SpecialSummon(tc2,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
	tc2:CompleteProcedure()
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Overlay(tc2,c)
		c:CancelToGrave()
	end
end

--Attach + Reset

function s.atfilter(c,tc)
	return (c:GetAttribute()&ATTRIBUTE_LIGHT==ATTRIBUTE_LIGHT or c:GetAttribute()&ATTRIBUTE_DARK==ATTRIBUTE_DARK) and c:IsCanBeXyzMaterial(tc)
end

function s.setfilter(c)
	return c:IsSSetable() and c:IsTrapspell()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST,nil)
end

function s.tg(c)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsSSetable() end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local tc=Duel.SelectMatchingCard(tp,s.atfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetHandler())
		Duel.SetTargetCard(tc)
	end
end

function s.op(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local cc=e:GetHandler()
		local tc=Duel.GetTargetCards(e):GetFirst()
		if not tc or not cc then return end
		local set,disc=tc:GetAttribute()&ATTRIBUTE_LIGHT==ATTRIBUTE_LIGHT and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil),tc:GetAttribute()&ATTRIBUTE_DARK==ATTRIBUTE_DARK and #(Duel.GetFieldGroup(tp,0,LOCATION_HAND):Filter(Card.IsDiscardable,nil))>0
		local additional=set and disc
		Duel.Overlay(cc,tc)
		Duel.SSet(tp,c)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		c:RegisterEffect(e1)
		if Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			local choice=aux.EffectCheck(tp,{set,disc},{aux.Stringid(id,2),aux.Stringid(id,3)})(e,tp,eg,ep,ev,re,r,rp)
			if choice==1 then
				tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
				Duel.SSet(tp,tc)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				tc:RegisterEffect(e2)
				if additional and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
					Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_HAND))
					tc=Duel.GetFieldGroup(tp,0,LOCATION_HAND):FilterSelect(tp,Card.IsDiscardable,1,nil)
					Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
				end
			end
			if choice==2 then
				Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_HAND))
				tc=Duel.GetFieldGroup(tp,0,LOCATION_HAND):FilterSelect(tp,Card.IsDiscardable,1,1,nil)
				Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
				if additional and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
					tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
					Duel.SSet(tp,tc)
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
					tc:RegisterEffect(e3)
				end
			end
		end
	end
end