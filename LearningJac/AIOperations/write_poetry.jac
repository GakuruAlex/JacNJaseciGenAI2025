import os;
import from dotenv { load_dotenv }
import from byllm { Model }


glob llm = Model(model_name="gemini/gemini-2.5-flash");


def write_poetry(topic: str) -> str by llm();


with entry {
    load_dotenv();
    os.environ["GEMINI_API_KEY"] = os.getenv("API_KEY");
    topic: str = "Roses are red";
    result: str = write_poetry(topic);
    print(f"{result}");
}
