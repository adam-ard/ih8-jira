require File.expand_path(File.dirname(__FILE__) + '/optparsewrapper')
require File.expand_path(File.dirname(__FILE__) + '/showSubcommand')
require File.expand_path(File.dirname(__FILE__) + '/setSubcommand')
require File.expand_path(File.dirname(__FILE__) + '/newSubcommand')
require File.expand_path(File.dirname(__FILE__) + '/moveSubcommand')
require File.expand_path(File.dirname(__FILE__) + '/deleteSubcommand')
require File.expand_path(File.dirname(__FILE__) + '/epicSubcommand')

$subcommands={
  'show' => lambda { | opts, args | handle_show_cmd(opts, args) },
  'set'  => lambda { | opts, args | handle_set_mode(opts, args) },
  'new'  => lambda { | opts, args | handle_new_mode(opts, args) },
  'move' => lambda { | opts, args | handle_move_mode(opts, args) },
  'delete' => lambda { | opts, args | handle_delete_mode(opts, args) },
  'epics' => lambda { | opts, args | handle_epic_cmd(opts, args) }
}

opw = Optparsewrapper.new()
opw.setGlobalUsage('Usage: ih8-jira [options] < set | show | new | move | delete | epics >')
opw.addSubcommand('show', $show_usage, $show_argTable)
opw.addSubcommand('set', $set_usage, $set_argTable)
opw.addSubcommand('new', $new_usage, $new_argTable)
opw.addSubcommand('move', $move_usage, $move_argTable)
opw.addSubcommand('delete', $delete_usage, $delete_argTable)
opw.addSubcommand('epics', $epic_usage, $epic_argTable)

opw.handle_cmd_line(ARGV) do | subcmd, opts, args |
  $subcommands[subcmd].call(opts, args)
end
