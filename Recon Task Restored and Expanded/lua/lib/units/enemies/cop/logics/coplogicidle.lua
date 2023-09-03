local old_chk_relocate = CopLogicIdle._chk_relocate
function CopLogicIdle._chk_relocate(data)
    -- FUCK this stupid fucking game
    if data.objective and data.objective.type == "defend_area" and data.objective.grp_objective and data.objective.grp_objective ~= "assault_area" then
        return
    end
    return old_chk_relocate(data)
end