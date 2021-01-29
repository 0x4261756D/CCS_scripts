--Light Realm of the Bilighteral - Paradiso
Duel.LoadScript("bilightutility.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x1000)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Change Damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re,r) return r&REASON_EFFECT~=0 end)
	c:RegisterEffect(e1)
	--Attribute Addition
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsOriginalAttribute,ATTRIBUTE_DARK))
	e2:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e2)
	--Boost
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(s.atkboost))
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(aux.TargetBoolFunction(s.defboost))
	e4:SetValue(s.defval)
	c:RegisterEffect(e4)
	--Protecc
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(s.atkboost))
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(aux.TargetBoolFunction(s.defboost))
	e6:SetValue(1)
	c:RegisterEffect(e6)
	--Place Counters
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_SUMMON_SUCCESS)
	e7:SetRange(LOCATION_FZONE)
	e7:SetOperation(s.acop)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e8)
	local e9=e7:Clone()
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e9)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EVENT_CHAINING)
	e10:SetRange(LOCATION_FZONE)
	e10:SetOperation(s.acop2)
	c:RegisterEffect(e10)
	--Remove Counters + return
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_QUICK_O)
	e11:SetCode(EVENT_FREE_CHAIN)
	e11:SetRange(LOCATION_FZONE)
	e11:SetCost(s.rccost)
	e11:SetTarget(s.rctg)
	e11:SetOperation(s.rcop)
	c:RegisterEffect(e11)
end

s.counter_place_list={0x1000}

--Boost

function s.atkboost(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAttackPos() and c:IsFaceup()
end

function s.atkval(e,c)
	return c:GetDefense()
end

function s.defboost(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsDefensePos() and c:IsFaceup()
end

function s.defval(e,c)
	return c:GetAttack()
end

--Place Counters

function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsAttribute,nil,ATTRIBUTE_LIGHT)
	local ct=0
	for tc in g:Iter() do
		if tc:HasLevel() then ct=ct+2*tc:GetLevel()
			elseif tc:HasRank() then ct=ct+2*tc:GetRank()
				elseif tc:IsLinkMonster() then ct=ct+2*tc:GetLink()
					else return
		end
	end
	e:GetHandler():AddCounter(0x1000,ct)
end

function s.acop2(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(0x400) then
		e:GetHandler():AddCounter(0x1000,1)
	end
end

--Remove Counters

function s.tdfilter(c,ct)
	return c:IsAbleToDeck() and ((ct>=4 and c:IsFacedown()) or (ct>=4 and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup() and c:IsSetCard(0x400)) or (c:IsFaceup() and c:IsSetCard(0x400) and c:IsMonster() and ct>=2*c:GetLevel()))
end

function s.fdfilter(c,ct)
	return c:IsAbleToDeck() and ct>=4 and c:IsFacedown()
end

function s.stfilter(c,ct)
	return c:IsAbleToDeck() and ct>=4 and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup() and c:IsSetCard(0x400)
end

function s.fumfilter(c,ct,lv)
	return c:IsAbleToDeck() and c:IsFaceup() and c:IsSetCard(0x400) and c:IsMonster() and ct>=lv and ct>=2*c:GetLevel()
end

function s.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetCounter(0x1000)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,ct)
	local fd,st,lv2m,fum=g:IsExists(s.fdfilter,1,nil,ct),g:IsExists(s.stfilter,1,nil,ct),g:IsExists(s.fumfilter,1,nil,ct,4),false
	if chk==0 then return #g>0 end
	local a={}
	for i=2,24,2 do
		if i==4 then 
			if fd or st or lv2m then table.insert(a,4) end
			break
		end
		if g:IsExists(s.fumfilter,1,nil,ct,i) then 
			table.insert(a,i)
			fum=true
		end
	end
	local choice=aux.EffectCheck(tp,{fd,st,fum},{aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3)})
	ct=Duel.AnnounceNumber(tp,table.unpack(a))
	e:GetHandler():RemoveCounter(tp,0x1000,ct,REASON_EFFECT)
	e:SetLabelObject({ct,choice})
end

function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local ct,choice=table.unpack(e:GetLabelObject())
	local tc
	if choice==0 then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		tc=Duel.SelectMatchingCard(tp,s.fdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,ct)
	end
	if choice==1 then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		tc=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,ct)
	end
	if choice==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		tc=Duel.SelectMatchingCard(tp,s.fumfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,ct,ct/2)
		end
	Duel.SendtoDeck(tc,tp,2,REASON_EFFECT)
end