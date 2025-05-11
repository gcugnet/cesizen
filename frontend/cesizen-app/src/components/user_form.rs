use dioxus::prelude::*;

#[component]
pub fn UserForm(
    email: Signal<String>,
    password: Signal<String>,
    show_email_field: bool,
    show_password_field: bool,
    button_message: String,
    onclick: EventHandler<MouseEvent>,
) -> Element {
    rsx! {
        if show_email_field {
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
        }

        if show_password_field {
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

        button {
            class: "mx-4 mt-4 btn btn-primary",
            onclick: move |event| onclick.call(event),
            "{button_message}"
        }
    }
}
