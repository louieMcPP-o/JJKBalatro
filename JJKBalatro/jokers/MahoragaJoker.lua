SMODS.Atlas { key = "Mahoraga", path = "Mahoraga.png", px = 71, py = 95  }

local PREFIX = SMODS.current_mod.prefix
local SUKUNA = "j_" .. PREFIX .. "_Sukuna"

local function has_sukuna()
    return G.jokers and #SMODS.find_card(SUKUNA, true) > 0
end

SMODS.Joker{
    key = "Mahoraga",
    loc_txt = {
        name = "Mahoraga",
        text = {
            "Every {X:green,C:white}8th{} turn add:",
            "{X:mult,C:white} 2X MULT {} and {C:attention}Disables{} the next boss blind",
            "Mult: {X:mult,C:white} #1#X {}, Turns: {X:green,C:white} #2# / 8 {}",
        }
    },
    config = { extra = { xmult = 3, wheel = 0, boss_remove = false } },
    atlas = "Mahoraga",
    pos = { x = 0, y = 0 },
    soul_pos = {x = 1, y = 0},
    rarity = 4,
    cost = 50,
    blueprint_compat = true,

    in_pool = function()
        return false
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.xmult,
            card.ability.extra.wheel
        } }
    end,


calculate = function(self, card, context)
    if context.before then
        if not context.blueprint then
            card.ability.extra.wheel = card.ability.extra.wheel + 1
        end
        if card.ability.extra.wheel == 8 then
            card.ability.extra.xmult = card.ability.extra.xmult + 2
            card.ability.extra.boss_remove = true
            card.ability.extra.wheel = 0
        end
        if card.ability.extra.wheel == 0 then
            return{message = "Wheel Reset!"}
        else
            return{message = card.ability.extra.wheel.."/ 8"}
        end
    end
    if context.setting_blind and card.ability.extra.boss_remove and G.GAME.blind.boss and not context.blueprint then
        G.GAME.blind:disable()
        card.ability.extra.boss_remove = false
        return{message = "ADAPTED"}
    end
    if context.end_of_round and context.main_eval and not context.blueprint
       and G.GAME.blind.boss and has_sukuna() then
        card.ability.extra.xmult = card.ability.extra.xmult * 3
        return { message = "Adapted to the King!", colour = G.C.RED }
    end
    if context.joker_main then
        return {
            xmult = card.ability.extra.xmult,
        }
    end
end
}
