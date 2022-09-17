# Orderbook Techical Analysis

The goal of this project is to provide the full stack of a website where (a hopefully novel) method of technical analysis can be done on a securities orderbook, as well as accumulate hisorical financial data and provide traditional technical analysis tools.
Currently the project is being developed to use crypto currencies as the securities because we require a level 2/3 financial data stream and those tend to be prohibitively expensive for "traditonal" financial markets ( NYSE , NASDAQ etc)

## Orderbook technical analysis motivation
The main idea or goal of the project is to provide vizualization and tehcnical analysis tools to be done on the orderbook of a security.  Traditional technical analysis (think tradingview) is done on previous trades (candlestick charts) however the motivational idea behind this project is that additional information such as "sentiment" can be seen in a secutity's orderbook and how it changes.  The price levels at which orders are placed and whether those orders filled or cancelled can privide insight into the "sentiment" of traders. A very ignorant and high level overview of one type of insitutional high frequency algorithmic trading is that it is usually done based on orders in the orderbook of a secutriy and so the hope is that there may be conclusions that can be drawn about a security's market based on it's current orderbook and how the orderbook changes in combination with trades that have occured.

The idea arose after watching a [very interesting video about the 2010 flash crash](https://www.youtube.com/watch?v=_ZDEWVJan0s) and how it was perpetrated. The video skims over and gives you an idea of the methods behind most high frequency trading algorithms and how the trader exploited those methods (using spoofing).  Although there is no attempt at spoofing as it is illegal it does bear the question of whether there are conclusions that can be drawn from the orderbook.

---
# OrderbookTechAnalysis modules
## OrderbookTechAnalysis-Integration  -  This repo 
Integration of submodule repositories which together create the full stack.  It is mainly responsible for creating/restoring databases used in the deployment as well as creating the correct environment for the different elements/submodules to work together correctly. 
### Start/Run: 
  - Set necessary docker secrets in `/steup/secrets`, most are sefl-explanatory
    - mongo_root_user.txt  
    - mongo_root_pass.txt  
    - mongo_worker.txt: 
    - mongo_worker_password.txt: 
    - mysql_root_pass.txt: 
    - mysql-user.txt: 
    - mysql-user-password.txt
    > if you dont know how secrets work: look under `secrets` section of docker-compose, each files content becomes a variable you use elsewhere. eg. place mongoDB admin password in the file `./setup/secrets/mongo-root-password.txt` and that is what will be used
  -  `docker-compose up -d`   


## First run/New instance vs restore
This repo/inegration is setup in such a way that running for the first time will automatically create the necessary environment and databases (with some test data) to run all submodules which consistue the actual applocation.  If instead you want to restore databases that already contain development/production information in them, the setup scripts will take care of that as well you just need to make them available.  
### New Instance
Delete everything in the directory being mounted to hold the database (or the volume if you change `docker-compose.yml` to use a volume instead)
### Restoring  
Mount database dump(s) into `/restore` directory of either the mongoDB or mysql image and setup scripts it will restore that database automatically.
  - #### mongoDB
    - restore: mount database (created using mongodump) you want restored into `/restore` ( already included in `docker-compose.yml`).
      - If you have a list of database users and permissions that you want restored/applied to databases mount the file to `/restore/restore-users`.  This file requires the following format to be applied correctly.  
          > username:password:database:db permissions (readWrite, read, write, etc.)   

          ex:    

          > admin:password:orderbook:readWrite  
        
          NOTE: do not include empty line(s at the end), it will cause an issue during setup.
      - This is NOT currently required.  Currently included as a feature but intended for future changes to replace `mongo-user`.  The intention is to switch from one database user that does everything to multiple with different roles (e.g. one user for the logger submodule given only write permission to log data and another user for REST API with only read permissions). These permissions/roles are stored on the admin database and therefore user authentication is done against admin database.
  
    - backup: Use `mongodump`
      ex: (will backup orderbook&trades database to a file named `orderbooktrades.dump`)
      > `docker exec mongoDB-financialData sh -c 'mongodump --authenticationDatabase admin -u mongo-root-username -p mongo-root-password --db orderbook&trades --archive' > orderbooktrades.dump`


  - #### mysql  
    - restore: Supply a mysql dump created using `mysqldump` to `/restore` on new instance
      - like mongodb restore, if you have a list of users, databases and permissions for certain databases add them to `/restore/restore-users` and they will be applied.  
      - Different username/database/permission combos must be placed as separate line items with the following format  
          > username:password:database:db permissions (select, update, etc.)   

        ex: admin user which uses the password `password` and given ALL PRIVILEGES on database users  

          > admin:password:users:ALL PRIVILEGES  

           - currently there is no way to limit users to specific hosts using this method, they all use wildcard (%) as their host. Intended to be changed in the future.
           - also can't limit users permissions to individual tables, permissions applied the entire database specified
    - backup: Use `mysqldump`   
      ex. backs up database `orderbooktechanal` to a file named `orderbooktechanal.dump` (use `--all-databases` in place of `--databases orderbooktechanal` to back up everything)
      >  `docker exec orderbookTechAnalysisUsers mysqldump -uroot -psecret --databases orderbooktechanal > orderbooktechanal.dump` 



## OrderbookTechAnalysis-Logger
A service that is run to coninuaosuly monitor a level 2 / 3 financial data stream, consolidate and log the information into a database.

## OrderbookTechAnalysis-RESTAPI
The REST API backend that supplies the frontend website with (financial) data for display as well as user data for login etc.

## OrderbookTechAnalysis-Frontend
Frontend website that is responsible for displaying data, the technical analysis tools etc.