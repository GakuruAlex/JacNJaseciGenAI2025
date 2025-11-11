import os;


sem FunctionInfo.name = "The name of the function.";
sem FunctionInfo.params = "Dictionary of function parameters with their types.";
sem FunctionInfo.returns = "Dictionary containing the return type and description.";
sem FunctionInfo.variables = "Variables used inside the function and their inferred types.";
sem FunctionInfo.doc = "Natural language description of what the function does.";



sem ClassInfo.name = "The class name as defined in the source code.";
sem ClassInfo.doc = "Describes the purpose and responsibilities of the class.";
sem ClassInfo.functions = "Mapping of function names to their FunctionInfo definitions within the class.";



sem ModuleInfo.file_name = "The file name or module identifier.";
sem ModuleInfo.module_doc = "High-level description of what the module or file is responsible for.";
sem ModuleInfo.classes = "Dictionary of class names to their ClassInfo objects in this module.";
sem ModuleInfo.functions = "Dictionary of top-level function names to FunctionInfo objects in this module.";


impl CodeAnalyzer.create_module_info(content: dict[str, ModuleInfo]) -> dict[str, dict]{
::py::
# content may be a dict wrapper like {"all_ways_up": ModuleInfo(...)}
# or directly a ModuleInfo-like object. Normalize to module_obj and file_key.
print("CONTENT in CREATE MODULE INFO IS", content)

# unwrap wrapper dict if present (single-key mapping)
if isinstance(content, dict) and len(content) == 1:
    file_key, module_obj = next(iter(content.items()))
else:
    module_obj = content
    # try to read a file_name from the module_obj if present, else fallback
    file_key = getattr(module_obj, "file_name", None) or "unknown_module"

def _get_attr(obj, name, default=None):
    if obj is None:
        return default
    if isinstance(obj, dict):
        return obj.get(name, default)
    return getattr(obj, name, default)

# Build classes dict
classes_dict = {}
raw_classes = _get_attr(module_obj, "classes", {}) or {}
# raw_classes might be a dict or iterable
if isinstance(raw_classes, dict):
    class_items = raw_classes.items()
else:
    class_items = []
    for c in raw_classes:
        cname = _get_attr(c, "name", None) or "unknown_class"
        class_items.append((cname, c))

for cls_name, cls_obj in class_items:
    funcs_dict = {}
    raw_funcs = _get_attr(cls_obj, "functions", {}) or {}
    if isinstance(raw_funcs, dict):
        func_items = raw_funcs.items()
    else:
        func_items = []
        for f in raw_funcs:
            fname = _get_attr(f, "name", None) or "unknown_func"
            func_items.append((fname, f))

    for f_name, f_obj in func_items:
        funcs_dict[f_name] = {
            "params": _get_attr(f_obj, "params", {}),
            "returns": _get_attr(f_obj, "returns", {}),
            "variables": _get_attr(f_obj, "variables", {}),
            "doc": _get_attr(f_obj, "doc", ""),
        }

    classes_dict[cls_name] = {
        "doc": _get_attr(cls_obj, "doc", ""),
        "functions": funcs_dict,
    }

# Top-level functions
functions_dict = {}
raw_funcs = _get_attr(module_obj, "functions", {}) or {}
if isinstance(raw_funcs, dict):
    top_func_items = raw_funcs.items()
else:
    top_func_items = []
    for f in raw_funcs:
        fname = _get_attr(f, "name", None) or "unknown_func"
        top_func_items.append((fname, f))

for f_name, f_obj in top_func_items:
    functions_dict[f_name] = {
        "params": _get_attr(f_obj, "params", {}),
        "returns": _get_attr(f_obj, "returns", {}),
        "variables": _get_attr(f_obj, "variables", {}),
        "doc": _get_attr(f_obj, "doc", ""),
    }

module_dict = {
    file_key: {
        "doc": _get_attr(module_obj, "module_doc", ""),
        "classes": classes_dict,
        "functions": functions_dict
    }
}

print("CREATE_MODULE_INFO ->", module_dict)
return module_dict
::py::
}




impl CodeAnalyzer.populate_graph {
::py::
print("INSIDE POPULATE GRAPH before the loop", self.ccg)

for module_info in self.ccg:
    # module_info can be {"name": ModuleInfo(...)} or ModuleInfo-like object
    if isinstance(module_info, dict) and len(module_info) == 1:
        file_key, wrapper = next(iter(module_info.items()))
        module_obj = wrapper
    else:
        module_obj = module_info
        file_key = getattr(module_obj, "file_name", None) or "unknown_module"

    # sanitize file_key for BSON/Mongo safety
    safe_key = file_key.replace(".", "__dot__").replace("$", "__dollar__")

    try:
        module_dict = self.create_module_info(module_info)

    except Exception as e:
        # keep the walker resilient: store the error rather than raising
        module_dict = {"error": f"create_module_information_dict failed: {e}"}

    # set into sem_graph using sanitized key
    self.sem_graph[safe_key] = module_dict

print("POPULATE_GRAPH done; sem_graph keys:", list(self.sem_graph.keys()))
::py::
}

impl CodeAnalyzer.read_all_files{
        print(f"IN READ ALL FILES");
        print(f"Local Path is ", self.path);
        root_dir: str = self.path;
        ::py::
        if os.path.isdir(root_dir):
            for dirpath, dirnames, filenames in os.walk(root_dir):
                # skip hidden directories
                dirnames[:] = [d for d in dirnames if not d.startswith('.')]

                for filename in filenames:
                    if filename.startswith('.'):
                        continue

                    print("FILENAME", filename)
                    file_path = os.path.join(dirpath, filename)
                    print("FILEPATH", file_path)
                    if os.path.isfile(file_path):
                        current_file_dict: dict= {}
                        try:
                            with open(file_path, 'r') as f:
                                try:
                                    file_content = f.read()
                                    print("Reading content length:", len(file_content))
                                    #self.ccg.append({filename: create_code_context_graph(file_content)})
                                    current_file_dict[filename.split(".")[0]] = self.create_code_context_graph(file_content)
                                    self.ccg.append(current_file_dict)
                                    print("CCG", self.ccg)
                                    print(f"📖 Read file: {file_path}")
                                except Exception as e:
                                    import traceback
                                    print(f"⚠️ Could not read {file_path}: {e}")
                                    traceback.print_exc()

                        except Exception as e:
                            print(f"⚠️ Could not read {file_path}: {e}")

        elif os.path.isfile(root_dir):
            # handle the case where root_dir is itself a file
            try:
                with open(root_dir, 'r', encoding='utf-8') as f:
                    contents.append(f.read())
                print(f"📖 Read single file: {root_dir}")
            except Exception as e:
                print(f"⚠️ Could not read {root_dir}: {e}")

        else:
            print(f"⚠️ {root_dir} is not a valid file or directory")
        ::py::
            
}


