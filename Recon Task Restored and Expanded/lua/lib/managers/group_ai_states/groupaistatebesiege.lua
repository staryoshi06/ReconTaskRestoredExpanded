-- have to manually hook this one since we need to do stuff both before and after.
-- should be ok hopefully? hopefully won't break compatibility
local old_begin_assault = GroupAIStateBesiege._begin_assault_task
function GroupAIStateBesiege:_begin_assault_task(assault_areas)
    -- don't remove extra anticipation time if it's the first assault or skirmish (holdout)
    local extend_anticipation = self._task_data.assault.is_first or managers.skirmish:is_skirmish()
    

    old_begin_assault(self, assault_areas)

    if not self._task_data.assault.extra_time then
        self._task_data.assault.extra_time = 0
    end

    -- remove delay
    if (not extend_anticipation) and (not self._hunt_mode) and self._task_data.assault.is_hesitating then
        self._task_data.assault.is_hesitating = nil
        self._task_data.assault.phase_end_t = self._task_data.assault.phase_end_t - self:_get_difficulty_dependent_value(self._tweak_data.assault.hostage_hesitation_delay) + self._task_data.assault.extra_time
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
        --if more than 60 already, clamp to 60 and add extra time to anticipation
        elseif break_time > 60 then
            assault_task.extra_time = break_time - 60
            break_time = 60
        end
        assault_task.next_dispatch_t = self._t + break_time
        self._task_data.recon.break_extended = true
	end
end)

--menu stuff
Hooks:PostHook(GroupAIStateBesiege, "init", "star_recon_ai_state_besiege_init", function(self, group_ai_state)
    local menu_exists = (StarReconMenu and StarReconMenu._data.assault_condition)
    -- These are for checking whether the appropriate functions should be called, to save on overhead if they aren't needed
    self._goin_valid =  menu_exists  and StarReconMenu._data.assault_condition > 1
    -- I could make settings changeable during a heist but that could damage performance if extra functions are being called so frequently, so I'd rather not
    -- Instead, we're setting it in stone at heist start.
    -- If enough people request it I might make it an option
    self._recon_assault_condition = StarReconMenu._data.assault_condition
end)

function GroupAIStateBesiege:is_recon_allowed() 
    if not self._recon_assault_condition then
        return false
    end

    local condition = self._recon_assault_condition
    
    if condition > 2 or (condition > 1 and self._hostage_headcount > 0) then
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

    if reenforce_data.next_dispatch_t and reenforce_data.next_dispatch_t < t then
        reenforce_candidates = {}
    end

    local recon_candidates = nil
    local recon_candidates_are_safe = nil
    local backup_recon_candidates = {}
    local backup_recon_candidates_are_safe = nil
    local criminal_areas = {}
    local recon_data = task_data.recon

    -- new recon condition
    if recon_data.next_dispatch_t and recon_data.next_dispatch_t < t and not task_data.regroup.active and (not task_data.assault.active or (self._goin_valid and self:is_recon_allowed())) then
        recon_candidates = {}
    elseif self._task_data.assault.active and self._task_data.recon.tasks[1] and recon_data.next_dispatch_t and recon_data.next_dispatch_t < t and (not self._goin_valid or not self:is_recon_allowed()) then
        self._task_data.recon.tasks = {}
    end

    local assault_candidates = nil
    local assault_data = task_data.assault

    if self._difficulty_value > 0 and assault_data.next_dispatch_t and assault_data.next_dispatch_t < t and not task_data.regroup.active then
        assault_candidates = {}
    end

    if not reenforce_candidates and not recon_candidates and not assault_candidates then
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
                table.insert(criminal_areas, area)

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
            local awaiting_dispatch = nil

            -- check if there is already a queued task for this area
            for task_id, task in pairs(self._task_data.recon.tasks) do
                if task.target_area == area then
                    awaiting_dispatch = true

                    break
                end
            end

            -- do not readd tasks for areas already waiting for a recon group
            if not awaiting_dispatch then
                --check if recon team is already in or approaching this area
                for test_group_id, test_group in pairs(self._groups) do
                    if test_group.objective.type == "recon_area" and (test_group.objective.target_area == area or test_group.objective.area == area) then
                        occupied = true

                        break
                    end
                end

                local is_area_safe = nr_criminals == 0

                if occupied then
                    --if all areas are occupied we assign new tasks to those areas
                    if is_area_safe and not backup_recon_candidates_are_safe then
                        backup_recon_candidates = {
                            area
                        }
                        backup_recon_candidates_are_safe = true
                    else
                        table.insert(backup_recon_candidates, area)
                    end
                else

                    if is_area_safe and not recon_candidates_are_safe then
                        recon_candidates = {
                            area
                        }
                        recon_candidates_are_safe = true
                    else
                        table.insert(recon_candidates, area)
                    end
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

        i = i + 1
    until i > #to_search_areas

    if recon_data.break_extended and assault_data.active then
        recon_data.break_extended = nil
    end

    if recon_candidates and #recon_candidates == 0 then
        recon_candidates = backup_recon_candidates
        recon_candidates_are_safe = backup_recon_candidates_are_safe
    end

    --prevent cheese tactic, if no recon objectives or tasks and assault break is extended, or recon is set to appear always, then set task on the player
    if recon_candidates and not recon_candidates[1] and not recon_data.tasks[1] and (recon_data.break_extended or self._recon_assault_condition == 4) then
        recon_candidates_are_safe = false
        if assault_candidates then
            recon_candidates = assault_candidates
        else
            for criminal_key, criminal_data in pairs(self._char_criminals) do
                if not criminal_data.status then
                    local nav_seg = criminal_data.tracker:nav_segment()
                    local area = self:get_area_from_nav_seg_id(nav_seg)


                    table.insert(recon_candidates, area)
                end
            end
        end
    end


    if assault_candidates and #assault_candidates > 0 then
        self:_begin_assault_task(assault_candidates)
        
        recon_candidates = nil
    end

    if recon_candidates and #recon_candidates > 0 then
        -- if no safe areas, then define safe areas as areas with lowest criminals
        if not recon_candidates_are_safe and #recon_candidates > 1 then
            -- find lowest criminal count
            local lowest_nr_criminals = nil
            for _, area in pairs(criminal_areas) do
                local nr_criminals = table.size(area.criminal.units)
                if not lowest_nr_criminals or nr_criminals < lowest_nr_criminals then
                    lowest_nr_criminals = nr_criminals
                end
            end
            -- find areas with a higher count
            local higher_criminal_areas = {}
            for _, area in pairs(criminal_areas) do
                if table.size(area.criminal.units) > lowest_nr_criminals then
                    table.insert(higher_criminal_areas, area)
                end
            end

            -- criminal areas (aka areas to avoid) are now areas with higher criminal counts
            if #higher_criminal_areas < #recon_candidates and #higher_criminal_areas > 0 then
                recon_candidates_are_safe = true
                criminal_areas = higher_criminal_areas
            end
        end

        if recon_candidates_are_safe and #recon_candidates > 1 then
            local furthest_area = nil
            local furthest_area_dist = nil
            -- prioritise furthest area from criminals
            for _, area in pairs(recon_candidates) do
                -- to determine furthest area, we find the distance from the closest area containing criminals
                local closest_c_area_dist = nil
                for _, c_area in pairs(criminal_areas) do
                    if c_area == area then
                        closest_c_area_dist = 0
                        break
                    end
                    local dist = mvector3.distance_sq(area.pos, c_area.pos)
                    if not closest_c_area_dist or dist < closest_c_area_dist then
                        closest_c_area_dist = dist
                    end
                end
                if not furthest_area_dist or closest_c_area_dist > furthest_area_dist then 
                    furthest_area = area
                    furthest_area_dist = closest_c_area_dist
                end
            end
            recon_area = furthest_area
        else
            recon_area = recon_candidates[math.random(#recon_candidates)]
        end
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

function GroupAIStateBesiege:_begin_recon_task(recon_area)
	local new_task = {
		use_smoke = true,
		use_spawn_event = true,
		target_area = recon_area,
		start_t = self._t
	}

	table.insert(self._task_data.recon.tasks, new_task)

	-- OVERKILL ARE YOU STUPID???
end

--Have to redefine this one
function GroupAIStateBesiege:_upd_recon_tasks()
    local task_data = self._task_data.recon.tasks[1]

    self:_assign_enemy_groups_to_recon()

    local t = self._t

    if not task_data then
        --If recon isn't dispatched yet
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
                    target_area = task_data.target_area,
                    coarse_path = {
                        {
                            spawn_group.area.pos_nav_seg,
                            spawn_group.area.pos
                        }
                    }
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

-- There's no reason for this to be setting the next dispatch, as upd_reenforce_tasks sets it already
Hooks:PostHook(GroupAIStateBesiege, "_begin_reenforce_task", "star_recon_begin_reenforce_task", function(self, reenforce_area)
    if self._reenforce_valid then
        self._task_data.reenforce.next_dispatch_t = self._t - 1 --Because in order for this to execute the value would have had to be at least this
    end
end)

function GroupAIStateBesiege:_set_recon_objective_to_group(group)
	local current_objective = group.objective
	local target_area = current_objective.target_area or current_objective.area

    --get tactics
    local group_leader_u_key, group_leader_u_data = self._determine_group_leader(group.units)
    local tactics_map = nil
    if group_leader_u_data and group_leader_u_data.tactics then
		tactics_map = {}

		for _, tactic_name in ipairs(group_leader_u_data.tactics) do
			tactics_map[tactic_name] = true
		end
    end

    local coward = tactics_map and tactics_map.ranged_fire
    local charge = tactics_map and tactics_map.charge_recon

    local crim_obj_allowed = (self._task_data.recon.break_extended or self._recon_assault_condition == 4 or self._task_data.assault.is_first)
    local crims_at_obj = next(target_area.criminal.units)

	if not target_area.loot and not target_area.hostages and (not crim_obj_allowed or not self._recon_obj_count and not crims_at_obj) or not current_objective.moving_out and current_objective.moved_in and group.in_place_t and self._t - group.in_place_t > 15 then
		local recon_area = nil
		local to_search_areas = {
			current_objective.area
		}
		local found_areas = {
			[current_objective.area] = "init"
		}

        local areas_to_investigate = {}
        local areas_are_safe = nil
        local backup_areas = {}
        local backup_areas_are_safe = nil
        local criminal_areas = {}

		repeat
			local search_area = table.remove(to_search_areas, 1)

			if search_area.loot or search_area.hostages then
				local occupied = nil

				for test_group_id, test_group in pairs(self._groups) do
					if test_group ~= group and test_group.objective.type == "recon_area" and (test_group.objective.target_area == search_area or test_group.objective.area == search_area) then
						occupied = true

						break
					end
				end

				if not occupied and group.visited_areas and group.visited_areas[search_area] then
					occupied = true
				end

                local is_area_safe = not next(search_area.criminal.units)

				if occupied then
                    --if all areas are occupied we assign new tasks to those areas
                    if is_area_safe and not backup_areas_are_safe then
                        backup_areas = {
                            search_area
                        }
                        backup_areas_are_safe = true
                    else
                        table.insert(backup_areas, search_area)
                    end
                else

					if is_area_safe and not areas_are_safe then
                        areas_to_investigate = {
                            search_area
                        }
                        areas_are_safe = true
                    else
                        table.insert(areas_to_investigate, search_area)
                    end
				end

                if not is_area_safe then
                    table.insert(criminal_areas, search_area)
                end
			end

            for other_area_id, other_area in pairs(search_area.neighbours) do
                if not found_areas[other_area] then
                    table.insert(to_search_areas, other_area)

                    found_areas[other_area] = search_area
                end
            end
		until #to_search_areas == 0

        -- if no free objectives, then go to objectives which already have assigned recon
        if #areas_to_investigate == 0 and #backup_areas > 0 then
            areas_to_investigate = backup_areas
            areas_are_safe = backup_areas_are_safe
        end

        -- if allowing recon task to set objective on criminals, not already fighting criminals and no there are no normal objectives, then go to criminal objectives 
        if crim_obj_allowed and #areas_to_investigate == 0 and not crims_at_obj and #criminal_areas > 0 then
            areas_to_investigate = criminal_areas
            areas_are_safe = false
        end

        if #areas_to_investigate > 0 then
            -- if no safe areas, then define safe areas as areas with lowest criminals
            if not areas_are_safe and #areas_to_investigate > 1 then
                -- find lowest criminal count
                local lowest_nr_criminals = nil
                for _, area in pairs(criminal_areas) do
                    local nr_criminals = table.size(area.criminal.units)
                    if not lowest_nr_criminals or nr_criminals < lowest_nr_criminals then
                        lowest_nr_criminals = nr_criminals
                    end
                end
                -- find areas with a higher count
                local higher_criminal_areas = {}
                for _, area in pairs(criminal_areas) do
                    if table.size(area.criminal.units) > lowest_nr_criminals then
                        table.insert(higher_criminal_areas, area)
                    end
                end

                if #higher_criminal_areas < #areas_to_investigate and #higher_criminal_areas > 0 then
                    areas_are_safe = true
                    criminal_areas = higher_criminal_areas
                end
            end

            --prioritise areas close to the group
            if #areas_to_investigate > 1 then
                local closest_area_dist = nil
                local area_dists = {} -- list of areas and their dists
                for _, area in pairs(areas_to_investigate) do
                    local dist = mvector3.distance_sq(area.pos, current_objective.area.pos)
                    if not closest_area_dist or closest_area_dist > dist then
                        closest_area_dist = dist
                        area_dists[area] = dist
                    end
                end
                local areas_to_investigate = {}
                for area, dist in pairs(area_dists) do
                    if dist - closest_area_dist <= 1000000 then -- 10 metres squared distance from shortest distance
                        table.insert(areas_to_investigate, area)
                    end
                end
            end

            if areas_are_safe and #areas_to_investigate > 1 then
                local furthest_area = nil
                local furthest_area_dist = nil
                -- prioritise furthest area from criminals
                for _, area in pairs(areas_to_investigate) do
                    -- to determine furthest area, we find the distance from the closest area containing criminals
                    local closest_c_area_dist = nil
                    for _, c_area in pairs(criminal_areas) do
                        if c_area == area then
                            closest_c_area_dist = 0
                            break
                        end
                        local dist = mvector3.distance_sq(area.pos, c_area.pos)
                        if not closest_c_area_dist or dist < closest_c_area_dist then
                            closest_c_area_dist = dist
                        end
                    end
                    if not furthest_area_dist or closest_c_area_dist > furthest_area_dist then 
                        furthest_area = area
                        furthest_area_dist = closest_c_area_dist
                    end
                end
                recon_area = furthest_area
            else
                recon_area = areas_to_investigate[math.random(#areas_to_investigate)]
            end
        end

		if recon_area then
			local coarse_path = {
				{
					recon_area.pos_nav_seg,
					recon_area.pos
				}
			}
			local last_added_area = recon_area

			while found_areas[last_added_area] ~= "init" do
				last_added_area = found_areas[last_added_area]

				table.insert(coarse_path, 1, {
					last_added_area.pos_nav_seg,
					last_added_area.pos
				})
			end

			local grp_objective = {
				scan = true,
				pose = charge and "stand" or "crouch",
				type = "recon_area",
				stance = "hos",
				attitude = "avoid",
                interrupt_dis = coward and 800 or nil,
				area = current_objective.area,
				target_area = recon_area,
				coarse_path = coarse_path
			}

			self:_set_objective_to_enemy_group(group, grp_objective)

			current_objective = group.objective
        elseif current_objective and (not crim_obj_allowed or not crims_at_obj) and (not current_objective.assigned_t or self._t > current_objective.assigned_t + 10) then
            --STUCK
            if (not current_objective.assigned_t) then
                --loud might have just started, wait a few seconds
                current_objective.assigned_t = self._t
            else
                current_objective.type = "defend_area" --retires asap while not contributing to recon or assault force
                --log("RTRE: Unit stuck, retiring asap")
            end
		end
	end

	if current_objective.target_area then
		if current_objective.moving_out and not current_objective.moving_in and current_objective.coarse_path then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point and forwardmost_i_nav_point > 1 then
				for i = forwardmost_i_nav_point + 1, #current_objective.coarse_path do
					local nav_point = current_objective.coarse_path[i]

					if not self:is_nav_seg_safe(nav_point[1]) then
                        if self:get_area_from_nav_seg_id(current_objective.coarse_path[i][1]) == current_objective.target_area then -- enemies in target area
                            table.remove(current_objective.coarse_path)
                            return
                        end
                        -- else 
						for j = 0, #current_objective.coarse_path - forwardmost_i_nav_point do
							table.remove(current_objective.coarse_path)
						end

						local grp_objective = {
							attitude = "avoid",
							scan = true,
							pose = charge and "stand" or "crouch",
							type = "recon_area",
							stance = "hos",
                            interrupt_dis = coward and 800 or nil,
							area = self:get_area_from_nav_seg_id(current_objective.coarse_path[#current_objective.coarse_path][1]),
							target_area = current_objective.target_area
						}

						self:_set_objective_to_enemy_group(group, grp_objective)

						return
					end
				end
			end
            --ranged fire recon will retreat if players invade their area.
            if coward and forwardmost_i_nav_point and not self:is_nav_seg_safe(current_objective.coarse_path[forwardmost_i_nav_point][1]) then
                local retreat_area = nil
                local current_area = self:get_area_from_nav_seg_id(current_objective.coarse_path[forwardmost_i_nav_point][1])

                -- check if any of the group are in a safe area
                for u_key, u_data in pairs(group.units) do
                    local nav_seg_id = u_data.tracker:nav_segment()
        
                    if not current_objective.area.nav_segs[nav_seg_id] and self:is_nav_seg_safe(nav_seg_id) then
                        retreat_area = self:get_area_from_nav_seg_id(nav_seg_id)
        
                        break
                    end
                end
                -- check if the previous area was a safe area
                if not retreat_area then
                    if forwardmost_i_nav_point > 1 and self:is_nav_seg_safe(current_objective.coarse_path[forwardmost_i_nav_point - 1][1]) then
                        retreat_area = self:get_area_from_nav_seg_id(current_objective.coarse_path[forwardmost_i_nav_point - 1][1])
                    end
                end
                --check for surrounding safe areas
                if not retreat_area then
                    for other_area_id, other_area in pairs(current_area.neighbours) do
                        if self:is_area_safe(other_area) then
                            retreat_area = other_area
                            break
                        end
                    end
                end

                if retreat_area then
                    local grp_objective = {
                        attitude = "avoid",
                        scan = true,
                        pose = "stand",
                        type = "recon_area",
                        stance = "cbt",
                        interrupt_dis = 0,
                        area = retreat_area,
                        target_area = current_objective.target_area,
                        coarse_path = {
                            {
                                retreat_area.pos_nav_seg,
                                retreat_area.pos
                            }
                        }
                    }

                    self:_set_objective_to_enemy_group(group, grp_objective)

                    return
                end
            end
		end

        -- after spawning
		if not current_objective.moving_out and not current_objective.area.neighbours[current_objective.target_area.id] then
            -- check for alternate path if flanking and target area contains players.
            local alt_area = nil
            if tactics_map and tactics_map.flank and next(current_objective.target_area.criminal.units) then
                local alt_areas = {}
                for area_id, enter_from_area in pairs(current_objective.target_area.neighbours) do
                    local enter_from_here = true
                    --go around assault units if possible
                    local cop_units = enter_from_area.police.units
                    for u_key, u_data in pairs(cop_units) do
                        if u_data.group and u_data.group ~= group and u_data.group.objective.type == "assault_area" then
                            enter_from_here = false
                            break
                        end
                    end
                    if enter_from_here then
                        --check if other groups are attacking from that point. if so, we want to attack somewhere else
                        for group_id, group in pairs(self._groups) do
                            if group.objective and group.objective.target_area == current_objective.target_area and group.objective.coarse_path then
                                local other_path = group.objective.coarse_path
                                local attack_point = other_path[#other_path][1]
                                if attack_point == current_objective.target_area.pos_nav_seg and #other_path > 1 then
                                    attack_point = other_path[#other_path - 1][1]
                                end
                                if enter_from_area.pos_nav_seg == attack_point then
                                    enter_from_here = false
                                    break
                                end
                            end
                        end
                    end
                    if enter_from_here then
                        table.insert(alt_areas, enter_from_area)
                    end
                end
                if next(alt_areas) then
                    alt_area = alt_areas[math.random(#alt_areas)]
                end
            end
			local search_params = {
				id = "GroupAI_recon",
				from_seg = current_objective.area.pos_nav_seg,
				to_seg = alt_area and alt_area.pos_nav_seg or current_objective.target_area.pos_nav_seg,
				access_pos = self._get_group_acces_mask(group),
				verify_clbk = callback(self, self, "is_nav_seg_safe")
			}
			local coarse_path = managers.navigation:search_coarse(search_params)

			if coarse_path then
				self:_merge_coarse_path_by_area(coarse_path)
                if not alt_area then
				    table.remove(coarse_path)
                end

				local grp_objective = {
					scan = true,
					pose = charge and "stand" or "crouch",
					type = "recon_area",
					stance = "hos",
					attitude = "avoid",
                    interrupt_dis = coward and 800 or nil,
					area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
					target_area = current_objective.target_area,
					coarse_path = coarse_path
				}

				self:_set_objective_to_enemy_group(group, grp_objective)
			end
		end

		if not current_objective.moving_out and current_objective.area.neighbours[current_objective.target_area.id] then
            local area_hostile = next(current_objective.target_area.criminal.units)
			local grp_objective = {
				stance = area_hostile and "cbt" or "hos",
				scan = true,
				pose = charge and "stand" or "crouch",
				type = "recon_area",
				attitude = (area_hostile and crim_obj_allowed and not current_objective.target_area.hostages and not current_objective.target_area.loot) and "engage" or "avoid",
                interrupt_dis = coward and 800 or nil,
				area = current_objective.target_area
			}

			self:_set_objective_to_enemy_group(group, grp_objective)

			group.objective.moving_in = true
			group.objective.moved_in = true

			if area_hostile then
				self:_chk_group_use_smoke_grenade(group, {
					use_smoke = true,
					target_areas = {
						grp_objective.area
					}
				})
			end
		end
	end
end

Hooks:PostHook(GroupAIStateBesiege, "_assign_group_to_retire", "star_recon_retire_group", function(self, group)
    --Could not find flee point
    if group and group.objective and group.objective.type ~= "retire" then
        group.objective.type = "defend_area"
    end
end)

--fix retirement
function GroupAIStateBesiege:_assign_recon_groups_to_retire()
    --allow recon if valid
    if self._goin_valid and self:is_recon_allowed() then
        return
    end
	local function suitable_grp_func(group)
		if group.objective.type == "recon_area" then
			local grp_objective = {
				stance = "hos",
				attitude = "avoid",
				pose = "crouch",
				type = "assault_area",
				area = group.objective.area
			}

			self:_set_objective_to_enemy_group(group, grp_objective)
		end
	end

	self:_assign_groups_to_retire(self._tweak_data.assault.groups, suitable_grp_func, "assault_area")
end

function GroupAIStateBesiege:_assign_assault_groups_to_retire()
	local function suitable_grp_func(group)
		if group.objective.type == "assault_area" then
			local regroup_area = nil

			if next(group.objective.area.criminal.units) then
				for other_area_id, other_area in pairs(group.objective.area.neighbours) do
					if not next(other_area.criminal.units) then
						regroup_area = other_area

						break
					end
				end
			end

			regroup_area = regroup_area or group.objective.area
			local grp_objective = {
				stance = "hos",
				attitude = "avoid",
				pose = "crouch",
				type = "recon_area",
				area = regroup_area
			}

			self:_set_objective_to_enemy_group(group, grp_objective)
		end
	end

	self:_assign_groups_to_retire(self._tweak_data.recon.groups, suitable_grp_func, "recon_area")
end

function GroupAIStateBesiege:_assign_groups_to_retire(allowed_groups, suitable_grp_func, allowed_task)
	for group_id, group in pairs(self._groups) do
        if group.objective.type ~= "reenforce_area" and group.objective.type ~= "retire" and group.objective.type ~= allowed_task then 
            if not allowed_groups[group.type] then
                self:_assign_group_to_retire(group)
            elseif suitable_grp_func and allowed_groups[group.type] then
                suitable_grp_func(group)
            end
        end
	end
end


--DEBUG


Hooks:PreHook(GroupAIStateBesiege, "init", "star_recon_ai_state_besiege_init_debug", function(self, group_ai_state)
    self:set_debug_draw_state(true)
end)

function GroupAIStateBesiege:_draw_enemy_activity(t)
	local draw_data = self._AI_draw_data
	local brush_area = draw_data.brush_area
	local area_normal = -math.UP
	local logic_name_texts = draw_data.logic_name_texts
	local group_id_texts = draw_data.group_id_texts
	local panel = draw_data.panel
	local camera = managers.viewport:get_current_camera()

    -- custom debug
    if not draw_data.group_area_texts then
        draw_data.group_area_texts = {}
    end
    local group_area_texts = draw_data.group_area_texts

	if not camera then
		return
	end

	local ws = draw_data.workspace
	local mid_pos1 = Vector3()
	local mid_pos2 = Vector3()
	local focus_enemy_pen = draw_data.pen_focus_enemy
	local focus_player_brush = draw_data.brush_focus_player
	local suppr_period = 0.4
	local suppr_t = t % suppr_period

	if suppr_t > suppr_period * 0.5 then
		suppr_t = suppr_period - suppr_t
	end

	draw_data.brush_suppressed:set_color(Color(math.lerp(0.2, 0.5, suppr_t), 0.85, 0.9, 0.2))

	for area_id, area in pairs(self._area_data) do
		if table.size(area.police.units) > 0 then
			brush_area:half_sphere(area.pos, 22, area_normal)
		end
	end

	local function _f_draw_logic_name(u_key, l_data, draw_color)
		local logic_name_text = logic_name_texts[u_key]
		local text_str = l_data.name

		if l_data.objective then
			text_str = text_str .. ":" .. l_data.objective.type
		end

		if not l_data.group and l_data.team then
			text_str = l_data.team.id .. ":" .. text_str
		end

		if l_data.spawned_in_phase then
			text_str = text_str .. ":" .. l_data.spawned_in_phase
		end

		if l_data.unit:anim_state_machine() then
			text_str = text_str .. ":animation( " .. l_data.unit:anim_state_machine():segment_state(Idstring("base")) .. " )"
		end

		if logic_name_text then
			logic_name_text:set_text(text_str)
		else
			logic_name_text = panel:text({
				name = "text",
				font_size = 20,
				layer = 1,
				text = text_str,
				font = tweak_data.hud.medium_font,
				color = draw_color
			})
			logic_name_texts[u_key] = logic_name_text
		end

		local my_head_pos = mid_pos1

		mvector3.set(my_head_pos, l_data.unit:movement():m_head_pos())
		mvector3.set_z(my_head_pos, my_head_pos.z + 30)

		local my_head_pos_screen = camera:world_to_screen(my_head_pos)

		if my_head_pos_screen.z > 0 then
			local screen_x = (my_head_pos_screen.x + 1) * 0.5 * RenderSettings.resolution.x
			local screen_y = (my_head_pos_screen.y + 1) * 0.5 * RenderSettings.resolution.y

			logic_name_text:set_x(screen_x)
			logic_name_text:set_y(screen_y)

			if not logic_name_text:visible() then
				logic_name_text:show()
			end
		elseif logic_name_text:visible() then
			logic_name_text:hide()
		end
	end

	local function _f_draw_obj_pos(unit)
		local brush = nil
		local objective = unit:brain():objective()
		local objective_type = objective and objective.type

		if objective_type == "guard" then
			brush = draw_data.brush_guard
		elseif objective_type == "defend_area" then
			brush = draw_data.brush_defend
		elseif objective_type == "free" or objective_type == "follow" or objective_type == "surrender" then
			brush = draw_data.brush_free
		elseif objective_type == "act" then
			brush = draw_data.brush_act
		else
			brush = draw_data.brush_misc
		end

		local obj_pos = nil

		if objective then
			if objective.pos then
				obj_pos = objective.pos
			elseif objective.follow_unit then
				obj_pos = objective.follow_unit:movement():m_head_pos()

				if objective.follow_unit:base().is_local_player then
					obj_pos = obj_pos + math.UP * -30
				end
			elseif objective.nav_seg then
				obj_pos = managers.navigation._nav_segments[objective.nav_seg].pos
			elseif objective.area then
				obj_pos = objective.area.pos
			end
		end

		if obj_pos then
			local u_pos = unit:movement():m_com()

			brush:cylinder(u_pos, obj_pos, 4, 3)
			brush:sphere(u_pos, 24)
		end

		if unit:brain()._logic_data.is_suppressed then
			mvector3.set(mid_pos1, unit:movement():m_pos())
			mvector3.set_z(mid_pos1, mid_pos1.z + 220)
			draw_data.brush_suppressed:cylinder(unit:movement():m_pos(), mid_pos1, 35)
		end
	end

	local group_center = Vector3()

	for group_id, group in pairs(self._groups) do
		local nr_units = 0

		for u_key, u_data in pairs(group.units) do
			nr_units = nr_units + 1

			mvector3.add(group_center, u_data.unit:movement():m_com())
		end

		if nr_units > 0 then
			mvector3.divide(group_center, nr_units)

			local gui_text = group_id_texts[group_id]
			local group_pos_screen = camera:world_to_screen(group_center)

			if group_pos_screen.z > 0 then
				if not gui_text then
					gui_text = panel:text({
						name = "text",
						font_size = 24,
						layer = 2,
						text = group.team.id .. ":" .. group_id .. ":" .. group.objective.type,
						font = tweak_data.hud.medium_font,
						color = draw_data.group_id_color
					})
					group_id_texts[group_id] = gui_text
				end

				local screen_x = (group_pos_screen.x + 1) * 0.5 * RenderSettings.resolution.x
				local screen_y = (group_pos_screen.y + 1) * 0.5 * RenderSettings.resolution.y

				gui_text:set_x(screen_x)
				gui_text:set_y(screen_y)

				if not gui_text:visible() then
					gui_text:show()
				end
			elseif gui_text and gui_text:visible() then
				gui_text:hide()
			end

			for u_key, u_data in pairs(group.units) do
				draw_data.pen_group:line(group_center, u_data.unit:movement():m_com())
			end
		end

        --show target area 
        local area_text = group_area_texts[group_id]
        local group_area_pos_screen = (group.objective.target_area and camera:world_to_screen(group.objective.target_area.pos)) or (group.objective.area and camera:world_to_screen(group.objective.area.pos)) or nil
        local group_area_type = group.objective.target_area and "target_area" or "area"
        if group_area_pos_screen then
            if not area_text then
                area_text = panel:text({
                    name = "text",
                    font_size = 24,
                    layer = 2,
                    text = group.team.id .. ":" .. group_id .. ":" .. group_area_type,
                    font = tweak_data.hud.medium_font,
                    color = Color(1, 0, 0.45, 1)
                })
                group_area_texts[group_id] = area_text
            else
                area_text:set_text(group.team.id .. ":" .. group_id .. ":" .. group_area_type)
            end

            local screen_x = (group_area_pos_screen.x + 1) * 0.5 * RenderSettings.resolution.x
            local screen_y = (group_area_pos_screen.y + 1) * 0.5 * RenderSettings.resolution.y

            area_text:set_x(screen_x)
            area_text:set_y(screen_y)

            if not area_text:visible() then
                area_text:show()
            end
        end
        --end show target area

		mvector3.set_zero(group_center)
	end

	local function _f_draw_attention_on_player(l_data)
		if l_data.attention_obj then
			local my_head_pos = l_data.unit:movement():m_head_pos()
			local e_pos = l_data.attention_obj.m_head_pos
			local dis = mvector3.distance(my_head_pos, e_pos)

			mvector3.step(mid_pos2, my_head_pos, e_pos, 300)
			mvector3.lerp(mid_pos1, my_head_pos, mid_pos2, t % 0.5)
			mvector3.step(mid_pos2, mid_pos1, e_pos, 50)
			focus_enemy_pen:line(mid_pos1, mid_pos2)

			if l_data.attention_obj.unit:base() and l_data.attention_obj.unit:base().is_local_player then
				focus_player_brush:sphere(my_head_pos, 20)
			end
		end
	end

	local groups = {
		{
			group = self._police,
			color = Color(1, 1, 0, 0)
		},
		{
			group = managers.enemy:all_civilians(),
			color = Color(1, 0.75, 0.75, 0.75)
		},
		{
			group = self._ai_criminals,
			color = Color(1, 0, 1, 0)
		}
	}

	for _, group_data in ipairs(groups) do
		for u_key, u_data in pairs(group_data.group) do
			_f_draw_obj_pos(u_data.unit)

			if camera then
				local l_data = u_data.unit:brain()._logic_data

				_f_draw_logic_name(u_key, l_data, group_data.color)
				_f_draw_attention_on_player(l_data)
			end
		end
	end

	for u_key, gui_text in pairs(logic_name_texts) do
		local keep = nil

		for _, group_data in ipairs(groups) do
			if group_data.group[u_key] then
				keep = true

				break
			end
		end

		if not keep then
			panel:remove(gui_text)

			logic_name_texts[u_key] = nil
		end
	end

	for group_id, gui_text in pairs(group_id_texts) do
		if not self._groups[group_id] then
			panel:remove(gui_text)

			group_id_texts[group_id] = nil
		end
	end
    for group_id, gui_text in pairs(group_area_texts) do
		if not self._groups[group_id] then
			panel:remove(gui_text)

			group_area_texts[group_id] = nil
		end
	end
end