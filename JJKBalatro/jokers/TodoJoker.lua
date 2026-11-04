SMODS.Atlas { key = "Todo", path = "Todo.png", px = 71, py = 95 }

local PREFIX = SMODS.current_mod.prefix

local function has_brother()
  return G.jokers and #SMODS.find_card("j_" .. PREFIX .. "_Itadori") > 0
end

SMODS.Joker {
  key = "Todo",
  loc_txt = {
    name = "Aoi Todo",
    text = {
      "Before scoring, the first scored card",
      "becomes a {C:attention}copy{} of the highest",
      "card held in hand",
      "{C:mult}+#1#{} Mult, {C:green}#2# in #3#{} chance",
      "for a {X:mult,C:white} black flash {}",
      "{C:attention}Brothers:{} with {C:attention}Yuji{}, double",
      "odds and {C:attention}retrigger{} played cards"
    }
  },
  config = { extra = { mult = 40, odds = 4, flash_xmult = 10 } },
  rarity = 3,
  cost = 8,
  atlas = "Todo",
  pos = { x = 0, y = 0 },
  blueprint_compat = true,

  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { key = "black_flash", set = "Other" }
    local chance = (G.GAME and G.GAME.probabilities.normal) or 1
    if has_brother() then chance = chance * 2 end      
    return { vars = {
      card.ability.extra.mult,
      chance,
      card.ability.extra.odds,
      card.ability.extra.flash_xmult
    } }
  end,

  calculate = function(self, card, context)

   if context.before and not context.blueprint then
      local played = context.scoring_hand[1]
      local best = nil
      for _, c in ipairs(G.hand.cards) do
        if c.config.center ~= G.P_CENTERS.m_stone then
          if not best or c:get_id() > best:get_id() then
            best = c
          end
        end
      end
      if played and best and best:get_id() > played:get_id() then
        copy_card(best, played)
        return { message = "Boogie Woogie!", colour = G.C.BLUE }
      end
    end

    if context.retrigger_joker_check and not context.retrigger_joker
    and context.other_card.config.center.key == "j_" .. PREFIX .. "_Itadori" then
    return { repetitions = 1 }
    end

    if context.joker_main then
      local chance = G.GAME.probabilities.normal
      if has_brother() then chance = chance * 2 end

      if pseudorandom("kaisen_todo") < chance / card.ability.extra.odds then
        return {
          mult = card.ability.extra.mult,
          extra = {
            message = "Black Flash!",
            colour = G.C.RED,
            extra = { xmult = card.ability.extra.flash_xmult }
          }
        }
      else
        return { mult = card.ability.extra.mult }
      end
    end

  end
}