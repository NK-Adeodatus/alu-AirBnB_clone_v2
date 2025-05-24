#!/usr/bin/python3
""" Fabric script that distributes an archive to your web servers.
    The script should do the following:
    - create versions folder
    - compress web_static folder
    - create archive file"""

from fabric.api import local
from datetime import datetime


def do_pack():
    """Generates a .tgz archive from the contents of the web_static folder"""
    date = datetime.now().strftime("%Y%m%d%H%M%S")
    try:
        filename = "versions/web_static_{}.tgz".format(date)
        local("mkdir -p versions")
        local("tar -cvzf {} web_static".format(filename))
        return filename
    except:
        return None
