# Test OpenL2M using Docker Compose

This is a Docker Compose configuration to quickly test OpenL2M (NOT for production use!)

## OpenL2M Docker TEST Setup

These files can be used to build a TEST instance of OpenL2M in a docker container,
using "docker compose"

Note: you do NOT need to create a local git clone of the OpenL2M source code for this!

Below are steps that appear to work, with some additional testing hints...

Requirements:
    - a working docker host.
    - rights to "sudo" or otherwize run docker, create new containers, etc.
    - some working knowledge of using docker with compose.
    - git installed.

### Test Setup Steps

1 - clone the docker compose config. We use the directory "/opt/openl2m-docker-test/".
    Change as needed.
```
        sudo mkdir -p /opt/openl2m-docker-test
        cd /opt/openl2m-docker-test
        sudo git clone https://github.com/openl2m/docker-test .
```

2 - Copy the compose.override.example.yaml file:
```
        cp compose.override.example.yaml compose.override.yaml
```

and edit this file, if you need to change passwords or public ports.

3 - Run docker:
```
        sudo docker compose up
```

This will take a while. It pulls images from docker repositories, downloads OpenL2M
and then builds the application.

Note: this will map the test version of OpenL2M to port 8000 on your Docker host.
If you need to use a different port, please see the file "compose.override.example.yaml"

If you get something like this, things are running:
```
        openl2m-1   |   Applying ...
        openl2m-1   | Updating Wireshark Ethernet database...
        openl2m-1   | Initialization done!
        openl2m-1   | OpenL2M will now start FOR TESTING PURPOSES ONLY!
        openl2m-1   | Performing system checks...
        <a few other lines...>
```

Test from a browser, to "http://<your-host-ip>:8000/". If you get the login screen,
things are running!

Now hit Control-C, and run the containers as a daemon:
```
        sudo docker compose up -d
```

4 - Open a shell to the "openl2m" container, to create the superuser account:
```
        sudo docker exec -ti openl2m-testing-openl2m-1 bash
```

In this new shell, run:
```
        python3.11 openl2m/manage.py createsuperuser
```

follow the prompts, and when done:
```
        exit
```
    to get back to the host environment.

5 - go back to the web site, login and test as needed!

NOTE: this includes the documentation on the web site...

6 - stop when done. Run:
```
    sudo docker compose down
```

Other Docker Things:
--------------------
*NOTE*: Docker is a rich container environment, and showing all options is beyond the scope
of this README.txt!

* if you want to test a specific testing branch of OpenL2M, edit the compose.override.yaml file:
```
    - BRANCH=<branch-name>
```

* To clean up and rebuild the OpenL2M container to test new code (and leave the database intact):
```
    sudo docker compose build --no-cache openl2m
```

Be patient, this copies files again, and reinstalls the python dependencies...
Next run this to restart the containers:
```
    sudo docker compose up -d
```

* To clean up most *everything* related to OpenL2M, run:
```
    sudo docker compose down
    sudo docker image rm openl2m:test-build
    sudo docker volume rm openl2m-testing_postgres_data
```

If you really want to cleanup everything (make sure you know what this does!):
```
    sudo docker system prune -a
```

Debugging
---------

*NOTE*: This is NOT for the faint-of-heart! This is intended to help with debugging and troubleshooting only!
Please make sure you understand what you're doing before going this route!

* To enable DEBUG MODE, edit the compose.override.yaml file:
```
    - DEBUG=True
```

* To EDIT configuration (or code) inside the OpenL2M container for testing:

run the container in daemon mode:
```
    sudo docker compose up -d
```

You can now open a shell into the OpenL2M container, and edit with 'nano' or 'vi' :

```
    sudo docker exec -ti openl2m-testing-openl2m-1 bash
    # you are now already in the /opt/openl2m directory, so paths are relative to that!

    # e.g. edit the configuration:
    vi openl2m/configuration.py

    # since the daemon is running Django with the built-in webserver, file changes take effect immediately!
    # refresh the page in your browser as needed...

    # when done:
    exit
    # and back in the server shell:
    sudo docker compose down
```

Restart and you can now see lots of console debug messages when you login to web site.
