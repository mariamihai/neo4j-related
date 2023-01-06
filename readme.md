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
  - have at least one label for a node but no more than four

### MATCH

- read data
- similar to the `FROM` clause in an SQL statement
- need to return something
- you don't need to specify direction in the `MATCH` pattern, the query engine will look for all nodes that are connected, regardless of the direction of the relationship

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

### MERGE

- the `MERGE` operations work by first trying to find a pattern in the graph. If the pattern is found then the data already exists and is not created. If the pattern is not found, then the data can be created
- when using `MERGE` you need to add at least a property that will make the unique primary key for the node
```cypher
MERGE (p:Person {name: 'Michael Cain'})
```

Can merge multiple `MERGE` clauses together:
```cypher
MERGE (p:Person {name: 'Katie Holmes'})
MERGE (m:Movie {title: 'The Dark Knight'})
RETURN p, m
```

Create a relationship based on 2 existing nodes:
```cypher
MATCH (p:Person {name: 'Michael Cain'})
MATCH (m:Movie {title: 'The Dark Knight'})
MERGE (p)-[:ACTED_IN]->(m)
```

Create the nodes and the relationship
- using multiple clauses:
```cypher
MERGE (p:Person {name: 'Chadwick Boseman'})
MERGE (m:Movie {title: 'Black Panther'})
MERGE (p)-[:ACTED_IN]-(m)
```
(if the direction of the relationship is not set, it is assumed to be left-to-right)
- in single clause
```cypher
MERGE (p:Person {name: 'Emily Blunt'})-[:ACTED_IN]->(m:Movie {title: 'A Quiet Place'})
RETURN p, m
```

#### Customized MERGE behavior

- set behavior at runtime to set properties when the node is created or when it is found with `ON CREATE SET`, `ON MATCH SET` or `SET`
```cypher
// Find or create a person with this name
MERGE (p:Person {name: 'McKenna Grace'})

// Only set the `createdAt` property if the node is created during this query
ON CREATE SET p.createdAt = datetime()

// Only set the `updatedAt` property if the node was created previously
ON MATCH SET p.updatedAt = datetime()

// Set the `born` property regardless
SET p.born = 2006

RETURN p
```

### CREATE

- it doesn't look up the primary key before adding the node
- provides greater speed during import
- `MERGE` eliminates duplication of nodes






### SET

- set a property value
- this can be done with `MERGE` as well 

Set one or more properties:
```cypher
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE p.name = 'Michael Cain' AND m.title = 'The Dark Knight'
SET r.roles = ['Alfred Penny'], r.year = 2008
RETURN p, r, m
```

Update existing properties:
```cypher
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE p.name = 'Michael Cain' AND m.title = 'The Dark Knight'
SET r.roles = ['Mr. Alfred Penny']
RETURN p, r, m
```

Add new label to a node:
```cypher
MATCH (p:Person {name: 'Jane Doe'})
SET p:Developer
RETURN p
```

#### Unsetting a property

Remove property:
```cypher
MATCH (p:Person)
WHERE p.name = 'Gene Hackman'
SET p.born = null
RETURN p
```

### REMOVE

`REMOVE` can be used for removing a property as well:
```cypher
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE p.name = 'Michael Cain' AND m.title = 'The Dark Knight'
REMOVE r.roles
RETURN p, r, m
```

Remove a label from a node:
```cypher
MATCH (p:Person {name: 'Jane Doe'}) // Same as MATCH (p:Person:Developer {name: 'Jane Doe'})
REMOVE p:Developer
RETURN p
```

### DELETE

- attempting to delete a node with a relationship will throw an error - Neo4j prevents orphaned relationships in the graph

```cypher
MATCH (p:Person)
WHERE p.name = 'Jane Doe'
DELETE p
```

Remove a relationship:
```cypher
MATCH (p:Person {name: 'Jane Doe'})-[r:ACTED_IN]->(m:Movie {title: 'The Matrix'})
DELETE r
RETURN p, m
```

#### Using DETACH
Delete a node and all its relationships:
```cypher
MATCH (p:Person {name: 'Jane Doe'})
DETACH DELETE p
```

Delete all nodes and all relationships in the graph:
```cypher
MATCH (n)
DETACH DELETE n
```
(this will exhaust memory on a large db)

### Other

- `keys()` - get the properties of a node
```cyper
MATCH (p:Person)
RETURN p.name, keys(p) 
```

- get all node labels defined in the graph
```cypher
CALL db.labels()
```

- get all property keys defined (even if there are no nodes or relationships with them anymore)
```cypher
CALL db.propertyKeys()
```

- date specific uses
  - `datetime()` - current date and time
  - `date("2019-09-30")` = `2019-09-29`
  - `datetime({epochmillis: ms})` = `2019-09-25T06:29:39Z`
  - use APOC functions for more specific needs ([apoc.temporal](https://neo4j.com/labs/apoc/4.3/overview/apoc.temporal/))

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