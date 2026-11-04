
SMODS.Atlas { key = "ShikigamiPack", path = "ShikigamiPack.png", px = 71, py = 95 }

local PREFIX = SMODS.current_mod.prefix

-- shared helpers that other files (Megumi etc.) can use
KAISEN = KAISEN or {}
KAISEN.SHIKIGAMI = {}

local DOG_W = "c_" .. PREFIX .. "_dog_white"
local DOG_B = "c_" .. PREFIX .. "_dog_black"
local TOTALITY = "j_" .. PREFIX .. "_Totality"

function KAISEN.used_count()
  local n = 0
  for _ in pairs(G.GAME.kaisen_used or {}) do n = n + 1 end
  return n
end

function KAISEN.all_used()
  return KAISEN.used_count() >= #KAISEN.SHIKIGAMI
end

function KAISEN.mark_used(key)
  G.GAME.kaisen_used = G.GAME.kaisen_used or {}
  G.GAME.kaisen_used[key] = true

  -- both dogs used: summon Divine Dog: Totality (once per run)
  local used = G.GAME.kaisen_used
  if used[DOG_W] and used[DOG_B] and not G.GAME.kaisen_totality
     and #G.jokers.cards < G.jokers.config.card_limit then
    G.GAME.kaisen_totality = true
    G.E_MANAGER:add_event(Event({
      func = function()
        SMODS.add_card { key = TOTALITY }
        return true
      end
    }))
  end
end


-- the new card type
SMODS.ConsumableType {
  key = "Shikigami",
  primary_colour = HEX("2B2D42"),
  secondary_colour = HEX("4B4E6D"),
  collection_rows = { 5, 5 },
  shop_rate = 0,
  loc_txt = {
    name = "Shikigami",
    collection = "Shikigami Cards",
    undiscovered = { name = "Not Discovered", text = { "Use this card in", "a run to discover it" } }
  }
}

-- builder so each shikigami is short
-- ONLY ONE shikigami can be used per round
local function shikigami(t)
  local full_key = "c_" .. PREFIX .. "_" .. t.key
  KAISEN.SHIKIGAMI[#KAISEN.SHIKIGAMI + 1] = full_key

  -- each shikigami gets its own picture, e.g. nue.png
  SMODS.Atlas { key = "shk_" .. t.key, path = t.key .. ".png", px = 71, py = 95 }

  SMODS.Consumable {
    key = t.key,
    set = "Shikigami",
    atlas = "shk_" .. t.key,
    pos = { x = 0, y = 0 },
    cost = 3,
    loc_txt = { name = t.name, text = t.text },
    can_use = function(self, card)
      if G.GAME.kaisen_shk_round == G.GAME.round then return false end
      if t.can_use then return t.can_use() end
      return true
    end,
    use = function(self, card, area, copier)
      G.GAME.kaisen_shk_round = G.GAME.round
      t.use(card)
      KAISEN.mark_used(full_key)
      G.E_MANAGER:add_event(Event({
        func = function()
          if G.hand then G.hand:unhighlight_all() end
          return true
        end
      }))
    end
  }
end

local function in_blind() return G.GAME.blind and G.GAME.blind.in_blind end
local function selected(min, max)
  return function()
    local n = G.hand and #G.hand.highlighted or 0
    return n >= min and n <= max
  end
end

-- 1. DIVINE DOG: WHITE
shikigami {
  key = "dog_white", name = "Divine Dog: White", pos = { x = 0, y = 0 },
  text = { "Draw {C:attention}3{} cards" },
  can_use = in_blind,
    use = function(card)
    for i = 1, 3 do
      if #G.deck.cards > 0 then
        draw_card(G.deck, G.hand, 90, "up", true)
      end
    end
  end
}

-- 2. DIVINE DOG: BLACK
shikigami {
  key = "dog_black", name = "Divine Dog: Black", pos = { x = 1, y = 0 },
  text = { "{C:red}+2{} discards", "this round" },
  can_use = in_blind,
    use = function(card) 
    ease_discard(2) end
}

-- 3. NUE
shikigami {
  key = "nue", name = "Nue", pos = { x = 2, y = 0 },
  text = { "Level up your {C:attention}most played{}", "poker hand {C:attention}2{} times" },
  use = function(card)
    local best, most = "High Card", -1
    for name, hand in pairs(G.GAME.hands) do
      if hand.visible and hand.played > most then best, most = name, hand.played end
    end
    update_hand_text({ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
      { handname = localize(best, "poker_hands"), chips = G.GAME.hands[best].chips,
        mult = G.GAME.hands[best].mult, level = G.GAME.hands[best].level })
    level_up_hand(card, best, nil, 2)
    update_hand_text({ sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
      { mult = 0, chips = 0, handname = "", level = "" })
  end
}

-- 4. GREAT SERPENT: devour
shikigami {
  key = "serpent", name = "Great Serpent", pos = { x = 3, y = 0 },
  text = {
    "Select {C:attention}2{} cards: {C:red}destroy{} the left,",
    "the right permanently gains",
    "its {C:chips}Chips{}"
  },
  can_use = selected(2, 2),
  use = function(card)
    local prey, eater = G.hand.highlighted[1], G.hand.highlighted[2]
    if prey.T.x > eater.T.x then prey, eater = eater, prey end
    eater.ability.perma_bonus = (eater.ability.perma_bonus or 0) + prey:get_chip_bonus()
    prey:start_dissolve()
    SMODS.calculate_context({ remove_playing_cards = true, removed = { prey } })
  end
}

-- 5. TOAD: tongue grab
shikigami {
  key = "toad", name = "Toad", pos = { x = 4, y = 0 },
  text = {
    "Pull every card of the",
    "{C:attention}selected card's rank{} from",
    "your deck into your hand"
  },
  can_use = selected(1, 1),
  use = function(card)
    local rank = G.hand.highlighted[1]:get_id()
    local grabbed = {}
    for _, c in ipairs(G.deck.cards) do
      if c:get_id() == rank then grabbed[#grabbed + 1] = c end
    end
    for _, c in ipairs(grabbed) do
      draw_card(G.deck, G.hand, 90, "up", true, c)
    end
  end
}

-- 6. MAX ELEPHANT
shikigami {
  key = "elephant", name = "Max Elephant", pos = { x = 0, y = 1 },
  text = { "Up to {C:attention}2{} selected cards", "become {C:attention}Steel{} cards" },
  can_use = selected(1, 2),
  use = function(card)
    for _, c in ipairs(G.hand.highlighted) do c:set_ability(G.P_CENTERS.m_steel, nil, true) end
  end
}

-- 7. RABBIT ESCAPE: scatter the blind
shikigami {
  key = "rabbit", name = "Rabbit Escape", pos = { x = 1, y = 1 },
  text = {
    "Reduce the current blind's",
    "requirement by {C:attention}10%{}"
  },
  can_use = in_blind,
  use = function(card)
    G.GAME.blind.chips = math.floor(G.GAME.blind.chips * 0.9)
    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
  end
}

-- 8. ROUND DEER
shikigami {
  key = "deer", name = "Round Deer", pos = { x = 2, y = 1 },
  text = { "{C:blue}+1{} hand and {C:red}+1{} discard", "this round" },
  can_use = in_blind,
  use = function(card) ease_hands_played(1); ease_discard(1) end
}

-- 9. PIERCING OX: charge
shikigami {
  key = "ox", name = "Piercing Ox", pos = { x = 3, y = 1 },
  text = {
    "{C:attention}1{} selected card permanently",
    "gains {X:mult,C:white} X0.5 {} Mult"
  },
  can_use = selected(1, 1),
  use = function(card)
    local c = G.hand.highlighted[1]
    c.ability.perma_x_mult = (c.ability.perma_x_mult or 0) + 0.5
  end
}

-- 10. TIGER FUNERAL
shikigami {
  key = "tiger", name = "Tiger Funeral", pos = { x = 4, y = 1 },
  text = { "Gain {C:money}$3{} for each", "{C:attention}Shikigami{} used this run" },
  use = function(card) ease_dollars(3 * (KAISEN.used_count() + 1)) end
}

-- THE PACK: pick 1 of 3, it goes to your consumable slots
SMODS.Booster {
  key = "shikigami_pack",
  kind = "Shikigami",
  atlas = "ShikigamiPack",
  pos = { x = 0, y = 0 },
  config = { extra = 3, choose = 1 },
  cost = 4,
  weight = 1,
  draw_hand = false,
  select_card = "consumeables",
  loc_txt = {
    name = "Shikigami Pack",
    group_name = "Ten Shadows",
    text = { "Choose {C:attention}#1#{} of up to", "{C:attention}#2#{} Shikigami cards" }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.choose, card.ability.extra } }
  end,
  create_card = function(self, card, i)
    return { set = "Shikigami", area = G.pack_cards, skip_materialize = true, key_append = "kaisen_shk" }
  end
}