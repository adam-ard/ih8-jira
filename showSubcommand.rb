require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$sections=$IH8_JIRA_CONFIG['ih8-jira']['sections']
$show_usage = 'Usage: ih8-jira show [options]'
$show_argTable = [[true, 'issue_id', 'i', 'This is the id of the issue you wish to view (ex DEMO-192)'],
                  [true, 'assignee', 'a', 'Filter by assignee name'],
                  [true, 'section', 's', 'Filter by section name'],
                  [true, 'sprint', 'p', 'Filter by sprint (current, any)', 'current']]

def get_assignee(assignee_struct)
  if assignee_struct
    assignee_struct['name']
  else
    'unassigned'
  end
end

def get_last_sprint(sprint_string)
  if sprint_string["fields"]["customfield_10007"]
    sprint_string["fields"]["customfield_10007"][-1].split("[")[1].split(',')[3].split('=')[1]
  else
    "unassigned"
  end
end

def jql_query(jql)
  form_data={'jql' => jql, 'startAt' => 0, 'maxResults' => -1, 'fields'=> ['summary', 'status', 'assignee']}
  data=rest_post_request("rest/api/latest/search/", form_data)
  
  sprint_list=[]
  data['issues'].each do | item |
    sprint_list << [item['key'], item['fields']['status']['name'], item['fields']['summary'], get_assignee(item['fields']['assignee'])]
  end
  sprint_list
end

def print_attribute(name, data, location="")
  if data.nil?
    print "#{format("%11s", name)}:\tnone\n"
    return
  end

  curr_val=data
  location.split(".").each do |x|
    curr_val=curr_val[x]
    if curr_val.nil?
      print "#{format("%11s", name)}:\tnone\n"
      return
    end
  end
  print "#{format("%11s", name)}:\t#{curr_val}\n"
end

def print_issue(id)
  data=rest_get_request("rest/api/latest/issue/#{id}")

  print_attribute("id", id)
  print_attribute("Summary", data, 'fields.summary')
  print_attribute("author", data, 'fields.creator.key')
  print_attribute("assignee", data, 'fields.assignee.name')
  print_attribute("status", data, 'fields.status.name')
  print_attribute("estimate", data, 'fields.customfield_10004')
  print_attribute("sprint", get_last_sprint(data))

  if data['fields']['description']
    print "\nDescription:\n#{data['fields']['description']}\n"
  end
end

def print_sprint(assignee, section)
  sprint_list=jql_query("sprint in OpenSprints() AND project = \"#{$project}\"")

  unless section.nil?
    sprint_list.select! { |x| x[1] == section }
  end

  unless assignee.nil?
    sprint_list.select! { |x| x[3] == assignee }
  end

  print_sprint_list(sprint_list)
end

def print_backlog(assignee, section)
  sprint_list=jql_query("project = \"#{$project}\"")

  sprint_list.select! { |x| x[1] != "Done" }
  unless section.nil?
    sprint_list.select! { |x| x[1] == section }
  end

  unless assignee.nil?
    sprint_list.select! { |x| x[3] == assignee }
  end

  print_sprint_list(sprint_list)
end

def print_sprint_list(sprint_list)
  lists = {}
  $sections.each { |x| lists[x] = sprint_list.select { |y| y[1] == x }}
  lists.each do | key, item |
    if item.length != 0
      puts "  #{key}:"
    end
    item.sort_by! { |x| x[3] }
    item.each do | in_item |
      puts "    #{format("%-7s",in_item[0])} #{format("%11s",in_item[3])} #{format("%-.60s", in_item[2])}"
    end
  end
end

def handle_show_cmd(options, args)
  if options['issue_id']
    print_issue(options['issue_id'])
  elsif options['sprint'] == 'current'
    print_sprint(options['assignee'], options['section'])
  else
    print_backlog(options['assignee'], options['section'])
  end
end
