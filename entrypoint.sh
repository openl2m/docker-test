#!/bin/bash

#
# docker entrypoint file for testing OpenL2M.
# Note: this is NOT meant to become a production setup!!!
#

echo "Starting initialization..."

# the directory where the Django projec starts:
BASEDIR=/opt/openl2m/openl2m
# Python version to install and use:
PYTHON3=python3.11

echo "Working dir:"
pwd

# only copy new config first time:
if ! [ -f $BASEDIR/openl2m/configuration.py ]; then
    echo "Creating base configuration.py"
    cp $BASEDIR/openl2m/configuration.example.py $BASEDIR/openl2m/configuration.py

    SECRET_KEY="${SECRET_KEY:-$($PYTHON3 $BASEDIR/generate_secret_key.py)}"
    echo "SECRET_KEY = '$SECRET_KEY'" >> $BASEDIR/openl2m/configuration.py
    echo "DEBUG = ${DEBUG:-False}" >> $BASEDIR/openl2m/configuration.py

    cat <<EOF >> $BASEDIR/openl2m/configuration.py
DATABASE = {
    'NAME': '${DB_NAME:-openl2m}',      # Database name
    'USER': '${DB_USER:-openl2m}',      # PostgreSQL username
    'PASSWORD': '${DB_PASS:-changeme}', # PostgreSQL password
    'HOST': '${DB_HOST:-localhost}',               # Database server
    'PORT': '${DB_PORT:-}',         # Database port (leave blank for default)
}
EOF

fi

# update from git
echo "Updating from git..."
git pull

echo "Checking out '$BRANCH' code branch..."
git checkout $BRANCH

echo "Running OpenL2M Database updates..."
$PYTHON3 openl2m/manage.py migrate

# Recompile the documentation, these become Django static files!
echo "Updating HTML documentation..."
cd docs
make clean
make html
cd ..

echo "Collecting static files..."
$PYTHON3 openl2m/manage.py collectstatic --no-input
eval $COMMAND || exit 1

echo "Removing stale content types..."
$PYTHON3 openl2m/manage.py remove_stale_contenttypes --no-input

echo "Removing expired user sessions..."
$PYTHON3 openl2m/manage.py clearsessions

echo "Updating Wireshark Ethernet database..."
$PYTHON3 openl2m/lib/manuf/manuf/manuf.py --update

echo "Initialization done!"

echo "OpenL2M will now start FOR TESTING PURPOSES ONLY!"
$PYTHON3 openl2m/manage.py runserver 0:8000 --insecure
