Duel.LoadScript("customutility.lua")

SUMMON_TYPE_TRICK=SUMMON_TYPE_FUSION+69
REASON_TRICK=REASON_FUSION+69

if not Trick then
	Trick={}
end

function Trick.AddProcedure(c,desc,con,mons,traps)
	local min,max=GetMinMaxMaterialCount(2,mons,traps)
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e:SetDescription(desc)
	else 
		e:SetDescription(3500)
	end
	e:SetCode(EFFECT_SPSUMMON_PROC)
	e:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e:SetRange(LOCATION_EXTRA)
	e:SetCondition(Trick.Condition(con,mons,traps,min,max))
	e:SetTarget(Trick.Target(c,mons,traps,min,max))
	e:SetOperation(Trick.Operation(c))
	e:SetValue(SUMMON_TYPE_TRICK)
	c:RegisterEffect(e)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_MOVE)
	e1:SetCondition(Trick.Movecon)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetOperation(function(e) c:Type(c:Type()&~TYPE_FUSION) end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_MOVE)
	e2:SetCondition(Trick.Movecon2)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetOperation(function(e) c:Type(c:Type()|TYPE_FUSION) Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_RULE) end)
	c:RegisterEffect(e2)
	c:RegisterFlagEffect(3500,0,0,0)
	c:Type(c:Type()&~TYPE_FUSION)
end

function Trick.Condition(con,mons,traps,min,max)
	return function(e)
		return (not con or con(e)) and Trick.SummonCheck(e,e:GetHandlerPlayer(),mons,traps,min,max,0)
	end
end

function Trick.Target(c,mons,traps,min,max)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if Trick.SummonCheck(e,tp,mons,traps,min,max,0) then
			local mat=Trick.SummonCheck(e,tp,mons,traps,min,max,1)
			if #mat==0 then return false end
			e:SetLabelObject(mat)
			mat:KeepAlive()
			return true
		end
		return false
	end
end

function Trick.Operation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local mat=e:GetLabelObject()
		local traps=mat:Filter(Card.IsLocation,nil,LOCATION_SZONE):Filter(Card.IsFacedown,nil)
		Duel.ConfirmCards(1-tp,traps)
		Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_TRICK)
		c:SetMaterial(mat)
		c:CompleteProcedure()
		mat:DeleteGroup()
	end
end

function Trick.SummonCheck(e,tp,mons,traps,min,max,chk)
	local g=Duel.GetMatchingGroup(Trick.Matfilter,tp,LOCATION_MZONE+LOCATION_SZONE,0,nil)
	if chk==0 then
		return aux.SelectUnselectGroup(g,e,tp,min,max,Trick.Rescon(mons,traps,min),0)
	else
		local mat=aux.SelectUnselectGroup(g,e,tp,min,max,Trick.Rescon(mons,traps,min),1,tp,10002,Trick.Rescon(mons,traps,min),nil,true)
		mat:KeepAlive()
		return mat
	end
end

function Trick.Rescon(mons,traps,min)
	return function(sg,e,tp,mg)
		for _,t in ipairs(mons) do
			local g=Duel.GetMatchingGroup(t[1],tp,LOCATION_MZONE,0,nil)
			if #(sg&g)<t[2] or #(sg&g)>t[3] then
				return false
			end
		end
		for _,t in ipairs(traps) do
			local g=Duel.GetMatchingGroup(t[1],tp,LOCATION_SZONE,0,nil)
			if #(sg&g)<t[2] or #(sg&g)>t[3] then
				return false
			end
		end
		return #sg>=min and Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0
	end
end

function Trick.Movecon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
end

function Trick.Movecon2(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK)
end

function Trick.Matfilter(c)
	return c:IsCanBeTrickMaterial() and ((c:IsFaceup() and c:IsMonster()) or c:IsType(TYPE_SPELL))
end

function Card.IsTrick(c)
	return c:GetFlagEffect(3500)>0
end

function Card.IsCanBeTrickMaterial(c)
	return c:IsCanBeMaterial(SUMMON_TYPE_TRICK)
end