--This file contains a useful list of functions and constants which can be used for a lot of things. Each function should have a small description as well.

--constants
SUMMON_TYPE_TIMELEAP=SUMMON_TYPE_LINK+69
REASON_TIMELEAP=REASON_LINK+69
SUMMON_TYPE_CHAOS_SYNCHRO=SUMMON_TYPE_SYNCHRO+69
REASON_CHAOS_SYNCHRO=REASON_SYNCHRO+69
REGISTER_FLAG_FILTER=16

--Function to check whether a card is EXACTLY the passed type (like a more strict version of Card.IsType)
function Card.CheckType(c,tp)
	return (c:GetType()&tp)==tp
end

--Function to check whether an array/table contains a certain element
function contains(tab,element)
	for _,value in pairs(tab) do
		if value==element then
			return true
		end
	end
	return false
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
	function(c,codes,desc,cat,prop,typ,range,con,cost,tg,op,opt,flags)
	local effs,flags={},flags or {}
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
		c:RegisterEffect(e:Clone(),false,flags[i])
	end
	e:Reset()
end,"handler","codes","desc","cat","prop","typ","range","con","cost","tg","op","opt","flags")

--Standardcondition for Ventus monsters (if shuffled into the Deck by a Wind monster)
--can also support another condition if passed
function Auxiliary.VentusCon(con)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if not re or r&REASON_COST>0 then return false end 
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and (re:GetHandler():IsAttribute(ATTRIBUTE_WIND) or re:GetHandler():IsCode(65000040))
	end
end

--Condition to check the Summon type of a card
--can also support another condition if passed
function Auxiliary.SumtypeCon(c,st,con)
	return function(e,tp,eg,ep,ev,re,r,rp) 
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and c:IsSummonType(st)
	end
end

--This function merges t2 into t1 where t1,t2 are tables/arrays. If filter==true, duplicate entries will be filtered out.
function merge(t1, t2, filter)
	filter=filter or false
	if filter==true then
		local dup=false
		for _, i in ipairs(t2) do
			for _, j in ipairs(t1) do
				dup = (i == j)
				if dup then break end
			end
			if not dup then
				table.insert(t1, i)
			end
		end
	else
		for _, i in ipairs(t2) do
			table.insert(t1, i)
		end
	end
end

-- This function allocates <space> ids for setcountlimit
-- (the returned value should be used as the first limit, returned value + 1 for the second, etc.)
cur_id = 1 << 31
function getFreeIdSpace(space)
	cur_id = cur_id - space
	return cur_id
end

--Function which originally was intended for Effulgence Congregater Zalatiel. If "REGISTER_FLAG_FILTER" is passed as argument 3 or an "EVENT_" effect, GetCardEffect can filter for that as well.
local regeff2=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	if c:IsStatus(STATUS_INITIALIZING) and not e then
		error("Parameter 2 expected to be Effect, got nil instead.",2)
	end
	--1 == 511002571 - access to effects that activate that detach an Xyz Material as cost
	--2 == 511001692 - access to Cardian Summoning conditions/effects
	--4 ==  12081875 - access to Thunder Dragon effects that activate by discarding
	--8 == 511310036 - access to Allure Queen effects that activate by sending themselves to GY
	--16 == 300001010 - access to Effulgence Congregater Zalatiel to filter for "EVENT_" effects
	local reg_e=regeff2(c,e,forced)
	if not reg_e then
		return nil
	end
	local reg={...}
	local resetflag,resetcount=e:GetReset()
	for _,val in ipairs(reg) do
		local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
		if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
		if val==1 then
			e2:SetCode(511002571)
		elseif val==2 then
			e2:SetCode(511001692)
		elseif val==4 then
			e2:SetCode(12081875)
		elseif val==8 then
			e2:SetCode(511310036)
		elseif val==16 then
			e2:SetCode(300001010)
		end
		e2:SetLabelObject(e)
		e2:SetLabel(c:GetOriginalCode())
		if resetflag and resetcount then
			e2:SetReset(resetflag,resetcount)
		elseif resetflag then
			e2:SetReset(resetflag)
		end
		c:RegisterEffect(e2)
	end
	return reg_e
end

--Some smol utilities for Time Leap
function Card.IsTimeLeap(c)
	return c:GetFlagEffect(3400)>0
end

function Card.IsTimeLeapMaterial(c)
	return c:GetFlagEffect(3401)>0
end
