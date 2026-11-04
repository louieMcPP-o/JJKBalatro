SMODS.Atlas { key = "Sukuna", path = "Sukuna.png", px = 71, py = 95 }  

local PREFIX = SMODS.current_mod.prefix                
local MAHORAGA = "j_" .. PREFIX .. "_Mahoraga"         

local function has_mahoraga()
    return G.jokers and #SMODS.find_card(MAHORAGA, true) > 0   
end

SMODS.Joker{                                           
    key = "Sukuna",
    loc_txt = {
        name = "Sukuna",
        text = {
            "The {X:purple,C:white} King{} of Curses...",   
            "{C:attention}Four Arms:{} {C:attention}+#1#{} hand size",
            "{C:attention}Dismantle:{} after each hand, {C:attention}destroys{} the",
            "lowest card held and gains {X:mult,C:white}X#2#{} Mult",
            "{C:mult}Cleave:{} {X:mult,C:white}X#3#{} per scored card",
            "{C:mult}Fuga:{} final hand, {X:mult,C:white}X#4#{} per Dismantle this round",
            "{X:purple,C:white}Malevolent Shrine:{} first hand vs a {C:attention}Boss{},",
            "retrigger scored cards {C:attention}#5#{} times",
            "{C:inactive}(Currently {X:mult,C:white}X#6#{C:inactive} Mult){}"   
        }
    },
    
    config = { extra = { hand_gain = 1, dismantle_mult = 0.2, cleave_mult = 1.2,
                         fuga_mult = 4, shrine_trigger = 3, xmult = 1, dismantled = 0 } },
    atlas = "Sukuna",
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
            card.ability.extra.hand_gain,
            card.ability.extra.dismantle_mult,
            card.ability.extra.cleave_mult,
            card.ability.extra.fuga_mult,
            card.ability.extra.shrine_trigger,
            card.ability.extra.xmult
        } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.hand_gain)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.hand_gain)
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play
           and G.GAME.blind.boss and G.GAME.current_round.hands_played == 0 then
            return {
                message = "Malevolent Shrine!",
                colour = G.C.PURPLE,
                repetitions = card.ability.extra.shrine_trigger
            }
        end

        if context.individual and context.cardarea == G.play then
            return { xmult = card.ability.extra.cleave_mult }
        end

        if context.after and not context.blueprint then
            local low = nil                          
            for _, c in ipairs(G.hand.cards) do
                if c.config.center ~= G.P_CENTERS.m_stone then
                    if not low or c:get_id() < low:get_id() then
                        low = c
                    end
                end
            end
            if low then
                low:start_dissolve()
                SMODS.calculate_context({ remove_playing_cards = true, removed = { low } })
                card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.dismantle_mult
                card.ability.extra.dismantled = card.ability.extra.dismantled + 1   
                return { message = "Dismantle!", colour = G.C.RED }
            end
        end
        if context.end_of_round and context.main_eval and not context.blueprint
           and G.GAME.blind.boss and has_mahoraga() then
            card.ability.extra.xmult = card.ability.extra.xmult * 3
            return { message = "SYNERGY!", colour = G.C.PURPLE }
        end
        if context.joker_main then
            if G.GAME.current_round.hands_left == 0 and card.ability.extra.dismantled > 0 then
                return {
                    xmult = card.ability.extra.xmult,
                    extra = {
                        message = "Fuga!",
                        colour = G.C.RED,
                        xmult = card.ability.extra.fuga_mult * card.ability.extra.dismantled
                    }
                }
            end
            return { xmult = card.ability.extra.xmult }
        end

        if context.setting_blind and not context.blueprint then
            card.ability.extra.dismantled = 0
        end
    end,                                               
}