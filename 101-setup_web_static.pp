# alu-Airbnb_clone_v2 - Deploy static, task 5. Puppet for setup

# general update before nginx install
exec { 'general update':
  path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  user    => 'root',
  command => 'apt-get -y update',
}

# install nginx
package { 'nginx':
  ensure  => installed,
  require => Exec['general update'],
}

# start nginx service
service { 'nginx':
  ensure  => running,
}

# build directories (parents are not automatically generated by puppet)
# recrusive ownership of /data/ to ubuntu:ubuntu
file { [ '/data',
  '/data/web_static',
  '/data/web_static/releases',
  '/data/web_static/releases/test',
  '/data/web_static/shared', ]:
  ensure  => directory,
  owner   => 'ubuntu',
  group   => 'ubuntu',
  recurse => true,
}

# create sample web content
$content = "<html>\n  <head>\n  </head>\n  <body>\n    Holberton School\n  </body>\n</html>\n"
file { 'sample web content':
  ensure  => file,
  path    => '/data/web_static/releases/test/index.html',
  owner   => 'ubuntu',
  group   => 'ubuntu',
  content => $content,
  require => File['/data/web_static/releases/test'],
}

# create symlink /data/web_static/current -> /data/web_static/releases/test/
file { 'symbolic link to test/ dir':
  ensure  => link,
  path    => '/data/web_static/current',
  owner   => 'ubuntu',
  group   => 'ubuntu',
  replace => true,
  target  => '/data/web_static/releases/test',
  require => File['sample web content'],
}

# backup nginx.conf
exec { 'backup nginx config':
  path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  user    => 'root',
  command => 'cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bup',
  require => File['symbolic link to test/ dir'],
}

# update nginx config to serve content from web_static/
# (can't use file_line due to puppet stblib not being installed on test container)
exec { 'update nginx config':
  path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  user    => 'root',
  unless  => 'grep -q "location \/hbnb_static\/ {$" /etc/nginx/sites-available/default',
  command => 'sed -i "0,/^\tlocation \/ {$/s/^\tlocation \/ {$/\tlocation \/hbnb_static\/ {\n\t\talias \/data\/web_static\/current\/;\n\t\tautoindex off;\n\t}\n\n\tlocation \/ {/" /etc/nginx/sites-available/default',
  require => Exec['backup nginx config'],
}

# reload nginx with new config (must use exec as service can only restart, not reload)
exec { 'reload nginx':
  path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  user    => 'root',
  command => 'service nginx reload',
  require => Exec['update nginx config'],
}
