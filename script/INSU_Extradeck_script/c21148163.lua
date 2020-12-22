--Spider Dragon, Nightmare Creator
function c21148163.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,4,4,c21148163.lcheck)
	--add
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c21148163.thcon)
	e1:SetTarget(c21148163.thtg)
	e1:SetOperation(c21148163.thop)
	c:RegisterEffect(e1)
	--Disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c21148163.tgtg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e3)
	--move
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(2)
	e4:SetCondition(c21148163.seqcon)
	e4:SetOperation(c21148163.seqop)
	c:RegisterEffect(e4)
	--spsummon only
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_SPSUMMON_CONDITION)
	e5:SetValue(c21148163.splimit)
	c:RegisterEffect(e5)
	--cannot release
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_UNRELEASABLE_SUM)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e7)
end
function c21148163.cfilter(c,tp,seq,lc)
	return c:GetSequence()==seq and c:IsControler(tp)
	 	and c:IsCanBeLinkMaterial(lc,tp)
end
function c21148163.lcheck(g,lc,tp)
	local emz1 = Duel.GetFieldCard(tp,LOCATION_MZONE,5)
    local emz2 = Duel.GetFieldCard(tp,LOCATION_MZONE,6)
    if emz1 or emz2 then
        local count = 0
        if emz1 and g:IsContains(emz1) then count = count + 1 end
        if emz2 and g:IsContains(emz2) then count = count + 1 end
        if count < 1 then return false end
    end
    return g:IsExists(Card.IsType,1,nil,TYPE_EFFECT,lc,SUMMON_TYPE_LINK,tp)
end

function c21148163.splimit(e,se,sp,st)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
end

function c21148163.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c21148163.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c21148163.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToHand),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function c21148163.tgtg(e,c)
	local tp=e:GetHandler():GetControler()
	return e:GetHandler():GetLinkedGroup():IsContains(c)
		and not (c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsControler(tp))
end

function c21148163.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	if seq<5 then return false end
	return not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function c21148163.rmfilter(c,tp,e,a)
	return ((c:GetSequence()==e:GetHandler():GetSequence()+a and c:IsControler(tp))
	 or (c:GetSequence()==e:GetHandler():GetSequence() and c:IsControler(1-tp)))
		and c:IsAbleToRemove()
end
function c21148163.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	local seq=c:GetSequence()
	if seq<5 then return end
	local a=1
	if seq>5 then a=-1 end
	if Duel.CheckLocation(tp,LOCATION_MZONE,seq+a) then
		Duel.MoveSequence(c,seq+a)
	else
		if Duel.IsExistingMatchingCard(c21148163.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,e,a) then
			local g=Duel.SelectMatchingCard(tp,c21148163.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,e,a)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			Duel.MoveSequence(c,seq+a)
		end
	end
end