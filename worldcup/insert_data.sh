#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#POSGRES-FUNCTIONS
RETURN_TEAM_ID() {
  # $1 = PSQL
  # $2 = Name of the Team
  echo $($1 "SELECT team_id FROM teams WHERE name='$2';")
}
ADD_TEAM_NAME() {
  # $1 = PSQL
  # $2 = Name of the Team
  echo $($1 "INSERT INTO teams(name) VALUES('$2');")
}
ADD_GAME_INFO() {
  # $1 = PSQL
  # $2 = year
  # $3 = round
  # $4 = winner_name
  # $5 = opponent_name
  # $6 = winner_goals
  # $7 = opponent_goals
  WINNER_ID=$(RETURN_TEAM_ID "$PSQL" "$4")
  OPPONENT_ID=$(RETURN_TEAM_ID "$PSQL" "$5")
  echo $($1 "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($2,'$3',$WINNER_ID,$OPPONENT_ID,$6,$7);")
}

#CSV-SETTINGS
CSV_FILE=games.csv
SKIP_HEADERS=1

#Loop
cat $CSV_FILE | while IFS="," read YEAR RND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if (( SKIP_HEADERS ))
  then
    ((SKIP_HEADERS--))
  else
    #echo "$YEAR | $RND | $WINNER | $OPPONENT | $WINNER_GOALS | $OPPONENT_GOALS"
    # Check if WinnerTeam exists
    echo "Winning Team: $WINNER"
    RES_WINNER=$(RETURN_TEAM_ID "$PSQL" "$WINNER")
    if [[ -z $RES_WINNER ]]
      then
        echo "No ID!"
        RES_STORE_INFO=$(ADD_TEAM_NAME "$PSQL" "$WINNER")
        echo "Added Team $WINNER to 'teams'-Table."
    fi
    echo "Opponent Team: $OPPONENT"
    # Check if OpponentTeam exists
    RES_OPPONENT=$(RETURN_TEAM_ID "$PSQL" "$OPPONENT")
    if [[ -z $RES_OPPONENT ]]
      then
        echo "No ID!"
        RES_STORE_INFO=$(ADD_TEAM_NAME "$PSQL" "$OPPONENT")
        echo "Added Team $OPPONENT to 'teams'-Table."
    fi
    ADD_GAME_INFO "$PSQL" $YEAR "$RND" "$WINNER" "$OPPONENT" $WINNER_GOALS $OPPONENT_GOALS
    echo -e "GameInfo Added\n"
  fi
done
