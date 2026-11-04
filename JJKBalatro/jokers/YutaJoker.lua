SMODS.Atlas { key = "Yuta", path = "Yuta.png", px = 71, py = 95 }

local PREFIX = SMODS.current_mod.prefix
local MOD_ID = SMODS.current_mod.id
local YUTA = "j_" .. PREFIX .. "_Yuta"
local RIKA = "j_" .. PREFIX .. "_Rika"

local function has_rika()
  return G.jokers and #SMODS.find_card(RIKA) > 0
end

local function pick_target(card)
  local options = {}
  for _, j in ipairs(G.jokers.cards) do
    local c = j.config.center
    if j ~= card and c.mod and c.mod.id == MOD_ID and c.blueprint_compat
       and c.key ~= YUTA and c.key ~= RIKA then
      options[#options + 1] = c.key
    end
  end
  if #options > 0 then
    card.ability.extra.target = pseudorandom_element(options, pseudoseed("kaisen_yuta"))
  else
    card.ability.extra.target = nil
  end
end

SMODS.Joker {
  key = "Yuta",
  loc_txt = {
    name = "Yuta Okkotsu",
    text = {
      "Each round, {C:attention}copies{} the ability",
      "of a random {C:attention}Jujutsu{} joker",
      "{C:inactive}(Currently: {C:attention}#1#{C:inactive}){}",
      "Also {C:attention}retrigers{} any cards with {C:276B65}Cursed Energy{}",
      "With {C:attention}Rika{}, activates {C:attention}twice{}"
    }
  },
  config = { extra = { target = nil } },
  rarity = 4,          
  cost = 20,
  atlas = "Yuta",
  pos = { x = 0, y = 0 },
  blueprint_compat = true,

  loc_vars = function(self, info_queue, card)
    local name = "None"
    if card.ability.extra.target then
      name = localize { type = "name_text", set = "Joker", key = card.ability.extra.target }
    end
    return { vars = { name } }
  end,


  add_to_deck = function(self, card, from_debuff)
    if from_debuff then return end
    G.E_MANAGER:add_event(Event({
      func = function()
        pick_target(card)
        if not has_rika() and #G.jokers.cards < G.jokers.config.card_limit then
          RIKA.in_pool(1) 
        end
        return true
      end
    }))
  end,

  calculate = function(self, card, context)
    if context.setting_blind and not context.blueprint then
      pick_target(card)
      return { message = "Technique Copied!", colour = G.C.PURPLE }
    end

    if context.joker_main then
      if context.played_card == "cursed_energy" then
        return{
          message = "Card Retriggered!",
          colour = G.C.PURPLE,
          repetitions = 1,
        }
      end
    end



    
    if context.retrigger_joker_check and not context.retrigger_joker
       and context.other_card == card and has_rika() then
      return { repetitions = 1 }
    end

   
    if card.ability.extra.target then
      local target = SMODS.find_card(card.ability.extra.target)[1]
      if target then
        return SMODS.blueprint_effect(card, target, context)
      end
    end
  end
}