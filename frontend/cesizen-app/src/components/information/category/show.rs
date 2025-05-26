use cesizen_api::api::{information_category::InformationCategory, uuid::Uuid};
use dioxus::{logger::tracing::info, prelude::*};

use crate::{Route, API};

#[component]
pub fn Show(id: Uuid) -> Element {
    let nav = navigator();

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
                    {
                        info!("{:?}", e);
                        let _ = nav
                            .push(Route::NotFound {
                                route: vec![
                                    "information".to_string(),
                                    "categories".to_string(),
                                    id.to_string(),
                                ],
                            });
                        rsx! { "" }
                    }
                },
                None => rsx! {},
            }
        }
    }
}
