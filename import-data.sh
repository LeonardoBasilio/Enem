sleep 60
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P bi@123456 -d master -i setup.sql
