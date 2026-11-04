SMODS.Atlas { key = "MeiMei", path = "MeiMei.png", px = 71, py = 95 }

SMODS.Joker{
    key = "Mei",
    loc_txt = {
        name = "Mei Mei",
        text = {
            "Gives {C:mult}+#3#{} mult for each played{C:attention} face{} card ",
            "Gains {X:attention,C:white}+1{} crow every round, up to a maximum of {X:attention,C:white}5{} crows",
            "{C:attention}Bird Strike:{} on final hand sacrifice each crow for {X:mult,C:white}+ #1#X{} Mult",
            "Gains {C:money}+$#4#{} for each {C:attention}crow{} at end of round ",
            "{X:inactive,C:white}(Currently:#2#/5){} {X:mult,C:white} X#5#{} {C:money} +$#4#{}{}",
        }
    },
    config = { extra = { crow_mult = 0.75 , crow_count = 0 , face_mult = 3, money = 1 } },
    rarity = 2,
    cost = 6,
    atlas = "MeiMei",
    pos = { x = 0, y = 0 },
    blueprint_compat = true,

    loc_vars = function ( self, info_queue, card)
        local crows = 1 + ( card.ability.extra.crow_count * card.ability.extra.crow_mult)
        return { vars = { card.ability.extra.crow_mult , card.ability.extra.crow_count, card.ability.extra.face_mult, card.ability.extra.money, crows } }
    end,


    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_face() then
                return {mult = card.ability.extra.face_mult}
            end
        end
        if context.joker_main then     

            if G.GAME.current_round.hands_left == 0 then
                local crow_mult = 1 + ( card.ability.extra.crow_count * 0.75)
                card.ability.extra.crow_count = 0
                return { message = "Bird Strike!", x_mult = crow_mult}
            end
        end
        if context.end_of_round and context.main_eval and not context.blueprint then
            card.ability.extra.crow_count = math.min(card.ability.extra.crow_count + 1, 5)
            return {message = "Crow Gained!"}
        end    
    end,

    calc_dollar_bonus = function(self, card)
        local dollar_gain = card.ability.extra.crow_count * card.ability.extra.money

        if dollar_gain > 0 then
            return dollar_gain
        end
    end,     
        
}