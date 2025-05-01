use serde::{Deserialize, Serialize};
use thiserror::Error;

use super::{CesizenApi, json_api};

#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    name: String,
    email: String,
    role: Role,
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
enum Role {
    User,
    Admin,
}

#[derive(Debug, Error)]
pub enum ListError {
    #[error("An error occurred during the API request.")]
    ApiError(#[from] super::ApiError),
    #[error("Failed to parse users.")]
    ParseError(#[from] serde_json::Error),
    #[error("Failed to format response.")]
    FormatError,
    #[error("An unknown error occurred.")]
    UnknownError(Vec<json_api::Error>),
}

impl User {
    pub async fn list(api: &CesizenApi) -> Result<Vec<User>, ListError> {
        let response = api.get("users").await?; // Returns if ApiError

        match response {
            json_api::Response::Success { data } => match data {
                json_api::ResponseData::Collection(items) => {
                    let users: Vec<User> = items
                        .iter()
                        .map(|item| serde_json::from_value(item.attributes.clone()))
                        .collect::<Result<Vec<User>, serde_json::Error>>()?;
                    Ok(users)
                }
                json_api::ResponseData::Resource(_) => Err(ListError::FormatError),
            },
            json_api::Response::Error { errors } => Err(ListError::UnknownError(errors)),
        }
    }
}
