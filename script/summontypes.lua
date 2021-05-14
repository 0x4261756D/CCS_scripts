--This file contains all Custom Summon Types

Duel.LoadScript("customutility.lua")

--LINK SUMMON WITH SPELLS/TRAPS AS MATERIAL

function Link.AddSpellTrapProcedure(c,f,min,max,specialchk,desc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1174)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	if max==nil then max=c:GetLink() end
	e1:SetCondition(Link.STCondition(f,min,max,specialchk))
	e1:SetTarget(Link.STTarget(f,min,max,specialchk))
	e1:SetOperation(Link.STOperation(f,min,max,specialchk))
	e1:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e1)
end

function Link.STFilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFacedown()
end

function Link.STConditionFilter(c,f,lc,tp)
	if c:IsMonster() then 
		return c:IsCanBeLinkMaterial(lc,tp) and (not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
	else 
		return not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp)
	end
end

function Link.STCondition(f,minc,maxc,specialchk)
	return function(e,c,must,g,min,max)
		if c==nil then return true end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local tp=c:GetControler()
		local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_SZONE,0,nil,TYPE_SPELL+TYPE_TRAP)
		if not g then
			g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		end
		g:Merge(g2)
		local mg=g:Filter(Link.STConditionFilter,nil,f,c,tp)
		local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
		if must then mustg:Merge(must) end
		if min and min < minc then return false end
		if max and max > maxc then return false end
		min = min or minc
		max = max or maxc
		if mustg:IsExists(aux.NOT(Link.STConditionFilter),1,nil,f,c,tp) or #mustg>max then return false end
		local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
		tg=tg:Filter(Link.STConditionFilter,nil,f,c,tp)
		local res=(mg+tg):Includes(mustg) and #mustg<=max
		if res then
			if #mustg==max then
				local sg=Group.CreateGroup()
				res=mustg:IsExists(Link.CheckRecursive,1,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt)
			elseif #mustg<max then
				local sg=mustg
				res=(mg+tg):IsExists(Link.CheckRecursive,1,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt)
			end
		end
		aux.DeleteExtraMaterialGroups(emt)
		return res
	end
end

function Link.STTarget(f,minc,maxc,specialchk)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
		local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_SZONE,0,nil,TYPE_SPELL+TYPE_TRAP)
		if not g then
			g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		end
		g:Merge(g2)
		if min and min < minc then return false end
		if max and max > maxc then return false end
		min = min or minc
		max = max or maxc
		local mg=g:Filter(Link.STConditionFilter,nil,f,c,tp)
		local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
		if must then mustg:Merge(must) end
		local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
		tg=tg:Filter(Link.STConditionFilter,nil,f,c,tp)
		local sg=Group.CreateGroup()
		local finish=false
		local cancel=false
		sg:Merge(mustg)
		while #sg<max do
			local filters={}
			if #sg>0 then
				Link.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg+tg,mg+tg,c,min,max,f,specialchk,mg,emt,filters)
			end
			local cg=(mg+tg):Filter(Link.CheckRecursive,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt,{table.unpack(filters)})
			if #cg==0 then break end
			finish=#sg>=min and #sg<=max and Link.CheckGoal(tp,sg,c,min,f,specialchk,filters)
			cancel=not og and Duel.IsSummonCancelable() and #sg==0
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
			local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,1,1)
			if not tc then break end
			if #mustg==0 or not mustg:IsContains(tc) then
				if not sg:IsContains(tc) then
					sg:AddCard(tc)
				else
					sg:RemoveCard(tc)
				end
			end
		end
		if #sg>0 then
			local filters={}
			Link.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg+tg,mg+tg,c,min,max,f,specialchk,mg,emt,filters)
			sg:KeepAlive()
			g2:KeepAlive()
			local reteff=Effect.GlobalEffect()
			reteff:SetTarget(function()return sg,sg:Filter(Link.STFilter,nil),filters,emt end)
			e:SetLabelObject(reteff)
			return true
		else 
			aux.DeleteExtraMaterialGroups(emt)
			return false
		end
	end
end

function Link.STOperation(f,minc,maxc,specialchk)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
		local g,g2,filt,emt=e:GetLabelObject():GetTarget()()
		e:GetLabelObject():Reset()
		for _,ex in ipairs(filt) do
			if ex[3]:GetValue() then
				ex[3]:GetValue()(1,SUMMON_TYPE_LINK,ex[3],ex[1]&g,c,tp)
			end
		end
		c:SetMaterial(g)
		Duel.ConfirmCards(1-tp,g2)
		Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
		g:DeleteGroup()
		aux.DeleteExtraMaterialGroups(emt)
	end
end

--Global Check to allow Spells/Traps to be used in Fusion Summons of cards that the "value" function returns
--If "value" is nil, it defaults to the card itself
function Fusion.AddSpellTrapRep(c,s,value,f,...)
	f(...)
	aux.GlobalCheck(s,function()
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD)
		ge:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		ge:SetTargetRange(LOCATION_SZONE+LOCATION_HAND,0)
		ge:SetTarget(function(e,cc) return cc:IsType(TYPE_SPELL+TYPE_TRAP) end)
		ge:SetValue(value or function(e,cc) if not cc then return false end return cc:IsOriginalCode(c:GetOriginalCode()) end)
		Duel.RegisterEffect(ge,0)
	end)
end

--TIME LEAP

--The Summon works by banishing a monster with 1 level lower than the Time Leap Monster from your field
--Time Banish means, that the summoned monster will be banished in the end phase and a monster which has been used as material can be summoned back

function Card.IsCanBeTimeleapMaterial(c)
	return c:IsCanBeMaterial(SUMMON_TYPE_TIMELEAP)
end

--Explanation of params:
--c=card which will be summoned, con=required conditions, f=filter for materials, min/max=how many materials are needed,
--desc=optional description, tb=bool to specify whether to time banish in the end phase, ...=all extraparams of "f".
function Auxiliary.AddTimeLeapProcedure(c,con,f,min,max,desc,tb,...)
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
	e1:SetCondition(aux.TimeLeapCondition(c,f,min,table.unpack(params)))
	e1:SetTarget(aux.TimeLeapTarget(c,f,min,max,table.unpack(params)))
	e1:SetOperation(aux.TimeLeapOperation(c))
	e1:SetValue(SUMMON_TYPE_TIMELEAP)
	c:RegisterEffect(e1)
	if tb==true then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(function(e) return Duel.GetTurnPlayer()==c:GetControler() end)
		e2:SetTarget(aux.TimeBanishTarget(c))
		e2:SetOperation(aux.TimeBanishOperation(c))
		c:RegisterEffect(e2)
	end
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REMOVE_TYPE)
	e3:SetValue(TYPE_FUSION)
	e3:SetRange(LOCATION_EXTRA)
	c:RegisterEffect(e3)
	c:RegisterFlagEffect(3400,0,0,0)
end

function Auxiliary.TimeLeapCondition(c,f,min,...)
	local params={...}
	local g=Duel.GetMatchingGroup(Card.IsLevel,c:GetControler(),LOCATION_MZONE,0,nil,c:GetLevel()-1):Filter(Card.IsCanBeTimeleapMaterial,nil):Filter(f,nil,table.unpack(params))
	return #g>=min and Duel.GetFlagEffect(c:GetControler(),c:GetOriginalCode())==0
end

function Auxiliary.TimeLeapTarget(c,f,min,max,...)
	local params={...}
	local g=Duel.GetMatchingGroup(Card.IsLevel,tp,LOCATION_MZONE,0,nil,c:GetLevel()-1):Filter(Card.IsCanBeTimeleapMaterial,nil)
	if #g>=min then
		local mat=g:FilterSelect(tp,f,min,max,true,nil,table.unpack(params))
		e:SetLabelObject(mat)
		mat:KeepAlive()
		return true
		else return false
	end
end

function Auxiliary.TimeLeapOperation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local mat=e:GetLabelObject()
		Duel.Remove(mat,POS_FACEUP,REASON_MATERIAL+REASON_TIMELEAP)
		Duel.RegisterFlagEffect(tp,c:GetOriginalCode(),RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
		for tc in ~mat do
			tc:RegisterFlagEffect(3401,RESET_PHASE+PHASE_END,0,1,EFFECT_FLAG_CLIENT_HINT,1,0,3401)
		end
		c:SetMaterial(mat)
		c:CompleteProcedure()
		mat:DeleteGroup()
	end
end

function Auxiliary.TimeBanishTarget(c)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return c:IsAbleToRemove() end
	end
end

function Auxiliary.TimeBanishFilter(c)
	return c:GetFlagEffect(3401)>0
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
		local tc=Duel.SelectMatchingCard(tp,aux.spfilter(e,tp,0,false,false,aux.TimeBanishFilter),tp,LOCATION_REMOVED,0,1,1,nil)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--CHAOS SYNCHRO (basically Synchro Summoning by banishing materials from the GY with more flexibility)

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
	e:SetCondition(aux.ChaosSynchroCondition(c,f1,extraparams1,specialcheck1,atmin,atmax,f2,extraparams2,specialcheck2,antmin,antmax))
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

function Auxiliary.ChaosSynchroCondition(c,f1,extraparams1,specialcheck1,atmin,atmax,f2,extraparams2,specialcheck2,antmin,antmax)
	return function(e)
		local lv,tp=c:GetLevel(),e:GetHandlerPlayer()
		local gt,gnt
		gt=Duel.GetMatchingGroup(aux.cstfilter,tp,LOCATION_GRAVE,0,nil,c)
		gnt=Duel.GetMatchingGroup(aux.csntfilter,tp,LOCATION_GRAVE,0,nil,c)
		if f1 then
			if extraparams1 then
				gt=gt:Filter(f1,nil,table.unpack(extraparams1))
			else
				gt=gt:Filter(f1,nil)
			end
		end
		if f2 then
			if extraparams2 then
				gnt=gnt:Filter(f2,nil,table.unpack(extraparams2))
			else
				gnt=gnt:Filter(f2,nil)
			end
		end
		return Duel.GetLocationCountFromEx(tp)>0 and aux.SelectUnselectGroup(gt+gnt,e,tp,atmin+antmin,atmax+antmax,aux.csrescon(lv,gt,atmin,atmax,specialcheck1,gnt,antmin,antmax,specialcheck2),0)
	end
end

function Auxiliary.ChaosSynchroTarget(c,f1,extraparams1,specialcheck1,atmin,atmax,f2,extraparams2,specialcheck2,antmin,antmax)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local lv=c:GetLevel()
		local gt,gnt
		gt=Duel.GetMatchingGroup(aux.cstfilter,tp,LOCATION_GRAVE,0,nil,c)
		gnt=Duel.GetMatchingGroup(aux.csntfilter,tp,LOCATION_GRAVE,0,nil,c)
		if f1 then
			if extraparams1 then
				gt=gt:Filter(f1,nil,table.unpack(extraparams1))
			else
				gt=gt:Filter(f1,nil)
			end
		end
		if f2 then
			if extraparams2 then
				gnt=gnt:Filter(f2,nil,table.unpack(extraparams2))
			else
				gnt=gnt:Filter(f2,nil)
			end
		end
		if Duel.GetLocationCountFromEx(tp)>0 and aux.SelectUnselectGroup(gt+gnt,e,tp,atmin+antmin,atmax+antmax,aux.csrescon(lv,gt,atmin,atmax,specialcheck1,gnt,antmin,antmax,specialcheck2),0) then
			local mat=aux.SelectUnselectGroup(gt+gnt,e,tp,atmin+antmin,atmax+antmax,aux.csrescon(lv,gt,atmin,atmax,specialcheck1,gnt,antmin,antmax,specialcheck2),1,tp,HINTMSG_REMOVE,nil,nil,true)
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