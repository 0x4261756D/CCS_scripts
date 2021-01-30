--Chaos Realm of the Bilighteral - Purgatorio
Duel.LoadScript("bilightutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x13)
	c:EnableCounterPermit(0x1000)
	c:EnableCounterPermit(0x1001)
	aux.GlobalCheck(s,function()
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_ADJUST)
		ge:SetOperation(s.checkop)
		Duel.RegisterEffect(ge,0)
	end)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabelObject(ge)
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
	e4:SetDescription(aux.Stringid(id,0))
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

--Xyz Materials

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local lr,dr=false,false
	for tc in aux.Next(eg) do
		if tc:IsCode(300001006) then lr=true end
		if tc:IsCode(300001007) then dr=true end
	end
	e:SetLabelObject({lr,dr})
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local lr,dr=table.unpack({e:GetLabelObject():GetLabelObject()})
	return lr and dr
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g1,g2=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,300001006),Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,300001007)
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
	e:GetHandler():AddCounter(0x13,#eg)
end

--Remove Counters

function s.filter1(c,ct)
	return c:IsAbleToGrave() and (c:IsFacedown() or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup())) and ct>=2
end

function s.filter2(c,ct)
	return c:IsAbleToGrave() and c:IsFaceup() and ((c:HasLevel() and ct>=c:GetLevel()) or (c:IsType(TYPE_XYZ) and ct>=c:GetRank()) or (c:IsLinkMonster() and ct>=2*c:GetLink()))
end

function s.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x1001)
	local fdst,fum=Duel.IsExistingTarget(s.filter1,tp,0,LOCATION_MZONE+LOCATION_SZONE,1,nil,ct),Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil,ct)
	if chk==0 then return fdst or fum end
	local choice=aux.EffectCheck(tp,{fdst,fum},{aux.Stringid(id,1),aux.Stringid(id,2)})
	if choice==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=Duel.SelectTarget(tp,s.filter1,tp,0,LOCATION_MZONE+LOCATION_SZONE,1,1,nil,ct):GetFirst()
		ct=2
	elseif choice==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tc=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,ct):GetFirst()
		if tc:HasLevel() then
			ct=tc:GetLevel()
		elseif tc:GetRank()>0 then
			ct=tc:GetRank()
		elseif tc:IsLinkMonster() then
			ct=2*tc:GetLink()
		else return
		end
	else return
	end
	e:GetHandler():RemoveCounter(tp,0x1001,ct,REASON_COST)
end

function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE+CATEGORY_DAMAGE,nil,1,1-tp,LOCATION_MZONE+LOCATION_SZONE)
end

function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local atk,def
	if Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
		if tc:IsMonster() then
			if tc:IsLinkMonster() then
				atk,def=tc:GetTextAttack(),0
			else atk,def=tc:GetTextAttack(),tc:GetTextDefense()
			end
			Duel.Damage(1-tp,(atk+def)/2,REASON_EFFECT)
		end
	end
end