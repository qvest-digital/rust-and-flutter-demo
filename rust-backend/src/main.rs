use env_logger::Env;
use std::io;

mod api;
mod db;
mod shared;

#[actix_web::main]
async fn main() -> io::Result<()> {
    env_logger::init_from_env(Env::default().default_filter_or("info"));
    api::run_server().await
}
