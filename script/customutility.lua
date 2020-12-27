--Hilfskostenfunktion um ein Anzahl X Xyz Materialien abzuhängen (min=<X=<max). min=nil -> alle Materialien werden abgehängt.
--label=true -> Die Anzahl abgehängter Materialien wird als Label gespeichert.
function Auxiliary.doccost(min,max,label)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local ct,eff,set,label=c:GetOverlayCount(),Duel.IsPlayerAffectedByEffect(tp,CARD_NUMERON_NETWORK),c:IsSetCard(0x14b),label or false
		local min=min or ct
		local max=max or min
		if chk==0 then return c:CheckRemoveOverlayCard(tp,min,REASON_COST) or (eff and set) end
		if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
			return true
				else c:RemoveOverlayCard(tp,min,max,REASON_COST)
		end
		if label==true then 
			e:SetLabel(#Duel.GetOperatedGroup())
		end
	end
end