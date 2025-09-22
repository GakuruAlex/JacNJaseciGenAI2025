import random;


obj Game {
    has has_won: bool;

    def play {
        raise NotImplementedError("Subclasses must implement this method") ;
    }
}


obj GuessingGame(Game) {
    has has_won: bool = False,
        user_guess: int = 0,
        num_guesses: int = 0,
        correct_number: int = random.randint(0, 100);

    def play {
        print(
            "I am thinking of a number between 0 and 100. Try to guess it in as few guesses as you can. "
        );
        while not self.has_won {
            try {
                self.num_guesses += 1;
                self.user_guess = int(self.get_user_guess());
            } except ValueError {
                print("It has to be a number");
                continue;
            }
            if self.user_guess < 0 {
                print("Number has to be positive!.");
                continue;
            }
            if self.is_user_guess_correct() {
                self.has_won = True;
                print(f"You won! You took {self.num_guesses} guesses.");
                break;
            } else {
                print(self.guess_low_or_high());
                continue;
            }
        }
    }

    def get_user_guess {
        return input("What is your guess ? ");
    }

    def is_user_guess_correct {
        return self.correct_number == self.user_guess;
    }

    def guess_low_or_high {
        return "Your guess is too high."
        if self.user_guess > self.correct_number
        else "Your guess is too low.";
    }
}


with entry {
    game = GuessingGame();
    game.play();
}
