# Neo4j

## My completed courses

- [Neo4j Fundamentals](https://graphacademy.neo4j.com/u/cc0153fe-e780-4bae-80f3-a56cf17c7421/neo4j-fundamentals/)
- [Cypher Fundamentals](https://graphacademy.neo4j.com/courses/cypher-fundamentals/certificate/)
- [Graph Data Modeling Fundamentals](https://graphacademy.neo4j.com/courses/modeling-fundamentals/certificate/)

- [Building Neo4j Applications with Go](https://graphacademy.neo4j.com/courses/app-go/certificate/) (my implementation [here](https://github.com/mariamihai/neo4j-app-go))

## Cypher

Pattern:
- nodes with `()`: `(Person)`
- labels with `:`: `(:Person)`
- relationships with `--` or greater or less for direction (`->`, `<-`): `(:Person)--(:Movie)` or `(:Person)->(:Movie)`
- type of relationship with `[]`: `[:ACTED_IN]`
- properties are specified in JSON like syntax: `{name: 'Tom Hanks'}`

Example of pattern: `(m:Movie {title: 'Cloud Atlas'})<-[:ACTED_IN]-(p:Person)`

<br>

- labels, property keys and variables are case-sensitive
- cypher keywords are not case-sensitive
- **best practices**:
  - name labels with `CamelCase`
  - property keys and variables with `camelCase`
  - cypher keywords with `UPPERCASE`

### MATCH

- read data
- similar to the `FROM` clause in an SQL statement
- need to return something

Return all nodes with the label `Person`:
```cypher
MATCH (p:Person)
RETURN p
```

Return a person based on a property:
```cypher
MATCH (p:Person {name: 'Tom Hanks'})
RETURN p
```

Return a property:
```cypher
MATCH (p:Person {name: 'Tom Hanks'})
RETURN p.born
```

Return a property based on a relation:
```cypher
MATCH (p:Person {name: 'Tom Hanks'})-[:ACTED_IN]->(m:Movie)
RETURN m.title
```

### WHERE

Filter by specifying the property value:
```cypher
MATCH (p:Person)
WHERE p.name = 'Tom Hanks' OR p.name = 'Rita Wilson'
RETURN p.name, p.born
```

Filter by node labels:
```cypher
MATCH (p)-[:ACTED_IN]->(m)
WHERE p:Person AND m:Movie AND m.title='The Matrix'
RETURN p.name
```
is same as:
```cypher
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE m.title='The Matrix'
RETURN p.name
```

Filter with ranges:
```cypher
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE 2000 <= m.released <= 2003
RETURN p.name, m.title, m.released
```

Filter by existence of a property:
```cypher
MATCH (p:Person)-[:ACTED_IN]->(m:Movie)
WHERE p.name='Jack Nicholson' AND m.tagline IS NOT NULL
RETURN m.title, m.tagline
```

Filter strings:
- partial strings (`STARTS WITH`, `ENDS WITH`, `CONTAINS`):
```cypher
MATCH (p:Person)-[:ACTED_IN]->()
WHERE p.name STARTS WITH 'Michael'
RETURN p.name
```
- string tests are case-sensitive
- `toLower()`, `toUpper()` functions
```cypher
MATCH (p:Person)-[:ACTED_IN]->()
WHERE toLower(p.name) STARTS WITH 'michael'
RETURN p.name
```

Filter by patterns in the graph:
```cypher
// Find all people who wrote a movie but not directed it
MATCH (p:Person)-[:WROTE]->(m:Movie)
WHERE NOT exists( (p)-[:DIRECTED]->(m) )
RETURN p.name, m.title
```

Filter using lists:
- of numeric or string values
```cypher
MATCH (p:Person)
WHERE p.born IN [1965, 1970, 1975]
RETURN p.name, p.born
```
- existing lists in the graph
```cypher
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE  'Neo' IN r.roles AND m.title='The Matrix'
RETURN p.name, r.roles
```

### Other

- `keys()` - get the properties of a node
```cyper
MATCH (p:Person)
RETURN p.name, keys(p) 
```

- get all property keys defined in the graph (even if there are no nodes or relationships with them anymore)
```cypher
CALL db.propertyKeys()
```

## Random

- Neo4j’s Cypher statement language is optimized for node traversal so that relationships are not traversed multiple times
- each relationship must have a direction in the graph. The relationship can be queried in either direction, or ignored completely at query time
- Neo4j stores nodes and relationships as objects that are linked to each other via pointers
  - `index-free adjacency` - a reference to the relationship is stored with both start and end nodes



## Links

- [resources](https://neo4j.com/developer/resources/)
- [docs](https://neo4j.com/docs/)
- [sandbox](https://sandbox.neo4j.com/)
- [Neo4j YT](https://www.youtube.com/channel/UCvze3hU6OZBkB1vkhH2lH9Q)
- [Graph Academy](https://graphacademy.neo4j.com/)
- [GraphGists](https://neo4j.com/graphgists/)
- [Neo4j GitHub](https://github.com/neo4j-contrib)