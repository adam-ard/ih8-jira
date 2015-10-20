require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$move_usage = 'Usage: ih8-jira move <issue_id> <target_section>'
$move_argTable = []

def get_transistion_id(id, target)
  data=rest_get_request("rest/api/latest/issue/#{id}/transitions")
  data['transitions'].each() do | t |
    if t['to']['name'] == target
      return t['id']
    end
  end
  return nil
end

def handle_move_mode(options, args)
  t_id=get_transistion_id(args[0], args[1])
  if t_id.nil?
    p "That transition is currently disallowed by the workflow setup in jira, try a different path to get there"
    return
  end
  form_data={"transition"=> { "id" => t_id}}
  rest_post_request("rest/api/latest/issue/#{args[0]}/transitions", form_data)
end
