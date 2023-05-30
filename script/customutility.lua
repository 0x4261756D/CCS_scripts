--This file contains a useful list of functions and constants which can be used for a lot of things.

--constants
REGISTER_FLAG_FILTER=16
HINTMSG_REMOVE_COUNTER=10001
--functions
local function arg_dump(e, func, kind, ...)
	if DEBUG_ID == e:GetHandler():GetCode() then
		Debug.Message(kind.." of "..e:GetHandler():GetCode())
		local t = table.pack(...)
		local str = "  "
		for i = 1, t.n do
			str = str..i..": "..type(t[i]).." "
		end
		Debug.Message(str)
	end
	return func(...)
end

local SetTg = Effect.SetTarget
Effect.SetTarget = function (e, func)
	return SetTg(e, function (...)
		return arg_dump(e, func, "Target", ...)
	end)
end
local SetCon = Effect.SetCondition
Effect.SetCondition = function (e, func)
	return SetCon(e, function (...)
		return arg_dump(e, func, "Condition", ...)
	end)
end
local SetOp = Effect.SetOperation
Effect.SetOperation = function (e, func)
	return SetOp(e, function (...)
		return arg_dump(e, func, "Operation", ...)
	end)
end

function Card.GetMaxCounterRemoval(c,tp,cttypes,reason)
	local ct=0
	if type(cttypes)=="table" then
		for _,cttype in ipairs(cttypes) do
			for i=1,c:GetCounter(cttype) do
				if c:IsCanRemoveCounter(tp,cttype,i,reason) then
					ct=ct+1
				else
					break
				end
			end
		end
	else
		for i=1,c:GetCounter(cttypes) do
			if c:IsCanRemoveCounter(tp,cttypes,i,reason) then
				ct=ct+1
			else
				break
			end
		end
	end
	return ct
end

function Card.MaxCounterRemovalCheck(c,tp,cttypes,ctamount,reason)
	return c:GetMaxCounterRemoval(tp,cttypes,reason)>=ctamount
end

function Group.GetMaxCounterRemoval(g,tp,cttypes,reason)
	local ct=0
	if type(cttypes)=="table" then
		for _,cttype in ipairs(cttypes) do
			for tc in g:Iter() do
				ct=ct+tc:GetMaxCounterRemoval(tp,cttype,reason)
			end
		end
	else
		for tc in g:Iter() do
			ct=ct+tc:GetMaxCounterRemoval(tp,cttypes,reason)
		end
	end
	return ct
end

function Group.CanRemoveCounter(g,tp,cttypes,ctamount,reason)
	return g:GetMaxCounterRemoval(tp,cttypes,reason)>=ctamount
end

function Group.RemoveCounter(g,tp,cttypes,ctamount,reason)
	if type(cttypes)=="table" then
		local ct=0
		for _,cttype in ipairs(cttypes) do
			ct=ct+g:GetMaxCounterRemoval(tp,cttype,reason)
		end
		if ct<ctamount then return end
		local choices,tc,choice
		for i=1,ctamount do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE_COUNTER)
			tc=g:FilterSelect(tp,Card.MaxCounterRemovalCheck,1,1,nil,tp,cttypes,1,reason):GetFirst()
			choices={}
			for _,cttype in ipairs(cttypes) do
				table.insert(choices,{tc:IsCanRemoveCounter(tp,cttype,1,reason),tonumber(cttype)})
			end
			choice=Duel.SelectEffect(tp,table.unpack(choices))
			tc:RemoveCounter(tp,cttypes[choice],1,reason)
		end
	else
		if not g:CanRemoveCounter(tp,cttypes,ctamount,reason) then return end
		local tc
		for i=1,ctamount do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE_COUNTER)
			tc=g:FilterSelect(tp,Card.IsCanRemoveCounter,1,1,nil,tp,cttypes,1,reason):GetFirst()
			tc:RemoveCounter(tp,cttypes,1,reason)
		end
	end
end

function Synchro.Tuner(f,...)
	local params={...}
	return function(target,scard,sumtype,tp)
		return target:IsType(TYPE_TUNER,scard,sumtype,tp) and (not f or f(target,table.unpack(params)))
	end
end

function Card.CheckType(c,tp)
	return (c:GetType()&tp)==tp
end

function contains(tab,element)
	for _,value in pairs(tab) do
		if value==element then
			return true
		end
	end
	return false
end

function removeall(tab,element)
	for _,value in pairs(tab) do
		if value==element then
			table.remove(tab,value)
		end
	end
end

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

function Auxiliary.spfilter(e,tp,sumtype,nocheck,nolimit,f,...)
	local params={...}
	return function(c)
		if f then return c:IsCanBeSpecialSummoned(e,sumtype,tp,nocheck,nolimit) and f(c,table.unpack(params))
		else return c:IsCanBeSpecialSummoned(e,sumtype,tp,nocheck,nolimit) end
	end
end

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

function Auxiliary.SumtypeCon(c,st,con)
	return function(e,tp,eg,ep,ev,re,r,rp) 
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and c:IsSummonType(st)
	end
end

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

local regeff2=Card.RegisterEffect
function Card.RegisterEffect(c,e,forced,...)
	if c:IsStatus(STATUS_INITIALIZING) and not e then
		error("Parameter 2 expected to be Effect, got nil instead.",2)
	end
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
		if val==16 then
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

function Fusion.AddSpellTrapRep(c,s,value,f,...)
	f(...)
	aux.GlobalCheck(s,function()
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD)
		ge:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		ge:SetTargetRange(LOCATION_SZONE+LOCATION_HAND,LOCATION_SZONE+LOCATION_HAND)
		ge:SetTarget(function(e,cc) return cc:IsType(TYPE_SPELL+TYPE_TRAP) end)
		ge:SetValue(value or function(e,cc) if not cc then return false end return cc:IsOriginalCode(c:GetOriginalCode()) end)
		Duel.RegisterEffect(ge,0)
	end)
end
