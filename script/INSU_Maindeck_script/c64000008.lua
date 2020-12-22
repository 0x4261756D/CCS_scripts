--sea of cloads
function c64000008.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c64000008.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
    --search
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(64000008,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c64000008.thtg)
	e5:SetOperation(c64000008.thop)
	c:RegisterEffect(e5)
	--avoid battle damage
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(c64000008.target)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	end

function c64000008.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsFaceup() and tc:GetSummonPlayer() then
			tc:AddCounter(0x1019,1)
		end
		tc=eg:GetNext()
	end
end
	function c64000008.thfilter(c)
	return (c:IsCode(82760689) or c:IsCode(19980975) or c:IsCode(63741331) or c:IsCode(511001924) or c:IsCode(64000009)
	or c:IsCode(23639291) or c:IsCode(511001788) or c:IsCode(55375684) or c:IsCode(90135989) or c:IsCode(511001787)
		or c:IsCode(45653036) or c:IsCode(90557975) or c:IsCode(70017) or c:IsCode(18158397)) and c:IsAbleToHand()
end
function c64000008.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c64000008.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c64000008.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c64000008.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c64000008.target(e,c)
	return c:IsSetCard(0x18) 
end