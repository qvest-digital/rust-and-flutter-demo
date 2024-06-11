use crate::api::error::ApiError;
use crate::db::database::Database;
use crate::db::Pool;
use crate::shared::{CreateTask, Task};
use actix_web::http::StatusCode;
use actix_web::web::{Data, Json, Path};
use actix_web::{delete, get, options, post, HttpResponse};
use std::result;

type Result<T> = result::Result<T, ApiError>;

#[get("/health")]
pub async fn health() -> &'static str {
    "Up and running!"
}

#[get("/tasks")]
pub async fn get_tasks(pool: Data<Pool>) -> Result<Json<Vec<Task>>> {
    let db = Database::from(pool);
    let result = db.get_tasks()?;
    Ok(Json(result))
}

#[post("/tasks")]
pub async fn create_task(task: Json<CreateTask>, pool: Data<Pool>) -> Result<HttpResponse> {
    let db = Database::from(pool);
    db.create_task(task.into_inner())?;
    Ok(HttpResponse::new(StatusCode::CREATED))
}

#[delete("/tasks/{id}")]
pub async fn set_task_done(id: Path<String>, pool: Data<Pool>) -> Result<HttpResponse> {
    let db = Database::from(pool);
    db.set_task_done(&id.into_inner())?;
    Ok(HttpResponse::new(StatusCode::ACCEPTED))
}

#[options("/tasks")]
pub async fn preflight_tasks() -> HttpResponse {
    HttpResponse::Ok()
        .insert_header(("Access-Control-Allow-Methods", "GET,POST,OPTIONS"))
        .insert_header(("Access-Control-Allow-Headers", "*"))
        .finish()
}

#[options("/tasks/{id}")]
pub async fn preflight_tasks_id() -> HttpResponse {
    HttpResponse::Ok()
        .insert_header(("Access-Control-Allow-Methods", "DELETE,OPTIONS"))
        .insert_header(("Access-Control-Allow-Headers", "*"))
        .finish()
}
