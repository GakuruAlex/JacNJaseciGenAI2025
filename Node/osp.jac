node Node{
    has name: str;
}

node EndNode{}
glob END = EndNode();


walker PathWalker{

    has input: str;

    can start with `root entry{
        visit [-->];
    } 
    can visit_node with Node entry{
        self.input += " visiting node " + here.name + ",";
        visit [-->];
    }
    can visit_end with EndNode entry{
        self.input += " end of nodes";
        return;
    }
}

with entry{
    root ++> Node(name="A")
         ++> Node(name="B")
         ++> END;

    nodewalker =  PathWalker("Starting traversal...") spawn root;

    print(nodewalker.input);

}