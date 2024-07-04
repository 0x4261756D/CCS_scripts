Duel.LoadScript("customutility.lua")

function Link.AddSpellTrapProcedure(c,f,min,max,specialchk,desc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1174)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	if max==nil then max=c:GetLink() end
	e1:SetCondition(Link.STCondition(f,min,max,specialchk))
	e1:SetTarget(Link.STTarget(f,min,max,specialchk))
	e1:SetOperation(Link.STOperation(f,min,max,specialchk))
	e1:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e1)
end

function Link.STConditionFilter(c,f,lc,tp)
    if c:IsMonster() then 
        local res1=c:IsCanBeLinkMaterial(lc,tp) and (not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
        local res2=false
        local formud_eff=c:IsHasEffect(50366775)
        if formud_eff then
            local label={formud_eff:GetLabel()}
            for i=1,#label-1,2 do
                c:AssumeProperty(label[i],label[i+1])
            end
            res2=c:IsCanBeLinkMaterial(lc,tp) and (not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
        end
        return res1 or res2
    else
        return not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp)
    end
end

function Link.STCondition(f,minc,maxc,specialchk)
	return function(e,c,must,g2,min,max)
		if not c then return true end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local tp=c:GetControler()
		if not g2 then
			g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		end
		local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_SZONE,0,nil,TYPE_SPELL+TYPE_TRAP)
		g:Merge(g2)
		local mg=g:Filter(Link.STConditionFilter,nil,f,c,tp)
		local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
		if must then mustg:Merge(must) end
		if min and min < minc then return false end
		if max and max > maxc then return false end
		min = min or minc
		max = max or maxc
		if mustg:IsExists(aux.NOT(Link.STConditionFilter),1,nil,f,c,tp) or #mustg>max then return false end
		local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
		tg=tg:Filter(Link.STConditionFilter,nil,f,c,tp)
		local res=(mg+tg):Includes(mustg) and #mustg<=max
		if res then
			if #mustg==max then
				local sg=Group.CreateGroup()
				res=mustg:IsExists(Link.CheckRecursive,1,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt)
			elseif #mustg<max then
				local sg=mustg
				res=(mg+tg):IsExists(Link.CheckRecursive,1,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt)
			end
		end
		aux.DeleteExtraMaterialGroups(emt)
		return res
	end
end

function Link.STTarget(f,minc,maxc,specialchk)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
				if not g then
					g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
				end
                local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_SZONE,0,nil,TYPE_SPELL+TYPE_TRAP)
                g:Merge(g2)
				if min and min < minc then return false end
				if max and max > maxc then return false end
				min = min or minc
				max = max or maxc
				local mg=g:Filter(Link.STConditionFilter,nil,f,c,tp)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
				if must then mustg:Merge(must) end
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
				tg:Match(Link.STConditionFilter,nil,f,c,tp)
				local sg=Group.CreateGroup()
				local finish=false
				local cancel=false
				sg:Merge(mustg)
				local mg_tg=mg+tg
				while #sg<max do
					local filters={}
					if #sg>0 then
						Link.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg_tg,mg_tg,c,min,max,f,specialchk,mg,emt,filters)
					end
					local cg=mg_tg:Filter(Link.CheckRecursive,sg,tp,sg,mg_tg,c,min,max,f,specialchk,mg,emt,{table.unpack(filters)})
					if #cg==0 then break end
					finish=#sg>=min and #sg<=max and Link.CheckGoal(tp,sg,c,min,f,specialchk,filters)
					cancel=not og and Duel.IsSummonCancelable() and #sg==0
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,1,1)
					if not tc then break end
					if #mustg==0 or not mustg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
						else
							sg:RemoveCard(tc)
						end
					end
				end
				if #sg>0 then
					local filters={}
					Link.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg_tg,mg_tg,c,min,max,f,specialchk,mg,emt,filters)
					sg:KeepAlive()
					e:SetLabelObject({sg,filters,emt})
					return true
				else
					aux.DeleteExtraMaterialGroups(emt)
					return false
				end
			end
end

function Link.STOperation(f,minc,maxc,specialchk)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
				local g,filt,emt=table.unpack(e:GetLabelObject())
				for _,ex in ipairs(filt) do
					if ex[3]:GetValue() then
						ex[3]:GetValue()(1,SUMMON_TYPE_LINK,ex[3],ex[1]&g,c,tp)
						if ex[3]:CheckCountLimit(tp) then
							ex[3]:UseCountLimit(tp,1)
						end
					end
				end
				for tc in g:Iter() do
					local formud_eff=tc:IsHasEffect(50366775)
					if formud_eff then
						local res1=tc:IsCanBeLinkMaterial(c,tp) and (not f or f(tc,c,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
						local label={formud_eff:GetLabel()}
						for i=1,#label-1,2 do
							tc:AssumeProperty(label[i],label[i+1])
						end
						local res2=tc:IsCanBeLinkMaterial(c,tp) and (not f or f(tc,c,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
						if not res2 or (res1 and res2 and not Duel.SelectEffectYesNo(tp,tc)) then
							Duel.AssumeReset()
						end
					end
				end
				c:SetMaterial(g)
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
				aux.DeleteExtraMaterialGroups(emt)
			end
end
