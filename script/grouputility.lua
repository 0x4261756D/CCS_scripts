Duel.LoadScript("customutility.lua")

function Card.GetMaxCounterRemoval(c,tp,cttypes,reason)
	local ct=0
	if type(cttypes)=="table" then
		for _,cttype in ipairs(cttypes) do
			for i=1,c:GetCounter(cttype) do
				if c:IsCanRemoveCounter(tp,cttype,i,reason) then
					ct=ct+1
				else
					break
				end
			end
		end
	else
		for i=1,c:GetCounter(cttypes) do
			if c:IsCanRemoveCounter(tp,cttypes,i,reason) then
				ct=ct+1
			else
				break
			end
		end
	end
	return ct
end

function Card.MaxCounterRemovalCheck(c,tp,cttypes,ctamount,reason)
	return c:GetMaxCounterRemoval(tp,cttypes,reason)>=ctamount
end

function Group.GetMaxCounterRemoval(g,tp,cttypes,reason)
	local ct=0
	if type(cttypes)=="table" then
		for _,cttype in ipairs(cttypes) do
			for tc in g:Iter() do
				ct=ct+tc:GetMaxCounterRemoval(tp,cttype,reason)
			end
		end
	else
		for tc in g:Iter() do
			ct=ct+tc:GetMaxCounterRemoval(tp,cttypes,reason)
		end
	end
	return ct
end

function Group.CanRemoveCounter(g,tp,cttypes,ctamount,reason)
	return g:GetMaxCounterRemoval(tp,cttypes,reason)>=ctamount
end

function Group.RemoveCounter(g,tp,cttypes,ctamount,reason)
	if type(cttypes)=="table" then
		local ct=0
		for _,cttype in ipairs(cttypes) do
			ct=ct+g:GetMaxCounterRemoval(tp,cttype,reason)
		end
		if ct<ctamount then return end
		local choices,tc,choice
		for i=1,ctamount do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE_COUNTER)
			tc=g:FilterSelect(tp,Card.MaxCounterRemovalCheck,1,1,nil,tp,cttypes,1,reason):GetFirst()
			choices={}
			for _,cttype in ipairs(cttypes) do
				table.insert(choices,{tc:IsCanRemoveCounter(tp,cttype,1,reason),tonumber(cttype)})
			end
			choice=Duel.SelectEffect(tp,table.unpack(choices))
			tc:RemoveCounter(tp,cttypes[choice],1,reason)
		end
	else
		if not g:CanRemoveCounter(tp,cttypes,ctamount,reason) then return end
		local tc
		for i=1,ctamount do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE_COUNTER)
			tc=g:FilterSelect(tp,Card.IsCanRemoveCounter,1,1,nil,tp,cttypes,1,reason):GetFirst()
			tc:RemoveCounter(tp,cttypes,1,reason)
		end
	end
end