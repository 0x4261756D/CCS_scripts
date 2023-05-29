--D/D Headhunter
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c) 
	--SS with opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.pendcost)
	e1:SetTarget(s.pendtg)
	e1:SetOperation(s.pendop)
	c:RegisterEffect(e1)
	--SS with banished monsters
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,{id,1})
	e2:SetCost(s.sscost)
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)
	--Non Tuner
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE+LOCATION_PZONE)
	e3:SetCode(EFFECT_NONTUNER)
	e3:SetValue(s.ntval)
	c:RegisterEffect(e3)
end

--SS with opponent's monster

function s.revfilter(c,e,tp)
	return c:IsSetCard(0xaf) and not c:IsPublic() and c:IsMonster() and c:IsType(TYPE_PENDULUM) and Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,c,e,tp)
end

function s.tgfilter(c,rev,e,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
	c:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_MATERIAL)
	c:RegisterEffect(e2,true)
	local res=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,c,rev,e,tp) and (c:IsCanBeFusionMaterial() or c:IsCanBeSynchroMaterial() or c:IsCanBeXyzMaterial() or c:IsCanBeLinkMaterial())
	e1:Reset()
	e2:Reset()
	return res
end

function s.spfilter(c,tc,rev,e,tp)
	e:GetHandler():AssumeProperty(ASSUME_LEVEL,rev:GetLevel())
	tc:AssumeProperty(ASSUME_RACE,RACE_FIEND)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(0x10af)
	tc:RegisterEffect(e1)
	local mat=Group.FromCards(e:GetHandler(),tc)
	local st,tpe
	if c:IsType(TYPE_FUSION) then
		st=SUMMON_TYPE_FUSION
	elseif c:IsType(TYPE_SYNCHRO) then
		st=SUMMON_TYPE_SYNCHRO
	elseif c:IsType(TYPE_XYZ) then
		st=SUMMON_TYPE_XYZ
	elseif c:IsType(TYPE_LINK) then
		st=SUMMON_TYPE_LINK
	else
		return false
	end
	local res=c:IsSetCard(0x10af) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,st,tp,true,true) and Duel.GetLocationCountFromEx(tp,tp,Group.FromCards(e:GetHandler(),tc),c)>0
		and ((c:IsType(TYPE_FUSION) and c:CheckFusionMaterial(mat)) or (c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil,mat)) or (c:IsType(TYPE_XYZ) and c:IsXyzSummonable(nil,mat)) or (c:IsType(TYPE_LINK) and c:IsLinkSummonable(nil,mat)))
	e1:Reset()
	return res
end

function s.pendcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	Duel.ConfirmCards(tp,g)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(g:GetFirst())
end

function s.pendtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rev=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc,rev,e,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,rev,e,tp)
end

function s.pendop(e,tp,eg,ep,ev,re,r,rp)
	local c,rev,tc=e:GetHandler(),e:GetLabelObject(),Duel.GetFirstTarget()
	c:AssumeProperty(ASSUME_LEVEL,rev:GetLevel())
	tc:AssumeProperty(ASSUME_RACE,RACE_FIEND)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
	tc:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_MATERIAL)
	tc:RegisterEffect(e2,true)
	if not rev or not tc or not tc:IsRelateToEffect(e) or not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,tc,rev,e,tp) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local op=Duel.SelectEffect(tp,{aux.TRUE,aux.Stringid(id,2)},{rev:IsAbleToExtra(),aux.Stringid(id,3)})
		if op==1 then
			Duel.MoveToField(rev,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			Duel.SendtoExtraP(rev,nil,REASON_EFFECT)
		end
		if rev:IsLocation(LOCATION_EXTRA+LOCATION_PZONE) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc,rev,e,tp):GetFirst()
			local st,res
			if sc:IsType(TYPE_FUSION) then
				st,res=SUMMON_TYPE_FUSION,REASON_FUSION
			elseif sc:IsType(TYPE_SYNCHRO) then
				st,res=SUMMON_TYPE_SYNCHRO,REASON_SYNCHRO
			elseif sc:IsType(TYPE_XYZ) then
				st,res=SUMMON_TYPE_XYZ,REASON_XYZ
			else
				st,res=SUMMON_TYPE_LINK,REASON_LINK
			end
			local g=Group.FromCards(c,tc)
			if st~=SUMMON_TYPE_XYZ then
				Duel.SendtoGrave(g,REASON_EFFECT+REASON_MATERIAL+res)
			else
				Duel.Overlay(sc,g)
			end
			if Duel.SpecialSummon(sc,st,tp,tp,false,false,POS_FACEUP)>0 then
				sc:SetMaterial(g)
				sc:CompleteProcedure()
			end
		end
	end
	e1:Reset()
	e2:Reset()
end

--SS with banished monsters

function s.matfilter(c,e)
	return c:IsSetCard(0xaf) and c:IsMonster() and c:IsFaceup() and c:IsCanBeEffectTarget(e) and (c:IsCanBeFusionMaterial() or c:IsCanBeSynchroMaterial() or c:IsCanBeXyzMaterial() or c:IsCanBeLinkMaterial())
end

function s.revfilter2(c,e,tp,mat)
	return c:IsSetCard(0x10af) and not c:IsPublic() and c:IsMonster() and c:IsType(TYPE_EXTRA) and aux.SelectUnselectGroup(mat,e,tp,1,#mat,s.rescon(c),0) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end

function s.rescon(c)
	return function(sg,e,tp,mg)
		local st
		if c:IsType(TYPE_FUSION) then
			st=SUMMON_TYPE_FUSION
		elseif c:IsType(TYPE_SYNCHRO) then
			st=SUMMON_TYPE_SYNCHRO
		elseif c:IsType(TYPE_XYZ) then
			st=SUMMON_TYPE_XYZ
		else
			st=SUMMON_TYPE_LINK
		end
		return (c:IsType(TYPE_FUSION) and c:CheckFusionMaterial(sg)) or (c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(sg,sg)) or (c:IsType(TYPE_XYZ) and c:IsXyzSummonable(sg,sg)) or (c:IsType(TYPE_LINK) and c:IsLinkSummonable(sg,sg)) 
			and c:IsCanBeSpecialSummoned(e,st,tp,false,false)
	end
end

function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	local mat=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.revfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mat) and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
	end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rev=Duel.SelectMatchingCard(tp,s.revfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mat):GetFirst()
	mat=aux.SelectUnselectGroup(mat,e,tp,1,#mat,s.rescon(rev),1,tp,HINTMSG_TARGET,s.rescon(rev),s.rescon(rev),false)
	Duel.ConfirmCards(1-tp,rev)
	Duel.HintSelection(mat)
	e:SetLabelObject({rev,mat})
	mat:KeepAlive()
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c,sc,mat=e:GetHandler(),table.unpack(e:GetLabelObject())
	if not sc or not mat or Duel.GetLocationCountFromEx(tp,tp,nil,sc)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local st,res
	if sc:IsType(TYPE_FUSION) then
		st,res=SUMMON_TYPE_FUSION,REASON_FUSION
	elseif sc:IsType(TYPE_SYNCHRO) then
		st,res=SUMMON_TYPE_SYNCHRO,REASON_SYNCHRO
	elseif sc:IsType(TYPE_XYZ) then
		st,res=SUMMON_TYPE_XYZ,REASON_XYZ
	else
		st,res=SUMMON_TYPE_LINK,REASON_LINK
	end
	if st~=SUMMON_TYPE_XYZ then
		Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+res)
	else
		Duel.Overlay(sc,mat)
	end
	if Duel.SpecialSummon(sc,st,tp,tp,false,false,POS_FACEUP)>0 then
		sc:SetMaterial(mat)
		sc:CompleteProcedure()
	end
end

--Non-Tuner

function s.ntval(c,sc,tp)
	return sc and sc:IsSetCard(0x10af)
end
