--Chaos Realm of the Bilighteral - Purgatorio
Duel.LoadScript("bilightutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x13)
	c:EnableCounterPermit(0x1000)
	c:EnableCounterPermit(0x1001)
	--Flags
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_ALL)
	e0:SetOperation(s.flagop)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcon)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	--Copy Effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.cop)
	c:RegisterEffect(e2)
	--Place Counters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)
	--Remove Counters + send + burn
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,12))
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCost(s.rccost)
	e4:SetTarget(s.rctg)
	e4:SetOperation(s.rcop)
	c:RegisterEffect(e4)
end

s.counter_place_list={0x1000,0x1001,0x13}

--Flags

function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsCode,1,nil,id-2) then Duel.RegisterFlagEffect(tp,id-2,0,0,0) end
	if eg:IsExists(Card.IsCode,1,nil,id-1) then Duel.RegisterFlagEffect(tp,id-1,0,0,0) end
end

--Xyz Materials

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id-2)>0 and Duel.GetFlagEffect(tp,id-1)>0
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g1,g2=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,id-2),Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,id-1)
	if #g1>0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local sg1,sg2=g1:Select(tp,1,1,nil),g2:Select(tp,1,1,nil)
		Duel.Overlay(e:GetHandler(),sg1+sg2)
	end
end

--Copy Effects

function s.cop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	for tc in g:Iter() do
		local code=tc:GetOriginalCode()
		if c:IsFaceup() and c:GetFlagEffect(code)==0 then
			c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
			c:RegisterFlagEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
	end
end

--Place Counters

function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local ct=0
	for tc in eg:Iter() do
		if tc:HasLevel() then ct=ct+tc:GetLevel()
			elseif tc:GetRank()>0 then ct=ct+tc:GetRank()
				elseif tc:IsLinkMonster() then ct=ct+2*tc:GetLink()
					elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) then ct=ct+2
						else return
		end
	end
	e:GetHandler():AddCounter(0x13,ct)
end

--Remove Counters

function s.stfilter(c,tp,ct)
	return ((c:IsAbleToGrave() and not c:IsLocation(LOCATION_GRAVE)) or c:IsAbleToDeck() or c:IsAbleToHand() or (c:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0)) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup() and ct>=2
end

function s.fumfilter(c,e,tp,ct)
	return ((c:IsAbleToGrave() and not c:IsLocation(LOCATION_GRAVE)) or c:IsAbleToDeck() or c:IsAbleToHand() or (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)) and c:IsFaceup() and ((c:HasLevel() and ct>=c:GetLevel()) or (c:IsType(TYPE_XYZ) and ct>=c:GetRank()) or (c:IsLinkMonster() and ct>=2*c:GetLink()))
end

function s.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local cel,inf,cha=e:GetHandler():GetCounter(0x1000),e:GetHandler():GetCounter(0x1001),e:GetHandler():GetCounter(0x13)
	local ct,ctr=cel+inf+2*cha,0
	local celcr,infcr,chacr={},{},{}
	local st,fum=Duel.IsExistingTarget(s.stfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp,ct),Duel.IsExistingTarget(s.fumfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,ct)
	if chk==0 then return st or fum end
	local choice=aux.EffectCheck(tp,{st,fum},{aux.Stringid(id,10),aux.Stringid(id,11)})
	local tc
	if choice==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=Duel.SelectTarget(tp,s.stfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp,ct):GetFirst()
		ctr=2
	elseif choice==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=Duel.SelectTarget(tp,s.fumfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,ct):GetFirst()
		if tc:HasLevel() then
			ctr=tc:GetLevel()
		elseif tc:GetRank()>0 then
			ctr=tc:GetRank()
		elseif tc:IsLinkMonster() then
			ctr=2*tc:GetLink()
		else return
		end
	else return
	end
	local ss,set,th,td,tg=tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0,tc:IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0,tc:IsAbleToHand(),tc:IsAbleToDeck(),tc:IsAbleToGrave() and not tc:IsLocation(LOCATION_GRAVE)
	choice=aux.EffectCheck(tp,{ss,set,th,td,tg},{aux.Stringid(id,5),aux.Stringid(id,6),aux.Stringid(id,7),aux.Stringid(id,8),aux.Stringid(id,9)})
	for i=math.min(math.abs(ctr-2*cha-cel-inf),cha),math.min(ctr,cha) do
		table.insert(chacr,i)
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	cha=Duel.AnnounceNumber(tp,table.unpack(chacr))
	ctr=ctr-2*cha
	for i=math.min(math.abs(ctr-inf),cel),math.min(ctr,cel) do
		table.insert(celcr,i)
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	cel=Duel.AnnounceNumber(tp,table.unpack(celcr))
	ctr=ctr-cel
	for i=math.min(ctr,inf),math.min(ctr,inf) do
		table.insert(infcr,i)
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
	inf=Duel.AnnounceNumber(tp,table.unpack(infcr))
	e:GetHandler():RemoveCounter(tp,0x13,cha,REASON_COST)
	e:GetHandler():RemoveCounter(tp,0x1000,cel,REASON_COST)
	e:GetHandler():RemoveCounter(tp,0x1001,inf,REASON_COST)
	e:SetLabel(choice)
end

function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE+CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local tc,choice=Duel.GetFirstTarget(),e:GetLabel()
	if (choice==0 and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.GetLocationCount(tp,LOCATION_MZONE)==0)) or (choice==1 and (not tc:IsSSetable() or Duel.GetLocationCount(tp,LOCATION_SZONE)==0)) or (choice==2 and not tc:IsAbleToHand()) or (choice==3 and not tc:IsAbleToDeck()) or (choice==4 and not tc:IsAbleToGrave()) then
		return
	end
	if choice==0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif choice==1 then
		Duel.SSet(tp,tc)
	elseif choice==2 then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	elseif choice==3 then
		Duel.SendtoDeck(tc,tp,2,REASON_EFFECT)
	elseif choice==4 then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	else return
	end
end

