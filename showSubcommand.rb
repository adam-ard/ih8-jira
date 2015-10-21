require 'rainbow/ext/string'

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
    '-'
  end
end

def get_last_sprint(sprint_string)
  if sprint_string['fields'] && sprint_string["fields"]["customfield_10007"]
    sprint_string["fields"]["customfield_10007"][-1].split("[")[1].split(',')[3].split('=')[1]
  else
    "-"
  end
end

def jql_query(jql)
  form_data={'jql' => jql, 'startAt' => 0, 'maxResults' => -1, 'fields'=> ['summary', 'status', 'assignee', 'labels']}
  data,err=rest_post_request("rest/api/latest/search/", form_data)
  if err
    return []
  end
  
  sprint_list=[]
  data['issues'].each do | item |
    sprint_list << [item['key'], item['fields']['status']['name'], item['fields']['summary'], get_assignee(item['fields']['assignee']), item['fields']['labels']]
  end
  sprint_list
end

def print_attribute(name, data, location="")
  if data.nil?
    puts "#{format("%11s", name)}:\tnone"
    return
  end

  curr_val=data
  location.split(".").each do |x|
    curr_val=curr_val[x]
    if curr_val.nil?
      puts "#{format("%11s", name)}:\tnone"
      return
    end
  end
  puts "#{format("%11s", name)}:\t#{curr_val}"
end

def print_issue(id)
  data, err=rest_get_request("rest/api/latest/issue/#{id}")
  if err
    return false
  end

  print_attribute("id", id)
  print_attribute("Summary", data, 'fields.summary')
  print_attribute("author", data, 'fields.creator.key')
  print_attribute("assignee", data, 'fields.assignee.name')
  print_attribute("status", data, 'fields.status.name')
  print_attribute("estimate", data, 'fields.customfield_10004')
  print_attribute("sprint", get_last_sprint(data))

  if data['fields'] && data['fields']['description']
    puts "\nDescription:\n#{data['fields']['description']}"
  end
  return true
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
      color = :green
      if in_item[4].include? "committed"
        color = :red
      end
      puts "    #{format("%-7s",in_item[0])}".color(color) + " #{format("%11s",in_item[3])} #{format("%-.60s", in_item[2])}"
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
