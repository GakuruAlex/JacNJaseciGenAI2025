node Book{
    has title: str;
    has genre: str;
    has price: float;

}

node Author{
    has name: str;
}


node Student{
    has name: str;
    has student_id: str;
}

edge Published{
    has published_on: str;
    has publishing_company: str; 
}


edge CheckedOut{
    has date_out: str;
    has duration: int;
    has expected_return: str;
}

walker RentedBooks {
    has books: list[str] = [];
    can start with `root entry{
        visit [-->];
    }
    can visit_book with Book entry{
        if [here ->:CheckedOut:->]{

        self.books.append(here.title);
        }

    }
}
with entry{

        # First book
    student_a =  Student(
        name="John Doe",
        student_id="Abdcs1234"
    );

    student_b = Student(
        name ="Jane Doe",
        student_id = "zshjjkswe"
    );

    book_b = Book(
        title="A tale of Jac",
        genre = "Programmming",
        price = 39.99
    );
    book_a = Book(
        title="Lion and the Witch",
        genre="Fantasy",
        price=49.99
    );
    published_book =Published(
        published_on="07/02/2002",
        publishing_company="J&D"
    );
    author = Author(
        name="Jane Doe"
    );
    author_2 = Author(name = "Magic Mike");

    book_a_checked_out =CheckedOut(
        date_out="28/09/2025",
        duration=3,
        expected_return="01/10/2025"
    );

    root ++> book_a;
    book_a +>:published_book:+> author;
    book_a +>:book_a_checked_out:+> student_a;

    root ++> book_b;
    book_b +>:published_book:+> author_2;
    book_b +>:book_a_checked_out:+> student_b;

    # Second book
    rented = RentedBooks() spawn root;


    # Spawn walker

    print(rented.books);

}

