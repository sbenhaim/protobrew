# This files defines commands for deploying and administering the wiki
#
# In order to execute stuff here, you will need to install fabric. On
# Ubuntu you can do this by simply doing:
#
#     $ sudo apt-get install fabric
#
# Commands defined here can be run by doing:
#
#     $ fab <command>
#
# Now, RTFM.  http://docs.fabfile.org/en/1.4.2/tutorial.html
#
import os
from fabric.api import run, local, abort, settings, lcd, cd, require, env, put, sudo

APP_LOCATION = "/srv/node/humonwiki"
THIS_DIR = os.path.dirname(__file__)
BUILD_DIR = os.path.join(THIS_DIR, ".build")
DEMETEORIZED_DIR = os.path.join(BUILD_DIR, ".demeteorized")


def staging():
    # Prefix used to point at staging environment
    #
    # Example: fab staging deploy
    #
    env.user = 'humonwiki'
    env.hosts = ['checksum.io', ]
    env.is_configured = True


def hostconfig():
    """Run against a server to perform the initia setup

    Exampele::

        $ fab staging hostconfig

    These scripts assume that the target server for deployment is running
    Debian 7.0 "wheezy"

    """
    with settings(user='root'):
        # install supervisord
        run("apt-get install supervisor")
        with settings(warn_only=True):
            # for some reason, this gives a non-zero return even when it succeeds
            run("service supervisor restart")

        # install nginx
        run("apt-get install nginx")
        run("service nginx restart")

        # install nodejs and npm from backports
        run("echo 'deb http://ftp.us.debian.org/debian wheezy-backports main' > "
             "/etc/apt/sources.list.d/wheezy-backports.list")
        run("apt-get update")
        run("apt-get install nodejs curl")
        run("curl https://npmjs.org/install.sh | sh")

        # install mongodb
        run("apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10")
        run("echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' > "
             "/etc/apt/sources.list.d/mongodb.list")
        run("apt-get update")
        run("apt-get install mongodb-10gen")
        run("service mongodb restart")


def install_configs():
    with settings(user='root'):
        put(".deploy/nginx.conf", "/etc/nginx/nginx.conf")  # TODO: may not want to do this directory to nginx.conf
        put(".deploy/runwiki.sh", "/srv/node/humonwiki/runwiki.sh")
        put(".deploy/supervisord.conf", "/etc/supervisor/conf.d/humonwiki.conf")
        run("chmod +x /srv/node/humonwiki/runwiki.sh")


def build_bundle():
    # This build step uses demeteorizer to package together a set
    # of build artifacts that is our meteor appliation with all
    # dependencies which can be run as if it were just a node app
    with settings(warn_only=True):
        if local('which demeteorizer').failed:
            print "-- Demeteroizer is not installed, but this is required to build"
            print "-- Please install demeteorizer:"
            print "--  $ sudo -H npm install -g demeteorizer"
            print "--"
            abort("Cannot continue without demeteorizer")

    # we have demeteorizer, do some demteorization
    demdir = DEMETEORIZED_DIR
    local("rm -rf {demdir}".format(demdir=demdir))
    local("demeteorizer -o {demdir}".format(demdir=demdir))

    # build a tarball that we can push
    with lcd(os.path.join(BUILD_DIR, ".demeteorized")):
        local("tar czvf ../humonwiki-demeteorized.tar.gz *")


def push_bundle():
    # Push the tarball to the remote machine
    put(os.path.join(BUILD_DIR, "humonwiki-demeteorized.tar.gz"),
        "/tmp/humonwiki-demeteorized.tar.gz")


def unpack_bundle():
    # Unpack the deployed demeteorized bundle on the target system
    run("rm -rf /srv/node/humonwiki.old")
    run("install -d /srv/node/humonwiki")
    run("mv /srv/node/humonwiki /srv/node/humonwiki.old")
    run("install -d /srv/node/humonwiki")
    run("tar xzvf /tmp/humonwiki-demeteorized.tar.gz -C /srv/node/humonwiki/")


def stop_services():
    # note: we do not stop nginx, just reload the config later
    with settings(user='root'):
        run("/etc/init.d/supervisor stop")


def start_services():
    with settings(user='root'):
        with settings(warn_only=True):
            run("/etc/init.d/supervisor start")
        run("/etc/init.d/nginx reload")


def deploy():
    if not hasattr(env, 'is_configured'):
        abort("Must specify either local or production before deploy (e.g. fab staging deploy)")

    build_bundle()
    push_bundle()
    stop_services()
    unpack_bundle()
    install_configs()
    start_services()

