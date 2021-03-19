--This file contains a useful list of functions and constants which can be used for a lot of things. Each function should have a small description as well.

--constants
SUMMON_TYPE_TIMELEAP=SUMMON_TYPE_LINK+69
REASON_TIMELEAP=REASON_LINK+69
SUMMON_TYPE_CHAOS_SYNCHRO=SUMMON_TYPE_SYNCHRO+69
REASON_CHAOS_SYNCHRO=REASON_SYNCHRO+69

--Function to check whether a card is EXACTLY the passed type (like a more strict version of Card.IsType)
function Card.CheckType(c,tp)
	return (c:GetType()&tp)==tp
end

--Function to select an option based on the condition on the same place as the option in the first table
--If the third table isn't nil, the corresponding operation will be executed.
--Example Call: local x=aux.EffectCheck(tp,cons,strings,ops)(e,tp,eg,ep,ev,re,r,rp)
function Auxiliary.EffectCheck(tp,cons,strings,ops)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local eff,sel={},{}
		for i,con in ipairs(cons) do
			if con then
				table.insert(eff,strings[i])
				table.insert(sel,i)
			end
		end
		local choice=Duel.SelectOption(tp,table.unpack(eff))
		if ops then ops[sel[choice+1]](e,tp,eg,ep,ev,re,r,rp) end
		return sel[choice+1]
	end
end

--doccost detaches a specific amount of materials from an Xyz monster (min=<X=<max). min=nil -> detaches all materials.
--label=true -> the amount of detached materials will be saved as a label.
--The function also supports another cost when passed as parameter 4.
--If "cost" isn't nil, it is required that "order" isn't nil as well, otherwise the passed function won't be executed.
--order=0 -> the passed cost will be executed before the detaching, order=1 -> afterwards
function Auxiliary.doccost(min,max,label,cost,order)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local ct,eff,set,label=c:GetOverlayCount(),Duel.IsPlayerAffectedByEffect(tp,CARD_NUMERON_NETWORK),c:IsSetCard(0x14b),label or false
		local min=min or ct
		local max=max or min
			if chk==0 then 
				if cost then
					return (c:CheckRemoveOverlayCard(tp,min,REASON_COST) or (eff and set)) and cost(e,tp,eg,ep,ev,re,r,rp,0)
					else return c:CheckRemoveOverlayCard(tp,min,REASON_COST) or (eff and set)
				end
			end
			if cost then
				if order==0 then
					if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
						cost(e,tp,eg,ep,ev,re,r,rp,1)
						return true
							else
								cost(e,tp,eg,ep,ev,re,r,rp,1)
								c:RemoveOverlayCard(tp,min,max,REASON_COST)
					end
				elseif order==1 then
					if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
						cost(e,tp,eg,ep,ev,re,r,rp,1)
						return true
							else
								c:RemoveOverlayCard(tp,min,max,REASON_COST)
								cost(e,tp,eg,ep,ev,re,r,rp,1)
					end
				else
					if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
						return true
							else
								c:RemoveOverlayCard(tp,min,max,REASON_COST)
					end
				end
			else
				if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
						return true
							else
								c:RemoveOverlayCard(tp,min,max,REASON_COST)
				end
			end
		if label==true then 
			e:SetLabel(#Duel.GetOperatedGroup())
		end
	end
end

--aux.spfilter is a shortcut to check for legally special summonable. It has to be called with e,tp,the summon type and bools whether summon conditions and revive limit are ignored and also supports another filter which has to be fullfilled along with all its extraparams.
--Example: Duel.IsExistingMatchingCard(aux.spfilter(e,tp,s.filter,a,b),tp,LOCATION_GRAVE,0,1,nil) where a and b are the extraparams of s.filter.
function Auxiliary.spfilter(e,tp,sumtype,nocheck,nolimit,f,...)
	local params={...}
	return function(c)
		if f then return c:IsCanBeSpecialSummoned(e,sumtype,tp,nocheck,nolimit) and f(c,table.unpack(params))
		else return c:IsCanBeSpecialSummoned(e,sumtype,tp,nocheck,nolimit) end
	end
end

--Shortcut function to register the same effect on different events. (Useful for something like "If this card is summoned" to take care of all summon events).
--Like with all fwna's, the arguments are passed as a table where "codes" is a table of all events which should be used.
Auxiliary.MultiRegister=aux.FunctionWithNamedArgs(
	function(c,codes,desc,cat,prop,typ,range,con,cost,tg,op,opt)
	local effs={}
	local e=Effect.CreateEffect(c)
	if desc then e:SetDescription(desc) end
	if cat then e:SetCategory(cat) end
	if prop then e:SetProperty(prop) end
	if range then e:SetRange(range) end
	e:SetType(typ)
	if con then e:SetCondition(con) end
	if cost then e:SetCost(cost) end
	if tg then e:SetTarget(tg) end
	e:SetOperation(op)
	if opt then
		if opt=="sopt" then e:SetCountLimit(1)
		elseif type(opt)=="number" and opt>0 then e:SetCountLimit(opt)
		elseif opt=="hopt" then e:SetCountLimit(1,c:GetOriginalCode())
		end
	end
	for i=1,#codes do
		e:SetCode(codes[i])
		c:RegisterEffect(e:Clone())
	end
	e:Reset()
end,"handler","codes","desc","cat","prop","typ","range","con","cost","tg","op","opt")

--The following function adds a proc for the Chaos Synchro Summon type to a card (basically Synchro Summoning by banishing materials from the GY with more flexibility).
--Parameter Explanation:
--c: The card which receives the proc
--f1: A filter to further specify the legal Tuners with extraparams1 as a table of needed extraparameters.
--atmin/atmax: minimum/maximum amount of Tuners
--f2,extraparams2,antmin/antmax: the same but for Nontuners
--specialcheck1,specialcheck2: Filters to handle what the groups of selected Tuners/Nontuners must include
--desc: an optional descrption
Auxiliary.AddChaosSynchroProcedure=aux.FunctionWithNamedArgs(
	function(c,f1,extraparams1,specialcheck1,atmin,atmax,f2,extraparams2,specialcheck2,antmin,antmax,desc)
	atmin,atmax,antmin,antmax=atmin or 1,atmax or 99,antmin or 1,antmax or 99
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e:SetDescription(desc)
		else 
			e:SetDescription(3402)
	end
	e:SetCode(EFFECT_SPSUMMON_PROC)
	e:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e:SetRange(LOCATION_EXTRA)
	e:SetTarget(aux.ChaosSynchroTarget(c,f1,extraparams1,specialcheck1,atmin,atmax,f2,extraparams2,specialcheck2,antmin,antmax))
	e:SetOperation(aux.ChaosSynchroOperation(c))
	e:SetValue(SUMMON_TYPE_CHAOS_SYNCHRO)
	c:RegisterEffect(e)
end,"handler","tfilter","extraparams1","specialchk1","atmin","atmax","ntfilter","extraparams2","specialchk2","antmin","antmax","desc")

function Auxiliary.cstfilter(c,tc)
	return c:IsCanBeSynchroMaterial(tc) and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end

function Auxiliary.csntfilter(c,tc)
	return c:IsCanBeSynchroMaterial(tc) and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end

function Auxiliary.csrescon(lv,gt,atmin,atmax,specialcheck1,gnt,antmin,antmax,specialcheck2)
	return function(sg,e,tp,mg)
		return sg:GetSum(Card.GetLevel)==lv and atmin<=#(sg-gnt) and #(sg-gnt)<=atmax and antmin<=#(sg-gt) and #(sg-gt)<=antmax and (not specialcheck1 or specialcheck1(sg-gnt)) and (not specialcheck2 or specialcheck2(sg-gt))
	end
end

function Auxiliary.ChaosSynchroTarget(c,f1,extraparams1,specialcheck1,atmin,atmax,f2,extraparams2,specialcheck2,antmin,antmax)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local lv=c:GetLevel()
		local gt,gnt
		gt=Duel.GetMatchingGroup(aux.cstfilter,tp,LOCATION_GRAVE,0,nil,c)
		gnt=Duel.GetMatchingGroup(aux.csntfilter,tp,LOCATION_GRAVE,0,nil,c)
		if f1 then gt=gt:Filter(f1,nil,table.unpack(extraparams1)) end
		if f2 then gnt=gnt:Filter(f2,nil,table.unpack(extraparams2)) end
		if Duel.GetLocationCountFromEx(tp)>0 and aux.SelectUnselectGroup(gt+gnt,e,tp,atmin+antmin,atmax+antmax,aux.csrescon(lv,gt,atmin,atmax,specialcheck1,gnt,antmin,antmax,specialcheck2),0) then
			local mat=aux.SelectUnselectGroup(gt+gnt,e,tp,atmin+antmin,atmax+antmax,aux.csrescon(lv,gt,atmin,atmax,specialcheck1,gnt,antmin,antmax,specialcheck2),1,tp,nil,nil,nil,true)
			if #mat<atmin+antmin then return false end
			e:SetLabelObject(mat)
			mat:KeepAlive()
			return true
			else return false
		end
	end
end

function Auxiliary.ChaosSynchroOperation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=e:GetLabelObject()
		c:SetMaterial(g)
		Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_CHAOS_SYNCHRO)
		g:DeleteGroup()
	end
end

function Card.IsCanBeTimeleapMaterial(c)
	return c:IsCanBeMaterial(SUMMON_TYPE_TIMELEAP)
end

--Explanation of params:
--c=card which will be summoned, con=required conditions, f=filter for materials, min/max=how many materials are needed,
--desc=optional description, tb=bool to specify whether to time banish in the end phase, extraparams=array containing all extraparams of "f".
Auxiliary.AddTimeLeapProcedure=aux.FunctionWithNamedArgs(
	function(c,con,f,min,max,desc,tb,extraparams)
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
		e1:SetCondition(aux.TimeLeapCondition(con))
		e1:SetTarget(aux.TimeLeapTarget(c,f,min,max,table.unpack(extraparams)))
		e1:SetOperation(aux.TimeLeapOperation(c))
		e1:SetValue(SUMMON_TYPE_TIMELEAP)
		c:RegisterEffect(e1)
			if tb==true then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_PHASE+PHASE_END)
				e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetRange(LOCATION_MZONE)
				e2:SetCondition(function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
				e2:SetTarget(aux.TimeBanishTarget(c))
				e2:SetOperation(aux.TimeBanishOperation(c))
				c:RegisterEffect(e2)
			end
end,"handler","con","filter","min","max","desc","time banish","extraparams")

function Auxiliary.TimeLeapCondition(con)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and Duel.GetFlagEffect(tp,3400)==0
	end
end

function Auxiliary.TimeLeapTarget(c,f,min,max,...)
	local params={...}
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(Card.IsLevel,tp,LOCATION_MZONE,0,nil,c:GetLevel()-1):Filter(Card.IsCanBeTimeleapMaterial,nil)
		if #g>=min then
			local mat=g:FilterSelect(tp,f,min,max,true,nil,table.unpack(params))
			e:SetLabelObject(mat)
			return true
			else return false
		end
	end
end

function Auxiliary.TimeLeapOperation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local mat=e:GetLabelObject()
		c:SetMaterial(mat)
		Duel.Remove(mat,POS_FACEUP,REASON_MATERIAL+REASON_FUSION+69)
		Duel.RegisterFlagEffect(tp,3400,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
		mat:RegisterFlagEffect(3401,RESET_PHASE+PHASE_END,0,1,EFFECT_FLAG_CLIENT_HINT,1,0,3401)
	end
end

function Auxiliary.TimeBanishTarget(c)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return c:IsAbleToRemove() end
	end
end

function Auxiliary.TimeBanishFilter(c)
	return c:GetFlagEffect(3401)~=0
end

function Auxiliary.TimeBanishOperation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT,tp)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetValue(1)
		c:RegisterEffect(e1,true)
		local tc=Duel.SelectMatchingCard(tp,aux.spfilter(e,tp,0,aux.TimeBanishFilter),tp,LOCATION_REMOVED,0,1,1,nil)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
