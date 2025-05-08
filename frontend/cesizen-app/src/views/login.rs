use crate::API;
use cesizen_api::api::{user::User, LoginInfo};
use dioxus::{logger::tracing::info, prelude::*};

#[component]
pub fn Login() -> Element {
    let mut email = use_signal(|| "".to_string());
    let mut password = use_signal(|| "".to_string());

    // let mut user: Signal<Option<User>> = use_signal(|| None::<User>);
    let mut response = use_signal(|| None::<User>);

    let login = move |_| {
        spawn(async move {
            match API
                .write()
                .login(LoginInfo::Password {
                    email: email.to_string(),
                    password: password.to_string(),
                })
                .await
            {
                Ok(user) => {
                    info!("Success!");
                    response.set(Some(user));
                }
                Err(e) => {
                    info!("{}", e);
                }
            }
        });
    };

    rsx! {
        div { class: "m-8 flex flex-col text-xl items-center", "Page de connexion" }

        {response.read().as_ref().map(|user| rsx! {
            div { class: "mx-4 mt-4 alert alert-success", "Bienvenue {user.name()} !" }
        })}

        div { class: "flex flex-col items-center",
            fieldset { class: "fieldset",
                legend { class: "fieldset-legend", "Email" }
                input {
                    id: "email",
                    r#type: "text",
                    class: "input",
                    placeholder: "test@test.com",
                    value: "{email}",
                    oninput: move |event| email.set(event.value()),
                }
            }

            fieldset { class: "fieldset",
                legend { class: "fieldset-legend", "Mot de passe" }
                input {
                    id: "email",
                    r#type: "password",
                    class: "input",
                    value: "{password}",
                    oninput: move |event| password.set(event.value()),
                }
            }

            button { class: "mx-4 mt-4 btn btn-primary", onclick: login, "Se connecter" }
        }
    }
}
