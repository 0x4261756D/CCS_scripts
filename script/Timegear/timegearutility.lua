Duel.LoadScript("customutility.lua")
--Little note on how to use functions from this file:
--The card has to use "Duel.LoadScript("timegearutility.lua")" before its initial_effect.
--Explanation of params:
--c=card which will be summoned, con=required conditions, f=filter for materials, min/max=how many materials are needed,
--desc=optional description, tb=bool to specify whether to time banish in the end phase, extraparams=array containing all extraparams of "f".

--constants
SUMMON_TYPE_TIMELEAP=SUMMON_TYPE_LINK+69
--SET_TIMEGEAR=

Timegear={}
Timegear.AddTimeLeapProcedure=aux.FunctionWithNamedArgs(
	function Timegear.AddTimeLeapProcedure(c,con,f,min,max,desc,tb,extraparams)
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
		e1:SetCondition(Timegear.TimeLeapCondition(con))
		e1:SetTarget(Timegear.TimeLeapTarget(c,f,min,max,table.unpack(extraparams)))
		e1:SetOperation(Timegear.TimeLeapOperation(c))
		e1:SetValue(SUMMON_TYPE_TIMELEAP)
		c:RegisterEffect(e1)
			if tb==true then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_PHASE+PHASE_END)
				e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetRange(LOCATION_MZONE)
				e2:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
				e2:SetTarget(Timegear.TimeBanishTarget(c))
				e2:SetOperation(Timegear.TimeBanishOperation(c))
				c:RegisterEffect(e2)
			end
end,"handler","con","filter","min","max","desc","time banish","extraparams")

function Timegear.TimeLeapCondition(con)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and Duel.GetFlagEffect(tp,3400)==0
	end
end

function Timegear.TimeLeapTarget(c,f,min,max,...)
	local params={...}
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(Card.IsLevel,tp,LOCATION_MZONE,0,nil,c:GetLevel()-1)
		if #g>=min and then
			local mat=g:FilterSelect(tp,f,min,max,true,nil,table.unpack(params)):GetFirst()
			e:SetLabelObject(mat)
			return true
			else return false
		end
	end
end

function Timegear.TimeLeapOperation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local mat=e:GetLabelObject()
		c:SetMaterial(Group.FromCards(mat))
		Duel.Remove(mat,POS_FACEUP,REASON_MATERIAL+REASON_FUSION+69)
		Duel.RegisterFlagEffect(tp,3400,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
		mat:RegisterFlagEffect(3401,RESET_PHASE+PHASE_END,0,1,EFFECT_FLAG_CLIENT_HINT,1,0,3401)
	end
end

function Timegear.TimeBanishTarget(c)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return c:IsAbleToRemove() end
	end
end

function Timegear.TimeBanishFilter(c,e,tp)
	return c:GetFlagEffect(3401)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function Timegear.TimeBanishOperation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT,tp)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetValue(1)
		c:RegisterEffect(e1,true)
		local tc=Duel.SelectMatchingCard(tp,Timegear.TimeBanishFilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
