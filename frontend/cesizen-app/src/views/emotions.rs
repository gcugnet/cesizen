use crate::{API, CURRENT_USER};
use cesizen_api::api::chrono::{DateTime, Local, Utc};
use cesizen_api::api::emotion::Emotion;
use cesizen_api::api::user::User;
use dioxus::logger::tracing::info;
use dioxus::prelude::*;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum EmotionsError {
    #[error("Failed to fetch emotions: {0}")]
    FetchError(String),

    #[error("User not found")]
    UserNotFound,

    #[error("Invalid data: {0}")]
    InvalidData(String),
}

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
            let uuid = current_user.as_ref().map(|user| user.id());

            if let Some(id) = uuid {
                let resp = User::get(&API.read(), id).await;

                match resp {
                    Ok(response) => {
                        info!("{:?}", response);
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

    fn get_sorted_emotions(user: &Option<User>) -> Result<Vec<Emotion>, EmotionsError> {
        if let Some(user) = user {
            if let Some(emotions) = user.emotions() {
                let mut sorted_emotions = emotions.to_vec();
                sorted_emotions.sort_by(|a, b| b.inserted_at().cmp(&a.inserted_at()));

                return Ok(sorted_emotions);
            }
        }

        Err(EmotionsError::FetchError(
            "Failed to get emotions".to_string(),
        ))
    }

    fn format_date_french(dt: &DateTime<Utc>) -> String {
        let local_dt = dt.with_timezone(&Local);
        let now = Local::now();

        // Get dates without time for comparison
        let date_only = local_dt.date_naive();
        let today = now.date_naive();

        let diff = today.signed_duration_since(date_only).num_days();

        match diff {
            0 => "Aujourd'hui".to_string(),
            1 => "Hier".to_string(),
            2 => "Avant-hier".to_string(),
            3..=7 => format!("Il y a {} jours", diff),
            _ => {
                // For older dates, show the actual date
                local_dt.format("%d/%m/%Y").to_string()
            }
        }
    }

    rsx! {
        div { class: "flex flex-col sm:flex-row gap-4 justify-center items-center p-4 mb-8",
            button { class: "btn btn-primary btn", onclick: get_basic_emotions, "Charger les émotions" }

            button { class: "btn btn-primary", onclick: get_user_emotions, "Mes émotions" }
        }

        div { class: "flex justify-center",
            if let Some(basic_emotions) = &*basic_emotions.read() {
                ul {
                    for emotion in basic_emotions.iter() {
                        div { class: "m-2 card w-96 bg-base-100 card-xs shadow-sm",
                            div { class: "card-body items-center text-center",
                                div { class: "card-title", "{emotion.name()}" }
                            }
                        }
                    }
                }
            }
        }

        div {
            if let Ok(sorted_emotions) = get_sorted_emotions(&user.read()) {
                div { class: "card w-full card-xl",
                    div { class: "card-body items-center",
                        div { class: "card-title", "Mes émotions" }
                        ul { class: "timeline timeline-vertical",
                            for (_index , emotion) in sorted_emotions.iter().enumerate() {
                                li { class: "timeline item",
                                    div { class: "timeline-start text-sm mr-2",
                                        p { class: "text-xs opacity-50",
                                            "{format_date_french(emotion.inserted_at())}"
                                        }
                                    }
                                    div { class: "timeline-middle",
                                        svg {
                                            width: "12",
                                            height: "12",
                                            view_box: "0 0 12 12",
                                            fill: "currentColor",
                                            class: "text-primary",
                                            circle { cx: "6", cy: "6", r: "6" }
                                        }
                                    }
                                    div { class: "timeline-end timeline-box font-bold my-4",
                                        "{emotion.name()}"
                                    }
                                    hr {}
                                    hr {}
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
