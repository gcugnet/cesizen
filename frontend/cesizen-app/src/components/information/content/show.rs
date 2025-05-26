use cesizen_api::api::{information_content::InformationContent, uuid::Uuid};
use dioxus::{html::nav, logger::tracing::info, prelude::*};

use crate::{Route, API};

#[component]
pub fn Show(category_id: Uuid, content_id: Uuid) -> Element {
    let nav = navigator();
    let get_content =
        use_resource(
            move || async move { InformationContent::get(&API.read(), &content_id).await },
        );

    rsx! {
        div { class: "h-full items-center justify-center",
            match &*get_content.read_unchecked() {
                Some(Ok(content)) => rsx! {
                    div { class: "col-span-2 my-6 card w-full bg-base-100 card-xl shadow-sm",
                        div { class: "card-body items-center text-center",
                            div { class: "card-title", "{content.title()}" }
                            p { "{content.body()}" }
                        }
                    }
                },
                Some(Err(e)) => rsx! {
                    {
                        info!("{:?}", e);
                        let _ = nav
                            .push(Route::NotFound {
                                route: vec!["information/contents".to_string(), content_id.to_string()],
                            });
                        rsx! { "" }
                    }
                },
                None => rsx! {},
            }
        }
    }
}
