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
