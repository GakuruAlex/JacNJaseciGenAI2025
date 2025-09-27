import os;
import from byllm {Model}
import from dotenv {load_dotenv}
glob npc_model = Model(model_name ="gemini/gemini-2.5-flash");


node Service {}

walker StateAgent{

    has state: dict = {};

    can start with `root entry {
        visit [-->(`?Service)];
    }
}

node Weather(Service){
    has temp: int = 110;

    can get with StateAgent entry {

        visitor.state["temperature"] = self.temp;
    }
}


node Time(Service){

    has hour: int = 10;

    can get with StateAgent entry {

        visitor.state["time"] = f"{self.hour}:00 AM";
    }
}
"""Adjusts the tone or personality of the shop keeper npc depending on weather/time."""
def get_ambient_mood(state: dict) -> str by npc_model();

node NPC{

    can get with StateAgent entry {
        visitor.state["npc_mood"] = get_ambient_mood(visitor.state);
    }
}

walker NPCWalker(StateAgent){

    can visit_npc with `root entry{

        visit [-->(`?NPC)];
    }
}


with entry{

    load_dotenv();

    os.environ["GEMINI_API_KEY"] = os.getenv("API_KEY");

    root ++> Weather();
    root ++> Time();
    root ++> NPC();

    agent = NPCWalker() spawn root;

    print(agent.state["npc_mood"]);
}