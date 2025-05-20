use cesizen_helpers::tracing::LogResult;
use serde::{Deserialize, Serialize};
use thiserror::Error;

use super::information_category::InformationCategory;
use super::{CesizenApi, json_api};

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ContentType {
    Text,
    Image,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InformationContent {
    id: String,
    attributes: InformationContentAttributes,
    #[serde(default)]
    relationships: Relationships,
    #[serde(skip)]
    category: Option<InformationCategory>,
}

#[derive(Debug, Serialize, Deserialize, Default)]
pub struct Relationships {
    #[serde(default)]
    category: RelationshipData,
}

#[derive(Debug, Serialize, Deserialize, Default)]
pub struct RelationshipData {
    data: Option<ResourceIdentifier>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ResourceIdentifier {
    id: String,
    #[serde(rename = "type")]
    resource_type: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct InformationContentAttributes {
    // category: Option<InformationCategory>,
    category_id: String,
    title: String,
    #[serde(rename = "type")]
    content_type: ContentType,
    body: String,
}

#[derive(Debug, Error)]
pub enum ListError {
    #[error("An error occurred during the list information contents API request.")]
    ApiError(#[from] super::ApiError),
    #[error("Failed to parse information contents.")]
    ParseError(#[source] serde_json::Error),
    #[error("The list of information contents don’t match this application requirements.")]
    FormatError,
    #[error("An unknown error occurred while listing information contents.")]
    UnknownError(Vec<json_api::Error>),
}

#[derive(Debug, Error)]
pub enum GetError {
    #[error("An error occurred during the get information content API request.")]
    ApiError(#[from] super::ApiError),
    #[error("Failed to parse information content.")]
    ParseError(#[source] serde_json::Error),
    #[error("The information content doesn’t match this application requirements.")]
    FormatError,
    #[error("An unknown error occurred while getting information content.")]
    UnknownError(Vec<json_api::Error>),
}

impl InformationContent {
    // Getter methods
    pub fn id(&self) -> &str {
        &self.id
    }

    pub fn category_id(&self) -> &str {
        &self.attributes.category_id
    }

    pub fn category(&self) -> Option<&InformationCategory> {
        self.category.as_ref()
    }

    pub fn title(&self) -> &str {
        &self.attributes.title
    }

    pub fn content_type(&self) -> &ContentType {
        &self.attributes.content_type
    }

    pub fn body(&self) -> &str {
        &self.attributes.body
    }

    // API functions
    pub async fn list(api: &CesizenApi) -> Result<Vec<InformationContent>, ListError> {
        let response = api.get("information/contents").await?;

        match response {
            json_api::Response::Success { data, .. } => match data {
                json_api::ResponseData::Collection(items) => {
                    let contents = items
                        .iter()
                        .map(|item| serde_json::from_value(serde_json::to_value(item).unwrap()))
                        .collect::<Result<Vec<InformationContent>, serde_json::Error>>()
                        .map_err(ListError::ParseError)
                        .log_err()?;

                    Ok(contents)
                }
                json_api::ResponseData::Resource(_) => Err(ListError::FormatError).log_err(),
            },
            json_api::Response::Error { errors } => Err(ListError::UnknownError(errors)).log_err(),
        }
    }

    pub async fn get(api: &CesizenApi, id: &str) -> Result<InformationContent, GetError> {
        let endpoint = format!("information/contents/{id}?include=category");
        let response = api.get(&endpoint).await?;

        match response {
            json_api::Response::Success { data, included, .. } => match data {
                json_api::ResponseData::Resource(item) => {
                    let mut content: InformationContent =
                        serde_json::from_value(serde_json::to_value(item).unwrap())
                            .map_err(GetError::ParseError)
                            .log_err()?;

                    if let Some(included_data) = included {
                        for include in included_data {
                            if include.resource_name == "category"
                                && Some(include.id.clone())
                                    == content
                                        .relationships
                                        .category
                                        .data
                                        .as_ref()
                                        .map(|d| d.id.clone())
                            {
                                content.category =
                                    serde_json::from_value(serde_json::to_value(include).unwrap())
                                        .map_err(GetError::ParseError)
                                        .log_err()
                                        .ok();
                            }
                        }
                    }

                    Ok(content)
                }
                json_api::ResponseData::Collection(_) => Err(GetError::FormatError).log_err(),
            },
            json_api::Response::Error { errors } => Err(GetError::UnknownError(errors)).log_err(),
        }
    }
}
