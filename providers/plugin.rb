def ruby_bin
  node[:sensu][:use_embedded_ruby] ? "/usr/bin/ruby" : "/opt/sensu/embedded/bin/ruby"
end

def plugins_dir
  "#{node[:sensu][:directory]}/plugins"
end

def community_plugins_dir
  "#{plugins_dir}/sensu-community-plugins"
end

def escape_sed str
  str.gsub(/\//, '\/')
end


action :install do
  escaped_env = escape_sed("/usr/bin/env")
  escaped_ruby = escape_sed(ruby_bin)

  unless ::File.exist?("#{community_plugins_dir}/#{new_resource.kind}/#{new_resource.name}")
    Chef::Log.fatal "#{community_plugins_dir}/#{new_resource.kind}/#{new_resource.name} is not exist"
    raise
  end

  bash new_resource.name do
    user "root"
    cwd node[:sensu][:directory]
    code <<-EOH
    sed -e "s/#{escaped_env} ruby/#{escaped_env} #{escaped_ruby}/g" "#{community_plugins_dir}/#{new_resource.kind}/#{new_resource.name}" > "#{plugins_dir}/#{new_resource.name}"
    chmod 755 "#{plugins_dir}/#{new_resource.name}"
EOH
    not_if { ::File.exist?("#{plugins_dir}/#{new_resource.name}") }
  end
end

action :remove do
  file "#{plugins_dir}/#{new_resource.name}" do
    action :delete
  end
end
