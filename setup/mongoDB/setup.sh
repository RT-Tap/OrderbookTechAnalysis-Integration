#!/bin/bash
# check if restore directory has a mongo dump to restore if so restore any and all dumps then add users from a userlist
DIR="/restore"
rootusername=`cat /run/secrets/mongo_root_user`
rootpassword=`cat /run/secrets/mongo_root_pass`
# if [ "$(ls -A $DIR)" ]; then
if [ -d "$DIR" ]; then
     # put all dumps into an array to loop over and restore
     dbs=($(ls $DIR))
     for i in ${dbs[@]}; do
        if [$i != "restore-users"]; then
            echo "restoring ${i}..."
            mongorestore -u $rootusername -p $rootpassword --authenticationDatabase admin -d "${i}" "/restore/${i}"
        fi
     done
     if [ -f "$DIR/restore-users"]; then
        while IFS= read -r line; do
            userinfo=($(echo "$line" |  awk -F: '{print $1,$2,$3,$4}'))
            echo "Restoring/adding user ${userinfo[0]} to ${userinfo[2]} with permission ${userinfo[3]}"
            echo "db.createUser({ user: \"${userinfo[0]}\" , pwd: \"${userinfo[1]}\" , roles: [{ role:\"${userinfo[3]}\" , db: \"${userinfo[0]}\" }]" >> /docker-entrypoint-initdb.d/scripts/restoreUsers-ready.js
        done < $DIR/restore-users
        mongo < /docker-entrypoint-initdb.d/scripts/restoreUsers-ready.js
     fi
else
    echo "$DIR is Empty - populating with empty database and demo-database"
    echo "Adding users and their roles"
    if [[ -z "${WORKER_USERNAME}" && -z "${WORKER_PASSWORD}" ]]; then
        mongo < ./setup_scripts/createTestDBs.js 
        echo "db.createUser({ user: process.env.WORKER_USERNAME , pwd: process.env.WORKER_PASSWORD , roles: [{ role:\"readWrite\" , db: \"demo-orderbook\&trades\" }]" > /docker-entrypoint-initdb.d/scripts/restoreUsers-ready.js
        echo "db.createUser({ user: process.env.WORKER_USERNAME , pwd: process.env.WORKER_PASSWORD , roles: [{ role:\"readWrite\" , db: \"orderbook\&trades\" }]" > /docker-entrypoint-initdb.d/scripts/restoreUsers-ready.js
        mongo < /docker-entrypoint-initdb.d/scripts/restoreUsers-ready.js
    else
        echo "db.createUser({ user: \"mainworker\" , pwd: \"13Bm4vP5P45kh\" , roles: [{ role:\"readWrite\" , db: \"demo-orderbook\&trades\" }]" > /docker-entrypoint-initdb.d/scripts/restoreUsers-ready.js
        echo "db.createUser({ user: \"mainworker\" , pwd: \"13Bm4vP5P45kh\" , roles: [{ role:\"readWrite\" , db: \"orderbook\&trades\" }]" > /docker-entrypoint-initdb.d/scripts/restoreUsers-ready.js
        mongo < /docker-entrypoint-initdb.d/scripts/restoreUsers-ready.js
    fi
fi
