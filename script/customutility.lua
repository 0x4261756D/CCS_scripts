--Hilfskostenfunktion um eine Anzahl X Xyz Materialien abzuhängen (min=<X=<max). min=nil -> alle Materialien werden abgehängt.
--label=true -> Die Anzahl abgehängter Materialien wird als Label gespeichert.
--Es ist ebenfalls möglich eine weitere Kostenfunktion mit einzubinden, indem diese als Parameter 4 mit übergeben wird.
--wird order (Parameter 5) mitgegeben wird cost nach dem Abhängen ausgeführt, sonst davor.

function Auxiliary.doccost(min,max,label,cost,order)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local ct,eff,set,label=c:GetOverlayCount(),Duel.IsPlayerAffectedByEffect(tp,CARD_NUMERON_NETWORK),c:IsSetCard(0x14b),label or false
		local min=min or ct
		local max=max or min
		if chk==0 then
			return (c:CheckRemoveOverlayCard(tp,min,REASON_COST) or (eff and set)) and cost and cost(e,tp,eg,ep,ev,re,r,rp,0)
		end
		if cost then
			if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
				cost(e,tp,eg,ep,ev,re,r,rp,1)
				return true
			else
				if order then
					c:RemoveOverlayCard(tp,min,max,REASON_COST)
					cost(e,tp,eg,ep,ev,re,r,rp,1)
				else
					cost(e,tp,eg,ep,ev,re,r,rp,1)						
					c:RemoveOverlayCard(tp,min,max,REASON_COST)
				end
			end
		else
			if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
				return true
			else
				c:RemoveOverlayCard(tp,min,max,REASON_COST)
			end
		end
		if label then 
			e:SetLabel(#Duel.GetOperatedGroup())
		end
	end
end