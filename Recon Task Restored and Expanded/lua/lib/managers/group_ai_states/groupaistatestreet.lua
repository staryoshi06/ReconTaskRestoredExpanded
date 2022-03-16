-- like for besiege we need to manually hook.
local old_begin_assault = GroupAIStateStreet._begin_assault
function GroupAIStateStreet:_begin_assault()
    -- don't remove extra anticipation time if it's the first assault or skirmish (holdout)
    local extend_anticipation = self._task_data.assault.is_first or managers.skirmish:is_skirmish()

    old_begin_assault(self)

    -- remove delay
    if (not extend_anticipation) and (not self._hunt_mode) and self._task_data.assault.is_hesitating then
        self._task_data.assault.is_hesitating = nil
        self._task_data.assault.phase_end_t = self._task_data.assault.phase_end_t - self:_get_difficulty_dependent_value(self._tweak_data.assault.hostage_hesitation_delay)
    end
end

--I don't even think this state is used in this game but whatever lol
Hooks:PostHook(GroupAIStateStreet, "_begin_new_tasks", "star_recon_begin_new_tasks_street", function (self)
    if self._goin_valid and recon_data.next_dispatch_t and recon_data.next_dispatch_t < t and task_data.assault.active and is_recon_allowed() then
        local recon_candidates = {}
        local i = 1
        repeat
            local area = to_search_areas[i]
            local nr_police = table.size(area.police.units)
		    local nr_criminals = table.size(area.criminal.units)
            if area.loot or area.hostages then
                local occupied = nil
    
                for group_id, group in pairs(self._groups) do
                    if group.objective.target_area == area or group.objective.area == area then
                        occupied = true
    
                        break
                    end
                end
    
                if not occupied then
                    local is_area_safe = nr_criminals == 0
    
                    if is_area_safe then
                        if are_recon_candidates_safe then
                            table.insert(recon_candidates, area)
                        else
                            are_recon_candidates_safe = true
                            recon_candidates = {
                                area
                            }
                        end
                    elseif not are_recon_candidates_safe then
                        table.insert(recon_candidates, area)
                    end
                end
            end
            i = i + 1
        until i > #to_search_areas
        if recon_candidates and #recon_candidates > 0 then
            local recon_area = recon_candidates[math.random(#recon_candidates)]
    
            self:_begin_recon_task(recon_area)
        end
    end
end)

local old_upd_reenforce_tasks = GroupAIStateStreet._upd_reenforce_tasks
function GroupAIStateStreet:_upd_reenforce_tasks() 
    if not self._reenforce_valid or is_reenforce_allowed() then
        old_upd_reenforce_tasks(self)
    else
        --retire all
        if self._task_data and self._task_data.reenforce.active then
            self._task_data.reenforce.active = nil
            for group_id, group in pairs(self._groups) do
                if group.objective.type == "reenforce_area" then
                    if self._task_data and not self._task_data.assault.active) then
                        group.objective.attitude = "avoid",
                        group.objective.scan = true,
                        group.objective.stance = "hos",
                        group.objective.type = "recon_area",
                        self:_set_recon_objective_to_group(group)
                    else
                        self:_assign_group_to_retire(group)
                    end
                end
            end
        end
    end
end