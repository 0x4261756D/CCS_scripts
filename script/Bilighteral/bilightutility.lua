Duel.LoadScript("customutility.lua")

function Card.IsTrapspell(c)
	local e=c:IsHasEffect(EFFECT_ADD_TYPE)
	return c:IsType(TYPE_TRAP) and e:GetValue()==TYPE_SPELL
end

Bilighteral={}

function Bilighteral.CreateActivation(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(TYPE_SPELL)
	e2:SetRange(LOCATION_ALL)
	c:RegisterEffect(e2)
end

function Bilighteral.spellcon(con)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp
	end
end

Bilighteral.AddSpellEffect=aux.FunctionWithNamedArgs(
function(c,cat,prop,con,cost,tg,op)
	local e=Effect.CreateEffect(c)
	e:SetDescription(3403)
	if cat then
		e:SetCategory(cat)
	end
	if prop then
		e:SetProperty(prop)
	end
	e:SetType(EFFECT_TYPE_ACTIVATE)
	e:SetCode(EVENT_FREE_CHAIN)
	e:SetCountLimit(1,c:GetOriginalCode())
	e:SetCondition(Bilighteral.spellcon(con))
	if cost then
		e:SetCost(cost)
	end
	if tg then
		e:SetTarget(tg)
	end
	if op then
		e:SetOperation(op)
	end
	return e
end,"handler","cat","prop","con","cost","tg","op")

function Bilighteral.trapcon(con)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and e:GetHandler():IsLocation(LOCATION_SZONE) and e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
	end
end

Bilighteral.AddTrapEffect=aux.FunctionWithNamedArgs(
	function(c,cat,prop,con,cost,tg,op) 
		local e=Effect.CreateEffect(c)
		e:SetDescription(3404)
		if cat then
			e:SetCategory(cat)
		end
		e:SetType(EFFECT_TYPE_ACTIVATE)
		e:SetCode(EVENT_FREE_CHAIN)
		e:SetCountLimit(1,c:GetOriginalCode()+100)
		if prop then
			e:SetProperty(prop)
		end
		e:SetCondition(Bilighteral.trapcon(con))
		if cost then
			e:SetCost(cost)
		end
		if tg then
			e:SetTarget(tg)
		end
		if op then
			e:SetOperation(op)
		end
		return e
end,"handler","cat","prop","con","cost","tg","op")

function Bilighteral.remfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x400) and c:IsMonster()
end

function Bilighteral.bmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Bilighteral.remfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,Bilighteral.remfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
