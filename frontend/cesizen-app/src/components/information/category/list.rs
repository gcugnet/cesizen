use cesizen_api::api::information_category::InformationCategory;
use dioxus::{logger::tracing::info, prelude::*};

use crate::API;

#[component]
pub fn List() -> Element {
    let mut information_categories = use_signal(Vec::new);

    let _list_categories = use_resource(move || async move {
        match InformationCategory::list(&API.read()).await {
            Ok(categories) => information_categories.set(categories),
            Err(e) => info!("Erreur: {e}"),
        }
    });

    rsx! {
        div { class: "h-[60vh] grow flex items-center justify-center",
            ul {
                for category in information_categories.iter() {
                    div { class: "m-12 card w-96 bg-base-100 card-xl shadow-sm",

                        div { class: "card-body items-center text-center",
                            div { class: "card-title", "{category.name()}" }
                            if let Some(description) = category.description() {
                                p { "{description}" }
                            }
                            button { class: "my-2 btn btn-primary", "Voir" }
                        }
                    }
                }
            }
        }
    }
}
