SMODS.Atlas { key = "JujutsuPack", path = "JujutsuPack.png", px = 71, py = 95 }

local MOD_ID = SMODS.current_mod.id


local function jjk_jokers()
  local list = {}
  local showman = next(SMODS.find_card("j_ring_master"))
  for _, center in ipairs(G.P_CENTER_POOLS.Joker) do
    if center.mod and center.mod.id == MOD_ID 
       and not (center.in_pool and not center:in_pool())
       and (showman or #SMODS.find_card(center.key, true) == 0) then
      list[#list + 1] = center.key
    end
  end
  return list
end


local pack_picks = {}

SMODS.Booster {
  key = "jujutsu_pack",
  kind = "Buffoon",
  atlas = "JujutsuPack",
  pos = { x = 0, y = 0 },
  config = { extra = 2, choose = 1 },
  cost = 6,
  weight = 0.5,   
  loc_txt = {
    name = "Jujutsu Pack",
    group_name = "Jujutsu Kaisen",
    text = { "Choose {C:attention}#1#{} of up to", "{C:attention}#2#{} Jujutsu Jokers" }
  },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.choose, card.ability.extra } }
  end,

  
  in_pool = function(self)
    return #jjk_jokers() > 0
  end,

  create_card = function(self, card, i)
    if i == 1 then pack_picks = {} end   

    
    local options = {}
    for _, key in ipairs(jjk_jokers()) do
      if not pack_picks[key] then options[#options + 1] = key end
    end
    if #options == 0 then options = { "j_joker" } end   

    local pick = pseudorandom_element(options, pseudoseed("kaisen_jjkpack" .. i))
    pack_picks[pick] = true
    return { set = "Joker", key = pick, area = G.pack_cards, skip_materialize = true }
  end
}