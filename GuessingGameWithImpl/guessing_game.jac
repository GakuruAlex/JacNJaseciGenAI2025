import from random { randint }


obj Game {
    has num_attempts: int,
        has_won: bool;

    def play;
}


obj GuessingGame(Game) {
    has correct_number: int;

    def init;
    override def play;
    def is_correct(guess: int);
    def low_or_high(guess: int);
    def get_user_guess;
}


with entry {
    game = GuessingGame();
    game.play();
}
