SMODS.Atlas { key = "Rika", path = "Rika.png", px = 71, py = 95 }

local tarted_rika = 1

SMODS.Joker {
  key = "Rika",
  loc_txt = {
    name = "Rika",
    text = {
      "{X:mult,C:white} X#1# {} Mult",
      "{C:attention}Yuta{} activates twice",
      "while Rika is with him"
    }
  },
  config = { extra = { xmult = 2 } },
  rarity = 3,
  cost = 8,
  atlas = "Rika",
  pos = { x = 0, y = 0 },
  blueprint_compat = true,

    in_pool = function(x)
      if x == tarted_rika then
        return true
      else 
        return false
      end
    end,


  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.xmult } }
  end,

  calculate = function(self, card, context)
    if context.joker_main then
      return { xmult = card.ability.extra.xmult }
    end
  end
}