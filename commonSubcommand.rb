require 'json'
require 'net/http'
require 'yaml'

$auth_username=ENV['IH8_JIRA_USERNAME']
$auth_password=ENV['IH8_JIRA_PASSWORD']
$IH8_JIRA_CONFIG = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/config.yml'))
$jira_server=$IH8_JIRA_CONFIG['ih8-jira']['server']
$project=$IH8_JIRA_CONFIG['ih8-jira']['project']
$project_key=$IH8_JIRA_CONFIG['ih8-jira']['project_key']

# takes two hashes and recursively merges them
def update(d,u)
  u.each do | k, v |
    if v.is_a?(Hash)
      d[k] =  update(d[k] || {}, v)
    else
      d[k] = u[k]
    end
  end
  return d
end

def rest_request(cmd)
  uri = URI("#{$jira_server}/#{cmd}")

  req=yield(uri.request_uri)
  req["Content-Type"]="application/json"
  req.basic_auth($auth_username, $auth_password)
  
  client=Net::HTTP.new(uri.hostname, uri.port)
  client.use_ssl = true
  res=client.request(req)
  if res.body
    JSON.parse(res.body)
  else
    {}
  end
end

def rest_get_request(cmd)
  rest_request(cmd) do | request_uri |
    Net::HTTP::Get.new(request_uri)
  end
end

def rest_delete_request(cmd)
  rest_request(cmd) do | request_uri |
    Net::HTTP::Delete.new(request_uri)
  end
end

def rest_post_request(cmd, data={})
  rest_request(cmd) do | request_uri |
    req = Net::HTTP::Post.new(request_uri)
    unless data == {}
      req.body = data.to_json
    end
    req
  end
end

def rest_put_request(cmd, data={})
  rest_request(cmd) do | request_uri |
    req = Net::HTTP::Put.new(request_uri)
    unless data == {}
      req.body = data.to_json
    end
    req
  end
end
