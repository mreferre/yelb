require 'pg'
require 'pg_ext'

def restaurantsdbread(restaurant)
    con = PG.connect  :host => $yelbdbhost,
                      :port => $yelbdbport,
                      :dbname => 'yelbdatabase',
                      :user => 'postgres',
                      :password => 'postgres_password'
    con.prepare('statement1', 'SELECT count FROM restaurants WHERE name =  $1')
    res = con.exec_prepared('statement1', [ restaurant ])
    con.close
    return res.getvalue(0,0)
end 
