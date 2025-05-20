use std::collections::HashMap;

use crate::components::user_form::{event_to_hashmap_string, Config, Fields};
use crate::{components::UserForm, Route, API, CURRENT_USER};
use cesizen_api::api::LoginInfo;
use dioxus::prelude::*;

#[derive(Default)]
enum LoginState {
    #[default]
    Initial,
    Loading,
    Error(String),
}

#[component]
pub fn Login() -> Element {
    let nav = navigator();

    let mut state = use_signal(LoginState::default);

    let user_form_config = Config {
        login_form: true,
        fields: vec![Fields::Email, Fields::Password],
    };

    let values: Signal<HashMap<String, dioxus::events::FormValue>> = use_signal(HashMap::new);

    let login = move |event: Event<FormData>| async move {
        state.set(LoginState::Loading);

        let formatted_data = event_to_hashmap_string(&event);

        spawn(async move {
            match API
                .write()
                .login(LoginInfo::Password {
                    email: formatted_data
                        .get("email")
                        .unwrap_or(&Default::default())
                        .as_str(),
                    password: formatted_data
                        .get("password")
                        .unwrap_or(&Default::default())
                        .as_str(),
                })
                .await
            {
                Ok(user) => {
                    CURRENT_USER.write().replace(user);
                    let _ = nav.push(Route::Home { greetings: true });
                }
                Err(_e) => {
                    state.set(LoginState::Error(
                        "Nom d’utilisateur ou mot de passe invalide.".to_string(),
                    ));
                }
            }
        });
    };

    rsx! {
        div { class: "my-4",
            match &*state.read() {
                LoginState::Loading => rsx! {
                    div { class: "alert alert-info", "Connexion en cours ..." }
                },
                LoginState::Error(err) => rsx! {
                    div { class: "alert alert-error", "Erreur: {err}" }
                },
                LoginState::Initial => rsx! {},
            }
        }

        div { class: "h-full grow flex flex-col items-center justify-center",
            div { class: "h-full grow flex flex-col items-center justify-center",
                UserForm {
                    values,
                    config: user_form_config,
                    fieldset_label: "Formulaire de connexion".to_string(),
                    button_text: "Se connecter".to_string(),
                    action: login,
                }

            }

            div { class: "m-8 flex flex-col text-xs font-medium items-center",
                "Vous n’avez pas encore de compte ?"
                Link {
                    class: "mx-4 mt-2 btn btn-sm btn-secondary",
                    to: Route::Register {},
                    "Créer un compte"
                }
            }
        }
    }
}
