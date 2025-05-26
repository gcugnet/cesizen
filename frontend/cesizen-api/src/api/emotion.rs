use cesizen_helpers::tracing::LogResult;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use thiserror::Error;
use uuid::Uuid;

use super::{CesizenApi, json_api};

#[derive(Debug, Serialize, Deserialize, Clone)]

pub struct Emotion {
    id: Uuid,
    attributes: EmotionAttributes,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct EmotionAttributes {
    basic_emotion_id: Uuid,
    name: String,
    inserted_at: DateTime<Utc>,
}

#[derive(Debug, Error)]
pub enum ListError {
    #[error("An error occurred during the list emotions API request.")]
    ApiError(#[from] super::ApiError),
    #[error("Failed to parse emotions.")]
    ParseError(#[source] serde_json::Error),
    #[error("The list of emotions don’t match this application requirements.")]
    FormatError,
    #[error("An unknown error occurred while listing emotions.")]
    UnknownError(Vec<json_api::Error>),
}

#[derive(Debug, Error)]
pub enum GetError {
    #[error("An error occurred during the get emotion API request.")]
    ApiError(#[from] super::ApiError),
    #[error("Failed to parse emotion.")]
    ParseError(#[source] serde_json::Error),
    #[error("The emotion doesn’t match this application requirements.")]
    FormatError,
    #[error("An unknown error occurred while getting emotion.")]
    UnknownError(Vec<json_api::Error>),
}

impl Emotion {
    pub fn id(&self) -> &Uuid {
        &self.id
    }

    pub fn basic_emotion_id(&self) -> &Uuid {
        &self.attributes.basic_emotion_id
    }

    pub fn name(&self) -> &str {
        &self.attributes.name
    }

    pub fn inserted_at(&self) -> &DateTime<Utc> {
        &self.attributes.inserted_at
    }

    pub async fn list(api: &CesizenApi) -> Result<Vec<Emotion>, ListError> {
        let response = api.get("emotions").await?;

        match response {
            json_api::Response::Success { data, .. } => match data {
                json_api::ResponseData::Collection(items) => {
                    let categories = items
                        .iter()
                        .map(|item| serde_json::from_value(serde_json::to_value(item).unwrap()))
                        .collect::<Result<Vec<Emotion>, serde_json::Error>>()
                        .map_err(ListError::ParseError)
                        .log_err()?;

                    Ok(categories)
                }
                json_api::ResponseData::Resource(_) => Err(ListError::FormatError).log_err(),
            },
            json_api::Response::Error { errors } => Err(ListError::UnknownError(errors)).log_err(),
        }
    }

    pub async fn get(api: &CesizenApi, id: &Uuid) -> Result<Emotion, GetError> {
        let endpoint = format!("emotions/{}", id);
        let response = api.get(&endpoint).await?;

        match response {
            json_api::Response::Success { data, .. } => match data {
                json_api::ResponseData::Resource(item) => {
                    let category = serde_json::from_value(serde_json::to_value(item).unwrap())
                        .map_err(GetError::ParseError)
                        .log_err()?;

                    Ok(category)
                }
                json_api::ResponseData::Collection(_) => Err(GetError::FormatError).log_err(),
            },
            json_api::Response::Error { errors } => Err(GetError::UnknownError(errors)).log_err(),
        }
    }
}
