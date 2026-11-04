SMODS.Atlas { key = "Finger", path = "Finger.png", px = 71, py = 95 }  

local PREFIX = SMODS.current_mod.prefix
local YUJI = "j_" .. PREFIX .. "_Itadori"      
local SUKUNA = "j_" .. PREFIX .. "_Sukuna"     

SMODS.ConsumableType {
    key = "Finger",                             
    shop_rate = 0,                            
    primary_colour = HEX("2B2D42"),
    secondary_colour = HEX("8B0000"),
    collection_rows = { 1 },                  
    loc_txt = {                                
        name = "Finger",
        collection = "Sukuna's Fingers",        
        undiscovered = { name = "Not Discovered", text = { "Find it in a run", "to discover it" } }
    }
}

SMODS.Consumable {                              
    key = "finger",                            
    set = "Finger",                             
    atlas = "Finger",                           
    pos = { x = 0, y = 0 },
    soul_pos = {x = 1, y = 0}, 
    cost = 2,
    loc_txt = {
        name = "Sukuna's Finger",
        text = {
            "Feed one of {C:purple}Sukuna's{} fingers to {C:attention}Yuji{}",
            "At {C:attention}#1#{} fingers, he becomes {C:purple}Sukuna{}",
            "{C:inactive}(Eaten: #2#/#1#){}"
        }
    },
    config = { extra = { total = 20 } },        

    loc_vars = function(self, info_queue, card)
        return { vars = {
            card.ability.extra.total,
            (G.GAME and G.GAME.sukuna_fingers) or 0    
        } }
    end,

    in_pool = function()
        return G.jokers and #SMODS.find_card(YUJI, true) > 0   
    end,

    can_use = function(self, card)
        return G.jokers and #SMODS.find_card(YUJI, true) > 0
    end,

    use = function(self, card, area, copier)
        G.GAME.sukuna_fingers = (G.GAME.sukuna_fingers or 0) + 1    
        local yuji_card = SMODS.find_card(YUJI, true)[1]          
        if not yuji_card then return end                            

        SMODS.calculate_effect({
            message = G.GAME.sukuna_fingers .. "/" .. card.ability.extra.total,
            colour = G.C.PURPLE
        }, yuji_card)

        if G.GAME.sukuna_fingers >= card.ability.extra.total and G.P_CENTERS[SUKUNA] then
            G.E_MANAGER:add_event(Event({
                func = function()
                    yuji_card:set_ability(G.P_CENTERS[SUKUNA])
                    yuji_card:juice_up()
                    play_sound("timpani")
                    SMODS.calculate_effect({ message = "The King of Curses awakens!", colour = G.C.RED }, yuji_card)
                    G.GAME.shop_rate = 0
                    return true
                end
            }))
        end
    end
}