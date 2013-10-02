Puppet
======

A puppet module to configure puppet.

Client Config
-------------

The client module will install the puppetlabs repo, configure the agent,
and ensure the agent is running.

Server Config
-------------

The master config will install the puppetlabs repo and ensure the following are configured and running:
* puppetmaster
* puppetdb
* puppet agent

Multi-master configs
--------------------

Multi master environments are not currently tested or supported.  (It might work?)

Independent master configs
--------------------------

With independent_agent = true the server module will install a puppet master instance
that is independent of the parent master.  The independent master will be able to serve
a different set of modules to a different set of clients.  The agent on the master will
remain a client of the parent master.
