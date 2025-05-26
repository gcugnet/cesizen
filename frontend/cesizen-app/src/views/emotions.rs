use crate::API;
use cesizen_api::api::emotion::Emotion;
use dioxus::logger::tracing::info;
use dioxus::prelude::*;

/// The Home page component that will be rendered when the current route is `[Route::Home]`
#[component]
pub fn Emotions() -> Element {
    let mut basic_emotions = use_signal(|| None);

    let get_basic_emotions = move |_| {
        spawn(async move {
            let resp = Emotion::list(&API.read()).await;

            match resp {
                Ok(basic_emotions_response) => {
                    basic_emotions.set(Some(basic_emotions_response));
                }
                Err(e) => {
                    info!("Erreur {:?}", e);
                }
            }
        });
    };

    rsx! {
        if let Some(basic_emotions) = &*basic_emotions.read() {
            ul {
                for emotion in basic_emotions.iter() {
                    div { class: "m-12 card w-96 bg-base-100 card-xl shadow-sm",
                        div { class: "card-body items-center text-center",
                            div { class: "card-title", "{emotion.name()}" }
                        }
                    }
                }
            }
        }

        button { class: "btn btn-primary", onclick: get_basic_emotions, "Get Basic Emotions" }
    }
}
