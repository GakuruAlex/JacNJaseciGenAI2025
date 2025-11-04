import from re {search}
import subprocess;
import os;
impl Project.project_name{

    #https://github.com/USERNAME/PROJECT_NAME.git
    #git@github.com:USERNAME/PROJECT_NAME.git

    pattern = r'^(?:(?:https://github\.com/)||(?:git@github\.com:))\w+/(?P<name>\w+).git$';

    result = search(pattern, self.repo_url);

    if result{
        #print(result.group("name")); debugging re
        self.folder_name = result.group("name");
}
}

impl ProjectManger.clone_repo{
    try{
        result = subprocess.run(['git', 'clone', here.repo_url], check= True, capture_output = True, text= True) ;

    }

    except subprocess.CalledProcessError as e{
        print("Error cloning repo!", e.stderr);
        err_text = (e.stderr or e.stdout or "").strip();
        
        if "already exists" in err_text{
            here.project_name();
        
        }
        
        
    }
    else{
        here.project_name();
    }

    #add folder to graph
    folder = Folder(path = f"./{here.folder_name}", name=here.folder_name);
    here ++> folder;
    self.connections.append((f"{here} --> Connected Neighbor:--> {folder}"));

    print(os.listdir(folder.path));

    visit[-->(`?Folder)];
    summary = derive_project_structure(self.connections);
    print(summary);


}

impl ProjectManger.add_files{
    files: list = os.listdir(here.path);

    for file in files {
        full_path: str = os.path.join(here.path, file);
        if os.path.isfile(full_path){
            new_file = File(path = full_path, name=file);
            here+>:HasFiles:+> new_file ;

            print(f"Added file {file} to Folder {here.name}");
            self.connections.append((f"{here}--> Connected Neighbor:-->{new_file}"));

        }

}
}
