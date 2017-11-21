# dockerscripts
A public home for scripts I use on docker hosts, starting on 2017-11-21

I have an esxi vmware host at home I use to hosts some websites, a reverse-proxy to protect the websites, a mail-server, a time-server and so on. Just for fun and profit and to learn and play around.

I used to host each website or service on one vm-machine based on Debian and such a host would typically be about 8gig. Using docker however, such a host is 200mb: thats 1/40 smaller. So I am slowly replacing vmware hosts based on some debian, with docker hosts. Such hosts, if implemented on for instance photon-OS (https://vmware.github.io/photon/) are typically 200mb.

However, docker-hosts are different in that you need to have a strategy to backup your configuration, logging and application-data. You can of course just save snapshots of the virtual hosts, but thats not the docker way.

So I have experimented by building a small deployment stategy with some scripting. This place is the home for this.

The following guides/scripts have a home here:
1. Howto setup a vmware-based small Linux host with Docker and docker-compose, in this case based on Photon-OS
2. An explanation on the data-challenge with docker deployment (without using orkestration). About backing up your data in configuration, logging and user/application -data 
3. Building a small framework to update docker images while still being able to roll back to a previous version

There's more, but later.
You can find me at https://www.hanscees.com/ or on twitter as @hanscees 
