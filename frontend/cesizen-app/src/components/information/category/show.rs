use cesizen_api::api::{information_category::InformationCategory, uuid::Uuid};
use dioxus::prelude::*;

use crate::API;

#[component]
pub fn Show(id: Uuid) -> Element {
    let get_category =
        use_resource(move || async move { InformationCategory::get(&API.read(), &id).await });

    rsx! {
        div { class: "h-full items-center justify-center",
            match &*get_category.read_unchecked() {
                Some(Ok(category)) => rsx! {
                    div { class: "col-span-2 my-6 card w-full bg-base-100 card-xl shadow-sm",
                        div { class: "card-body items-center text-center",
                            div { class: "card-title", "{category.name()}" }
                            if let Some(description) = category.description() {
                                p { "{description}" }
                            }
                        }
                    }
                },
                Some(Err(e)) => rsx! {
                    div { "Erreur lors de la récupération des catégories : {e}" }
                },
                None => rsx! {},
            }
        }
    }
}
