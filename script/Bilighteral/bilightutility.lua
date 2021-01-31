Duel.LoadScript("customutility.lua")

function Card.IsTrapspell(c)
	return c:IsType(TYPE_SPELL) and c:IsType(TYPE_TRAP)
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
end

function Bilighteral.spellcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp
end

function Bilighteral.spellcon2(con)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return Bilighteral.spellcon(e,tp,eg,ep,ev,re,r,rp) and con(e,tp,eg,ep,ev,re,r,rp)
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
	if con then e:SetCondition(Bilighteral.spellcon2(con))
		else e:SetCondition(Bilighteral.spellcon)
	end
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

function Bilighteral.trapcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_SZONE) and e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end

function Bilighteral.trapcon2(con)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return Bilighteral.trapcon(e,tp,eg,ep,ev,re,r,rp) and con(e,tp,eg,ep,ev,re,r,rp)
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
		if con then 
			e:SetCondition(Bilighteral.trapcon2(con))
			else e:SetCondition(Bilighteral.trapcon)
		end
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