use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
#[serde(untagged)]
pub enum Response {
    Success {
        data: ResponseData,
        // included: Vec<serde_json::Value>,
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
