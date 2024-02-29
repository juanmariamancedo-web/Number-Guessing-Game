#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo Enter your username:
read USERNAME

USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")
GAMES_PLAYED=$($PSQL "select games_played from users where username = '$USERNAME'")
BEST_GAME=$($PSQL "select best_game from users where username = '$USERNAME'")

if [ -z "$USER_ID" ]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users (username) VALUES ('$USERNAME')" > /dev/null 2>&1
else
  $PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID" > /dev/null 2>&1
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

ALEATORY_NUMBER=$((RANDOM % 1000 + 1))

echo -e "\nGuess the secret number between 1 and 1000:"
read INPUT

while [[ ! "$INPUT" =~ ^[0-9]+$ ]]; do
  echo "That is not an integer, guess again:"
  read INPUT
done

NUMBER_OF_GUESSES=1

while [ $INPUT -ne $ALEATORY_NUMBER ]
do
  if [ "$ALEATORY_NUMBER" -lt "$INPUT" ]; then
    echo "It's higher than that, guess again:"
  else 
    echo "It's lower than that, guess again:"
  fi

  read INPUT

  while [[ ! "$INPUT" =~ ^[0-9]+$ ]]; do
    echo "That is not an integer, guess again:"
    read INPUT
  done

  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
done

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

if [ -z "$BEST_GAME" ] || [ "$NUMBER_OF_GUESSES" -lt "$BEST_GAME" ]; then
  $PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'" > /dev/null 2>&1
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $ALEATORY_NUMBER. Nice job!"
