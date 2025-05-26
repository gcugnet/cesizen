use crate::utils::string::StringPreview;
use cesizen_api::api::{information_content::InformationContent, uuid::Uuid};
use dioxus::{logger::tracing::info, prelude::*};

use crate::{Route, API};

#[component]
pub fn List(id: Option<Uuid>) -> Element {
    let nav = navigator();

    let category_id = id;

    let list_contents = use_resource(move || async move {
        InformationContent::list(&API.read(), category_id.as_ref()).await
    });

    rsx! {
        match &*list_contents.read_unchecked() {
            Some(Ok(contents)) => rsx! {
                // div { class: "container mx-auto px-4",
                div { class: "flex flex-wrap gap-6 justify-center",
                    for content in contents.iter() {
                        div { class: "mx-6 mb-6 card md:w-[80vw] lg:w-[40vw] 2xl:w-[30vw] bg-base-100 card-l shadow-sm",
                            div { class: "card-body items-center text-center",
                                div { class: "card-title", "{content.title()}" }
                                p { "{content.body().preview(200)}" }
                                button {
                                    class: "mt-2 btn btn-primary",
                                    onclick: {
                                        let category_id = *content.category_id();
                                        info!("{category_id}");
                                        let content_id = *content.id();
                                        move |_| {
                                            nav.push(Route::Content {
                                                category_id,
                                                content_id,
                                            });
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
            None => rsx! {},
        }
    }
}
