use std::result;
use std::sync::Arc;

use actix_web::web::Data;
use r2d2::PooledConnection;
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::ffi::SQLITE_INTERNAL;
use rusqlite::{ffi, params, Error};

use crate::db::Pool;
use crate::shared::{CreateTask, Task};

type Result<T> = result::Result<T, Error>;

pub struct Database {
    pool: Arc<Pool>,
}

impl From<Data<Pool>> for Database {
    fn from(value: Data<Pool>) -> Self {
        Self {
            pool: value.into_inner(),
        }
    }
}

impl Database {
    fn get_connection(&self) -> Result<PooledConnection<SqliteConnectionManager>> {
        match self.pool.get() {
            Ok(conn) => Ok(conn),
            Err(_) => Err(Error::SqliteFailure(
                ffi::Error::new(SQLITE_INTERNAL),
                Some(String::from("")),
            )),
        }
    }

    pub fn create_task(&self, dto: CreateTask) -> Result<()> {
        let task = Task::from(dto);
        let conn = self.get_connection()?;
        let mut stmt = conn.prepare("INSERT INTO task VALUES(?,?,?,?,?)")?;
        stmt.execute(params![
            task.id.to_string(),
            task.title,
            task.description,
            task.created.to_string(),
            task.done
        ])?;
        Ok(())
    }

    pub fn get_tasks(&self) -> Result<Vec<Task>> {
        let conn = self.get_connection()?;
        let mut stmt = conn.prepare("SELECT * FROM task ORDER BY done ASC, created DESC")?;
        let result = stmt
            .query_map(params![], |row| Task::from_row(row))?
            .filter(|res| res.is_ok())
            .map(|res| res.unwrap())
            .collect::<Vec<Task>>();
        Ok(result)
    }

    pub fn set_task_done(&self, id: &str) -> Result<()> {
        let conn = self.get_connection()?;
        let mut stmt = conn.prepare("UPDATE task SET done = true WHERE id = ?")?;
        let affected_rows = stmt.execute(params![id])?;
        if affected_rows > 0 {
            return Ok(());
        }
        Err(Error::QueryReturnedNoRows)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::shared::CreateTask;
    use r2d2_sqlite::SqliteConnectionManager;
    use std::sync::Arc;

    #[test]
    fn test_create_task() {
        // create & initialize in-memory database
        let manager = SqliteConnectionManager::memory();
        let pool = Pool::new(manager).unwrap();
        let db = Database {
            pool: Arc::new(pool),
        };
        init_db(&db).expect("Failed to initialize database");

        // create task
        let dto = CreateTask {
            title: String::from("Test Task"),
            description: None,
        };

        // verify task creation
        let result = db.create_task(dto);
        assert!(result.is_ok());
    }

    #[test]
    fn test_get_tasks() {
        // create & initialize in-memory database
        let manager = SqliteConnectionManager::memory();
        let pool = Pool::new(manager).unwrap();
        let db = Database {
            pool: Arc::new(pool),
        };
        init_db(&db).expect("Failed to initialize database");

        // create task
        let dto = CreateTask {
            title: String::from("Test Task"),
            description: Some(String::from("Test Description")),
        };
        db.create_task(dto).expect("Failed to create task");

        // verify task retrieval
        let result = db.get_tasks();
        assert!(result.is_ok());
        let tasks = result.unwrap();
        assert_eq!(tasks.len(), 1);
        let task = tasks.get(0).expect("Failed to get task");
        assert_eq!(task.title, "Test Task");
        assert!(task.description.is_some());
        let description = task
            .description
            .as_ref()
            .expect("Failed to unwrap description");
        assert_eq!(description, "Test Description");
    }

    #[test]
    fn test_set_task_done() {
        // create & initialize in-memory database
        let manager = SqliteConnectionManager::memory();
        let pool = Pool::new(manager).unwrap();
        let db = Database {
            pool: Arc::new(pool),
        };
        init_db(&db).expect("Failed to initialize database");

        // create task
        let dto = CreateTask {
            title: String::from("Test Task"),
            description: None,
        };
        db.create_task(dto).expect("Failed to create task");

        // set task done
        let tasks = db.get_tasks().unwrap();
        let task = &tasks[0];
        let result = db.set_task_done(&task.id.to_string());
        assert!(result.is_ok());
    }

    fn init_db(db: &Database) -> Result<()> {
        match db.get_connection().unwrap().execute(
            "CREATE TABLE task (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT,
                created TEXT NOT NULL,
                done BOOLEAN NOT NULL
            )",
            params![],
        ) {
            Ok(_) => Ok(()),
            Err(e) => Err(e),
        }
    }
}
