use crate::db::Pool;
use crate::shared::{CreateTask, Task};
use actix_web::web::Data;
use r2d2::PooledConnection;
use r2d2_sqlite::SqliteConnectionManager;
use rusqlite::ffi::SQLITE_INTERNAL;
use rusqlite::{ffi, params, Error};
use std::result;
use std::sync::Arc;

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
