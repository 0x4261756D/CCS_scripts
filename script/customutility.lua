--Hilfskostenfunktion um eine Anzahl X Xyz Materialien abzuhängen (min=<X=<max). min=nil -> alle Materialien werden abgehängt.
--label=true -> Die Anzahl abgehängter Materialien wird als Label gespeichert.
--Es ist ebenfalls möglich eine weitere Kostenfunktion mit einzubinden, indem diese als Parameter 4 mit übergeben wird.
--Dabei ist drauf zu achten, dass dann auch eine 0 oder 1 als Parameter 5 mitgegeben wird (0 führt die zusätzliche Kostenfunktion vor dem Abhängen aus, 1 tut es nachdem äbgehängt wurde).
function Auxiliary.doccost(min,max,label,cost,order)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local ct,eff,set,label=c:GetOverlayCount(),Duel.IsPlayerAffectedByEffect(tp,CARD_NUMERON_NETWORK),c:IsSetCard(0x14b),label or false
		local min=min or ct
		local max=max or min
		if chk==0 then 
			if cost then
				return (c:CheckRemoveOverlayCard(tp,min,REASON_COST) or (eff and set)) and cost(e,tp,eg,ep,ev,re,r,rp,0)
				else return c:CheckRemoveOverlayCard(tp,min,REASON_COST) or (eff and set)
			end
		end
		if cost then
			if order==0 then
				if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
					cost(e,tp,eg,ep,ev,re,r,rp,1)
					return true
						else
							cost(e,tp,eg,ep,ev,re,r,rp,1)
							c:RemoveOverlayCard(tp,min,max,REASON_COST)
				end
			elseif order==1 then
				if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
					cost(e,tp,eg,ep,ev,re,r,rp,1)
					return true
						else
							c:RemoveOverlayCard(tp,min,max,REASON_COST)
							cost(e,tp,eg,ep,ev,re,r,rp,1)
				end
			end
		else
			if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
				return true
					else
						c:RemoveOverlayCard(tp,min,max,REASON_COST)
			end
		end
		if label==true then 
			e:SetLabel(#Duel.GetOperatedGroup())
		end
	end
end