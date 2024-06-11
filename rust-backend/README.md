# rust-backend

The backend for the ToDo demo-app written in rust.
This app features the actix-web framework to build a REST-API.
Data is persisted in an SQLite database which is accessed via connection pool.
In the given connection pooling setup it is fairly easy to exchange the SQLite e.g. by a Postgres DB.

## To run locally
1. Download and install rust https://www.rust-lang.org/tools/install
2. Run ```db/setup_db.sh``` in order to build & initialize the SQLite database. (Might require you to install sqlite on your machine)
3. Start the api with ```cargo run```

Alternatively  you can execute `make` when rust is installed.

## Rust development
To get started into rust development find help in the links below:
- https://doc.rust-lang.org/stable/book/
- https://doc.rust-lang.org/rust-by-example/
