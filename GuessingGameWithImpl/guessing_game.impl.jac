import from random { randint }


impl Game.play{
    raise NotImplementedError("Subclassess must implement this method.") ;
}


impl GuessingGame.init{
    self.num_attempts = 0;
    self.has_won = False;
}


impl GuessingGame.get_user_guess -> str {
    self.num_attempts += 1;
    return input("What's your guess? ");
}


impl GuessingGame.is_correct(guess: int) -> bool {
    return guess == self.correct_number;
}


impl GuessingGame.low_or_high(guess: int) -> str {
    return "Your guess is too high!"
    if guess > self.correct_number
    else "Your guess is too low!";
}


impl GuessingGame.play{
    print(
        "I am thinking of a number between 0 and 100. Try to guess it in as little time as possible."
    );
    while not self.has_won {
        try {
            guess: int = int(self.get_user_guess());
        } except ValueError {
            print("Your guess must be a number!. Try again.");
            continue;
        } else {
            if guess < 0 {
                print("Guess must be greater than 0. Try again.");
                continue;
            } else {
                if self.is_correct(guess) {
                    print(f"You guessed correct and in {self.num_attempts} attempts! ");
                    return;
                } else {
                    print(self.low_or_high(guess));
                    continue;
                }
            }
        }
    }
}
