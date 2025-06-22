#!/bin/bash

DB_NAME="periodic_table"
USER="freecodecamp"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

if [[ $1 =~ ^[0-9]+$ ]]; then
  QUERY_CONDITION="atomic_number = $1"
else
  QUERY_CONDITION="symbol = '$1' OR name = '$1'"
fi

RESULT=$(psql -U "$USER" -d "$DB_NAME" -t --no-align -c "
SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p ON e.atomic_number = p.atomic_number
JOIN types t ON p.type_id = t.type_id
WHERE $QUERY_CONDITION;
")

if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit
fi

IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME TYPE MASS MELTING BOILING <<< "$RESULT"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius." 

echo "I have to commit changes"