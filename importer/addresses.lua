local addresses = osm2pgsql.define_node_table('addresses', {
    { column = 'city' },
    { column = 'street' },
    { column = 'place' },
    { column = 'housenumber' },
    { column = 'geom',       type = 'point', not_null = true },
}
)

function osm2pgsql.process_node(object)
    if not (object.tags['addr:city'] and
            (object.tags['addr:TW:dataset'] or object.tags['source:url'])) then
        return
    end
    local a = {
        city = object.tags['addr:city'],
        street = object.tags['addr:street'],
        place = object.tags['addr:place'],
        housenumber = object.tags['addr:housenumber'],
        geom = object:as_point()
    }
    addresses:insert(a)
end
