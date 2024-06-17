use chrono::{DateTime, Local};
use rusqlite::Row;
use serde::{Deserialize, Serialize};
use std::str::FromStr;
use uuid::Uuid;

#[derive(Debug, Serialize)]
pub struct Task {
    pub id: Uuid,
    pub title: String,
    pub description: Option<String>,
    pub created: DateTime<Local>,
    pub done: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateTask {
    pub title: String,
    pub description: Option<String>,
}

impl From<CreateTask> for Task {
    fn from(value: CreateTask) -> Self {
        Self {
            id: Uuid::new_v4(),
            title: value.title,
            description: value.description,
            created: Local::now(),
            done: false,
        }
    }
}

impl Task {
    pub fn from_row(row: &Row) -> Result<Self, rusqlite::Error> {
        Ok(Self {
            id: Uuid::from_str(&row.get::<usize, String>(0)?).unwrap(),
            title: row.get(1)?,
            description: row.get(2)?,
            created: DateTime::from_str(&row.get::<usize, String>(3)?).unwrap(),
            done: row.get(4)?,
        })
    }
}
