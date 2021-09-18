Duel.LoadScript("customutility.lua")

SUMMON_TYPE_CHAOS_SYNCHRO=SUMMON_TYPE_SYNCHRO+69
REASON_CHAOS_SYNCHRO=REASON_SYNCHRO+69

if not ChaosSynchro then
	ChaosSynchro={}
end

ChaosSynchro.AddProcedure=aux.FunctionWithNamedArgs(
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
	e:SetCondition(ChaosSynchro.Condition(c,f1,extraparams1,specialcheck1,atmin,atmax,f2,extraparams2,specialcheck2,antmin,antmax))
	e:SetTarget(ChaosSynchro.Target(c,f1,extraparams1,specialcheck1,atmin,atmax,f2,extraparams2,specialcheck2,antmin,antmax))
	e:SetOperation(ChaosSynchro.Operation(c))
	e:SetValue(SUMMON_TYPE_CHAOS_SYNCHRO)
	c:RegisterEffect(e)
end,"handler","tfilter","extraparams1","specialchk1","atmin","atmax","ntfilter","extraparams2","specialchk2","antmin","antmax","desc")

function ChaosSynchro.tfilter(c,tc)
	return c:IsCanBeSynchroMaterial(tc) and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end

function ChaosSynchro.ntfilter(c,tc)
	return c:IsCanBeSynchroMaterial(tc) and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end

function ChaosSynchro.rescon(lv,gt,atmin,atmax,specialcheck1,gnt,antmin,antmax,specialcheck2)
	return function(sg,e,tp,mg)
		return sg:GetSum(Card.GetLevel)==lv and atmin<=#(sg-gnt) and #(sg-gnt)<=atmax and antmin<=#(sg-gt) and #(sg-gt)<=antmax and (not specialcheck1 or specialcheck1(sg-gnt)) and (not specialcheck2 or specialcheck2(sg-gt))
	end
end

function ChaosSynchro.Condition(c,f1,extraparams1,specialcheck1,atmin,atmax,f2,extraparams2,specialcheck2,antmin,antmax)
	return function(e)
		local lv,tp=c:GetLevel(),e:GetHandlerPlayer()
		local gt,gnt
		gt=Duel.GetMatchingGroup(ChaosSynchro.tfilter,tp,LOCATION_GRAVE,0,nil,c)
		gnt=Duel.GetMatchingGroup(ChaosSynchro.ntfilter,tp,LOCATION_GRAVE,0,nil,c)
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
		return Duel.GetLocationCountFromEx(tp)>0 and aux.SelectUnselectGroup(gt+gnt,e,tp,atmin+antmin,atmax+antmax,ChaosSynchro.rescon(lv,gt,atmin,atmax,specialcheck1,gnt,antmin,antmax,specialcheck2),0)
	end
end

function ChaosSynchro.Target(c,f1,extraparams1,specialcheck1,atmin,atmax,f2,extraparams2,specialcheck2,antmin,antmax)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local lv=c:GetLevel()
		local gt,gnt
		gt=Duel.GetMatchingGroup(ChaosSynchro.tfilter,tp,LOCATION_GRAVE,0,nil,c)
		gnt=Duel.GetMatchingGroup(ChaosSynchro.ntfilter,tp,LOCATION_GRAVE,0,nil,c)
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
		if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_SYNCHRO)>0 and aux.SelectUnselectGroup(gt+gnt,e,tp,atmin+antmin,atmax+antmax,aux.csrescon(lv,gt,atmin,atmax,specialcheck1,gnt,antmin,antmax,specialcheck2),0) then
			local mat=aux.SelectUnselectGroup(gt+gnt,e,tp,atmin+antmin,atmax+antmax,aux.csrescon(lv,gt,atmin,atmax,specialcheck1,gnt,antmin,antmax,specialcheck2),1,tp,HINTMSG_REMOVE,nil,nil,true)
			if #mat<atmin+antmin then return false end
			e:SetLabelObject(mat)
			mat:KeepAlive()
			return true
			else return false
		end
	end
end

function ChaosSynchro.Operation(c)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local g=e:GetLabelObject()
		c:SetMaterial(g)
		Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_CHAOS_SYNCHRO)
		g:DeleteGroup()
	end
end