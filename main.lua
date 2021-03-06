

local PLAYER_LOC = 1

--every board location in monopoly in order from GO and moving clockwise around the board.
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

--map which holds the locatons and the count of how many times player lands on that place.
local SPOTS = {}

--number of times to roll the dice.
local LIMIT = 10000000

--16 diffrent cards for chance and community chest.
local function buildCards() 
    return {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
end

--initalize the SPOTS map with 0 for each place.
local function initSpots() 
    for i=1,#PLACE_MAP,1 do
        SPOTS[PLACE_MAP[i]] = 0
    end
    SPOTS["Jail"] = 0
end

--when player lands on a spot increment the count by one.
local function updateSpots()
    --if player in in jail(not just visiting).
    if PLAYER_LOC == 41 then
        SPOTS["Jail"] = SPOTS["Jail"] + 1
        PLAYER_LOC = 11
    else
        SPOTS[PLACE_MAP[PLAYER_LOC]] = SPOTS[PLACE_MAP[PLAYER_LOC]]  + 1
    end
end

--based on ucrrent location, move to nearest utility.
local function advanceToNearestUtility()
    if PLAYER_LOC < 13 or PLAYER_LOC >= 29  then
        PLAYER_LOC = 13
    else
        PLAYER_LOC = 29
    end
    updateSpots()
end

--based on current location, move to nearest railroad.
local function advanceToNearestRailRoad()
    if PLAYER_LOC >= 36 and PLAYER_LOC < 6 then
        PLAYER_LOC = 6
    elseif PLAYER_LOC >= 6 and PLAYER_LOC < 16 then
        PLAYER_LOC = 16
    elseif PLAYER_LOC >= 16 and PLAYER_LOC < 26 then
        PLAYER_LOC = 26
    else
        PLAYER_LOC = 36
    end
    updateSpots()
end

--when player draws a card from community chest or chance remove that card from the deck.
local function removeCard(deck,i,remove,isChance)
    remove(deck,i)
    --if deck is empty.
    if #deck < 1 then
        --build new deck
        local deck = buildCards()
        if isChance then
            --chance has 2 advanceToNearestRailRaod cards.
            deck[#deck + 1] = 4
        end
        return deck
    end
    return deck
end


--check out which chance card was drawn.
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
        advanceToNearestRailRoad()
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

--checkout which community chest card was drawn.
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
    local rand   = math.random
    table.insert(chance,4)
    math.randomseed(os.time())
    initSpots()
    updateSpots()
    -- booleans to record if the last 3 dice rolls are doubles.
    local prev1 = false
    local prev2 = false
    local prev3 = false
    for i=1,LIMIT,1 do
        prev3 = prev2
        prev2 = prev1
        local dice1 = rand(1,6)
        local dice2 = rand(1,6) 
        prev1 = dice1 == dice2
    -- if all three are doubles then it's off to jail.
        if prev1 and prev2 and prev3  then
            PLAYER_LOC = 41
            updateSpots()
        else
            --player location is modulo with teh number of places. adding 1 to account for human readable based indexing.
            PLAYER_LOC = ((PLAYER_LOC + dice1 + dice2) % 40) + 1
            updateSpots()
            if PLACE_MAP[PLAYER_LOC] == "Chance" then
                local j = rand(#chance)
                checkChance(chance[j])
                chance = removeCard(chance,j,remove,true)
            elseif PLACE_MAP[PLAYER_LOC] == "Community Chest" then
                local j = rand(#community)
                checkCommunity(community[j])
                community = removeCard(community,j,remove,false)
            elseif PLACE_MAP[PLAYER_LOC] == "Go To Jail" then
                PLAYER_LOC = 41
                updateSpots()
            end
        end
   end
end


--sort results from most to least chance.
local function sortResults()
    --holds sorted keys from most chance to least chance.
    local sorted = {}
    for k,_ in pairs(SPOTS) do
        local temp = k
        for i=1,#sorted,1 do
            if SPOTS[temp] > SPOTS[sorted[i]] then
                local temp2 = sorted[i]
                sorted[i] = temp
                temp = temp2
            end
        end
        --after the above loop temp will be the current lowest chance place. as such it belongs int eh back of the list.
        sorted[#sorted + 1] = temp
    end
    return sorted
end


local function printResults()
    local file = io.open("results.md","w")
    file:write("|Place  |Chance|\n:---|---:\n")
    local sorted = sortResults()
    for i=1, #sorted,1 do
        file:write("|",sorted[i]," | ",(SPOTS[sorted[i]] / LIMIT) * 100,"|\n")
    end
    file:close()
end

main()
printResults()

