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
	--local e3=Bilighteral.AddTrapEffect({handler=c,cat=CATEGORY_SPECIAL_SUMMON,prop=EFFECT_FLAG_CARD_TARGET,con=s.trapcon,tg=s.traptg,op=s.trapop})
	--c:RegisterEffect(e3)
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
	local rk,att=c:GetRank(),c:GetAttribute()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and (c:GetAttribute()&ATTRIBUTE_LIGHT==ATTRIBUTE_LIGHT or c:GetAttribute()&ATTRIBUTE_DARK==ATTRIBUTE_DARK) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk,pg,att) --and c:IsSetCard(0x400)
end

function s.filter2(c,e,tp,mc,rk,pg,att)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and not c:IsRank(rk) and not c:IsAttribute(att) and mc:IsCanBeXyzMaterial(c,tp)
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

--attach + reset

function s.atfilter(c,tc)
	return (c:GetAttribute()&ATTRIBUTE_LIGHT==ATTRIBUTE_LIGHT or c:GetAttribute()&ATTRIBUTE_DARK==ATTRIBUTE_DARK) and c:IsCanBeXyzMaterial(tc)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,nil)
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
		local tc=Duel.GetTargetCards(e)
		if not tc or not cc then return end
		Duel.Overlay(cc,tc)
		Duel.SSet(tp,c)
	end
end