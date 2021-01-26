--This file contains a useful list of functions which can be used for a lot of things. Each function should have a small description as well.

--Function to check whether a card is EXACTLY the passed type (like a more strict version of Card.IsType)
function Card.CheckType(c,tp)
	return (c:GetType()&tp)==tp
end

--doccost detaches a specific amount of materials from an Xyz monster (min=<X=<max). min=nil -> detaches all materials.
--label=true -> the amount of detached materials will be saved as a label.
--The function also supports another cost when passed as parameter 4.
--If "cost" isn't nil, it is required that "order" isn't nil as well, otherwise the passed function won't be executed.
--order=0 -> the passed cost will be executed before the detaching, order=1 -> afterwards
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
				else
					if (eff and set) and (ct==0 or (ct>0 and Duel.SelectYesNo(tp,aux.Stringid(CARD_NUMERON_NETWORK,1)))) then
						return true
							else
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
		if label==true then 
			e:SetLabel(#Duel.GetOperatedGroup())
		end
	end
end
--aux.spfilter is a shortcut to check for legally special summonable. It has to be called with e,tp and the summon type and also supports another filter which has to be fullfilled along with all its extraparams.
--Example: Duel.IsExistingMatchingCard(aux.spfilter(e,tp,s.filter,a,b),tp,LOCATION_GRAVE,0,1,nil) where a and b are the extraparams of s.filter.
function Auxiliary.spfilter(e,tp,sumtype,f,...)
	local params={...}
	return function(c)
		if f then return c:IsCanBeSpecialSummoned(e,sumtype,tp,false,false) and f(c,table.unpack(params))
		else return c:IsCanBeSpecialSummoned(e,sumtype,tp,false,false) end
	end
end
