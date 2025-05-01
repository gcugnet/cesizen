mod json_api;

use reqwest::{Client, Response, StatusCode};
use thiserror::Error;

#[derive(Clone)]
pub struct CesizenApi {
    base_url: String,
    client: Client,
}

#[derive(Debug, Error)]
pub enum ApiError {
    #[error("API route not found.")]
    NotFound,
    #[error("An error occurred during authentication process.")]
    AuthenticationError,
    #[error("An unknown error occurred.")]
    UnknownError,
    #[error("An error occurrend during the API request.")]
    RequestError(#[from] reqwest::Error),
}

impl CesizenApi {
    pub fn new() -> Self {
        CesizenApi {
            base_url: String::from("http://localhost:4000/api/v1"),
            client: Client::new(),
        }
    }

    /// Sends a HTTP GET request.
    async fn get(&self, endpoint: &str) -> Result<json_api::Response, ApiError> {
        let response = self
            .client
            .get(format!("{}/{}", &self.base_url, endpoint))
            .send()
            .await?;

        self.handle_response(response).await
    }

    /// Handles server responses.
    async fn handle_response(&self, response: Response) -> Result<json_api::Response, ApiError> {
        match response.status() {
            StatusCode::OK | StatusCode::CREATED | StatusCode::ACCEPTED => {
                let json_response = response.json::<json_api::Response>().await?;

                Ok(json_response)
            }
            StatusCode::NOT_FOUND => Err(ApiError::NotFound),
            StatusCode::UNAUTHORIZED => Err(ApiError::AuthenticationError),
            _ => Err(ApiError::UnknownError),
        }
    }
}

impl Default for CesizenApi {
    fn default() -> Self {
        Self::new()
    }
}
