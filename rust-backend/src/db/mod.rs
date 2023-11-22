pub mod database;

use r2d2_sqlite::SqliteConnectionManager;

pub type Pool = r2d2::Pool<SqliteConnectionManager>;

pub fn get_db_pool() -> Pool {
    let manager = SqliteConnectionManager::file("db/tasks.sqlite");
    Pool::new(manager).expect("Failed to load database, have you run db/setup_db.sh?")
}
