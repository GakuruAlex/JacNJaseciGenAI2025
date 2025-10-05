import random;

"""A Number Guessing Game"""

node turn {
    has correct_number: int = random.randint(1, 100);

}

walker GuessGame {
    has num_of_tries: int = 0;

    def get_guess() -> int;
    def guess_high_low(guess: int, correct_number: int) -> str;
    def guess_correct(guess: int, correct_number: int) -> bool;
    can process_guess with turn entry;


    can start with `root entry{
        print("I'm thinking of a number between 1 and 100. Can you guess it?");

        visit [-->(`?turn)];

    }
    can see_number with turn entry{

        print(f"Correct number is {here.correct_number}");

    }
}

with entry:__main__ {
    root ++> turn();
    GuessGame() spawn root;
}