require 'rainbow/ext/string'
require 'pp'

require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$sections=$IH8_JIRA_CONFIG['ih8-jira']['sections']
$show_usage = 'Usage: ih8-jira show [options]'
$show_argTable = [[true, 'issue_id', 'i', 'This is the id of the issue you wish to view (ex DEMO-192)'],
                  [true, 'assignee', 'a', 'Filter by assignee name'],
                  [true, 'section', 's', 'Filter by section name'],
                  [false, 'ignore_closed', 'i', "Ignore closed issues"]]

def get_assignee(assignee_struct)
  if assignee_struct
    assignee_struct['name']
  else
    '-'
  end
end

def jql_query(jql)
  total, max_results=100,100
  start = 0

  issues = []
  while start < total do
    form_data={'jql' => jql, 'startAt' => start, 'maxResults' => max_results, 'fields'=> ['summary', 'status', 'assignee', 'labels', 'priority']}
    data,err=rest_post_request("rest/api/latest/search/", form_data)
    issues.push(*data["issues"])
    if err
      return []
    end
    total = data["total"]
    start += max_results
  end

  puts "#{issues.length} Issues"

  issue_list=[]
  issues.each do | issue |
    issue_list << [issue['key'], issue['fields']['status']['name'], issue['fields']['summary'], get_assignee(issue['fields']['assignee']), issue['fields']['labels'], issue['fields']['priority']['name']]
  end
  issue_list
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

def get_epic_name(data)
  id=nil
  if data['fields'] && data['fields']['customfield_10009']
    id=data['fields']['customfield_10009']
  else
    return "-"
  end

  data, err=rest_get_request("rest/api/latest/issue/#{id}")
  if err
    return "ERROR: can't retrieve epic"
  end
  if data['fields'] && data['fields']['customfield_10008']
    data['fields']['customfield_10008']
  else
    "Error: cant retrieve epic"
  end
end

def print_issue(id)
  data, err=rest_get_request("rest/api/latest/issue/#{id}")
  if err
    return false
  end

  print_attribute("id", id)
  print_attribute("summary", data, 'fields.summary')
  print_attribute("author", data, 'fields.creator.key')
  print_attribute("assignee", data, 'fields.assignee.name')
  print_attribute("status", data, 'fields.status.name')
  print_attribute("priority", data, 'fields.priority.name')
  print_attribute("labels", data, 'fields.labels')
  print_attribute("epic", get_epic_name(data))

  puts "\n"
  print_attribute("description", data, 'fields.description')
  return true
end

def print_issues(assignee, section, ignore_closed)
  query = "#{$team_query} AND issuetype != Epic AND status != Backlog"
  if ignore_closed
    query << " AND status != Closed"
  end
  issue_list=jql_query(query)

  unless section.nil?
    issue_list.select! { |x| x[1] == section }
  end

  unless assignee.nil?
    issue_list.select! { |x| x[3] == assignee }
  end

  print_issue_list(issue_list)
end

def print_backlog(assignee)
  issue_list=jql_query("#{$team_query} AND status = Backlog AND issuetype != Epic" )

  unless assignee.nil?
    issue_list.select! { |x| x[3] == assignee }
  end

  print_issue_list(issue_list)
end

def print_issue_list(issue_list)
  lists = {}
  $sections.each { |x| lists[x] = issue_list.select { |y| y[1] == x }}
  lists.each do | key, issue |
    if issue.length != 0
      puts "  #{key}:"
    end
    issue.sort_by! { |x| x[3] }
    issue.each do | in_issue |
      color = :green
      if in_issue[5] == "Critical"
        color = :red
      end
      puts "    #{format("%-10s",in_issue[0])}".color(color) + " #{format("%18s",in_issue[3])} #{format("%-.60s", in_issue[2])}"
    end
  end
end

def handle_show_cmd(options, args)
  if options['issue_id']
    print_issue(options['issue_id'])
  elsif options['section'] == 'Backlog'
    print_backlog(options['assignee'])
  else
    print_issues(options['assignee'], options['section'], options['ignore_closed'])
  end
end
