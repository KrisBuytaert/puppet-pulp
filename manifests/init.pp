# Class: pulp
#
# This module manages pulp
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]



class pulp {

  package {
                "pulp":
                        ensure => "present";
                "pulp-admin":
                        ensure => "present";
          }


   
  service { 
                  "httpd":
                      ensure => "running";

# When you run into AutoReconnect: could not find master/primary
# It means mongodb ain't running 

                  "mongod":
                      ensure => "running";
	
		"pulp-server":
                      ensure => "running",
		      require => File['/var/lib/mongodb/'];
	
        }
   
   file {"/var/lib/mongodb/":
	require => Exec["pulpinit"]
   } 

   exec { "pulpinit":
	
 	command => "/etc/init.d/pulp-server init ",
    	refreshonly => true,
    	creates => "/var/lib/mongodb",
   }

   

}
