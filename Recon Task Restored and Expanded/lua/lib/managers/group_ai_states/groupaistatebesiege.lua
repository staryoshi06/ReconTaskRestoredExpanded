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
    self._task_data.recon.break_extended = nil

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
        self._task_data.recon.break_extended = true
	end
end)

--menu stuff
Hooks:PostHook(GroupAIStateBesiege, "init", "star_recon_ai_state_besiege_init", function(self, group_ai_state)
    local menu_exists = (StarReconMenu and StarReconMenu._data.assault_behaviour and StarReconMenu._data.assault_condition)
    -- These are for checking whether the appropriate functions should be called, to save on overhead if they aren't needed
    self._goin_valid =  menu_exists and StarReconMenu._data.assault_behaviour ~= 2  and StarReconMenu._data.assault_condition > 1
    self._reenforce_valid = menu_exists and StarReconMenu._data.assault_behaviour > 1
    -- I could make settings changeable during a heist but that could damage performance if extra functions are being called so frequently, so I'd rather not
    -- Instead, we're setting it in stone at heist start.
    -- If enough people request it I might make it an option
    self._recon_assault_condition = StarReconMenu._data.assault_condition
    self._recon_assault_behaviour = StarReconMenu._data.assault_behaviour
end)

function GroupAIStateBesiege:is_recon_allowed() 
    if not self._recon_assault_condition then
        return false
    end

    local condition = self._recon_assault_condition
    
    if condition > 3 or (condition > 2 and self._task_data.recon.loot_present) or (condition > 1 and self._hostage_headcount > 0) then
        return true
    end
    return false
end

function GroupAIStateBesiege:is_reenforce_allowed()
    if not self._recon_assault_behaviour then
        return false
    end

    local behaviour = self._recon_assault_behaviour

    if behaviour == 4 then
        return true
    end
    
    local recon_allowed = nil
    if self.assault_condition == 4 then
        recon_allowed = self._task_data.recon.valid_recon_objectives
    else
        recon_allowed = self:is_recon_allowed()
    end

    if self._task_data and self._task_data.assault.active and ((behaviour == 3 and not recon_allowed) or (behaviour == 2 and recon_allowed)) then
        return true
    end
    return false
end

--to do this with a hook it's potentially too performance-damaging so it's redefined
function GroupAIStateBesiege:_begin_new_tasks()
    local all_areas = self._area_data
    local nav_manager = managers.navigation
    local all_nav_segs = nav_manager._nav_segments
    local task_data = self._task_data
    local t = self._t
    local reenforce_candidates = nil
    local reenforce_data = task_data.reenforce
    
    local check_loot, check_valid_objs = nil
    if self._recon_assault_condition then
        if self._recon_assault_condition == 3 then
            check_loot = true
            if not self._task_data.recon.next_lootcheck_t then
                self._task_data.recon.next_lootcheck_t = t
            end
        elseif self._recon_assault_condition == 4 and self._recon_assault_behaviour and (self._recon_assault_behaviour == 2 or self._recon_assault_behaviour == 3)  then
            check_valid_objs = true
            if not self._task_data.recon.next_objcheck_t then
                self._task_data.recon.next_objcheck_t = t
            end
        end
    end

    if reenforce_data.next_dispatch_t and reenforce_data.next_dispatch_t < t and ((not self._reenforce_valid) or self:is_reenforce_allowed()) then
        reenforce_candidates = {}
    end

    local recon_candidates, are_recon_candidates_safe = nil
    local recon_data = task_data.recon

    -- new recon condition
    if recon_data.next_dispatch_t and recon_data.next_dispatch_t < t and not task_data.regroup.active and (not task_data.assault.active or (self._goin_valid and self:is_recon_allowed())) then
        recon_candidates = {}
    elseif self._task_data.assault.active and self._task_data.recon.tasks[1] and recon_data.next_dispatch_t and recon_data.next_dispatch_t < t and not self:is_recon_allowed() then
        self._task_data.recon.tasks = {}
    end

    local assault_candidates = nil
    local assault_data = task_data.assault

    if self._difficulty_value > 0 and assault_data.next_dispatch_t and assault_data.next_dispatch_t < t and not task_data.regroup.active then
        assault_candidates = {}
    end

    if not reenforce_candidates and not recon_candidates and not assault_candidates then
        -- if necessary check for loot or valid recon objectives
        if check_loot and recon_data.next_lootcheck_t and recon_data.next_lootcheck_t < t then
            recon_data.loot_present = nil
            recon_data.next_lootcheck_t = t + 10
            for area_id, area in pairs(all_areas) do
                if area.loot then
                    recon_data.loot_present = true
                    break
                end
            end
        end
        if check_valid_objs and recon_data.next_objcheck_t and recon_data.next_objcheck_t < t then
            recon_data.valid_recon_objectives = nil
            recon_data.next_objcheck_t = t + 10
            for area_id, area in pairs(all_areas) do
                if area.loot or area.hostages then
                    recon_data.valid_recon_objectives = true
                    break
                end
            end
        end
        return
    end

    local found_areas = {}
    local to_search_areas = {}

    for area_id, area in pairs(all_areas) do
        if area.spawn_points then
            for _, sp_data in pairs(area.spawn_points) do
                if sp_data.delay_t <= t and not all_nav_segs[sp_data.nav_seg].disabled then
                    table.insert(to_search_areas, area)

                    found_areas[area_id] = true

                    break
                end
            end
        end

        if not found_areas[area_id] and area.spawn_groups then
            for _, sp_data in pairs(area.spawn_groups) do
                if sp_data.delay_t <= t and not all_nav_segs[sp_data.nav_seg].disabled then
                    table.insert(to_search_areas, area)

                    found_areas[area_id] = true

                    break
                end
            end
        end
    end

    if #to_search_areas == 0 then
        return
    end

    if assault_candidates and self._hunt_mode then
        for criminal_key, criminal_data in pairs(self._char_criminals) do
            if not criminal_data.status then
                local nav_seg = criminal_data.tracker:nav_segment()
                local area = self:get_area_from_nav_seg_id(nav_seg)
                found_areas[area] = true

                table.insert(assault_candidates, area)
            end
        end
    end

    local i = 1

    repeat
        local area = to_search_areas[i]
        local force_factor = area.factors.force
        local demand = force_factor and force_factor.force
        local nr_police = table.size(area.police.units)
        local nr_criminals = table.size(area.criminal.units)
        local criminal_character_in_area = false

        for criminal_key, _ in pairs(area.criminal.units) do
            if not self._criminals[criminal_key].status and not self._criminals[criminal_key].is_deployable then
                criminal_character_in_area = true

                break
            end
        end

        if reenforce_candidates and demand and demand > 0 and nr_criminals == 0 then
            local area_free = true

            for i_task, reenforce_task_data in ipairs(reenforce_data.tasks) do
                if reenforce_task_data.target_area == area then
                    area_free = false

                    break
                end
            end

            if area_free then
                table.insert(reenforce_candidates, area)
            end
        end

        if recon_candidates and (area.loot or area.hostages) then
            local occupied = nil

            -- check if there is already a queued task for this area
            for task_id, task in pairs(self._task_data.recon.tasks) do
                if task.target_area == area then
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

        if assault_candidates and criminal_character_in_area then
            table.insert(assault_candidates, area)
        end

        if not criminal_character_in_area then
            for neighbour_area_id, neighbour_area in pairs(area.neighbours) do
                if not found_areas[neighbour_area_id] then
                    table.insert(to_search_areas, neighbour_area)

                    found_areas[neighbour_area_id] = true
                end
            end
        end

        if check_loot and area.loot then
            recon_data.loot_present = true
            recon_data.next_lootcheck_t = t + 10
        end
        if check_valid_objs and (area.loot or area.hostages) then
            recon_data.valid_recon_objectives = true
            recon_data.next_objcheck_t = t + 10
        end

        i = i + 1
    until i > #to_search_areas

    if recon_data.break_extended and assault_data.active then
        recon_data.break_extended = nil
    end

    --prevent cheese tactic, if no recon objectives or tasks and assault break is extended, or recon is set to appear always, then set task on the player
    if recon_candidates and not recon_candidates[1] and not recon_data.tasks[1] and (recon_data.break_extended or self._recon_assault_condition == 5) then
        for criminal_key, criminal_data in pairs(self._char_criminals) do
            if not criminal_data.status then
                local nav_seg = criminal_data.tracker:nav_segment()
                local area = self:get_area_from_nav_seg_id(nav_seg)

                table.insert(recon_candidates, area)
            end
        end
    end


    if assault_candidates and #assault_candidates > 0 then
        self:_begin_assault_task(assault_candidates)
        
        recon_candidates = nil
    end

    if recon_candidates and #recon_candidates > 0 then
        local recon_area = recon_candidates[math.random(#recon_candidates)]

        self:_begin_recon_task(recon_area)
    end

    if reenforce_candidates and #reenforce_candidates > 0 then
        local lucky_i_candidate = math.random(#reenforce_candidates)
        local reenforce_area = reenforce_candidates[lucky_i_candidate]

        self:_begin_reenforce_task(reenforce_area)

        recon_candidates = nil
    end
end

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
function GroupAIStateBesiege:_upd_recon_tasks()
    local task_data = self._task_data.recon.tasks[1]

    self:_assign_enemy_groups_to_recon()

    local t = self._t

    if not task_data then
        --sometimes next dispatch is set to nil and then the tasks are cleared. unsure how but this should fix it
        if not self._task_data.recon.next_dispatch_t then
            self._task_data.recon.next_dispatch_t = t
        end
        return
    end

    local nr_wanted = 0
    local target_pos = task_data.target_area.pos

    if self._goin_valid and self._task_data.assault.active then
        -- removed assault groups retiring

        -- limit recon to both assault and recon spawn limits.
        local nr_wanted_recon = (math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.recon.force)/2)) - self:_count_recon_force()
        local nr_wanted_assault = self._task_data.assault.force - self:_count_police_force("assault") - (self._task_data.assault.phase == "anticipation" and 5 or 0)
        nr_wanted = nr_wanted_assault < nr_wanted_recon and nr_wanted_assault or nr_wanted_recon
        if self._task_data.assault.phase == "fade" then
            nr_wanted = 0
        end
    else
        self:_assign_assault_groups_to_retire()
        nr_wanted = self:_get_difficulty_dependent_value(self._tweak_data.recon.force) - self:_count_police_force("recon")
    end 

    if nr_wanted <= 0 then
        return
    end

    local used_event, used_group = nil

    if task_data.use_spawn_event then
        task_data.use_spawn_event = false

        if self:_try_use_task_spawn_event(t, task_data.target_area, "recon") then
            used_event = true
        end
    end

    if not used_event then
        if next(self._spawning_groups) then
            --Nothing
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

    if used_event or used_group then
        table.remove(self._task_data.recon.tasks, 1)

        self._task_data.recon.next_dispatch_t = t + math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.recon.interval)) + math.random() * self._tweak_data.recon.interval_variation
    end

    -- call out delay voiceline
    -- modified from _upd_assault_task
    local task_data = self._task_data.assault

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
	if self._goin_valid and self:is_recon_allowed() then
        return
    end
    old_retire_recon(self)
end

-- There's no reason for this to be setting the next dispatch, as upd_reenforce_tasks sets it already
Hooks:PostHook(GroupAIStateBesiege, "_begin_reenforce_task", "star_recon_begin_reenforce_task", function(self, reenforce_area)
    if self._reenforce_valid then
        self._task_data.reenforce.next_dispatch_t = self._t - 1 --Because in order for this to execute the value would have had to be at least this
    end
end)

--if adding reenforce then we only run this if they are allowed. otherwise run as normal for compatibility
local old_upd_reenforce_tasks = GroupAIStateBesiege._upd_reenforce_tasks
function GroupAIStateBesiege:_upd_reenforce_tasks() 
    if (not self._reenforce_valid) or self:is_reenforce_allowed() then
        old_upd_reenforce_tasks(self)
    else
        --retire all
        if self._task_data and self._task_data.reenforce.active then
            self._task_data.reenforce.active = nil
            for group_id, group in pairs(self._groups) do
                if group.objective.type == "reenforce_area" then
                    if self._task_data and not self._task_data.assault.active or self._recon_assault_behaviour == 3 then
                        group.objective.attitude = "avoid"
                        group.objective.scan = true
                        group.objective.stance = "hos"
                        group.objective.type = "recon_area"
                        self:_set_recon_objective_to_group(group)
                        --If too far away then just retire
                        if not group.objective.target_area or not group.objective.area or (mvector3.distance(group.objective.target_area.pos, group.objective.area.pos) > 5000 and not self._task_data.assault.active) then
                            self:_assign_group_to_retire(group)
                        end
                    else
                        self:_assign_group_to_retire(group)
                    end
                end
            end
            self._task_data.reenforce.tasks = {}
        end
    end
end

--TODO: Recon to reinforce?