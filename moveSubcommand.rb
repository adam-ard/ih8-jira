require File.expand_path(File.dirname(__FILE__) + '/commonSubcommand')

$move_usage = 'Usage: ih8-jira move <issue_id> <target_section>'
$move_argTable = []

def get_transistion_id(id, target)
  data, err=rest_get_request("rest/api/latest/issue/#{id}/transitions")
  if err
    return nil
  end

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
    return
  end
  form_data={"transition"=> { "id" => t_id}}
  data,err=rest_post_request("rest/api/latest/issue/#{args[0]}/transitions", form_data)
  return !err
end
