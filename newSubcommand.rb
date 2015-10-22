require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$new_usage = 'Usage: ih8-jira new [options]'
$new_argTable = [[true, 'assignee', 'a', 'new assignee'],
                 [true, 'estimate', 'e', 'new estimate'],
                 [true, 'component', 'c', 'new component'],
                 [true, 'summary', 's', 'new summary']]

def handle_new_mode(options, args)
  form_data={"fields"=> {"project"=> {"key"=> $project_key}, "issuetype"=> {"name"=> "Task"}}}

  if options['estimate']
    update(form_data, { 'fields'=> {'customfield_10004' => options['estimate'].to_i }})
  end
  if options['assignee']
    update(form_data, { 'fields'=> {'assignee' => {'name' => options['assignee']}}})
  end
  if options['summary']
    update(form_data, { 'fields'=> {'summary' => options['summary']}})
  end
  if options['component']
    update(form_data, { 'fields'=> {'components' => [{"name":options['component']}]}})
  end

  data,err=rest_post_request("rest/api/latest/issue/", form_data)
  unless err
    puts data['key']
  end
  return !err
end
