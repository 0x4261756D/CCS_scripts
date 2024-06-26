--Hypercosmic Amalgamation
local s,id=GetID()
function s.initial_effect(c)
	-- Ritual Summon Hypercosmic Ritual Monster
	Ritual.AddProcGreater({handler=c,filter=s.ritualfil})
	--Special summon (deck)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.extg)
	e1:SetOperation(s.exop)
	c:RegisterEffect(e1)
end
s.listed_series={0x4879}
s.listed_names={id,735773357}
function s.ritualfil(c)
	return c:IsSetCard(0x4879) and c:IsRitualMonster()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.cfilter(c)
	return c:IsSetCard(0x4879)
		and c:IsAbleToRemoveAsCost()and aux.SpElimFilter(c,true)
end
--function s.cfilter(c)
--	return c:IsSetCard(0x4879) and c:IsMonster() 
--		and c:IsAbleToRemoveAsCost()-- and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c,true,true))
--end
function s.rescon(checkfunc)
	return function(sg,e,tp,mg)
		--if not sg:CheckDifferentProperty(checkfunc) then return false,true end
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
	end
end
function s.spfilter(c,e,tp,sg)
	return c:IsCode(132913057) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
			and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
end
function s.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkcost=e:GetLabel()==1
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,nil)
	if chk==0 then
		if chkcost then
			e:SetLabel(0)
			return #cg>1 and aux.SelectUnselectGroup(cg,e,tp,13,13,s.rescon,0)
		else
			return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		end
	end
	if chkcost then
		local rg=aux.SelectUnselectGroup(cg,e,tp,13,13,s.rescon,1,tp,HINTMSG_REMOVE)
		Duel.Remove(rg,POS_FACEUP,REASON_COST)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.exop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end
--
--
--function s.hncost(e,tp,eg,ep,ev,re,r,rp,chk)
--	local c=e:GetHandler()
--	local mg1=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1)
--	local mg2=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,12)
----	local checkfunc=aux.PropertyTableFilter(Card.GetSetCard,0x10f2,0x2073,0x2017,0x1046)
--	if chk==0 then return c:IsAbleToRemoveAsCost() end
--	-- and aux.SelectUnselectGroup(mg,e,tp,4,4,s.rescon(checkfunc),0) end
--	--local sg=aux.SelectUnselectGroup(mg,e,tp,4,4,s.rescon(checkfunc),1,tp,HINTMSG_REMOVE,s.rescon(checkfunc))+c
--	Duel.Remove(sg,POS_FACEUP,REASON_COST)
--end
--function s.hntg(e,tp,eg,ep,ev,re,r,rp,chk)
--	if chk==0 then return true end
--	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
--end
--function s.hnop(e,tp,eg,ep,ev,re,r,rp)
--	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
--	local g=Duel.SelectMatchingCard(tp,s.hnfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
--	if #g>0 then
--		Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
--	end
--end
--