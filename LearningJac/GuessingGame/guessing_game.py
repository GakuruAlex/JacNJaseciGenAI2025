from random import randint
class Game:
    def __init__(self):
        self.attempts: int = 0
    def play(self)-> None:
        """_Start the game_

        Raises:
            NotImplementedError: _Ensure the subclasses implement the method_
        """
        raise NotImplementedError("Subclasses should implement this method.")

class GuessingGame(Game):
    def __init__(self):
        super().__init__()
        self.number_to_guess: int = randint(0, 100)
    def get_user_guess(self)-> str:
        """_Ask player for their guess_

        Returns:
            str: _A str rep of the player guess_
        """
        self.attempts += 1
        return input("What number am I thinking of ? ")
    
    def check_player_guess(self, guess: int) -> bool:
        """_Check if the player guessed the right number_

        Args:
            guess (_int_): _Number the player guessed_

        Returns:
            bool: _True if guess is equal to game's guess else False_
        """
        return guess == self.number_to_guess
    
    def low_or_high(self, number: int, guess: int)-> str:
        """_Determine if the player guess is higher or lower than thw game's guess_

        Args:
            number (_int_): _Game's guess_
            guess (_int_): _Player guess_

        Returns:
            str: _A str telling the player if their guess is higher or lower than the number to guess_
        """
        return  "Your guess is too high." if guess > number else "Your guess is too low."

    def play(self)-> None:
        """_Initialize the guessing game_

        Raises:
            Exception: _If player guesses a negative number_
        """
        while True:
            print("I am thinking of a number between 0 and 100. Try to guess it in as few attempts as possible.")
            try:
                player_guess: int = int(self.get_user_guess())
                if player_guess < 0:
                    raise Exception("Number must be positive")
            except ValueError:
                print("It has to be a number!")
                continue
            except Exception as e:
                print(e)
                continue
            else:
                is_correct: bool = self.check_player_guess(player_guess)
                if is_correct:
                    print(f"You got it right in {self.attempts} tries.")
                    break
                else:
                    print(self.low_or_high(guess = player_guess, number = self.number_to_guess))
                    continue


if __name__ == "__main__":
    game = GuessingGame()
    game.play()

                 
