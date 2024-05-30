wget http://ddnet.org/players.msgpack -O ../web/players.msgpack
cd data
rm -rf ddnet*
wget https://ddnet.org/stats/ddnet.sqlite.zip
unzip ddnet.sqlite.zip

# sqlite to csv
sqlite3 -header -csv ddnet.sqlite ".output maps.csv" "SELECT map, server, points, stars, mapper, IIF(timestamp = '0000-00-00 00:00:00', '', timestamp) AS timestamp FROM maps ORDER BY map"
sqlite3 -header -csv ddnet.sqlite ".output mapinfo.csv" "SELECT * FROM mapinfo ORDER BY map" 
sqlite3 -header -csv ddnet.sqlite ".output teamrace.csv" "SELECT map, name, printf('%.2f', time) as time, timestamp, hex(id) as hex FROM teamrace ORDER BY map, name, time, timestamp, id"
sqlite3 -header -csv ddnet.sqlite ".output race.csv" " \
    SELECT map, name, printf('%.2f', time) as time, timestamp, server, \
    printf('%.2f', cp1), printf('%.2f', cp2), printf('%.2f', cp3), \
    printf('%.2f', cp4), printf('%.2f', cp5), printf('%.2f', cp6), \
    printf('%.2f', cp7), printf('%.2f', cp8), printf('%.2f', cp9), \
    printf('%.2f', cp10), printf('%.2f', cp11), printf('%.2f', cp12), \
    printf('%.2f', cp13), printf('%.2f', cp14), printf('%.2f', cp15), \
    printf('%.2f', cp16), printf('%.2f', cp17), printf('%.2f', cp18), \
    printf('%.2f', cp19), printf('%.2f', cp20), printf('%.2f', cp21), \
    printf('%.2f', cp22), printf('%.2f', cp23), printf('%.2f', cp24), \
    printf('%.2f', cp25) FROM race ORDER BY map, name, time, timestamp, server"

# postgres to csv
PGPASSWORD=ddstats psql -U ddstats -h 127.0.0.1 -c "\COPY (SELECT * FROM maps ORDER BY map COLLATE \"C\") TO 'maps-psql.csv' CSV HEADER"
PGPASSWORD=ddstats psql -U ddstats -h 127.0.0.1 -c "\COPY (SELECT map, width, height, death::int, through::int, jump::int, dfreeze::int, ehook_start::int, hit_end::int, solo_start::int, tele_gun::int, tele_grenade::int, tele_laser::int, npc_start::int, super_start::int, jetpack_start::int, walljump::int, nph_start::int, weapon_shotgun::int, weapon_grenade::int, powerup_ninja::int, weapon_rifle::int, laser_stop::int, crazy_shotgun::int, dragger::int, door::int, switch_timed::int, switch::int, stop::int, through_all::int, tune::int, oldlaser::int, teleinevil::int, telein::int, telecheck::int, teleinweapon::int, teleinhook::int, checkpoint_first::int, bonus::int, boost::int, plasmaf::int, plasmae::int, plasmau::int FROM mapinfo ORDER BY map COLLATE \"C\") TO 'mapinfo-psql.csv' CSV HEADER"
PGPASSWORD=ddstats psql -U ddstats -h 127.0.0.1 -c "\COPY (SELECT map, name, ROUND(time::numeric, 2) as time, timestamp, UPPER(encode(id::bytea, 'hex')) as hex FROM teamrace ORDER BY map COLLATE \"C\", name COLLATE \"C\", time, timestamp, id) TO 'teamrace-psql.csv' CSV HEADER"
PGPASSWORD=ddstats psql -U ddstats -h 127.0.0.1 -c "\COPY (SELECT map, name, ROUND(time::numeric, 2), timestamp, server, \
    ROUND(cp1::numeric, 2), ROUND(cp2::numeric, 2), ROUND(cp3::numeric, 2), \
    ROUND(cp4::numeric, 2), ROUND(cp5::numeric, 2), ROUND(cp6::numeric, 2), ROUND(cp7::numeric, 2), \
    ROUND(cp8::numeric, 2), ROUND(cp9::numeric, 2), ROUND(cp10::numeric, 2), ROUND(cp11::numeric, 2), \
    ROUND(cp12::numeric, 2), ROUND(cp13::numeric, 2), ROUND(cp14::numeric, 2), ROUND(cp15::numeric, 2), \
    ROUND(cp16::numeric, 2), ROUND(cp17::numeric, 2), ROUND(cp18::numeric, 2), ROUND(cp19::numeric, 2), \
    ROUND(cp20::numeric, 2), ROUND(cp21::numeric, 2), ROUND(cp22::numeric, 2), ROUND(cp23::numeric, 2), \
    ROUND(cp24::numeric, 2), ROUND(cp25::numeric, 2) \
    FROM race ORDER BY map COLLATE \"C\", name COLLATE \"C\", time, timestamp, server COLLATE \"C\") TO 'race-psql.csv' CSV HEADER"

cd ..
