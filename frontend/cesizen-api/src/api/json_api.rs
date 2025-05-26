use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
#[serde(untagged)]
pub enum Response {
    Success {
        data: ResponseData,
        included: Option<Vec<Data>>,
        meta: serde_json::Value,
    },
    Error {
        errors: Vec<Error>,
    },
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(untagged)]
pub enum ResponseData {
    Resource(Data),
    Collection(Vec<Data>),
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Data {
    pub attributes: serde_json::Value,
    pub id: String,
    pub relationships: serde_json::Value,
    #[serde(rename = "type")]
    pub resource_name: String,
}

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct RelationshipData {
    pub data: Option<ResourceIdentifier>,
}

#[derive(Debug, Serialize, Deserialize, Default, Clone)]
pub struct Relationship<T> {
    pub data: Option<T>,
    // #[serde(default)]
    // pub links: Links,
    // #[serde(default)]
    // pub meta: Meta,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ResourceIdentifier {
    pub id: String,
    #[serde(rename = "type")]
    resource_type: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct LoginMeta {
    pub token: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Error {
    pub code: String,
    pub id: String,
    pub meta: serde_json::Value,
    pub status: i16,
    pub title: String,
    pub source: serde_json::Value,
    pub detail: String,
}
