import os;
import from random {randint}
import from dotenv {load_dotenv}
import from byllm {Model}

glob game_model = Model(model_name= "gemini/gemini-2.5-flash");

"""This is a geussing game.Creatively ask user for a guess between the given range.I will also keep track of how many tries it takes to get it right."""
def guess_prompt(low:int, high: int)-> str by game_model();

"""A prompt for user when they give an input that is not a number or its outside the range"""
def reprompt(low:int, high: int, user_input:any)-> str by game_model();

"""Give user a hint to lead them to the number lies gievn their guess and the correct number. Avoid ambiguity"""
def user_hint(user_guess: int, correct_number: int) ->str by game_model();

"""Congratulate user on winning"""
def congratulate_user(number_of_tries: int)-> str by game_model();

glob LOW = 0;
glob HIGH = 100;
walker GuessGame{

    has num_of_tries: int = 0;
    def get_user_guess(prompt: str)-> int;

    can start with `root entry;
    can play_game with Turn entry;

    
}

node Turn{
    has correct_number: int = randint(LOW, HIGH);
}


with entry:__main__{
    load_dotenv();
    os.environ["GEMINI_API_KEY"] = os.getenv("API_KEY");

    root ++> Turn();

    root spawn GuessGame();

    #print(guess_prompt(0, 100));
    #print(reprompt(0, 100, "hello"));
}