--Burning Steel Forge
--Script by Coroln
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --Back to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
    e2:SetCondition(s.tecon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
    --extra pendulum
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
    --Add 1 face-up Pendulum Monster from your Extra Deck to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.condition)
	e4:SetTarget(s.thtg3)
	e4:SetOperation(s.thop3)
	c:RegisterEffect(e4)
end
s.listed_series={0x478}
--back to hand
function s.cfilter(c,tp)
	return c:GetSummonPlayer()==tp and c:IsSummonType(SUMMON_TYPE_PENDULUM)
		and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x478)
end
function s.tecon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thfil(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x478) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfil,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfil,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--extra pendulum
function s.infilter(e,c)
    return c:IsSetCard(0x478) and c:IsType(TYPE_PENDULUM)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.infilter,1,true,nil,nil,e,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.infilter,1,1,true,nil,nil,e,tp)
	Duel.Release(g,REASON_COST)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		and Duel.GetFlagEffect(tp,id+100)==0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.DiscardDeck(p,val,REASON_EFFECT)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_ADJUST)
	e1:SetOperation(s.checkop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	s.checkop(e,tp)
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,0))
end
function s.checkop(e,tp)
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	if lpz~=nil and lpz:GetFlagEffect(id)<=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC_G)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_PZONE)
		e1:SetCondition(s.pencon)
		e1:SetOperation(s.penop)
		e1:SetValue(SUMMON_TYPE_PENDULUM)
		e1:SetReset(RESET_PHASE+PHASE_END)
		lpz:RegisterEffect(e1)
		lpz:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.pencon(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if rpz==nil or c==rpz or Duel.GetFlagEffect(tp,29432356)>0 then return false end
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
	if loc==0 then return false end
	local g=nil
	if og then
		g=og:Filter(Card.IsLocation,nil,loc)
	else
		g=Duel.GetFieldGroup(tp,loc,0)
	end
	return g:IsExists(Pendulum.Filter,1,nil,e,tp,lscale,rscale)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp)
	local ft=Duel.GetUsableMZoneCount(tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		ft=1
	end
	local loc=0
	if ft1>0 then loc=loc+LOCATION_HAND end
	if ft2>0 then loc=loc+LOCATION_EXTRA end
	local tg=nil
	if og then
		tg=og:Filter(Card.IsLocation,nil,loc):Filter(Pendulum.Filter,nil,e,tp,lscale,rscale):Filter(Card.IsSetCard,nil,0x478)
	else
		tg=Duel.GetMatchingGroup(Pendulum.Filter,tp,loc,0,nil,e,tp,lscale,rscale)
	end
	ft1=math.min(ft1,tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND))
	ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
	ft2=math.min(ft2,aux.CheckSummonGate(tp) or ft2)
	while true do
		local ct1=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		local ct2=tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
		local ct=ft
		if ct1>ft1 then ct=math.min(ct,ft1) end
		if ct2>ft2 then ct=math.min(ct,ft2) end
		local loc=0
		if ft1>0 then loc=loc+LOCATION_HAND end
		if ft2>0 then loc=loc+LOCATION_EXTRA end
		local g=tg:Filter(Card.IsLocation,sg,loc):Filter(Card.IsSetCard,nil,0x478)
		if #g==0 or ft==0 then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Group.SelectUnselect(g,sg,tp,true,true)
		if not tc then break end
		if sg:IsContains(tc) then
				sg:RemoveCard(tc)
				if tc:IsLocation(LOCATION_HAND) then
				ft1=ft1+1
			else
				ft2=ft2+1
			end
			ft=ft+1
		else
			sg:AddCard(tc)
			if tc:IsLocation(LOCATION_HAND) then
				ft1=ft1-1
			else
				ft2=ft2-1
			end
			ft=ft-1
		end
	end
	if #sg>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(tp,29432356,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
		Duel.HintSelection(Group.FromCards(c))
		Duel.HintSelection(Group.FromCards(rpz))
	end
end
--Add 1 face-up Pendulum Monster from your Extra Deck to your hand
function s.cfilter2(c,tp)
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousControler(tp) and c:GetPreviousSequence()<5 and c:IsReason(REASON_EFFECT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp)
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.thop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end