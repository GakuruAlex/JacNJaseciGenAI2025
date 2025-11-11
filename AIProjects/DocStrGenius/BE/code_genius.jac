import repo_mapper;
import code_analyzer;
import doc_genie;
import from utils {save_doc}
import from dotenv {load_dotenv}

::py::
load_dotenv()
::py::

node CodeGenius {
    has repo_url: str;

    def run() -> dict {
        let mapper = repo_mapper.RepoMapper(
                    repo_url = self.repo_url

        );
        mapper.map_repo();
        print("Mapper path is ", mapper.local_path);
        let analyzer = code_analyzer.CodeAnalyzer(path = mapper.local_path);
        
        let docgen = doc_genie.DocGenie(
            summary=mapper.summary,
            file_tree=mapper.file_tree,
            ccg=analyzer.ccg,
            sem_graph = analyzer.sem_graph,
            repo_name = mapper.repo_name
        );
        self ++> mapper;
        mapper++> analyzer;
        mapper ++> docgen;      

        return {
            "repo_url": self.repo_url,
            "status": "Documentation generation started",
            "markdown": docgen.markdown
        };
    }

    can execute with entry {
        let result = self.run();
        report result;
        visit[-->];

    }
}
