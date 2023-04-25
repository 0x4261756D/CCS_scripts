Duel.LoadScript("customutility.lua")

function Card.IsTrapSpell(c)
	local e=c:IsHasEffect(EFFECT_ADD_TYPE)
	return c:IsType(TYPE_TRAP) and e:GetValue()==TYPE_SPELL
end

Trapspell={}

function Trapspell.CreateActivation(c)
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

function Trapspell.Spellcon(con)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and Duel.GetCurrentChain()==0 and Duel.GetTurnPlayer()==tp
	end
end

Trapspell.AddSpellEffect=aux.FunctionWithNamedArgs(
function(c,cat,prop,opt,con,cost,tg,op)
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
	e:SetCountLimit(opt)
	e:SetCondition(Trapspell.Spellcon(con))
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

function Trapspell.Trapcon(con)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and e:GetHandler():IsLocation(LOCATION_SZONE) and e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
	end
end

Trapspell.AddTrapEffect=aux.FunctionWithNamedArgs(
	function(c,cat,prop,opt,con,cost,tg,op) 
		local e=Effect.CreateEffect(c)
		e:SetDescription(3404)
		if cat then
			e:SetCategory(cat)
		end
		e:SetType(EFFECT_TYPE_ACTIVATE)
		e:SetCode(EVENT_FREE_CHAIN)
		e:SetCountLimit(opt)
		if prop then
			e:SetProperty(prop)
		end
		e:SetCondition(Trapspell.Trapcon(con))
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