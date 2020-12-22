function c64000150.initial_effect(c)
--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,64000150)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c64000150.spcon)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RECOVER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,64000149)
	e2:SetCondition(c64000150.drcon)
	e2:SetTarget(c64000150.drtg)
	e2:SetOperation(c64000150.drop)
	c:RegisterEffect(e2)
end
function c64000150.spfilter(c)
	return c:IsFaceup() and (c:IsCode(79575620) or c:IsCode(5519829))
end
function c64000150.cfilter(c)
	return c:IsFaceup() and (c:IsCode(79575620) or c:IsSetCard(0x14d))
end
function c64000150.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c64000150.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c64000150.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function c64000150.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and ep==tp and e:GetHandler():IsRelateToEffect(e) end
	local d=1
	if Duel.IsExistingMatchingCard(c64000150.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler()) then
		d=2
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(d)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,d)
end
function c64000150.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
