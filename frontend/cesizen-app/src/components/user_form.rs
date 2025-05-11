use dioxus::prelude::*;

#[component]
pub fn UserForm(
    name: Option<Signal<String>>,
    email: Option<Signal<String>>,
    password: Option<Signal<String>>,
    password_confirmation: Option<Signal<String>>,
    button_message: String,
    onclick: EventHandler<MouseEvent>,
) -> Element {
    rsx! {
        if let Some(mut name) = name {
            fieldset { class: "fieldset",
                legend { class: "fieldset-legend", "Nom" }
                input {
                    id: "name",
                    r#type: "text",
                    class: "input",
                    placeholder: "Exemple",
                    value: "{name}",
                    oninput: move |event| name.set(event.value()),
                }
            }
        }

        if let Some(mut email) = email {
            fieldset { class: "fieldset",
                legend { class: "fieldset-legend", "Email" }
                input {
                    id: "email",
                    r#type: "text",
                    class: "input",
                    placeholder: "exemple@exemple.fr",
                    value: "{email}",
                    oninput: move |event| email.set(event.value()),
                }
            }
        }

        if let Some(mut password) = password {
            fieldset { class: "fieldset",
                legend { class: "fieldset-legend", "Mot de passe" }
                input {
                    id: "password", // Fixed ID
                    r#type: "password",
                    class: "input",
                    value: "{password}",
                    oninput: move |event| password.set(event.value()),
                }
            }
        }

        if let Some(mut password_confirmation) = password_confirmation {
            fieldset { class: "fieldset",
                legend { class: "fieldset-legend", "Confirmation du mot de passe" }
                input {
                    id: "password_confirmation", // Fixed ID
                    r#type: "password",
                    class: "input",
                    value: "{password_confirmation}",
                    oninput: move |event| password_confirmation.set(event.value()),
                }
            }
        }

        button {
            class: "mx-4 mt-4 btn btn-primary",
            onclick: move |event| onclick.call(event),
            "{button_message}"
        }
    }
}
