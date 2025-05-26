use cesizen_api::api::uuid::Uuid;
use dioxus::{logger::tracing::info, prelude::*};

use crate::{components::information::content::show::Show as ShowContent, Route};

#[component]
pub fn Content(category_id: Uuid, content_id: Uuid) -> Element {
    info!("Initial category_id: {category_id}");
    rsx! {
        div { class: "breadcrumbs text-sm",
            ul {
                li {
                    Link { to: Route::Home { greetings: false }, "Accueil" }
                }
                li {
                    Link {
                        to: {
                            info!("Category link category_id: {category_id}");
                            Route::Category { id: category_id }
                        },
                        "Catégorie"
                    }
                }
                li {
                    Link {
                        to: Route::Content {
                            category_id,
                            content_id,
                        },
                        "Contenu"
                    }
                }
            }
        }

        ShowContent { category_id, content_id }
    }
}
