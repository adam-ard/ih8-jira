require 'net/http'
require 'json'

require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$delete_usage = 'Usage: ih8-jira delete <issue_id>'
$delete_argTable = []

def handle_delete_mode(options, args)
  rest_delete_request("rest/api/latest/issue/#{args[0]}")
end
