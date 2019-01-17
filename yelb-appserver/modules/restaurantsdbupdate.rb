def restaurantsdbupdate(restaurant)
    con = PG.connect  :host => $yelbdbhost,
                      :port => $yelbdbport,
                      :dbname => 'yelbdatabase',
                      :user => 'postgres',
                      :password => 'postgres_password'
    con.prepare('statement1', 'UPDATE restaurants SET count = count +1 WHERE name = $1')
    res = con.exec_prepared('statement1', [ restaurant ])
    con.close
end 
