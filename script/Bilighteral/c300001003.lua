--Bilighteral Allure
Duel.LoadScript("bilightutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Act in za hando and on za fieldo
	Bilighteral.CreateActivation(c)
	--Spell Effect
	local e2=Bilighteral.AddSpellEffect({handler=c,cat=CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_TOGRAVE+CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_RECOVER,prop=EFFECT_FLAG_CARD_TARGET,tg=s.spelltg,op=s.spellop})
	c:RegisterEffect(e2)
	--Trap Effect
	local e3=Bilighteral.AddTrapEffect({handler=c,cat=CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE+CATEGORY_TODECK,prop=EFFECT_FLAG_CARD_TARGET,tg=s.traptg,op=s.trapop})
	c:RegisterEffect(e3)
end

--Spell Effect

function s.remfilter(c)
	return (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) and c:IsAbleToRemove()
end

function s.tgfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToGraveAsCost()
end

function s.spelltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingMatchingCard(s.remfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end

function s.spellop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.remfilter,tp,LOCATION_HAND,0,1,nil) or not Duel.IsPlayerCanDraw(tp,2) then return end
	Duel.Draw(tp,2,REASON_EFFECT)
	local tc=Duel.SelectMatchingCard(tp,s.remfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT,tp)
	local att=tc:GetFirst():GetAttribute()
	local dnd,pab=c:IsAttribute(ATTRIBUTE_LIGHT) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,ATTRIBUTE_DARK) and Duel.IsPlayerCanDraw(tp,1),c:IsAttribute(ATTRIBUTE_DARK) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,ATTRIBUTE_LIGHT) and Duel.IsExistingTarget(Card.IsDestructable,tp,0,LOCATION_MZONE,1,nil)
	local choice,additional=-1,dnd and pab
	if Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		choice=aux.EffectCheck(tp,{dnd,pab},{aux.Stringid(id,0),aux.Stringid(id,1)})
		if choice==0 then
			local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,ATTRIBUTE_DARK)
			Duel.SendtoGrave(tc,REASON_COST,tp)
			Duel.ShuffleDeck(tp)
			Duel.Draw(tp,1,REASON_EFFECT)
			Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT,nil)
			if additional then
				local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,ATTRIBUTE_LIGHT)
				Duel.SendtoGrave(tc,REASON_COST,tp)
				tc=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
				Duel.Destroy(tc,REASON_EFFECT)
				local val=(tc:GetTextAttack()+tc:GetTextDefense())/2
				Duel.Damage(1-tp,val,REASON_EFFECT)
				Duel.Recover(tp,val,REASON_EFFECT)
			end
		end
		if choice==1 then
			local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,ATTRIBUTE_LIGHT)
			Duel.SendtoGrave(tc,REASON_COST,tp)
			tc=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
			Duel.Destroy(tc,REASON_EFFECT)
			local val=(tc:GetTextAttack()+tc:GetTextDefense())/2
			Duel.Damage(1-tp,val,REASON_EFFECT)
			Duel.Recover(tp,val,REASON_EFFECT)
			if additional then
				local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,ATTRIBUTE_DARK)
				Duel.SendtoGrave(tc,REASON_COST,tp)
				Duel.ShuffleDeck(tp)
				Duel.Draw(tp,1,REASON_EFFECT)
				Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT,nil)
			end
		end
	end
end

--Trap Effect

function s.thfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x400)
end

function s.cfilter(c)
	return c:IsAbleToChangeControler()
end

function s.remfilter2(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemoveAsCost()
end

function s.traptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetTargetCard(tc)
end

function s.trapop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local choice,additional=-1,false
	local tc=Duel.GetTargetCards(e):GetFirst()
	if not tc then return end
	Duel.GetControl(tc,tp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	local l=g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)>0
	local d=g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_DARK)>0
	local ath,shuf=l and Duel.IsExistingMatchingCard(s.remfilter2,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_DARK) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil),d>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.IsExistingMatchingCard(s.remfilter2,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_LIGHT)
	local aditional=ath and shuf
	if Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		local choice=aux.EffectCheck(tp,{ath,shuf},{aux.Stringid(id,2),aux.Stringid(id,3)})
		if choice==0 then
			local rem=Duel.SelectMatchingCard(tp,s.remfilter2,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_DARK)
			Duel.Remove(rem,POS_FACEUP,REASON_COST,tp)
			local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
			Duel.SendtoHand(tc,REASON_EFFECT,tp)
			Duel.ConfirmCards(1-tp,tc)
			if additional and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				local rem=Duel.SelectMatchingCard(tp,s.remfilter2,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_LIGHT)
				Duel.Remove(rem,POS_FACEUP,REASON_COST,tp)
				Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_HAND))
				local tc=Duel.GetFieldGroup(tp,0,LOCATION_HAND):FilterSelect(tp,Card.IsAbleToDeck,1,1,nil)
				Duel.SendtoDeck(tc,2,REASON_EFFECT,1-tp)
			end
		end
		if choice==1 then
			local rem=Duel.SelectMatchingCard(tp,s.remfilter2,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_LIGHT)
			Duel.Remove(rem,POS_FACEUP,REASON_COST,tp)
			Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_HAND))
			local tc=Duel.GetFieldGroup(tp,0,LOCATION_HAND):FilterSelect(tp,Card.IsAbleToDeck,1,1,nil)
			Duel.SendtoDeck(tc,2,REASON_EFFECT,1-tp)
			if additional and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				local rem=Duel.SelectMatchingCard(tp,s.remfilter2,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_DARK)
				Duel.Remove(rem,POS_FACEUP,REASON_COST,tp)
				local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
				Duel.SendtoHand(tc,REASON_EFFECT,tp)
				Duel.ConfirmCards(1-tp,tc)
			end
		end
	end
end