SMODS.Atlas { key = "Megumi", path = "Megumi.png", px = 71, py = 95 }

local PREFIX = SMODS.current_mod.prefix
local MOD_ID = SMODS.current_mod.id
local MAHORAGA = "j_" .. PREFIX .. "_Mahoraga"  


local function made_count()
    local n = 0
    for _ in pairs(G.GAME.kaisen_made or {}) do n = n + 1 end
    return n
end

local function all_made()
    return made_count() >= #KAISEN.SHIKIGAMI
end

local function shikigami_create()
    G.GAME.kaisen_made = G.GAME.kaisen_made or {}   
    if G.GAME.consumeable_buffer + #G.consumeables.cards < G.consumeables.config.card_limit then
        local summon = pseudorandom_element(KAISEN.SHIKIGAMI, pseudoseed("kaisen_megumi"))

        if not G.GAME.kaisen_mahoraga_summoned then
            if all_made() then
                return false  
            end
            while G.GAME.kaisen_made[summon] do
                summon = pseudorandom_element(KAISEN.SHIKIGAMI, pseudoseed("kaisen_megumi"))
            end
        end

        G.GAME.kaisen_made[summon] = true  
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.add_card{
                    key = summon,
                }
                G.GAME.consumeable_buffer = 0
                return true
            end
        }))
        return true
    end
    return false
end

local function summon_mahoraga()
    if #G.jokers.cards < G.jokers.config.card_limit and #SMODS.find_card(MAHORAGA) == 0 then
        G.GAME.kaisen_mahoraga_summoned = true   
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.add_card { key = MAHORAGA }
                return true
            end
        }))
        return true
    end
    return false
end

SMODS.Joker{
    key = "Megumi",
    loc_txt = {
     name = "Megumi Fushiguro",
     text = {
         "{C:attention}Creates{} a {X:black,C:white}shikigami{} card every {C:attention}Round{}",
         "Once all 10 have been made, has a {C:green}#1# in #2#{} chance",
         "each round to summon {C:purple}Mahoraga{}",
         "{C:inactive}(Made: #3#/10){}"
        }
    },
    config = { extra = { odds = 4 } },
    rarity = 4,
    cost = 10,
    atlas = "Megumi",
    pos = { x = 0, y = 0 },
    blueprint_compat = true,

    loc_vars = function(self, info_queue, card)
        return { vars = {
            (G.GAME and G.GAME.probabilities.normal) or 1,
            card.ability.extra.odds,
            (G.GAME and made_count()) or 0   
        } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind then
            if all_made() and not G.GAME.kaisen_mahoraga_summoned
               and pseudorandom(pseudoseed("kaisen_mahoraga")) < G.GAME.probabilities.normal / card.ability.extra.odds then
                summon_mahoraga()
            else
                shikigami_create()
            end
        end
    end
}