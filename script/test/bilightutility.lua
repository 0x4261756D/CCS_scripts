Bilighteral={}

function Bilighteral.CreateActivation(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	c:RegisterEffect(e1)
	return
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
	e:SetDescription(aux.Stringid(300001000,0))
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
		e:SetDescription(aux.Stringid(300001000,1))
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

function Bilighteral.AddChaosSynchroProcedure(c,f1,atmin,atmax,f2,antmin,antmax,desc)
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e:SetDescription(desc)
		else 
			e:SetDescription(aux.Stringid(300001000,2))
	end
	e:SetCode(EFFECT_SPSUMMON_PROC)
	e:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e:SetRange(LOCATION_EXTRA)
	e:SetTarget(Bilighteral.ChaosSynchroTarget(c,f1,atmin,atmax,f2,antmin,antmax))
	e:SetOperation(Bilighteral.ChaosSynchroOperation(c))
	e:SetValue(SUMMON_TYPE_SYNCHRO+69)
	c:RegisterEffect(e)
end

function Bilighteral.tfilter(c,tc,att)
	return c:IsCanBeSynchroMaterial(tc) and c:IsType(TYPE_TUNER) and c:IsAttribute(att) and c:IsAbleToRemove()
end

function Bilighteral.ntfilter(c,tc,att)
	return c:IsCanBeSynchroMaterial(tc) and not c:IsType(TYPE_TUNER) and c:IsAttribute(att) and c:IsAbleToRemove()
end

function Bilighteral.rescon(lv,gt,atmin,atmax,gnt,antmin,antmax)
	return function(sg,e,tp,mg)
		return sg:GetSum(Card.GetLevel)==lv and atmin<=#(sg-gnt) and #(sg-gnt)<=atmax and antmin<=#(sg-gt) and #(sg-gt)<=antmax,sg:GetSum(Card.GetLevel)>lv or atmin>#(sg-gnt) or #(sg-gnt)>atmax or antmin>#(sg-gt) or #(sg-gt)>antmax
	end
end

function Bilighteral.ChaosSynchroTarget(c,f1,atmin,atmax,f2,antmin,antmax)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local lv=c:GetLevel()
		local gt=Duel.GetMatchingGroup(Bilighteral.tfilter,tp,LOCATION_GRAVE,0,nil,c,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK):Filter(f1,nil)
		local gnt=Duel.GetMatchingGroup(Bilighteral.ntfilter,tp,LOCATION_GRAVE,0,nil,c,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK):Filter(f2,nil)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and aux.SelectUnselectGroup(gt+gnt,e,tp,atmin+antmin,atmax+antmax,Bilighteral.rescon(lv,gt,atmin,atmax,gnt,antmin,antmax),0) then
			local mat=aux.SelectUnselectGroup(gt+gnt,e,tp,atmin+antmin,atmax+antmax,Bilighteral.rescon(lv,gt,atmin,atmax,gnt,antmin,antmax),1,tp,nil,Bilighteral.rescon(lv,gt,atmin,atmax,gnt,antmin,antmax),Bilighteral.rescon(lv,gt,atmin,atmax,gnt,antmin,antmax),true)
			e:SetLabelObject(mat)
			mat:KeepAlive()
			return true
			else return false
		end
	end
end

function Bilighteral.ChaosSynchroOperation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=e:GetLabelObject()
		c:SetMaterial(g)
		Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_SYNCHRO+69)
		g:DeleteGroup()
	end
end