mod error;
mod routes;

use crate::db;
use actix_web::middleware::{DefaultHeaders, Logger};
use actix_web::{web, App, HttpServer};
use std::io;

pub async fn run_server() -> io::Result<()> {
    let pool = db::get_db_pool();
    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(pool.clone()))
            .wrap(Logger::default())
            .wrap(DefaultHeaders::new().add(("Access-Control-Allow-Origin", "*")))
            .service(routes::health)
            .service(routes::get_tasks)
            .service(routes::create_task)
            .service(routes::set_task_done)
            .service(routes::preflight_tasks)
            .service(routes::preflight_tasks_id)
    })
    .bind(("127.0.0.1", 8090))?
    .run()
    .await
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::db::Pool;
    use crate::shared::CreateTask;
    use actix_web::test;
    use actix_web::App;
    use r2d2_sqlite::SqliteConnectionManager;
    use rusqlite::params;

    #[actix_web::test]
    async fn test_get_health() {
        let app = test::init_service(App::new().service(routes::health)).await;
        let req = test::TestRequest::get().uri("/health").to_request();
        let resp = test::call_service(&app, req).await;
        assert!(resp.status().is_success());
    }

    #[actix_web::test]
    async fn test_get_tasks() {
        let pool = init_db();
        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(routes::get_tasks),
        )
        .await;
        let req = test::TestRequest::get().uri("/tasks").to_request();
        let resp = test::call_service(&app, req).await;
        assert!(resp.status().is_success());
        assert_eq!(test::read_body(resp).await, "[]");
    }

    #[actix_web::test]
    async fn test_post_task() {
        let pool = init_db();
        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(routes::create_task),
        )
        .await;
        let req = test::TestRequest::post()
            .uri("/tasks")
            .set_json(CreateTask {
                title: String::from("Test Task"),
                description: None,
            })
            .to_request();
        let resp = test::call_service(&app, req).await;
        assert!(resp.status().is_success());
    }

    #[actix_web::test]
    async fn test_delete_task() {
        let pool = init_db();
        // add a task to mark as done
        pool.get()
            .expect("Failed to get connection")
            .execute(
                "INSERT INTO task (id, title, description, created, done) VALUES (?1, ?2, ?3, ?4, ?5)",
                params!["1", "Test Task", "", "2021-01-01T00:00:00Z", 0],
            )
            .expect("Failed to insert task");

        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(routes::set_task_done),
        )
        .await;
        let req = test::TestRequest::delete().uri("/tasks/1").to_request();
        let resp = test::call_service(&app, req).await;
        assert!(resp.status().is_success());
    }

    #[actix_web::test]
    async fn test_delete_task_not_found() {
        let pool = init_db();

        let app = test::init_service(
            App::new()
                .app_data(web::Data::new(pool.clone()))
                .service(routes::set_task_done),
        )
        .await;
        let req = test::TestRequest::delete().uri("/tasks/1").to_request();
        let resp = test::call_service(&app, req).await;
        assert_eq!(resp.status(), 404);
    }

    fn init_db() -> Pool {
        let manager = SqliteConnectionManager::memory();
        let pool = Pool::new(manager).unwrap();
        pool.get()
            .expect("Failed to get connection")
            .execute(
                "CREATE TABLE IF NOT EXISTS task
                    (
                        id          TEXT PRIMARY KEY,
                        title       TEXT    NOT NULL,
                        description TEXT,
                        created     TEXT    NOT NULL,
                        done        INTEGER NOT NULL
                    );",
                [],
            )
            .expect("Failed to create table");
        pool
    }
}
