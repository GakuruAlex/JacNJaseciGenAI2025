import from random { randint }


obj Game {
    has num_attempts: int = 0,
        has_won: bool = False;

    def play;
}


obj GuessingGame(Game) {
    has correct_number: int = randint(0, 100);

    def init;
    override def play;
    def is_correct(guess: int);
    def low_or_high(guess: int);
    def get_user_guess;
}

with entry{
    game = GuessingGame();
    game.play()

}