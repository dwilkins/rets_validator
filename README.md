rets_validator
==============

Fetches the metadata from a RETS server and validates the return records using the
lookups and edit masks

## Setup the app
### Get the code
* git clone git@github.com:dwilkins/rets_validator.git
* cp config/database.yml.sample config/database.yml
* _edit config/database.yml to add your usernames and password__

### create database tables
* rake db:create db:migrate

### Create a sever row:
* insert the following columns
  * servername (what you want to refer to the server)
  * username - your login to the rets server
  * password - your password on the rets server
  * login_url - you were probably given this

```SQL
insert into rets\_servers
     (name,username,password,login_url) values
     ('yourservername','rets_username','rets_password','http://rets.server.example.com/rets/login');
```
## Fetch data

* rake rets:metadata[yourservername]
* rake rets:data[yourservername,query,repeat_count, class] - example:
  * `rake rets:data[yourservername,135=1990-01-01T00:00:00-1990-01-02T00:00:00,1,1]`
* rake rets:validate[yourservername]


## Coming Soon

* rake rets:migrate[yourservername] <---- Move the rets data into your table structure
