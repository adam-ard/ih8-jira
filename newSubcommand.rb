require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$new_usage = 'Usage: ih8-jira new [options]'
$new_argTable = [[true, 'assignee', 'a', 'new assignee'],
                 [true, 'summary', 's', 'new summary'],
                 [true, 'priority', 'p', 'new priority'],
                 [true, 'description', 'd', 'new description']]

def handle_new_mode(options, args)
  form_data={"fields"=> {"project"=> {"key"=> $project_key}, "issuetype"=> {"name"=> "Task"}}}

  if options['priority']
    update(form_data, { 'fields'=> {'priority' => {'name' => options['priority'] }}})
  end
  if options['assignee']
    update(form_data, { 'fields'=> {'assignee' => {'name' => options['assignee']}}})
  end
  if options['description']
    update(form_data, { 'fields'=> {'description' => options['description']}})
  end
  if options['summary']
    update(form_data, { 'fields'=> {'summary' => options['summary']}})
  end

  data,err=rest_post_request("rest/api/latest/issue/", form_data)
  unless err
    puts data['key']
  end
  return !err
end
