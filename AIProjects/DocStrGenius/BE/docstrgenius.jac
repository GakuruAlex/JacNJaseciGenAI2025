import os;
import from time {strftime}
import from dotenv {load_dotenv}
import from byllm.llm {Model}


glob codegenius = Model(model_name = "gemini/gemini-2.5-flash");

enum STATUS{
    PENDING = "pending",
    RUNNING = "running",
    DONE = "done",
    FAILED = "failed"
}
node CodeGenius{
    has repo_url: str;
    has job_id: str;
    has status: str = STATUS.PENDING.value;
    has plan: str = "";
    has created_at: str = strftime("%Y-%m-%d %H:%M:%S");
    has repo_ref: str = "";
    has summary_ref: str = "";
    has analysis_ref: str = "";
    has doc_ref: str = "";


}

walker StartJob{
    can start_job on CodeGenius;
    
}