use cesizen_helpers::tracing::LogResult;
use serde::{Deserialize, Serialize};
use thiserror::Error;

use super::{CesizenApi, json_api};

#[derive(Debug, Serialize, Deserialize)]

pub struct InformationCategory {
    id: String,
    attributes: InformationCategoryAttributes,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InformationCategoryAttributes {
    name: String,
    description: Option<String>,
}

#[derive(Debug, Error)]
pub enum ListError {
    #[error("An error occurred during the list information categories API request.")]
    ApiError(#[from] super::ApiError),
    #[error("Failed to parse information categories.")]
    ParseError(#[source] serde_json::Error),
    #[error("The list of information categories don’t match this application requirements.")]
    FormatError,
    #[error("An unknown error occurred while listing information categories.")]
    UnknownError(Vec<json_api::Error>),
}

#[derive(Debug, Error)]
pub enum GetError {
    #[error("An error occurred during the get information category API request.")]
    ApiError(#[from] super::ApiError),
    #[error("Failed to parse information category.")]
    ParseError(#[source] serde_json::Error),
    #[error("The information category doesn’t match this application requirements.")]
    FormatError,
    #[error("An unknown error occurred while getting information category.")]
    UnknownError(Vec<json_api::Error>),
}

impl InformationCategory {
    pub fn id(&self) -> &str {
        &self.id
    }

    pub fn name(&self) -> &str {
        &self.attributes.name
    }

    pub fn description(&self) -> &Option<String> {
        &self.attributes.description
    }

    pub async fn list(api: &CesizenApi) -> Result<Vec<InformationCategory>, ListError> {
        let response = api.get("information/categories").await?;

        match response {
            json_api::Response::Success { data, .. } => match data {
                json_api::ResponseData::Collection(items) => {
                    let categories = items
                        .iter()
                        .map(|item| serde_json::from_value(serde_json::to_value(item).unwrap()))
                        .collect::<Result<Vec<InformationCategory>, serde_json::Error>>()
                        .map_err(ListError::ParseError)
                        .log_err()?;

                    Ok(categories)
                }
                json_api::ResponseData::Resource(_) => Err(ListError::FormatError).log_err(),
            },
            json_api::Response::Error { errors } => Err(ListError::UnknownError(errors)).log_err(),
        }
    }

    pub async fn get(api: &CesizenApi, id: &str) -> Result<InformationCategory, GetError> {
        let endpoint = format!("information/categories/{id}");
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
