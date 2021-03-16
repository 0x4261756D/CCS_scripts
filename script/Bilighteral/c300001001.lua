--These arguments, hot damn
Duel.LoadScript("bilightutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Act in za hando and on za fieldo
	Bilighteral.CreateActivation(c)
	--Spell Effect
	local e2=Bilighteral.AddSpellEffect({handler=c,cat=CATEGORY_SEARCH+CATEGORY_TOHAND,cost=s.spellcost,tg=s.spelltg,op=s.spellop})
	c:RegisterEffect(e2)
	--Trap Effect
	local e3=Bilighteral.AddTrapEffect({handler=c,cat=CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH,prop=EFFECT_FLAG_CARD_TARGET,cost=s.trapcost,tg=s.traptg,op=s.trapop})
	c:RegisterEffect(e3)
end

--Spell Effect

function s.tgfilter(c)
	return c:IsSetCard(0x400) and c:IsAbleToGraveAsCost()
end

function s.remfilter(c)
	return c:IsSetCard(0x400) and c:IsAbleToRemoveAsCost()
end

function s.dcfilter(c)
	return c:IsSetCard(0x400) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end

function s.thfilter(c)
	return c:IsSetCard(0x400) and c:IsAbleToHand()
end

function s.spellcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return 
		Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and
		Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) and
		Duel.IsExistingMatchingCard(s.remfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local c1=Duel.SelectMatchingCard(tp,s.remfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local c2=Duel.SelectMatchingCard(tp,s.dcfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local c3=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.Remove(c1,POS_FACEUP,REASON_COST,tp)
	Duel.SendtoGrave(c2,REASON_COST+REASON_DISCARD,tp)
	Duel.SendtoGrave(c3,REASON_COST,tp)
end

function s.spelltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>0 and aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,0,tp,LOCATION_DECK)
end

function s.spellop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local tc=aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,1,tp,nil,nil,nil,true)
	Duel.SendtoHand(tc,tp,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
end

--Trap Effect

function s.tdfilter(c)
	return c:IsAbleToDeckAsCost() and c:IsSetCard(0x400)
end

function s.trapcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return 
		Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and
		Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil)
	end
	local tc1=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local tc2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetTargetCard(tc1+tc2)
end

function s.traptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local add,draw=#g>0 and aux.SelectUnselectGroup(g,e,tp,1,2,aux.dncheck,0),#g>0 and Duel.IsPlayerCanDraw(tp,3) and Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,LOCATION_HAND,0,nil)>0
	if chk==0 then return add or draw end
	local choice=aux.EffectCheck(tp,{add,draw},{aux.Stringid(id,0),aux.Stringid(id,1)})
	if choice==0 then Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,nil,tp,LOCATION_DECK) end
	if choice==1 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_DRAW,nil,2,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND) end
	e:SetLabel(choice)
end

function s.trapop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if choice==0 and not (#g>0 or aux.SelectUnselectGroup(g,e,tp,1,2,aux.dncheck,0)) then return end
	if choice==1 and not (Duel.IsPlayerCanDraw(tp,3) or Duel.GetMatchingGroupCount(Card.IsDiscardable,tp,LOCATION_HAND,0,nil)>0) then return end
	if choice==0 then
		local tc=aux.SelectUnselectGroup(g,e,tp,1,2,aux.dncheck,1,tp,nil,nil,nil,true)
		Duel.SendtoHand(tc,REASON_EFFECT,tp)
		Duel.ConfirmCards(1-tp,tc)
	end
	if choice==1 then
		Duel.Draw(tp,3,REASON_EFFECT)
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT,nil)
	end
	Duel.SendtoDeck(Duel.GetTargetCards(e),tp,2,REASON_EFFECT)
end