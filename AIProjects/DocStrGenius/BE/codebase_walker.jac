walker codebase_walker {
    has repo_url: str;
    obj __specs__ {
        static has auth: bool = False;
    }

    can execute with `root entry {
        let genius = here ++> code_genius.CodeGenius(repo_url=self.repo_url);
        visit genius;
    }
}

import code_genius;
