Duel.LoadScript("customutility.lua")

STAGE_ROOKIE = 1
STAGE_CHAMPION = 2
STAGE_ULTIMATE = 3
STAGE_MEGA = 4
STAGE_ULTRA = 5

if not Digimon then
	Digimon={}
end

function Digimon.AddLogic(c,stage,rookies,champions,ultimates,megas,ultras)
    if Digimon.GetStage(c) >= STAGE_MEGA then
        c:EnableUnsummonable()
    end
    local digitations = {}
    local rookies = rookies or {}
    local champions = champions or {}
    local ultimates = ultimates or {}
    local megas = megas or {}
    local ultras = ultras or {}
    table.insert(digitations,rookies)
    table.insert(digitations,champions)
    table.insert(digitations,ultimates)
    table.insert(digitations,megas)
    table.insert(digitations,ultras)
    local m = c:GetMetatable()
    m.digitations = digitations
    m.stage = stage
end

function Digimon.GetStage(c)
    local m = c:GetMetatable()
    return m.stage or 0
end

function Digimon.GetDigitations(c,stage)
    local m = c:GetMetatable()
    if not m.digitations then return {} end
    if stage then return m.digitations[stage] end
    return m.digitations
end

function Digimon.SelectDigitations(c,tp,count,stage)
    local d = Digimon.GetDigitations(c,stage)
    if not d then return end
    local t,t2 = {},{}
    for _,code in ipairs(d) do
        table.insert(t,code)
        table.insert(t,OPCODE_ISCODE)
    end
    for i = 1, count do
        table.insert(t2,Duel.AnnounceCard(tp,table.unpack(t)))
    end
    return t2
end

function Digimon.IsExistingDigitationToSummon(g,e,tp,st,loc1,loc2,count,ex,ignore_conditions,ignore_limit,pos,stage,f,...)
    local params = {...}
    if type(g) == 'card' then g = Group.FromCards(g) end
    local d = {}
    for c in g:Iter() do
        table.insert(d,Digimon.GetDigitations(c,stage))
    end
    local g2 = Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,loc1,loc2,ex,e,st,tp,ignore_conditions,ignore_limit,pos)
    if f then g2 = g2:Filter(f,nil,table.unpack(params)) end
    local ct = 0
    for _,code in ipairs(d) do
        if g2:IsExists(Card.IsCode,1,nil,code) then
            ct = ct + 1
        end
    end
    return ct >= count
end

function Digimon.SelectDigitationToSummon(g,e,tp,st,loc1,loc2,min,max,ex,ignore_conditions,ignore_limit,pos,stage,f,...)
    local params = {...}
    if type(g) == 'card' then g = Group.FromCards(g) end
    if not Digimon.IsExistingDigitationToSummon(g,e,tp,st,loc1,loc2,min,ex,ignore_conditions,ignore_limit,pos,stage,f,table.unpack(params)) then return end
    local d = {}
    for c in g:Iter() do
        table.insert(d,Digimon.GetDigitations(c,stage))
    end
    local g2 = Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned,tp,loc1,loc2,ex,e,st,tp,ignore_conditions,ignore_limit,pos):Filter(Card.IsCode,nil,table.unpack(d))
    if f then g2 = g2:Filter(f,nil,table.unpack(params)) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    g2 = g2:Select(tp,min,max,nil)
    g2:KeepAlive()
    return g2
end

function Digimon.SummonDigitation(g,e,tp,st,loc1,loc2,min,max,ex,ignore_conditions,ignore_limit,pos,stage,f,...)
    local params = {...}
    if type(g) == 'card' then g = Group.FromCards(g) end
    local g2 = Digimon.SelectDigitationToSummon(g,e,tp,st,loc1,loc2,min,max,ex,ignore_conditions,ignore_limit,pos,stage,f,table.unpack(params))
    if g2 and #g2>0 then Duel.SpecialSummon(g2,st,tp,tp,ignore_conditions,ignore_limit,pos) end
    g2:DeleteGroup()
end
