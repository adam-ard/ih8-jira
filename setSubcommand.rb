require 'net/http'
require 'json'

require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$set_usage='Usage: ih8-jira set <issue_id> [options]'
$set_argTable=[[true, 'assignee', 'a', 'new assignee'],
               [true, 'summary', 's', 'new summary'],
               [true, 'estimate', 'e', 'new estimate'],
               [true, 'sprint', 'p', 'new sprint (backlog or current)']]


def handle_set_mode(options, args)
  if args.length < 1
    print "Wrong number of args, missing issue_id"
    exit
  end

  form_data={}
  if options['estimate']
    update(form_data, { 'fields'=> {'customfield_10004' => options['estimate'].to_i }})
  end
  if options['assignee']
    update(form_data, { 'fields'=> {'assignee' => {'name' => options['assignee']}}})
  end
  if options['summary']
    update(form_data, { 'fields'=> {'summary' => options['summary']}})
  end

  rest_put_request("rest/api/latest/issue/#{args[0]}", form_data)

  if options['sprint']
    data=rest_get_request("rest/greenhopper/latest/rapidview")
    data['views'].each() do | x |
      if x['name'] == $project
        data2=rest_get_request("rest/greenhopper/latest/sprintquery/#{x['id']}")
        data2['sprints'].each() do | y |
          if y['state'] == 'ACTIVE'
            if options['sprint'] == "current"
              data3=rest_post_request("rest/agile/1.0/sprint/#{y['id']}/issue", {"issues"=>[args[0]]})
            else
              data3=rest_post_request("rest/agile/1.0/backlog/issue", {"issues"=>[args[0]]})
            end
          end
        end
      end
    end
  end
end
