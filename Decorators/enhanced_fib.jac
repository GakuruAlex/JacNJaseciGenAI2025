import time;
import from functools {lru_cache}
def cache_decorator(func: callable)-> callable{
    cache: dict[int, int] = {};

    def wrapper(*args: any)-> any{
        cache_key = args;
        if cache_key in cache{
            #print(f"Cache hit for {func.__name__}{args}");
            return cache[cache_key];
        }
        result = func(*args);
        cache[cache_key] = result;
        return result;
    }

    return wrapper;
}


@cache_decorator
#@lru_cache(maxsize = None)
def efficient_fib(number: int) -> int{
    if number <=1{
        return number;
    }
    return efficient_fib(number-1) + efficient_fib(number-2);
}



with entry{

    number: int = 100;

    start_time: any = time.time_ns();

    efficient: int = efficient_fib(number);

    end_time: any = time.time_ns();

    elapsed_ns: any = round(((end_time - start_time) / 1_000_000), 10);



    print(f"Fib {number} = {efficient} using cache decorator and took roughly {elapsed_ns} ms ");
}