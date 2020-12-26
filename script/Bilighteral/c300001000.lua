--These High Heels, hot damn
Duel.LoadScript("bilightutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Act in za hando and on za fieldo
	Bilighteral.CreateActivation(c)
	--Spell Effect
	local e2=Bilighteral.AddSpellEffect({handler=c,cat=CATEGORY_SPECIAL_SUMMON,cost=s.spellcost,tg=s.spelltg,op=s.spellop})
	c:RegisterEffect(e2)
	--Trap Effect
	local e3=Bilighteral.AddTrapEffect({handler=c,cat=CATEGORY_REMOVE+CATEGORY_TOGRAVE+CATEGORY_DRAW,cost=s.trapcost,op=s.trapop})
	c:RegisterEffect(e3)
end

--Spell Effect

function s.tgfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToGraveAsCost()
end

function s.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsPublic() and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND,0,1,c,e,tp,c:GetLevel())
end

function s.filter2(c,e,tp,lv)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil,ATTRIBUTE_LIGHT)+Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil,ATTRIBUTE_DARK)
	local glv=g:GetSum(Card.GetLevel)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsPublic() and aux.SelectUnselectGroup(g,e,tp,1,99,s.rescon(c:GetLevel()+lv),0) and glv>=c:GetLevel()+lv
end

function s.rescon(lv)
	return function(sg,e,tp,mg)
		return sg:GetSum(Card.GetLevel)>=lv
	end
end

function s.spellcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil,ATTRIBUTE_LIGHT)+Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil,ATTRIBUTE_DARK)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) and #g>0 end
	local tc1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND,0,1,1,tc1,e,tp,tc1:GetFirst():GetLevel())
	local tg=aux.SelectUnselectGroup(g,e,tp,1,99,s.rescon(tc1:GetFirst():GetLevel()+tc2:GetFirst():GetLevel()),1,tp,nil,s.rescon(tc1:GetFirst():GetLevel()+tc2:GetFirst():GetLevel()),s.rescon(tc1:GetFirst():GetLevel()+tc2:GetFirst():GetLevel()),false)
	Duel.ConfirmCards(1-tp,tc1+tc2)
	Duel.SendtoGrave(tg,REASON_COST,tp)
	Duel.SetTargetCard(tc1+tc2)
end

function s.spelltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end

function s.spellop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or not tc then return end
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end

--Trap Effect

function s.tdfilter(c)
	return c:IsAbleToDeckAsCost() and c:IsSetCard(0x400)
end

function s.trapcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then return #g>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2*#g end
	local tc=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,99,nil)
	Duel.SendtoDeck(tc,tp,1,REASON_COST)
	e:SetLabel(#tc)
end

function s.trapop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<2*count or not Duel.IsPlayerCanDraw(tp,count) then return end
	local g=Duel.GetDecktopGroup(tp,2*count)
	Duel.ConfirmCards(tp,g)
	local tc=g:FilterSelect(tp,Card.IsAbleToGrave,count,count,nil)
	g:Sub(tc)
	Duel.SendtoGrave(tc,REASON_EFFECT,tp)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT,tp)
	Duel.Draw(tp,count,REASON_EFFECT)
end