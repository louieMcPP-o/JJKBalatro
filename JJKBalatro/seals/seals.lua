SMODS.Atlas { key = "Seals", path = "Seals.png", px = 71, py = 95 }


SMODS.Seal {
  key = "cursed_energy",
  atlas = "Seals",
  pos = { x = 0, y = 0 },
  badge_colour = HEX("276B65"),
  config = { extra = { gain = 3 } },
  loc_txt = {
    name = "Cursed Energy Seal",
    label = "Cursed Energy Seal",
    text = {
      "This card permanently gains",
      "{C:mult}+#1#{} Mult when scored"
    }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = { self.config.extra.gain } }
  end,
  calculate = function(self, card, context)
    if context.main_scoring and context.cardarea == G.play then
      card.ability.perma_mult = (card.ability.perma_mult or 0) + self.config.extra.gain
      return {
        message = "Cursed Energy!",
        colour = HEX("276B65"),
        extra = {
          message = "+" .. self.config.extra.gain .. " Mult",
          colour = G.C.MULT
        }
      }
    end
  end
}


SMODS.Seal {
  key = "binding_vow",
  atlas = "Seals",
  pos = { x = 1, y = 0 },
  badge_colour = HEX("D4A017"),
  config = { extra = { xmult = 2, max_cards = 3 } },
  loc_txt = {
    name = "Binding Vow Seal",
    label = "Binding Vow Seal",
    text = {
      "{X:mult,C:white} X#1# {} Mult if played in",
      "a hand of {C:attention}#2#{} or fewer cards"
    }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = { self.config.extra.xmult, self.config.extra.max_cards } }
  end,
  calculate = function(self, card, context)
    if context.main_scoring and context.cardarea == G.play
       and #context.full_hand <= self.config.extra.max_cards then
      return {
        message = "Binding Vow!",
        colour = HEX("D4A017"),
        extra = { xmult = self.config.extra.xmult }
      }
    end
  end
}

local HOLLOW_PURPLE_XMULT = 4

SMODS.Seal {
  key = "hollow_purple",
  atlas = "Seals",
  pos = { x = 2, y = 0 },
  badge_colour = HEX("9B30FF"),
  loc_txt = {
    name = "Hollow Purple Seal",
    label = "Hollow Purple Seal",
    text = {
      "{X:mult,C:white} X#1# {} Mult when scored,",
      "then the card is {C:red}destroyed{}"
    }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = { HOLLOW_PURPLE_XMULT } }
  end,
  calculate = function(self, card, context)
    if context.main_scoring and context.cardarea == G.play then
      return {
        message = "Hollow Purple!",
        colour = HEX("9B30FF"),
        extra = { xmult = HOLLOW_PURPLE_XMULT }
      }
    end
    if context.destroy_card == card and context.cardarea == G.play then
      return { remove = true }
    end
  end
}