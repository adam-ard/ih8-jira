require 'net/http'
require 'json'

require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$new_usage = 'Usage: ih8-jira new [options]'
$new_argTable = [[true, 'assignee', 'a', 'new assignee'],
                 [true, 'estimate', 'e', 'new estimate'],
                 [true, 'summary', 's', 'new summary']]

def handle_new_mode(options, args)
  form_data={"fields"=> {"project"=> {"key"=> "SD"}, "issuetype"=> {"name"=> "Task"}}}

  unless options['estimate'].nil?
    update(form_data, { 'fields'=> {'customfield_10004' => options['estimate'].to_i }})
  end
  unless options['assignee'].nil?
    update(form_data, { 'fields'=> {'assignee' => {'name' => options['assignee']}}})
  end
  unless options['summary'].nil?
    update(form_data, { 'fields'=> {'summary' => options['summary']}})
  end

  data=rest_post_request("rest/api/latest/issue/", form_data)
  puts data['key']
end
