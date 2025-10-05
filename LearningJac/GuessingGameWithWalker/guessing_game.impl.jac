impl GuessGame.get_guess {
    guess: str = input("What is your guess: ");
    while not guess.isdigit() {
        print("Your guess is not a number. Try again!");
        guess: str = input("What is your guess? ");
    }
    return int(guess);
}

impl GuessGame.guess_high_low(guess: int, correct_number: int) {
    if guess < correct_number {
        return "Your guess is too low.";
    } else {
        return "Your guess is too high.";
    }
}

impl GuessGame.guess_correct(guess: int, correct_number: int) {
    self.num_of_tries += 1;
    return guess == correct_number;
}

impl GuessGame.process_guess {
        guess: int = self.get_guess();

        if self.guess_correct(guess, here.correct_number) {
            print(f"Congratulations! You guessed correctly in {self.num_of_tries} tries.");
            disengage;
        } else {
            print(self.guess_high_low(guess, here.correct_number));
            visit here;
        }
    }
