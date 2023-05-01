ability_legend_base = class({})

function ability_legend_base:GetIntrinsicModifierName()
  return "modifier_"..self:GetAbilityName()
end

return ability_legend_base
