SMODS.Atlas { key = "Yuji", path = "Yuji.png", px = 71, py = 95 }

local PREFIX = SMODS.current_mod.prefix
local YUJI = "j_" .. PREFIX .. "_Itadori"
local TODO = "j_" .. PREFIX .. "_Todo"

local function has_brother()
  return G.jokers and #SMODS.find_card(TODO) > 0
end

SMODS.Joker {
  key = "Itadori",
  loc_txt = {
    name = "Yuji Itadori",
    text = {
      "{X:mult,C:white} X#1# {} Mult",
      "{C:green}#2# in #3#{} chance for a",
      "{X:mult,C:white} black flash {}",
      "{C:attention}Brothers:{} with {C:attention}Todo{}, double",
      "odds and {C:attention}retrigger{} each other"
    }
  },
  config = { extra = { xmult = 1.5, odds = 4, flash_xmult = 10 } },
  rarity = 3,
  cost = 8,
  atlas = "Yuji",
  pos = { x = 0, y = 0 },
  blueprint_compat = true,

  loc_vars = function(self, info_queue, card)
    info_queue[#info_queue + 1] = { key = "black_flash", set = "Other" }
    local chance = (G.GAME and G.GAME.probabilities.normal) or 1
    if has_brother() then chance = chance * 2 end
    return { vars = {
      card.ability.extra.xmult,
      chance,
      card.ability.extra.odds,
      card.ability.extra.flash_xmult
    } }
  end,

  calculate = function(self, card, context)
    if context.retrigger_joker_check and not context.retrigger_joker
       and context.other_card.config.center.key == TODO then
      return { repetitions = 1 }
    end

    if context.joker_main then
      local chance = G.GAME.probabilities.normal
      if has_brother() then chance = chance * 2 end

      if pseudorandom("kaisen_itadori") < chance / card.ability.extra.odds then
        return {
          xmult = card.ability.extra.xmult,
          extra = {
            message = "Black Flash!",
            colour = G.C.RED,
            extra = { xmult = card.ability.extra.flash_xmult }
          }
        }
      else
        return { xmult = card.ability.extra.xmult }
      end
    end
  end,

  add_to_deck = function(self, card, from_debuff)
    if not from_debuff then
      G.GAME.finger_rate = 15
    end
  end,

  remove_from_deck = function(self, card, from_debuff)
    if not from_debuff and #SMODS.find_card(YUJI, true) <= 1 then
      G.GAME.finger_rate = 0
    end
  end,
}