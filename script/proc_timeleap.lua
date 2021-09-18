Duel.LoadScript("customutility.lua")

SUMMON_TYPE_TIMELEAP=SUMMON_TYPE_LINK+69
REASON_TIMELEAP=REASON_LINK+69

if not TimeLeap then
	TimeLeap={}
end

function TimeLeap.AddProcedure(c,con,f,min,max,desc,tb,...)
	local params={...}
	local min=min or 1
	local max=max or min
	local tb=tb or false
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e1:SetDescription(desc)
	else 
		e1:SetDescription(3400)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(TimeLeap.Condition(c,con,f,min,params))
	e1:SetTarget(TimeLeap.Target(c,f,min,max,table.unpack(params)))
	e1:SetOperation(TimeLeap.Operation(c))
	e1:SetValue(SUMMON_TYPE_TIMELEAP)
	c:RegisterEffect(e1)
	if tb==true then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(function(e) return Duel.GetTurnPlayer()==c:GetControler() and c:IsSummonType(SUMMON_TYPE_TIMELEAP) end)
		e2:SetTarget(TimeLeap.TimeBanishTarget(c))
		e2:SetOperation(TimeLeap.TimeBanishOperation(c))
		c:RegisterEffect(e2)
	end
	c:RegisterFlagEffect(3400,0,0,0)
	c:Type(c:Type()&~TYPE_FUSION)
end

function TimeLeap.Condition(c,con,f,min,...)
	local params={...}
	return function(e)
		local g=Duel.GetMatchingGroup(Card.IsLevel,c:GetControler(),LOCATION_MZONE,0,nil,c:GetLevel()-1):Filter(Card.IsCanBeTimeleapMaterial,nil):Filter(f,nil,table.unpack(params))
		return #g>=min and Duel.GetFlagEffect(c:GetControler(),c:GetOriginalCode())==0 and (not con or con(e))
	end
end

function TimeLeap.Target(c,f,min,max,...)
	local params={...}
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(Card.IsLevel,tp,LOCATION_MZONE,0,nil,c:GetLevel()-1):Filter(Card.IsCanBeTimeleapMaterial,nil)
		if #g>=min then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local mat=g:FilterSelect(tp,f,min,max,true,nil,table.unpack(params))
			e:SetLabelObject(mat)
			mat:KeepAlive()
			return true
			else return false
		end
	end
end

function TimeLeap.Operation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local mat=e:GetLabelObject()
		Duel.Remove(mat,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
		Duel.RegisterFlagEffect(tp,c:GetOriginalCode(),RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
		for tc in ~mat do
			tc:RegisterFlagEffect(3401,RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY,0,1)
		end
		c:SetMaterial(mat)
		c:CompleteProcedure()
		mat:DeleteGroup()
	end
end

function TimeLeap.TimeBanishTarget(c)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return c:IsAbleToRemove() end
	end
end

function TimeLeap.TimeBanishFilter(c)
	return c:GetFlagEffect(3401)>0
end

function TimeLeap.TimeBanishOperation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT,tp)
		c:RegisterFlagEffect(3402,RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY,0,1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
		c:RegisterEffect(e1,true)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,aux.spfilter(e,tp,0,false,false,TimeLeap.TimeBanishFilter),tp,LOCATION_REMOVED,0,1,1,nil)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function Card.IsTimeLeap(c)
	return c:GetFlagEffect(3400)>0
end

function Card.IsTimeLeapMaterial(c)
	return c:GetFlagEffect(3401)>0
end

function Card.IsCanBeTimeleapMaterial(c)
	return c:IsCanBeMaterial(SUMMON_TYPE_TIMELEAP)
end