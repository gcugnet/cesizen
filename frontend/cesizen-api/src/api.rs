pub mod information_category;
pub mod information_content;
pub mod user;

mod json_api;

use cesizen_helpers::tracing::LogResult as _;
use json_api::LoginMeta;
use reqwest::{Client, Response, StatusCode, header::HeaderMap};
use serde_json::json;
use thiserror::Error;
use user::User;

#[derive(Clone)]
pub struct CesizenApi {
    base_url: String,
    client: Client,
    bearer_token: Option<String>,
}

#[derive(Debug, Error)]
pub enum ApiError {
    #[error("Failed to parse users.")]
    ParseError(#[source] serde_json::Error),
    #[error("API route not found.")]
    NotFound,
    #[error("An error occurred during authentication process.")]
    AuthenticationError,
    #[error("An unknown error occurred.")]
    UnknownError,
    #[error("An error occurrend during the API request.")]
    RequestError(#[source] reqwest::Error),
}

pub enum LoginInfo<'a> {
    Password { email: &'a str, password: &'a str },
}

#[derive(Debug, Error)]
pub enum LoginError {
    #[error("Failed to parse data during login.")]
    ParseError(#[source] serde_json::Error),
    #[error("The login response's format don’t match this application requirements.")]
    FormatError,
    #[error("Login attempted with invalid credentials.")]
    InvalidCredentials,
    #[error("An unknown error occurred during login.")]
    UnknownError(Vec<json_api::Error>),
    #[error("An error occurrend during the API request.")]
    RequestError(#[source] ApiError),
}

impl CesizenApi {
    pub fn new() -> Self {
        CesizenApi {
            base_url: String::from("http://localhost:4000/api/v1"),
            client: Client::new(),
            bearer_token: None,
        }
    }

    pub fn is_authenticated(&self) -> bool {
        if let Some(_bearer) = &self.bearer_token {
            return true;
        }

        false
    }

    pub fn set_bearer_token(&mut self, bearer_token: String) {
        self.bearer_token = Some(bearer_token);
    }

    /// Set request headers.
    ///
    /// The 'Content-Type' has to fit AshJsonApi's expectations.
    /// The authentication is also handled here ('Authorization' header).
    fn set_headers(&self) -> HeaderMap {
        let mut headers = HeaderMap::new();

        headers.insert(
            reqwest::header::ACCEPT,
            "application/vnd.api+json".parse().unwrap(),
        );
        headers.insert(
            reqwest::header::CONTENT_TYPE,
            "application/vnd.api+json".parse().unwrap(),
        );

        if let Some(token) = &self.bearer_token {
            headers.insert(
                reqwest::header::AUTHORIZATION,
                format!("Bearer {}", token).parse().unwrap(),
            );
        }

        headers
    }

    /// Logs a User in.
    ///
    /// Could handle different types of login.
    pub async fn login(&mut self, login_infos: LoginInfo<'_>) -> Result<User, LoginError> {
        match login_infos {
            LoginInfo::Password { email, password } => {
                self.login_with_password(email, password).await
            }
        }
    }

    /// Logs a User in with email and password.
    async fn login_with_password(
        &mut self,
        email: &str,
        password: &str,
    ) -> Result<User, LoginError> {
        let body = json!({
            "data": {
                "type": "user",
                "attributes": {
                    "email": email,
                    "password": password
                }
            }
        });

        let response = self
            .post("login", body)
            .await
            .map_err(LoginError::RequestError)
            .log_err()?;

        match response {
            json_api::Response::Success { data, meta } => match data {
                json_api::ResponseData::Resource(resource) => {
                    let user: User = serde_json::from_value(resource.attributes.clone())
                        .map_err(LoginError::ParseError)
                        .log_err()?;

                    let LoginMeta { token } = serde_json::from_value(meta)
                        .map_err(LoginError::ParseError)
                        .log_err()?;

                    self.set_bearer_token(token);

                    Ok(user)
                }
                json_api::ResponseData::Collection(_) => Err(LoginError::FormatError).log_err(),
            },
            json_api::Response::Error { errors } => Err(LoginError::UnknownError(errors)),
        }
    }

    /// Sends a HTTP GET request.
    async fn get(&self, endpoint: &str) -> Result<json_api::Response, ApiError> {
        let response = self
            .client
            .get(format!("{}/{}", &self.base_url, endpoint))
            .headers(self.set_headers())
            .send()
            .await
            .map_err(ApiError::RequestError)
            .log_err()?; // Returns if ReqwestError

        self.handle_response(response).await
    }

    /// Sends a HTTP POST request.
    async fn post(
        &self,
        endpoint: &str,
        body: serde_json::Value,
    ) -> Result<json_api::Response, ApiError> {
        let response = self
            .client
            .post(format!("{}/{}", &self.base_url, endpoint))
            .json(&body)
            .headers(self.set_headers())
            .send()
            .await
            .map_err(ApiError::RequestError)
            .log_err()?;

        self.handle_response(response).await
    }

    /// Handles server responses.
    async fn handle_response(&self, response: Response) -> Result<json_api::Response, ApiError> {
        match response.status() {
            StatusCode::OK | StatusCode::CREATED | StatusCode::ACCEPTED => {
                let json_response = response
                    .json::<json_api::Response>()
                    .await
                    .map_err(ApiError::RequestError)
                    .log_err()?;

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
