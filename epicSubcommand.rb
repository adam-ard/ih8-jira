require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$epic_usage = 'Usage: ih8-jira epics'
$epic_argTable = []

def print_epic_list(epic_list)
  epic_list.each do | in_item |
    puts "    #{format("%-10s",in_item[0])} #{format("%-.60s", in_item[1])}"
  end
end

def handle_epic_cmd(options, args)
  jql="issuetype = Epic AND (#{$team_query})"
  form_data={'jql' => jql, 'startAt' => 0, 'maxResults' => -1, 'fields'=> ['summary']}
  data,err=rest_post_request("rest/api/latest/search/", form_data)
  if err
    return []
  end

  epic_list=[]
  data['issues'].each do | item |
    epic_list << [item['key'], item['fields']['summary']]
  end

  print_epic_list(epic_list)
end
