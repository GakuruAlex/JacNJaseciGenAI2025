import os;
import from dotenv {load_dotenv}
import from byllm.lib {Model}

glob codegenius = Model(model_name = "gemini/gemini-2.5-flash");
def derive_project_structure(project: Project) -> str by codegenius();
node Project{
    has repo_url: str = "";
    has folder_name: str = "";
    has folder_structure: str ="";

    def project_name;
}

node Folder{
    has name: str="";

    has path: str ="";

}
node File{
    has path: str = "";
    has name: str="";
    

    has summary: str ="";
}

edge SubFolders{}
edge HasFiles{}


walker ProjectManger{
    has connections: list = [];
    can start with `root entry{
        self.connections.append(f"{here}-->");
        visit[-->];
    }

    can clone_repo with Project entry;

    can add_files with Folder entry;

}


with entry:__main__{
    load_dotenv();

    root ++> Project(repo_url= "git@github.com:GakuruAlex/all_ways_up.git");
    
    project = root spawn ProjectManger();

    #print(project.connections);


    
}