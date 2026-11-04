SMODS.Atlas { key = "Toji", path = "Toji.png", px = 71, py = 95 }

local PREFIX = SMODS.current_mod.prefix
local MOD_ID = SMODS.current_mod.id
local TOJI = "j_" .. PREFIX .. "_Toji"


local function is_sorcerer(c)
  local center = c.config.center
  return c.ability.set == "Joker"
     and center.mod and center.mod.id == MOD_ID
     and center.key ~= TOJI
end


local function count_sorcerers()
  local n = 0
  if G.jokers then
    for _, j in ipairs(G.jokers.cards) do
      if is_sorcerer(j) then n = n + 1 end
    end
  end
  return n
end


local function refresh_debuffs()
  G.E_MANAGER:add_event(Event({
    func = function()
      for _, j in ipairs(G.jokers.cards) do
        SMODS.recalc_debuff(j)
      end
      return true
    end
  }))
end

SMODS.Joker {
  key = "Toji",
  loc_txt = {
    name = "Toji Fushiguro",
    text = {
      "{C:red}Debuffs{} all other",
      "{C:attention}Jujutsu{} jokers",
      "{X:mult,C:white} X#1# {} Mult for each one",
      "{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult){}"
    }
  },
  config = { extra = { xmult_each = 2.5 } },
  rarity = 4,
  cost = 20,
  atlas = "Toji",
  pos = { x = 0, y = 0 },
  blueprint_compat = true,

  loc_vars = function(self, info_queue, card)
    local total = card.ability.extra.xmult_each ^ count_sorcerers()
    return { vars = {
      card.ability.extra.xmult_each,
      math.floor(total * 100 + 0.5) / 100     
    } }
  end,

  add_to_deck = function(self, card, from_debuff)
    refresh_debuffs()
  end,

  remove_from_deck = function(self, card, from_debuff)
    refresh_debuffs()    
  end,

  calculate = function(self, card, context)

    if context.debuff_card and is_sorcerer(context.debuff_card) then
      return { debuff = true }
    end

    
    if context.joker_main then
      local n = count_sorcerers()
      if n > 0 then
        return { xmult = card.ability.extra.xmult_each ^ n }
      end
    end
  end
}