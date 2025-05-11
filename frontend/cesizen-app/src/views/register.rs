use crate::API;
use crate::{components::UserForm, Route};
use cesizen_api::api::{
    user::{User, UserParams},
    LoginInfo,
};
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
    let name = use_signal(|| "".to_string());
    let email = use_signal(|| "".to_string());
    let password = use_signal(|| "".to_string());
    let password_confirmation = use_signal(|| "".to_string());
    let mut state = use_signal(RegisterState::default);

    let register = move |_| {
        state.set(RegisterState::Loading);
        spawn(async move {
            match User::register(
                &API.read(),
                UserParams::new(
                    name.to_string(),
                    email.to_string(),
                    password.to_string(),
                    password_confirmation.to_string(),
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
                    div { class: "alert alert-info", "Création en cours ..." }
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
                    name: Some(name),
                    email: Some(email),
                    password: Some(password),
                    password_confirmation: Some(password_confirmation),
                    fieldset_label: "Formulaire de création de compte".to_string(),
                    button_message: "Créer un compte".to_string(),
                    onclick: register,
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
