use std::collections::HashMap;

use crate::components::user_form::{event_to_hashmap_string, Config, Fields};
use crate::API;
use crate::{components::UserForm, Route};
use cesizen_api::api::user::{User, UserParams};
use dioxus::prelude::*;

#[derive(Default)]
enum RegisterState {
    #[default]
    Initial,
    Loading,
    Success(),
    Error(String),
}

#[component]
pub fn Register() -> Element {
    let mut state = use_signal(RegisterState::default);

    let user_form_config = Config {
        login_form: false,
        fields: vec![
            Fields::Name,
            Fields::Email,
            Fields::Password,
            Fields::PasswordConfirmation,
        ],
    };

    let values: Signal<HashMap<String, dioxus::events::FormValue>> = use_signal(HashMap::new);

    let register = move |event: Event<FormData>| async move {
        state.set(RegisterState::Loading);

        let formatted_data = event_to_hashmap_string(&event);

        spawn(async move {
            match User::register(
                &API.read(),
                UserParams::new(
                    formatted_data
                        .get("name")
                        .unwrap_or(&Default::default())
                        .as_str(),
                    formatted_data
                        .get("email")
                        .unwrap_or(&Default::default())
                        .as_str(),
                    formatted_data
                        .get("password")
                        .unwrap_or(&Default::default())
                        .as_str(),
                    formatted_data
                        .get("password_confirmation")
                        .unwrap_or(&Default::default())
                        .as_str(),
                ),
            )
            .await
            {
                Ok(_user) => state.set(RegisterState::Success()),
                Err(e) => state.set(RegisterState::Error(e.to_string())),
            }
        });
    };

    rsx! {
        div { class: "my-4",
            match &*state.read() {
                RegisterState::Loading => rsx! {
                    div { class: "alert alert-info", "Création en course ..." }
                },
                RegisterState::Success() => rsx! {
                    div { class: "alert alert-success", "Compte utilisateur créé avec succès !" }
                },
                RegisterState::Error(err) => rsx! {
                    div { class: "alert alert-error", "Erreur: {err}" }
                },
                RegisterState::Initial => rsx! {},
            }
        }

        div { class: "h-full flex flex-col items-center justify-center",
            div { class: "flex flex-col items-center",
                UserForm {
                    values,
                    config: user_form_config,
                    fieldset_label: "Formulaire de création de compte".to_string(),
                    button_text: "Créer un compte".to_string(),
                    action: register,
                }
            }

            div { class: "m-8 flex flex-col text-xs font-medium items-center",
                "Vous avez déjà un compte ?"
                Link {
                    class: "mx-4 mt-2 btn btn-sm btn-secondary",
                    to: Route::Login {},
                    "Se connecter"
                }
            }
        }
    }
}
