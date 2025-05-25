use crate::utils::string::StringPreview;
use cesizen_api::api::{
    information_category::InformationCategory, information_content::InformationContent, uuid::Uuid,
};
use dioxus::prelude::*;

use crate::{Route, API};

#[component]
pub fn Show(id: Uuid) -> Element {
    let nav = navigator();

    let get_category =
        use_resource(move || async move { InformationCategory::get(&API.read(), &id).await });

    let list_contents =
        use_resource(move || async move { InformationContent::list(&API.read(), Some(&id)).await });

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
                None => rsx! {
                    div { "Chargement ..." }
                },
            }

            match &*list_contents.read_unchecked() {
                Some(Ok(contents)) => rsx! {
                    // div { class: "container mx-auto px-4",
                    div { class: "flex flex-wrap gap-6 justify-center",
                        for content in contents.iter() {
                            div { class: "mx-6 mb-6 card w-[40vw] bg-base-100 card-l shadow-sm",
                                div { class: "card-body items-center text-center",
                                    div { class: "card-title", "{content.title()}" }
                                    p { "{content.body().preview(200)}" }
                                    button {
                                        class: "mt-2 btn btn-primary",
                                        onclick: {
                                            let id = *content.id();
                                            move |_| {
                                                nav.push(Route::Category { id });
                                            }
                                        },
                                        "Voir"
                                    }
                                }
                                    // }
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
