--Dark Realm of the Bilighteral - Inferno
Duel.LoadScript("bilightutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x1001)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Change Recovery
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REVERSE_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	c:RegisterEffect(e1)
	--Attribute Addition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsOriginalAttribute,ATTRIBUTE_LIGHT))
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	--Values Down
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(aux.TargetBoolFunction(s.atkloss))
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(aux.TargetBoolFunction(s.defloss))
	e4:SetValue(s.defval)
	c:RegisterEffect(e4)
	--Effect Negation on battle
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(s.discon)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
	--Place Counters
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCondition(s.accon)
	e7:SetOperation(s.acop)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e8)
	--Remove Counters + send + burn
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,0))
	e9:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e9:SetType(EFFECT_TYPE_QUICK_O)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetRange(LOCATION_FZONE)
	e9:SetCost(s.rccost)
	e9:SetTarget(s.rctg)
	e9:SetOperation(s.rcop)
	c:RegisterEffect(e9)
end

s.counter_place_list={0x1001}

--Values Down

function s.atkloss(c)
	return c:IsAttackPos() and c:IsFaceup()
end

function s.atkval(e,c)
	return -c:GetDefense()
end

function s.defloss(c)
	return c:IsDefensePos() and c:IsFaceup()
end

function s.defval(e,c)
	return -c:GetAttack()
end

--Negation on battle

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return at and a:IsSetCard(0x400)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	tc:RegisterEffect(e2)
end

--Place Counters

function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end

function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	e:GetHandler():AddCounter(0x1001,#g)
end

--Remove Counters

function s.filter1(c,ct)
	return c:IsAbleToGrave() and (c:IsFacedown() or (c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup())) and ct>=2
end

function s.filter2(c,ct)
	return c:IsAbleToGrave() and c:IsFaceup() and ((c:HasLevel() and ct>=c:GetLevel()) or (c:HasRank() and ct>=c:GetRank()) or (c:IsLinkMonster() and ct>=2*c:GetLink()))
end

function s.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x1001)
	local fdst,fum=Duel.IsExistingTarget(s.filter1,tp,0,LOCATION_MZONE+LOCATION_SZONE,1,nil,ct),Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil,ct)
	if chk==0 then return fdst or fum end
	local choice=aux.EffectCheck(tp,{fdst,fum},{aux.Stringid(id,1),aux.Stringid(id,2)})
	if choice==0 then
		local tc=Duel.SelectTarget(tp,s.filter1,tp,0,LOCATION_MZONE+LOCATION_SZONE,1,1,nil,ct):GetFirst()
		ct=2
	elseif choice==1 then
		local tc=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,ct):GetFirst()
		if tc:HasLevel() then
			ct=tc:GetLevel()
		elseif tc:HasRank() then
			ct=tc:GetRank()
		elseif tc:IsLinkMonster() then
			ct=2*tc:GetLink()
		else return
		end
	else return
	end
	e:GetHandler():RemoveCounter(tp,0x1001,ct,REASON_EFFECT)
end

function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE+CATEGORY_DAMAGE,nil,1,1-tp,LOCATION_MZONE+LOCATION_SZONE)
end

function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local atk,def
	Duel.SendtoGrave(tc,REASON_EFFECT)
	if tc:IsMonster() then
		if tc:IsLinkMonster() then
			atk,def=tc:GetTextAttack(),0
		else atk,def=tc:GetTextAttack(),tc:GetTextDefense()
		end
		Duel.BreakEffect()
		Duel.Damage(1-tp,(atk+def)/2,REASON_EFFECT)
	end
end