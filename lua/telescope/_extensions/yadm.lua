local has_telescope, telescope = pcall(require, 'telescope')
local picker = require('telescope._extensions.yadm.yadm_picker')

if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
end

return telescope.register_extension {
  setup = picker.setup,
  exports = {
    yadm = function()
      -- Subcommand 1 logic
    end,
    pick = picker.pick
  }
}
