-- have to manually hook this one since we need to do stuff both before and after.
-- should be ok hopefully? hopefully won't break compatibility
local old_begin_assault = GroupAIStateBesiege._begin_assault_task
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
            assault_task.voice_delay = assault_task.next_dispatch_t
        end
        local break_time = self:_get_difficulty_dependent_value(self._tweak_data.assault.delay) + self:_get_difficulty_dependent_value(self._tweak_data.assault.hostage_hesitation_delay)
        --if less than 60 we add extra 5 seconds per hostage, but max 60 (if a difficulty would allow it to exceed 60 by default then I do not want to change that).
        if break_time < 60 then
            break_time = break_time + 5 * (self._hostage_headcount - 1)
            if break_time > 60 then break_time = 60 end
        end
        assault_task.next_dispatch_t = self._t + break_time
	end
end)

--menu stuff
Hooks:PostHook(GroupAIStateBesiege, "init", "star_recon_ai_state_besiege_init", function(self, group_ai_state)
    local menu_exists = (StarReconMenu and StarReconMenu._data.assault_behaviour and StarReconMenu._data.assault_condition)
    self._goin_valid =  menu_exists and StarReconMenu._data.assault_behaviour ~= 2  and StarReconMenu._data.assault_condition > 1
    self._reenforce_valid = menu_exists and ((StarReconMenu._data.assault_behaviour == 2 and StarReconMenu._data.assault_condition > 1) or StarReconMenu._data.assault_behaviour > 2)
end)

GroupAIStateBesiege:is_recon_allowed() 
    if not StarReconMenu or not StarReconMenu._data.assault_condition then
        return false
    end

    condition = StarReconMenu._data.assault_condition
    
    return condition > 3 or (condition > 2 and self:is_loot_present()) or (condition > 1 and self._hostage_headcount > 0)
end

GroupAIStateBesiege:is_loot_present()
    if self._area_data then
        for area_id, area in pairs(self._area_data) do
            if area.loot then
                return true
            end
        end
    end
    return false
end

GroupAIStateBesiege:is_reenforce_allowed()
    if not StarReconMenu or not StarReconMenu._data.assault_behaviour then
        return false
    end

    local behaviour = StarReconMenu._data.assault_behaviour

    if behaviour == 4 then
        return true
    end
    
    local recon_allowed = is_recon_allowed()
    return (self._task_data and self._task_data.assault.active and ((behaviour == 3 and not recon_allowed) or (behaviour == 2 and recon_allowed)))
end

-- I really don't want to override the function if feasible (for compatibility reasons) so we're copying some of the code
Hooks:PostHook(GroupAIStateBesiege, "_begin_new_tasks", "star_recon_begin_new_tasks_besiege", function (self)
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

function GroupAIStateBesiege:_count_recon_force()
    local amount = 0

    for group_id, group in pairs(self._groups) do
        if group.objective.type == "recon_area" then
            amount = amount + (group.has_spawned and group.size or group.initial_size)
        end
    end

    return amount
end

--Have to redefine this one
local old_upd_recon_tasks = GroupAIStateBesiege._upd_recon_tasks
function GroupAIStateBesiege:_upd_recon_tasks()
    --only redefine if using the appropriate settings
    if self._goin_valid then
        local task_data = self._task_data.recon.tasks[1]

        self:_assign_enemy_groups_to_recon()

        if not task_data then
            return
        end

        local t = self._t

        -- removed assault groups retiring

        local target_pos = task_data.target_area.pos
        local nr_wanted = self:_get_difficulty_dependent_value(self._tweak_data.recon.force) - self:_count_recon_force() --custom function bc the previous one doesn't differentiate recon and assault groups because ???

        if nr_wanted <= 0 then
            return
        end

        local used_event, used_spawn_points, reassigned = nil

        if task_data.use_spawn_event then
            task_data.use_spawn_event = false

            if self:_try_use_task_spawn_event(t, task_data.target_area, "recon") then
                used_event = true
            end
        end

        if not used_event then
            local used_group = nil

            if next(self._spawning_groups) then
                used_group = true
            else
                local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, self._tweak_data.recon.groups, nil, nil, callback(self, self, "_verify_anticipation_spawn_point"))

                if spawn_group then
                    local grp_objective = {
                        attitude = "avoid",
                        scan = true,
                        stance = "hos",
                        type = "recon_area",
                        area = spawn_group.area,
                        target_area = task_data.target_area
                    }

                    self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)

                    used_group = true
                end
            end
        end

        if used_event or used_spawn_points or reassigned then
            table.remove(self._task_data.recon.tasks, 1)

            self._task_data.recon.next_dispatch_t = t + math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.recon.interval)) + math.random() * self._tweak_data.recon.interval_variation
        end
    else
        old_upd_recon_tasks(self)
    end
    task_data = self._task_data.assault

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
end

-- only retire if valid
local old_retire_recon = GroupAIStateBesiege._assign_recon_groups_to_retire
function GroupAIStateBesiege:_assign_recon_groups_to_retire()
	if self._goin_valid and not is_recon_allowed() then
        return
    end
    old_retire_recon(self)
end

--if adding reenforce then we only run this if they are allowed. otherwise run as normal for compatibility
local old_upd_reenforce_tasks = GroupAIStateBesiege._upd_reenforce_tasks
function GroupAIStateBesiege:_upd_reenforce_tasks() 
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

--TODO: Recon to reinforce?