walker StateAgent{
    has state: dict = {};

    can start with `root entry{
        visit [-->];
    }
}

node Weather{
    has temp: int = 80;

    can get with StateAgent entry{

        visitor.state["temperature"] = self.temp;
    }
}

node Time{

    has hour: int = 12;

    can get with StateAgent entry{

        visitor.state["time"] = f"{self.hour}:00";
    }
}


with entry{

    root ++> Weather();

    root ++> Time();

    agent = StateAgent() spawn  root;

    print(agent.state);
}