import from random {randint}
"""A Guessing Game"""
walker GuessingGame{
    has correct_number: int = randint(0, 100);
    has num_of_tries: int = 0;

    can start_game with `root entry;
    def guess_high_low(guess: int);
    def guess_correct(guess: int);
    def get_guess()-> int;
}

with entry{
    GuessingGame() spawn root;
}