--Zyhimirath the Merged Reality
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	-- Fusion Condition
	Fusion.AddProcMixN(c,true,true,700014149,1,aux.FilterBoolFunctionEx(Card.IsSetCard,0x4879),4)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or (st&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
