use cesizen_helpers::tracing::LogResult;
use serde::{Deserialize, Serialize};
use serde_json::json;
use thiserror::Error;
use uuid::Uuid;

use super::{
    CesizenApi,
    emotion::Emotion,
    json_api::{self, Relationship, ResourceIdentifier},
};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct User {
    id: Uuid,
    attributes: UserAttributes,
    relationships: UserRelationships,
    emotions: Option<Vec<Emotion>>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct UserAttributes {
    name: String,
    email: String,
    role: Role,
}

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct UserRelationships {
    #[serde(default)]
    emotions: Relationship<Vec<ResourceIdentifier>>,
}

#[derive(Debug, Serialize)]
pub struct UserParams {
    name: String,
    email: String,
    password: String,
    password_confirmation: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "snake_case")]
enum Role {
    User,
    Admin,
}

#[derive(Debug, Error)]
pub enum ListError {
    #[error("An error occurred during the list users API request.")]
    ApiError(#[from] super::ApiError),
    #[error("Failed to parse users.")]
    ParseError(#[source] serde_json::Error),
    #[error("The list user response's format don’t match this application requirements.")]
    FormatError,
    #[error("An unknown error occurred while listing users.")]
    UnknownError(Vec<json_api::Error>),
}

#[derive(Debug, Error)]
pub enum GetError {
    #[error("An error occurred during the get user API request.")]
    ApiError(#[from] super::ApiError),
    #[error("Failed to parse the user.")]
    ParseError(#[source] serde_json::Error),
    #[error("The user doesn’t match this application requirements.")]
    FormatError,
    #[error("An unknown error occurred while getting the user.")]
    UnknownError(Vec<json_api::Error>),
}

#[derive(Debug, Error)]
pub enum RegisterError {
    #[error("An error occurred during the list users API request.")]
    ApiError(#[from] super::ApiError),
    #[error("Failed to parse user.")]
    ParseError(#[source] serde_json::Error),
    #[error("The register user response's format don’t match this application requirements.")]
    FormatError,
    #[error("An unknown error occurred while registering the user.")]
    UnknownError(Vec<json_api::Error>),
}

impl User {
    pub fn id(&self) -> &Uuid {
        &self.id
    }

    pub fn name(&self) -> &str {
        &self.attributes.name
    }

    pub fn emotions(&self) -> &Option<Vec<Emotion>> {
        &self.emotions
    }

    /// Registers a user with a `name`, `email`, `password` and `password_confirmation`.
    pub async fn register(
        api: &CesizenApi,
        user_params: UserParams,
    ) -> Result<User, RegisterError> {
        let attributes = serde_json::to_value(user_params)
            .map_err(RegisterError::ParseError)
            .log_err()?;

        let body = json!({
            "data": {
                "type": "user",
                "attributes": attributes,
            }
        });

        let response = api.post("register", body).await?;

        match response {
            json_api::Response::Success { data, .. } => match data {
                json_api::ResponseData::Resource(resource) => {
                    let user: User = serde_json::from_value(resource.attributes.clone())
                        .map_err(RegisterError::ParseError)
                        .log_err()?;

                    Ok(user)
                }
                json_api::ResponseData::Collection(_) => Err(RegisterError::FormatError).log_err(),
            },
            json_api::Response::Error { errors } => Err(RegisterError::UnknownError(errors)),
        }
    }

    /// Get a single user with its associated emotions.
    pub async fn get(api: &CesizenApi, id: &Uuid) -> Result<User, GetError> {
        let endpoint = format!("users/{id}/?include=emotions");
        let response = api.get(&endpoint).await?;

        match response {
            json_api::Response::Success { data, included, .. } => match data {
                json_api::ResponseData::Resource(item) => {
                    let mut user: User =
                        serde_json::from_value(serde_json::to_value(item).unwrap())
                            .map_err(GetError::ParseError)
                            .log_err()?;

                    if let Some(included_data) = included {
                        // Get all emotion IDs from relationships
                        let emotion_ids: Vec<String> = user
                            .relationships
                            .emotions
                            .data
                            .as_ref()
                            .map(|resources| resources.iter().map(|r| r.id.clone()).collect())
                            .unwrap_or_default();

                        let included_emotions: Vec<_> = included_data
                            .into_iter()
                            .filter(|include| {
                                include.resource_name == "emotion"
                                    && emotion_ids.contains(&include.id)
                            })
                            .map(|include| {
                                serde_json::from_value(serde_json::to_value(include).unwrap())
                                    .map_err(GetError::ParseError)
                            })
                            .collect::<Result<Vec<_>, _>>()
                            .log_err()?;

                        user.emotions = Some(included_emotions);
                    }

                    Ok(user)
                }
                json_api::ResponseData::Collection(_) => Err(GetError::FormatError).log_err(),
            },
            json_api::Response::Error { errors } => Err(GetError::UnknownError(errors)).log_err(),
        }
    }

    /// Lists users.
    pub async fn list(api: &CesizenApi) -> Result<Vec<User>, ListError> {
        let response = api.get("users").await?; // Returns if ApiError

        match response {
            json_api::Response::Success { data, .. } => match data {
                json_api::ResponseData::Collection(items) => {
                    let users: Vec<User> = items
                        .iter()
                        .map(|item| serde_json::from_value(item.attributes.clone()))
                        .collect::<Result<Vec<User>, serde_json::Error>>()
                        .map_err(ListError::ParseError)
                        .log_err()?;

                    Ok(users)
                }
                json_api::ResponseData::Resource(_) => Err(ListError::FormatError).log_err(),
            },
            json_api::Response::Error { errors } => Err(ListError::UnknownError(errors)).log_err(),
        }
    }
}

impl UserParams {
    pub fn new(
        name: String,
        email: String,
        password: String,
        password_confirmation: String,
    ) -> Self {
        Self {
            name,
            email,
            password,
            password_confirmation,
        }
    }
}
