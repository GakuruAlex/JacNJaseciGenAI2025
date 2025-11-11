import os;
import from utils {save_doc}
import from byllm.lib {Model}
import from typing {Any}
glob llm = Model(model_name="gemini/gemini-2.5-flash");

obj FunctionInfo {
    has name: str;
    has params: dict[str, str];  # name: type
    has returns: dict[str, str]; # {"type": "List[int]", "desc": "..."}
    has variables: dict[str, str];
    has doc: str;
}
obj ClassInfo {
    has name: str;
    has doc: str;
    has functions: dict[str, FunctionInfo];
}

obj ModuleInfo {
    has file_name: str;
    has module_doc: str;
    has classes: dict[str, ClassInfo];
    has functions: dict[str, FunctionInfo];
}

# keep ModuleInfo object if available; otherwise explicit summary object
obj ModuleSummary {
  has file_name: str;
  has module_doc: str;
  has classes: dict[str, dict[str, Any]];   # class_name -> {doc, functions}
  has functions: dict[str, dict[str, Any]]; # func_name -> {params, returns, variables, doc}
}


node CodeAnalyzer {
    has path: str;
    has ccg: list[dict[str, ModuleInfo], ...] = [];
    has sem_graph: dict[str, Any] = {};

    


    """Generate a ModuleInfo for all given str of a read file."""
    def create_code_context_graph(text: str)-> ModuleInfo  by llm(
            method = "ReAct",
            incl_info ={"module_info": ModuleInfo, "function_info": FunctionInfo, "class_info": ClassInfo}

        );

    
    def read_all_files;
    def populate_graph;
    """Create a dictionary from the ModuleInfo obj given. The Module info may have obj like FunctionInfo and ClassInfo"""
    def create_module_info(content: dict[str, ModuleInfo]) -> dict[str, dict];
    def create_module_information_dict(content: dict[str, ModuleInfo]) -> ModuleSummary  by llm(
    method = "ReAct",
    tools= [self.create_module_info],
    incl_info ={"module_info": ModuleInfo, "function_info": FunctionInfo, "class_info": ClassInfo}
    );
    can execute with entry {
        self.read_all_files();
        self.populate_graph();
        report {
            "ccg": self.ccg,
            "sem_graph": self.sem_graph
        };
        visit[-->];
    }
}
