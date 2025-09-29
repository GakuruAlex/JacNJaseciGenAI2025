def working_with_decorators(func: callable)-> callable{
    def wrapper(*args: any, **kwargs: any)-> any{
        print("Decorator start");
            result: any = func(*args, **kwargs);
        print("Decorator end");
        return result;

    }
    return wrapper;
}


@working_with_decorators
def greet(name: str) -> None{
    print(f"hello, {name}");
}

with entry{
    greet("Jane");
}