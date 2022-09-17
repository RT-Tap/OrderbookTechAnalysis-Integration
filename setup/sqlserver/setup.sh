#!/bin/bash
DIR="/restore"
# if [ "$(ls -A $DIR)" ]; then
if [ -d "$DIR" ]; then
    dbs=($(ls $DIR))
    for i in ${dbs[@]}; do
        if [ $i != "restore-users" ]; then
            echo "restoring ${i}..."
            mysql -uroot -p"$MARIADB_ROOT_PASSWORD" < "/restore/${i}"
        fi
    done
    if [ -f "$DIR/restore-users"]; then
        while IFS= read -r line; do
            userinfo=($(echo "$line" |  awk -F: '{print $1,$2,$3,$4}'))
            echo "Restoring/adding user ${userinfo[0]} to ${userinfo[2]} with permission ${userinfo[3]}"
            mysql -uroot -p"$MARIADB_ROOT_PASSWORD" < "CREATE USER '${userinfo[0]}'@'%' IDENTIFIED BY '${userinfo[1]}'; GRANT ${userinfo[3]} ON ${userinfo[2]} . * TO '${userinfo[0]}'@'%';"
            mysql -uroot -p"$MARIADB_ROOT_PASSWORD" < " FLUSH PRIVILEGES;"
        done < $DIR/restore-users
    fi
else
    mysql -uroot -p"$MARIADB_ROOT_PASSWORD" < /docker-entrypoint-initdb.d/initSQLDB
    mysql -uroot -p"$MARIADB_ROOT_PASSWORD" < "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; GRANT ALL PRIVILEGES ON orderbooktechanal . * TO '$MYSQL_USER'@'%'; FLUSH PRIVILEGES;"
fi