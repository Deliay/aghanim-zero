modifier_legend_base = class({})

function modifier_legend_base:IsHidden()
    return true
end

function modifier_legend_base:IsDebuff()
  return false
end

function modifier_legend_base:IsPurgable()
  return false
end

function modifier_legend_base:AllowIllusionDuplicate()
  return true
end

return modifier_legend_base
