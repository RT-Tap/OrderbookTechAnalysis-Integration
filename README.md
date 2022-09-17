# Orderbook Techical Analysis

The goal of this project is to provide the full stack of a website where (a hopefully novel) method of technical analysis can be done on a securities orderbook, as well as accumulate hisorical financial data and provide traditional technical analysis tools.
Currently the project is being developed to use crypto currencies as the securities because we require a level 2/3 financial data stream and those tend to be prohibitively expensive for "traditonal" financial markets ( NYSE , NASDAQ etc)

## Orderbook technical analysis motivation
The main idea or goal of the project is to provide vizualization and tehcnical analysis tools to be done on the orderbook of a security.  Traditional technical analysis (think tradingview) is done on previous trades (candlestick charts) however the motivational idea behind this project is that additional information such as "sentiment" can be seen in a secutity's orderbook and how it changes.  The price levels at which orders are placed and whether those orders filled or cancelled can privide insight into the "sentiment" of traders. A very ignorant and high level overview of one type of insitutional high frequency algorithmic trading is that it is usually done based on orders in the orderbook of a secutriy and so the hope is that there may be conclusions that can be drawn about a security's market based on it's current orderbook and how the orderbook changes in combination with trades that have occured.

The idea arose after watching a [very interesting video about the 2010 flash crash](https://www.youtube.com/watch?v=_ZDEWVJan0s) and how it was perpetrated. The video skims over and gives you an idea of the methods behind most high frequency trading algorithms and how the trader exploited those methods (using spoofing).  Although there is no attempt at spoofing as it is illegal it does bear the question of whether there are conclusions that can be drawn from the orderbook.

---
# OrderbookTechAnalysis modules
## OrderbookTechAnalysis-Integration  -  This repo 
Integration of submodule repositories which together create the full stack.  It is mainly responsible for creating/restoring databases used in the deployment as well as creating the correct environment for the different elements/submodules to work together correctly.  Included in `docker-compose.yml` is phpmyadmin and mongoexpress to aid development.
  - docker-compose.yml : where most of the setup takes place, setting environment variables for security  
    - Note: loki is used for logging you may want to remove this section from each service
    - mongo-express & phpmyadmin: not needed but can come in usefull during development  

following only needed during first run - to restore or setup environment
  - ./setup : setup scripts for databases and environment
  - ./setup/secrets/* : basically where all of the setup takes place - this is where all your secret environment variables go. Most are self explanatory.
    - mongo-root-username.txt: root username
    - mongo-root-password.txt: password for root user  
    #### Optional (used for phpmyadmin / mongoexpress)
    - mongo-root-password-urlencoded.txt: only necessary if you plan to use mongoexpress and your password contains special characters such as @ or % - used to access (manipulate) database using mongo-express which uses a url to connect to database and therefore special characters need encoding  
    - mongo-user.txt: the user that will handle reads for the REST API and writes for the logger service (in the future this will be broken into two separate users)
    - mongo-user-password.txt: the password for the working user  
        - If `mongo-user.txt` and `mongo-user-password.txt` are not included the default values will be used
        - Alternatively `mongo-user.txt`/`mongo-user-password.txt` can be replaced with a file `/restore/restore-users` in the mongoDB container and populated with user(s) for different operations/databases for fine grain control over permissions as described below in the restore database section.  Essentially you could replace `mongo-user.txt`/`mongo-user-password.txt` with the following to get the same results (you may need to remove the secret from `docker-compose.yml` for it to run) 
            > mongo-user:mongo-user-password:demo-db:readWrite
  - if you dont know how secrets work: look under `secrets` section of docker-compose, each files content becomes a variable you use elsewhere. eg. place mongoDB admin password in the file `./setup/secrets/mongo-root-password.txt` and that is what will be used
## new instance vs restore
Setup in such a way that running fresh instance (database not initiated yet) will create the necessary environment to run all submodules.  Can also restore databases that already contain development/production information in them.  
### New instance
provide all the necessary docker secrets and everything should be created in working order.  
  - necessary secrets 
    - mongo-root-username
    - mongo-root-password
    - mongo-user
    - mongo-user-password
    - mysql-root-password
    - mysql-user
    - mysql-user-password
  - Necessary only if mongo-express and/or mhpmyadmin are used
    - mongo-url
    - mongo-root-password-url-encoded
### Restoring  
Mounting database dump(s) into `/restore` of either the mongoDB or mysql image it will restore that database automatically.
  - #### mongoDB
    - restore databases/users: mount all the databases (created using mongodump) you want restored into `/restore` ( mount locations already included in `docker-compose.yml`).  
      - If you have a list of users and permissions that you want restored/applied to these databases mount a file to `/restore/restore-users` that has the following format and it will be applied.  
          > username:password:database:db permissions (readWrite, read, write, etc.)   

          ex:    

          > admin:password:orderbook:readWrite  
        
          NOTE: do not include empty lines
      - This is only really necessary if you store user credentials and permissions on the admin database.  The alternate method is to store users of databases on the databases themselves and authenticate against that database, currently we are authenticating against the admin database and therefore this is included.  
    - backup: use mongodump
      ex: (will backup orderbook&trades database to a file named `orderbooktrades.dump`)
      > `docker exec mongoDB-financialData sh -c 'mongodump --authenticationDatabase admin -u mongo-root-username -p mongo-root-password --db orderbook&trades --archive' > orderbooktrades.dump`


  - #### mysql  
    - restore: Supply a mysql dump created using `mysqldump` to `/restore` on first run
      - like mongodb restore, if you have a list of users, databases and permissions for certain databases add them to `/restore/restore-users` and they will be applied.  Different username/database/permission combos must be placed as separate line items   
          > username:password:database:db permissions (select, update, etc.)   

        ex: (give user admin which uses the password password ALL PRIVILEGES on database users)   

          > admin:password:users:ALL PRIVILEGES  

           - currently there is no way to limit users to hosts using this method, they all use wildcard (%) as their host- this should change in the future
           - also can't limit users permissions to individual tables, permissions applied the entire database specified- this may change in the future
    - backup: create using `mysqldump`   
      ex. backs up database `orderbooktechanal` to a file named orderbooktechanal.dump (use `--all-databases` in place of `--databases orderbooktechanal` to back up everything)
      >  `docker exec orderbookTechAnalysisUsers mysqldump -uroot -psecret --databases orderbooktechanal > orderbooktechanal.dump` 



## OrderbookTechAnalysis-Logger
 A service that is run to coninuaosuly monitor a level 2 / 3 financial data stream, consolidate and log the information into a database.

## OrderbookTechAnalysis-RESTAPI
The REST API backend that supplies the frontend website with (financial) data for display as well as user data for login etc.

## OrderbookTechAnalysis-Frontend
Frontend website that is responsible for displaying data, the technical analysis tools etc.