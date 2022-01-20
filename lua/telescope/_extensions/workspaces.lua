local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local telescope = require("telescope")

local workspaces = require("workspaces")

local workspaces_picker = function(opts)
    -- compute spacing
    local workspaces_list = workspaces.get()
    local width = 10
    for _, workspace in ipairs(workspaces_list) do
        if #workspace.name > width then
            width = #workspace.name + 2
        end
    end

    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = width },
            {},
        },
    })

    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Workspaces",

        finder = finders.new_table({
            results = workspaces_list,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = function(entry)
                        return displayer({
                            { entry.ordinal },
                            { entry.value.path, "String" },
                        })
                    end,
                    ordinal = entry.name,
                }
            end
        }),

        sorter = conf.generic_sorter(opts),

        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local workspace = action_state.get_selected_entry().value
                workspaces.open(workspace.name)
            end)
            return true
        end,
    }):find()
end

return telescope.register_extension({
    exports = {
        workspaces = workspaces_picker,
    },
})
