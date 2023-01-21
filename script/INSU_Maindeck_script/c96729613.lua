--Preperation Routine
local s, id = GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_HAND,0,nil)>0 end
	local hg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil) --hand cards
	if hg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local tc=hg:Select(tp,1,1,nil):GetFirst()
		Duel.ConfirmCards(1-tp,tc,REASON_COST)
		Duel.ShuffleHand(tp)
		e:SetLabel(tc:GetCode())
	end
end
function s.offilter(c,r) --on field filter
	return c:IsFaceup() and c:IsCode(r)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Debug.Message(Duel.IsExistingMatchingCard(s.offilter,tp,LOCATION_ONFIELD,0,1,nil,e:GetLabel()))
	if Duel.IsExistingMatchingCard(s.offilter,tp,LOCATION_ONFIELD,0,1,nil,e:GetLabel()) then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	
	local dc=Duel.GetOperatedGroup() --drawn cards
	local mg=dc:Filter(Card.IsType,nil,TYPE_MONSTER) --monster group
	--local nmg=dc:Filter(function(c) return not c:IsType(TYPE_MONSTER) end,nil) --non monster group
	nmg = dc:Clone() 
	nmg:Sub(mg) --non monster group
	if mg:GetCount()==0 then
		if Duel.Remove(nmg,POS_FACEDOWN,REASON_EFFECT)==3 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	elseif mg:GetCount()==1 then
		if Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)==1 then
			Duel.SendtoGrave(nmg,REASON_EFFECT)
		end
	elseif mg:GetCount()==2 then Duel.Remove(mg,POS_FACEDOWN,REASON_EFFECT)
	elseif mg:GetCount()==3 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
		--smg=Group.Filter(mg,s.spfilter,nil) --summonable monster group
		--if smg:GetCount()>0 then
		if mg:IsExists(s.spfilter,1,nil,e,tp) then
			smg=Group.Filter(mg,s.spfilter,nil,e,tp) --summonable monster group
			Duel.SpecialSummon(smg,0,tp,tp,false,false,POS_FACEUP)
			
			local tc=smg:GetFirst()
			while tc do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+0x1fe0000)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+0x1fe0000)
				tc:RegisterEffect(e2)
				tc=smg:GetNext()
			end
		--	Duel.SpecialSummonComplete()
			mg:Sub(smg)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e3:SetTargetRange(1,0)
			e3:SetTarget(s.splimit)
			e3:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e3,tp)
		end
		Duel.SendtoDeck(mg,tp,2,REASON_EFFECT)
	end
	end
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
