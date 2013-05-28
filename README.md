rets_validator
==============

Fetches the metadata from a RETS server and validates the return records using the
lookups and edit masks

Currently all of this is stored in a big ol' ugly hash.  Now that the POC is done,
I'll separate it into some classes next.


Just the rake task is wired up right now - hard coded for the Las Vegas
MLS data
```
(export RETS_USER=username;export RETS_PASSWORD=password;  rake import:rets)
```

will generate a rets.yml file and try to fetch 100 rows from the Las Vegas
MLS server validating them.

