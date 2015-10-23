require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$epic_usage = 'Usage: ih8-jira epics'
$epic_argTable = []

def print_epic_list(epic_list)
  epic_list.select! { |e| e[2] != 'Done' }
  epic_list.each do | in_item |
    puts "    #{format("%-7s",in_item[0])} #{format("%-.60s", in_item[1])}"
  end
end

def handle_epic_cmd(options, args)
  jql="issuetype = Epic AND (#{$team_query})"
  form_data={'jql' => jql, 'startAt' => 0, 'maxResults' => -1, 'fields'=> ['summary', 'customfield_10601', 'customfield_10602']}
  data,err=rest_post_request("rest/api/latest/search/", form_data)
  if err
    return []
  end

  epic_list=[]
  data['issues'].each do | item |
    epic_list << [item['key'], item['fields']['customfield_10601'], item['fields']['customfield_10602']['value']]
  end

  print_epic_list(epic_list)
end
