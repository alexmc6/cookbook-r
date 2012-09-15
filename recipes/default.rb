#
# Author:: Steven Danna(<steve@opscode.com>)
# Cookbook Name:: R
# Recipe:: default
#
# Copyright 2011, Opscode, Inc
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

r_version = node['R']['version']

case node['platform']
when "ubuntu", "debian"
  # On Ubuntu or Debian we install via the
  # CRAN apt repository.
  include_recipe "apt"

  # Apt installs R here.  Needed for config template below
  r_install_dir = "/usr/lib/R"

  if node['platform'] == 'debian'
    distro_name = "#{node['lsb']['codename']}-cran/"
    keyserver_url = "pgp.mit.edu"
    key_id = "381BA480"
  else
    distro_name = "#{node['lsb']['codename']}/"
    keyserver_url = "keyserver.ubuntu.com"
    key_id = "E084DAB9"
  end

  apt_repository "cran-apt-repo" do
    uri "#{node['R']['cran_mirror']}/bin/linux/#{node['platform']}"
    distribution distro_name
    keyserver keyserver_url
    key key_id
    action :add
  end

  package 'r-base' do
    version r_version
    action :install
  end

  package 'r-base-dev' do
    version r_version
    action :install
  end

when "centos", "redhat", 'scientific', 'amazon', 'oracle'
  # On CentOs and RHEL we use epel
  include_recipe "yum::epel"

  package "R" do
    version r_version
    action :install
  end

  # By default, source install places R here.
  # Needed for config template below
  is_64 = node['kernel']['machine'] =~ /x86_64/
  r_install_dir = is_64 ? "/usr/lib64/R": "/usr/lib/R"

else
  Chef::Log.info("This cookbook is not yet supported on #{node['platform']}")
end

# Setting the default CRAN mirror makes
# remote administration of R much easier.
template "#{r_install_dir}/etc/Rprofile.site" do
  mode "777"
  variables( :cran_mirror => node['R']['cran_mirror'])
end
