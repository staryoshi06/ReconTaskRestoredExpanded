Hooks:PostHook(GroupAIStateBase, "register_rescueable_hostage", "star_recon_register_hostage", function(self, unit, rescue_area)
    local u_key = unit:key()
	local rescue_area = rescue_area or self:get_area_from_nav_seg_id(unit:movement():nav_tracker():nav_segment())
    if self._recon_objectives and not self._recon_objectives[u_key] then
        self._recon_objectives[u_key] = rescue_area
    elseif not self._recon_objectives then
        self._recon_objectives = {[u_key] = rescue_area}
    end
end)

Hooks:PostHook(GroupAIStateBase, "unregister_rescueable_hostage", "star_recon_unregister_hostage", function(self, u_key)
    if self._recon_objectives and self._recon_objectives[u_key] then
        self._recon_objectives[u_key] = nil
    end
    if not next(self._recon_objectives) then
        self._recon_objectives = nil
    end
end)

Hooks:PostHook(GroupAIStateBase, "register_loot", "star_recon_register_loot", function(self, loot_unit, pickup_area)
    local loot_u_key = loot_unit:key()
    if self._recon_objectives and not self._recon_objectives[loot_u_key] then
        self._recon_objectives[loot_u_key] = pickup_area
    elseif not self._recon_objectives then
        self._recon_objectives = {[loot_u_key] = pickup_area}
    end
end)

Hooks:PostHook(GroupAIStateBase, "unregister_loot", "star_recon_unregister_loot", function(self, loot_u_key)
    if self._recon_objectives and self._recon_objectives[loot_u_key] then
        self._recon_objectives[loot_u_key] = nil
    end
    if not next(self._recon_objectives) then
        self._recon_objectives = nil
    end
end)