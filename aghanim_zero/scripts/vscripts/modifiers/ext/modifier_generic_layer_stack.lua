modifier_generic_layer_stack = {}
function modifier_generic_layer_stack:IsHidden()
    return true
end
function modifier_generic_layer_stack:IsPurgable()
    return self.purgable
end
function modifier_generic_layer_stack:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_generic_layer_stack:OnCreated(kv)
    self.purgable = true
    if kv.purgable ~= nil then
        self.purgable = kv.purgable
    end
    self.destroy_no_layer = kv.destroy_no_layer
    self.stacks = kv.stacks
end

function modifier_generic_layer_stack:OnRemoved()
    if IsServer() then
        DecreaseStack({
            modifier = self.modifier,
            destroy_no_layer = self.destroy_no_layer,
            stacks = self.stacks
        })
    end
end
