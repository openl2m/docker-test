#############################
# OpenL2M Docker TEST Setup #
#############################

This directory contains the files to build a TEST instance of OpenL2M in a docker container, using "docker compose"

Note: you do NOT need to create a local git clone of the OpenL2M source code for this!

Below are steps that appear to work, with some additional testing hints...

Requirements:
    - a working docker host.
    - rights to create new containers.
    - working knowledge of using docker with compose.
    - git installed.

Test Setup Steps:
-----------------

1 - clone the docker compose config. We do in the directory "/opt/openl2m-docker-test/". Change as needed.

        mkdir -p /opt/openl2m-docker-test
        cd /opt/openl2m-docker-test
        git clone https://github.com/openl2m/docker-test .

2 - Run docker:

        sudo docker compose up

    This will take a while. It pulls images from docker repositories, downloads OpenL2M and then builds the application.
    If you get something like this, things are running:

        openl2m-1   |   Applying ...
        openl2m-1   | Updating Wireshark Ethernet database...
        openl2m-1   | Initialization done!
        openl2m-1   | OpenL2M will now start FOR TESTING PURPOSES ONLY!
        openl2m-1   | Performing system checks...
        <a few other lines...>

    Test from a browser, to "http://<your-host-ip>:8000/". If you get the login screen, things are running!

    Now hit Control-C, and run the containers as a daemon:

        sudo docker compose up -d

3 - Open a shell to the "openl2m" container, to create the superuser account:

        sudo docker exec -ti openl2m-testing-openl2m-1 bash

    In this new shell, run:

        python3.11 openl2m/manage.py createsuperuser

    and then:

        exit

    to get back to the host environment.

4 - go back to the web site, login and test as needed!

NOTE: this includes the documentation on the web site...

5 - stop when done. Run:

    sudo docker compose down


Other Docker Things:
--------------------
*NOTE*: Docker is a rich container environment, and showing all options is beyond the scope of this README.txt!

* if you want to test a specific testing branch of the code, you can start it as such:

    sudo BRANCH=<branch-name> docker compose up

* To clean up and rebuild the OpenL2M container to test new code (and leave the database intact):

    sudo docker compose build --no-cache openl2m

Be patient, this copies files again, and reinstalls the python dependencies...
Next run this to restart the containers:

    sudo docker compose up -d


* To clean up most *everything* related to OpenL2M, run:

    sudo docker compose down
    sudo docker image rm openl2m:test-build
    sudo docker volume rm openl2m-testing_postgres_data

  if you really want to cleanup everything (make sure you know what this does!):

    sudo docker system prune -a

Debugging and Editing INSIDE The Docker Image
---------------------------------------------
*NOTE*: This is NOT for the faint-of-heart! This is intended to help with debugging and troubleshooting only!
Please make sure you understand what you're doing before going this route!

* To EDIT configuration (or code) inside the OpenL2M container for testing:

run the container in daemon mode:

    sudo docker compose up -d

You can now open a shell into the OpenL2M container, and edit with 'nano' or 'vi' :

    sudo docker exec -ti openl2m-testing-openl2m-1 bash
    # you are now already in the /opt/openl2m directory, so paths are relative to that!

    # e.g. edit the configuration:
    vi openl2m/configuration.py

    # e.g. edit the snmp connector:
    vi switches/connect/snmp/connector.py

    # since the daemon is running Django with the built-in webserver, file changes take effect immediately!
    # refresh the page in your browser as needed...

    # when done:
    exit
    # and back in the server shell:
    sudo docker compose down

* To enable DEBUG MODE:

    sudo DEBUG=True docker compose up

  You can now see lots of console debug messages when you login to web site.

*NOTE:* if you bring up the containers with a different DEBUG value (or leave it off),
a new instance of the OpenL2M container is created and you will loose any edits you have done!

