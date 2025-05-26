use crate::{API, CURRENT_USER};
use cesizen_api::api::emotion::Emotion;
use cesizen_api::api::user::User;
use dioxus::logger::tracing::info;
use dioxus::prelude::*;

/// The Home page component that will be rendered when the current route is `[Route::Home]`
#[component]
pub fn Emotions() -> Element {
    let mut basic_emotions = use_signal(|| None);
    let mut user = use_signal(|| None);

    let get_basic_emotions = move |_| {
        spawn(async move {
            let resp = Emotion::list(&API.read()).await;

            match resp {
                Ok(response) => {
                    basic_emotions.set(Some(response));
                }
                Err(e) => {
                    info!("Erreur {:?}", e);
                }
            }
        });
    };

    let get_user_emotions = move |_| {
        let current_user = CURRENT_USER.cloned();
        info!("{:?}", current_user);

        spawn(async move {
            let uuid = if let Some(user) = &current_user {
                Some(user.id())
            } else {
                None
            };

            if let Some(id) = uuid {
                let resp = User::get(&API.read(), id).await;

                match resp {
                    Ok(response) => {
                        user.set(Some(response));
                    }
                    Err(e) => {
                        info!("Erreur {:?}", e);
                    }
                }
            } else {
                info!("Error: CURRENT_USER uuid is None.")
            }
        });
    };

    rsx! {
        if let Some(user) = &*user.read() {
            if let Some(emotions) = user.emotions() {
                ul {
                    for emotion in emotions.iter() {
                        p { "{emotion.name()}" }
                    }
                }
            }
        }


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

        button { class: "btn btn-primary", onclick: get_user_emotions, "Get User Emotions" }
    }
}
