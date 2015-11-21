#
# Cookbook Name:: packetbeat
# Recipe:: install
#
# Copyright 2015, Virender Khatri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node['packetbeat']['packages'].each do |p|
  package p
end

if node['platform_family'] == 'debian' && node['kernel']['machine'] == 'x86_64'
  arch_name = 'amd64'
else
  arch_name = node['kernel']['machine']
end

if node['packetbeat']['package_url'] == 'auto'
  package_url = value_for_platform_family(
    'debian' => "https://download.elasticsearch.org/beats/packetbeat/packetbeat_#{node['packetbeat']['version']}_#{arch_name}.deb",
    %w(rhel fedora) => "https://download.elasticsearch.org/beats/packetbeat/packetbeat-#{node['packetbeat']['version']}-#{arch_name}.rpm"
  )
else
  package_url = node['packetbeat']['package_url']
end

package_file = ::File.join(Chef::Config[:file_cache_path], ::File.basename(package_url))

remote_file package_file do
  source package_url
  not_if { ::File.exist?(package_file) }
end

package 'packetbeat' do
  source package_file
  options '--force-confdef --force-confold' if node['platform_family'] == 'debian'
  provider Chef::Provider::Package::Dpkg if node['platform_family'] == 'debian'
end
