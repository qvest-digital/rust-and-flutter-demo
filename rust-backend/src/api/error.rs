use actix_web::body::BoxBody;
use actix_web::http::StatusCode;
use actix_web::{HttpResponse, HttpResponseBuilder, ResponseError};
use log::error;
use rusqlite::ErrorCode;
use std::error::Error;
use std::fmt::{Display, Formatter};

#[derive(Debug, Clone)]
pub struct ApiError {
    pub status: StatusCode,
    pub message: String,
}

impl Error for ApiError {}

impl ResponseError for ApiError {
    fn status_code(&self) -> StatusCode {
        self.status
    }
    fn error_response(&self) -> HttpResponse<BoxBody> {
        HttpResponseBuilder::new(self.status).body(self.to_owned().message)
    }
}

impl Display for ApiError {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.message)
    }
}

impl From<rusqlite::Error> for ApiError {
    fn from(e: rusqlite::Error) -> Self {
        let status = match &e {
            rusqlite::Error::QueryReturnedNoRows => StatusCode::NOT_FOUND,
            rusqlite::Error::SqliteFailure(error, _) => match error.code {
                ErrorCode::NotFound => StatusCode::NOT_FOUND,
                ErrorCode::ConstraintViolation => StatusCode::CONFLICT,
                _ => StatusCode::INTERNAL_SERVER_ERROR,
            },
            _ => {
                error!("database threw error: {}", e);
                StatusCode::INTERNAL_SERVER_ERROR
            }
        };
        Self {
            status,
            message: format!("{}", e),
        }
    }
}
