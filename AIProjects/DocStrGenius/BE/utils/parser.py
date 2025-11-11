import ast

def parse_file(filepath):
    with open(filepath, "r") as f:
        tree = ast.parse(f.read())

    functions = []
    classes = []

    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            calls = [n.func.id for n in ast.walk(node) if isinstance(n, ast.Call) and isinstance(n.func, ast.Name)]
            functions.append({
                "name": node.name,
                "calls": calls
            })
        elif isinstance(node, ast.ClassDef):
            inherits = [base.id for base in node.bases if isinstance(base, ast.Name)]
            classes.append({
                "name": node.name,
                "inherits": inherits
            })

    return {
        "functions": functions,
        "classes": classes
    }
