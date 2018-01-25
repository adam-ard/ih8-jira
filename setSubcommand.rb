require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$set_usage='Usage: ih8-jira set <issue_id> [options]'
$set_argTable=[[true, 'assignee', 'a', 'new assignee'],
               [true, 'summary', 's', 'new summary'],
               [true, 'priority', 'p', 'new priority'],
               [true, 'description', 'd', 'new description']]


def handle_set_mode(options, args)
  if args.length < 1
    print "Wrong number of args, missing issue_id"
    exit
  end

  form_data={}
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

  unless form_data == {}
    data,err=rest_put_request("rest/api/latest/issue/#{args[0]}", form_data)
    if err
      return false
    end
  end
end
