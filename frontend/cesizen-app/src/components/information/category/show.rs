use cesizen_api::api::{
    information_category::InformationCategory, information_content::InformationContent, uuid::Uuid,
};
use dioxus::{logger::tracing::info, prelude::*};

use crate::API;

#[component]
pub fn Show(id: Uuid) -> Element {
    let nav = navigator();

    let get_category =
        use_resource(move || async move { InformationCategory::get(&API.read(), &id).await });

    let list_contents =
        use_resource(move || async move { InformationContent::list(&API.read(), Some(&id)).await });

    rsx! {
        div { class: "h-full flex items-center justify-center", "Test" }
    }
}
