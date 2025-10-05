impl GuessGame.start{
    visit [-->(`?Turn)];
}


impl GuessGame.get_user_guess(prompt: str)-> int{
    guess: str = input(f"{prompt} ");

    while not guess.isdigit(){
        prompt: str = reprompt(LOW, HIGH, guess);
        guess: str = input(f"{prompt} ");
    }
    self.num_of_tries += 1;
    return int(guess);

}
impl GuessGame.play_game{
    prompt: str = guess_prompt(LOW, HIGH);
    user_guess: int = self.get_user_guess(prompt);

    while True{

        if user_guess == here.correct_number{
            print(f"{congratulate_user(self.num_of_tries)}");
            break;
        }
        else{
            user_guess = self.get_user_guess(f"{user_hint(user_guess, here.correct_number)}");
        }
    }
}

