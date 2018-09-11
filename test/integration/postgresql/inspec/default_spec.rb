psql_as_animal = 'env PGPASSWORD=raaaaaaaaaaaaaaaaaaaaaaaaaaaaah psql -h 127.0.0.1 -U animal -d postgres'
# psql_as_krusty = 'env PGPASSWORD=getbacktowork psql -h 127.0.0.1 -U krusty -d postgres'

describe command("#{psql_as_animal} -c 'SELECT * from pg_database;' | grep dataflounder") do
  its('exit_status') { should eq 0 }
end
