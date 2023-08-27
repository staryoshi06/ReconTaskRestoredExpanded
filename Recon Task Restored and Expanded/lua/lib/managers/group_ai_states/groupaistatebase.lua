Hooks:PostHook(GroupAIStateBase, "register_rescueable_hostage", "star_recon_register_hostage", function(self, unit, rescue_area)
    if not self._recon_obj_count then
        self._recon_obj_count = 1
    else
        self._recon_obj_count = self._recon_obj_count + 1
    end
end)

Hooks:PostHook(GroupAIStateBase, "unregister_rescueable_hostage", "star_recon_unregister_hostage", function(self, u_key)
    if self._recon_obj_count then
        self._recon_obj_count = self._recon_obj_count - 1
    end

    if self._recon_obj_count = 0 then
        self._recon_obj_count = nil
    end
end)

Hooks:PostHook(GroupAIStateBase, "register_loot", "star_recon_register_loot", function(self, loot_unit, pickup_area)
    if not self._recon_obj_count then
        self._recon_obj_count = 1
    else
        self._recon_obj_count = self._recon_obj_count + 1
    end
end)

Hooks:PostHook(GroupAIStateBase, "unregister_loot", "star_recon_unregister_loot", function(self, loot_u_key)
    if self._recon_obj_count then
        self._recon_obj_count = self._recon_obj_count - 1
    end

    if self._recon_obj_count = 0 then
        self._recon_obj_count = nil
    end
end)