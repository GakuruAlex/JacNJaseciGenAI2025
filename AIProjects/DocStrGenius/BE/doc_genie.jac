import from byllm.lib { Model }
import from utils { save_doc }
import from typing {Any}

glob llm = Model(model_name="gemini/gemini-2.5-flash");

# keep ModuleInfo object if available; otherwise explicit summary object
obj ModuleSummary {
  has file_name: str;
  has module_doc: str;
  has classes: dict[str, dict[str, Any]];   # class_name -> {doc, functions}
  has functions: dict[str, dict[str, Any]]; # func_name -> {params, returns, variables, doc}
}


node DocGenie {
    has repo_name: str;
    has sem_graph: ModuleSummary = {};
    

    has summary: str = "";
    has file_tree: list[str, ...] = [];
    # ccg is a list of wrapper dicts like { "module_key": ModuleInfo-like-object }
    has ccg: list[dict[str, Any], ...] = [];
    has markdown: str = "";


    """Generate a readme using the sem graph given and the project tree. Include a code context graph from the sem_graph and api section where applicable."""
    def generate_readme_from_sem_graph(project_tree: str, sem_graph: dict[str, ModuleSummary]) -> str by llm(
    method = "ReAct",
    );

    def get_readme(){
        self.markdown = self.generate_readme_from_sem_graph(self.file_tree, self.sem_graph);
        save_doc.save(self.markdown, self.repo_name);

    }
    

    can execute with entry {
        self.get_readme();
        report {
            "markdown": self.markdown
        };
    }
}
