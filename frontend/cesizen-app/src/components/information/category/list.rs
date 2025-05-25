use crate::utils::string::StringPreview;
use cesizen_api::api::information_category::InformationCategory;
use dioxus::prelude::*;

use crate::{Route, API};

#[component]
pub fn List() -> Element {
    let nav = navigator();

    let list_categories =
        use_resource(move || async move { InformationCategory::list(&API.read()).await });

    rsx! {
        div { class: "h-full flex items-center justify-center",
            match &*list_categories.read_unchecked() {
                Some(Ok(categories)) => rsx! {
                    ul {
                        for category in categories.iter() {
                            div { class: "m-12 card w-96 bg-base-100 card-xl shadow-sm",
                                div { class: "card-body items-center text-center",
                                    div { class: "card-title", "{category.name()}" }
                                    if let Some(description) = category.description() {
                                        p { "{description.preview(70)}" }
                                    }
                                    button {
                                        class: "mt-2 btn btn-primary",
                                        onclick: {
                                            let id = *category.id();
                                            move |_| {
                                                nav.push(Route::Category { id });
                                            }
                                        },
                                        "Voir"
                                    }
                                }
                            }
                        }
                    }
                },
                Some(Err(e)) => rsx! {
                    div { "Erreur lors de la récupération des catégories : {e}" }
                },
                None => rsx! {
                    div { "Chargement ..." }
                },
            }
        }
    }
}
