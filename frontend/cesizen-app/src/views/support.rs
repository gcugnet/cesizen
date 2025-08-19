use dioxus::prelude::*;
use serde_json::json;

#[component]
pub fn Support() -> Element {
    let mut username = use_signal(|| "".to_string());
    let mut email = use_signal(|| "".to_string());
    let mut title = use_signal(|| "".to_string());
    let mut description = use_signal(|| "".to_string());

    let send = move |_| {
        let username_val = username.read().clone();
        let email_val = email.read().clone();
        let title_val = title.read().clone();
        let description_val = description.read().clone();

        spawn(async move {
            let body = json!({
                "username": username_val,
                "email": email_val,
                "title": title_val,
                "description": description_val
            });

            let _result = reqwest::Client::new()
                .post("http://localhost:4000/api/v1/issues")
                .json(&body)
                .send()
                .await;
        });
    };

    rsx! {
        div { class: "mt-4 flex flex-col items-center",
            div { class: "m-8 card w-[90vw] md:w-[50vw] bg-base-100 card-md shadow-sm",
                div { class: "card-body items-center text-center",
                    div { class: "card-title", "À votre écoute" }
                    p {
                        "Quelque soit l’anomalie rencontrée sur l’application Cesizen, n’hésitez pas à nous contacter. Nous serons heureux d’étudier votre demande et de vous aider !"
                    }
                }
            }

            fieldset { class: "fieldset bg-base-200 border-base-300 rounded-box w-xl border p-4",
                legend { class: "fieldset-legend", "Formulaire de contact" }
                form {
                    class: "grid grid-cols-4 gap-4 justify-center",
                    onsubmit: move |event| {
                        event.prevent_default();
                        send(());
                    },

                    div { class: "col-span-4 md:col-span-2",
                        legend { class: "label", "Nom" }
                        div {
                            input {
                                class: "mt-1 mb-2 input w-full",
                                r#type: "text",
                                placeholder: "Maurice",
                                value: "{username}",
                                oninput: move |event| username.set(event.value()),
                            }
                        }
                    }

                    div { class: "col-span-4 md:col-span-2",
                        legend { class: "label", "Email" }
                        div {
                            input {
                                class: "mt-1 mb-2 input w-full",
                                r#type: "email",
                                placeholder: "maurice.ravel@proton.me",
                                value: "{email}",
                                oninput: move |event| email.set(event.value()),
                            }
                        }
                    }

                    div { class: "col-span-4",
                        legend { class: "label", "Titre" }
                        div {
                            input {
                                class: "mt-1 mb-2 input w-full",
                                r#type: "text",
                                placeholder: "Je n'arrive pas à me connecter",
                                value: "{title}",
                                oninput: move |event| title.set(event.value()),
                            }
                        }
                    }

                    div { class: "col-span-4",
                        legend { class: "label", "Description" }
                        div {
                            textarea {
                                class: "mt-1 mb-2 textarea h-24 w-full",
                                placeholder: "J'ai essayé de me connecter mais je ne me souviens plus de mon mot de passe.",
                                value: "{description}",
                                oninput: move |event| description.set(event.value()),
                            }
                        }
                    }

                    div { class: "col-span-4 flex justify-center",
                        button { class: "btn btn-primary", r#type: "submit", "Envoyer" }
                    }
                }
            }
        }
    }
}
