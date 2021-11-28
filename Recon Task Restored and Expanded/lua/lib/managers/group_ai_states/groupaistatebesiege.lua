local old_begin_assault = GroupAIStateBesiege._begin_assault_task

-- have to manually hook this one since we need to do stuff both before and after.
-- should be ok hopefully? hopefully won't break compatibility
function GroupAIStateBesiege:_begin_assault_task(assault_areas)
    -- don't remove extra anticipation time if it's the first assault or skirmish (holdout)
    local extend_anticipation = self._task_data.assault.is_first or managers.skirmish:is_skirmish()

    old_begin_assault(self, assault_areas)

    -- remove delay
    if (not extend_anticipation) and (not self._hunt_mode) and self._task_data.assault.is_hesitating then
        self._task_data.assault.is_hesitating = nil
        self._task_data.assault.phase_end_t = self._task_data.assault.phase_end_t - self:_get_difficulty_dependent_value(self._tweak_data.assault.hostage_hesitation_delay)
    end
end

Hooks:PostHook(GroupAIStateBesiege, "_end_regroup_task", "star_recon_end_regroup_task", function(self)
    -- extend break only if not skirmish
    local extend_break = not managers.skirmish:is_skirmish()
    local assault_task = self._task_data.assault

    -- if players have hostages then increase assault break
    if extend_break and self._hostage_headcount > 0 then
        assault_task.is_hesitating = true
        if assault_task.next_dispatch_t then
            -- we'll call out the extra assault delay once normal delay ends
            assault_task.voice_delay = assault_task.next_dispatch_t - self._t
            assault_task.next_dispatch_t = assault_task.next_dispatch_t + self:_get_difficulty_dependent_value(self._tweak_data.assault.hostage_hesitation_delay)
        end
	end
end)

Hooks:PostHook(GroupAIStateBesiege, "_upd_recon_tasks", "star_recon_upd_recon_tasks", function(self)
    local task_data = self._task_data.assault

    -- call out delay voiceline
    -- modified from _upd_assault_task
    if task_data.is_hesitating and task_data.voice_delay and task_data.voice_delay < self._t then
        if self._hostage_headcount > 0 then
            local best_group = nil

            for _, group in pairs(self._groups) do
                --if possible we want retiring enemies to call for HRT but it's unlikely
                if not best_group or group.objective.type == "retire" then
                    best_group = group
                elseif best_group.objective.type ~= "recon_area" and group.objective.type ~= "retire" then
                    best_group = group
                end
            end

            if best_group and self:_voice_delay_assault(best_group) then
                task_data.is_hesitating = nil
            end
        else
            task_data.is_hesitating = nil
        end
    end
end)