import glob;
import os;

import from  utils {git_tools, repo_tools}
import from byllm.llm { Model }
import from directory_tree {DisplayTree}

glob llm = Model(model_name="gemini/gemini-2.5-flash");

node RepoMapper {
     has repo_url: str ;
     has repo_name: str="";

    has local_path: str = "";
    has file_tree: any = None;
    has summary: str = "";

    "Summarize the repo from content of readme or directory structure in absence of readme."
    def summarizerepo(file_tree: DisplayTree= "", readme: str = "")-> str by llm(
        method = "ReAct"
    );

    def map_repo() {
        
            base_dir = os.path.dirname(os.path.dirname(__file__));

            outputs_dir = os.path.join(base_dir, "outputs");
            os.makedirs(outputs_dir, exist_ok=True);

            repo_name = self.repo_url.split("/")[-1].replace(".git", "");
            self.repo_name = repo_name;
            self.local_path = os.path.join(outputs_dir, repo_name);
            print(">>> Running RepoMapper.map_repo for", self.repo_url);
            print("Repo URL IS:", self.repo_url);

        

            local: tup = repo_tools.prepare_repo(self.repo_url);
            print("LOCAL!!!!!!",local);
            self.local_path = local[0];
            self.file_tree = local[1];
            readme_content = local[2];

        
            self.summary = self.summarizerepo(file_tree= self.file_tree, readme= readme_content);
    }

    can execute with  entry {
        self.map_repo();
        print("INSIDE REPO MAPPER");
        print(self.file_tree);
        report {
            "repo_url": self.repo_url,
            "local_path": self.local_path,
            "summary": self.summary,
            "file_tree": self.file_tree,
            "markdown": self.summary
        };
        
        visit [-->];

    }

}