
impl GuessingGame.guess_high_low(guess: int){
    return "Your guess is too high" if self.correct_number < guess else "Your guess is too low.";
}

impl GuessingGame.guess_correct(guess: int){
    self.num_of_tries += 1;
    return self.correct_number == guess;
}

impl GuessingGame.get_guess{

    guess: str = input("What is your Guess: ");

    while not guess.isdigit(){

        print("Your guess is not a number. Try again!");
        guess: str = input("What is your Guess: ");
    }

    return int(guess);
}
impl GuessingGame.start_game{
    print("I am thinking of a number between 0 and 100. Try to guess it.");
    while True{
        user_guess: int = self.get_guess();
        if self.guess_correct(user_guess){
            print(f"Congratulations you won! It took you {self.num_of_tries} tries.");
            break;
        }
        else{
            print(self.guess_high_low(user_guess));
            continue;
        }


    }
}