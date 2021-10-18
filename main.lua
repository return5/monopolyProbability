

local PLAYER_LOC = 1

local PLACE_MAP = {
    "GO","Mediterranean Avenue","Community Chest","Baltic Avenu", "Income Tax",
    "Reading RailRoad","Oriental Avenue","Chance","Vermont Avenue","Connecticut Avenue",
    "Just Visiting Jail", "St.Charles Place", "Electric Company","States Avenue","Virginia avenue",
    "Pennsylvania RailRoad","St.James Place","Community Chest","Tennesse Avenue","New York Avenue",
    "Free Parking", "Kentuky Avenue", "Chance", "Indiana Avenue","Illinois Avenue","B.&O. RailRoad", 
    "Atlantic Avenue", "Ventnor Avenue", "Water Works","Marvin Gardens", "Go To Jail", "Pacific Avenue",
    "North Carolina Avenue", "Community Chest","Pennsylvania Avenue","Short Line","Chance",
    "Park Place","Luxury Tax", "BoardWalk"
}

local SPOTS = {}


local function buildCards() 
    return {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
end

local function initSpots() 
    for i=1,#PLACE_MAP,1 do
        SPOTS[PLACE_MAP[i]] = 0
    end
    SPOTS["Jail"] = 0
end

local function updateSpots()
    if PLAYER_LOC == 41 then
        SPOTS["Jail"] = SPOTS["Jail"] + 1
        PLAYER_LOC = 11
    else
        SPOTS[PLACE_MAP[PLAYER_LOC]] = SPOTS[PLACE_MAP[PLAYER_LOC]]  + 1
    end
end

local function removeCard(deck,i,remove)
    remove(deck,i)
    if #deck < 1 then
        return buildCards()
    end
    return deck
end


local function checkChance(i)
    if i == 1 then
        --BoardWalk
        PLAYER_LOC = 40
        updateSpots()
    elseif i == 2 then
        --go
        PLAYER_LOC = 1
        updateSpots()
    elseif i == 3 then
        --illinois avenue
        PLAYER_LOC = 25
        updateSpots()
    elseif i == 4 then
        advancedToNearestRailRoad()
    elseif i == 5 then
        advanceToNearestUtility()
    elseif i == 6 then
        --Reading RailRoad
        PLAYER_LOC = 6
        updateSpots()
    elseif i == 7 then
        --st.charles place
        PLAYER_LOC = 17
        updateSpots()
    elseif i == 8 then
        --move back 3 spaces
        PLAYER_LOC = (PLAYER_LOC - 3) % #PLACE_MAP
        updateSpots()
    elseif i == 9 then
        --go to jail
        PLAYER_LOC = 41
        updateSpots()
    end

end

local function checkCommunity(i)
    if i == 1 then
        --go to jail
        PLAYER_LOC = 41
        updateSpots()
    elseif i == 2 then
        --advance to go
        PLAYER_LOC = 1
        updateSpots()
    end
end


local function main() 
    local community = buildCards()
    local chance = buildCards()
    local remove = table.remove
    math.randomseed(os.time())
    initSpots()
    updateSpots()
    local prev1 = false
    local prev2 = false
    local prev3 = false
    for i=1,1000000,1 do
        prev3 = prev2
        prev2 = prev1
        local dice1 = math.random(1,6)
        local dice2 = math.random(1,6) 
        prev1 = dice1 == dice2
        if prev1 and prev2 and prev3  then
            PLAYER_LOC = 11
            updateSpots()
        else
            PLAYER_LOC = (PLAYER_LOC + dice1 + dice2) % #PLACE_MAP
            updateSpots()
            if PLACE_MAP[PLAYER_LOC] == "Chance" then
                local j = math.random(#chance)
                checkChance(j)
                chance = removeCard(chance,j,remove)
            elseif PLACE_MAP[PLAYER_LOC] == "Community Chest" then
                local j = math.random(#community)
                checkCommunity(j)
                community = removeCard(community,j,remove)
            elseif PLACE_MAP[PLAYER_LOC] == "Go To Jail" then
                PLAYER_LOC = 41
                updateSpots()
            end
        end
   end
end

local function printResults()
    local file = io.open("results.txt","w")
    for k,v in pairs(SPOTS) do
        file:write(k," : ",v,"\n")
    end
    file:close()
end

main()
printResults()

