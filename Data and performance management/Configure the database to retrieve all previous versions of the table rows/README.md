# Configure the database to retrieve all previous versions of the table rows

## Wiki Page

The Wiki page can be found [here](https://sites.google.com/site/yetanotherocmoriginal/home/12-ocm/data-and-performance-management/configure-the-database-to-retrieve-all-previous-versions-of-the-table-rows)

## Sample Usage

```
sqlplus / as sysdba
SET SERVEROUTPUT ON
@switch_session_to_examples.sql
@create_default_fda_ts.sql
EXIT
```
