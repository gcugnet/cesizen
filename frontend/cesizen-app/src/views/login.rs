use crate::components::UserForm;
use crate::API;
use cesizen_api::api::{user::User, LoginInfo};
use dioxus::prelude::*;

#[derive(Default)]
enum LoginState {
    #[default]
    Initial,
    Loading,
    Success(User),
    Error(String),
}

#[component]
pub fn Login() -> Element {
    let email = use_signal(|| "".to_string());
    let password = use_signal(|| "".to_string());
    let button_message = "Se connecter".to_string();
    let mut state = use_signal(LoginState::default);

    let login = move |_| {
        state.set(LoginState::Loading);
        spawn(async move {
            match API
                .write()
                .login(LoginInfo::Password {
                    email: email.to_string(),
                    password: password.to_string(),
                })
                .await
            {
                Ok(user) => state.set(LoginState::Success(user)),
                Err(e) => state.set(LoginState::Error(e.to_string())),
            }
        });
    };

    rsx! {
        div { class: "my-4",
            match &*state.read() {
                LoginState::Loading => rsx! {
                    div { class: "alert alert-info", "Connexion en cours ..." }
                },
                LoginState::Success(user) => rsx! {
                    div { class: "alert alert-success", "Bienvenue {user.name()} !" }
                },
                LoginState::Error(err) => rsx! {
                    div { class: "alert alert-error", "Erreur: {err}" }
                },
                LoginState::Initial => rsx! {},
            }
        }

        div { class: "m-8 flex flex-col text-xl items-center", "Page de connexion" }

        div { class: "flex flex-col items-center",
            UserForm {
                email,
                password,
                show_email_field: true,
                show_password_field: true,
                button_message,
                onclick: login,
            }
        }
    }
}
