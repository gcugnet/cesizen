use std::collections::HashMap;

use dioxus::{logger::tracing::info, prelude::*};

use strum::Display;
use strum::EnumIter;
use strum::IntoEnumIterator;

#[derive(Default, Clone, PartialEq)]
pub struct Config {
    pub login_form: bool,
    pub fields: Vec<Fields>,
}

#[derive(Copy, Clone, PartialEq, Eq, Hash, EnumIter, Display)]
#[strum(serialize_all = "snake_case")]
pub enum Fields {
    Name,
    Email,
    CurrentPassword,
    Password,
    PasswordConfirmation,
}

#[derive(Default, Debug, PartialEq, Eq)]
enum Validation {
    #[default]
    Unknown,
    Valid,
    Invalid(String),
}

impl From<Result<(), String>> for Validation {
    fn from(value: Result<(), String>) -> Self {
        match value {
            Ok(()) => Validation::Valid,
            Err(message) => Validation::Invalid(message),
        }
    }
}

struct FormValidation(HashMap<Fields, Validation>);

impl Default for FormValidation {
    fn default() -> Self {
        Self(
            Fields::iter()
                .map(|field| (field, Validation::default()))
                .collect(),
        )
    }
}

impl FormValidation {
    fn is_valid(&self, config: &Config) -> bool {
        self.0
            .iter()
            .filter(|(field, _validation)| config.fields.contains(field))
            .all(|(_field, validation)| *validation == Validation::Valid)
    }

    fn get_validation(&self, field: &Fields) -> &Validation {
        self.0.get(field).unwrap_or(&Validation::Unknown)
    }

    fn validate(&mut self, field: Fields, value: &str, password: Option<&str>) {
        // Retrieve the password for validate_password_confirmation function.
        // NOTE: This could be refactor if component was split in 2 or 3.
        let password = password.unwrap_or("");

        let validation_result = match field {
            Fields::Name => validate_name_input(value),
            Fields::Email => validate_email_input(value),
            Fields::CurrentPassword => validate_current_password_input(value),
            Fields::Password => validate_password_input(value),
            Fields::PasswordConfirmation => validate_password_confirmation_input(password, value),
        };

        self.0.insert(field, validation_result.into());
    }

    fn validate_all(&mut self, config: &Config, form_values: &FormData) {
        info!("{:?}", form_values.values());
        let password = form_values
            .values()
            .get("password")
            .unwrap_or(&FormValue::default())
            .as_value();

        for field in config.fields.iter() {
            self.validate(
                *field,
                &form_values
                    .values()
                    .get(&field.to_string())
                    .unwrap_or(&FormValue::default())
                    .as_value(),
                Some(&password),
            );
        }
    }
}

pub fn event_to_hashmap_string(event: &Event<FormData>) -> HashMap<String, String> {
    event
        .data
        .values()
        .iter()
        .map(|(key, value)| (key.clone(), value.as_value()))
        .collect()
}

#[component]
pub fn UserForm(
    values: Signal<HashMap<String, dioxus::events::FormValue>>,
    config: Config,
    fieldset_label: String,
    button_text: String,
    action: EventHandler<Event<FormData>>,
) -> Element {
    let mut form_validation = use_signal(FormValidation::default);
    let mut password = use_signal(String::new);

    fn input_class(is_valid: &Validation) -> String {
        match is_valid {
            Validation::Unknown => String::new(),
            Validation::Invalid(_) => "input-error".to_string(),
            Validation::Valid => "input-success".to_string(),
        }
    }

    fn password_label(login_form: bool) -> String {
        if login_form {
            "Mot de passe".to_string()
        } else {
            "Nouveau mot de passe".to_string()
        }
    }

    rsx! {
        fieldset { class: "fieldset bg-base-200 border-base-300 rounded-box w-xs border p-4",
            legend { class: "fieldset-legend", "{fieldset_label}" }

            form {
                class: "grid",
                onsubmit: move |event| {
                    if !config.login_form {
                        form_validation.write().validate_all(&config, &event.data);
                        let is_valid = form_validation.write().is_valid(&config);
                        if is_valid {
                            action(event);
                        }
                    } else {
                        action(event);
                    }
                },
                if config.fields.contains(&Fields::Name) {
                    legend { class: "label", "Nom" }
                    input {
                        class: "mt-1 mb-2 input {input_class(&form_validation.read().get_validation(&Fields::Name))}",
                        r#type: "text",
                        id: "name",
                        name: "name",
                        placeholder: "Exemple",
                        oninput: move |event| {
                            form_validation.write().validate(Fields::Name, &event.data.value(), None);
                        },
                    }
                    if let Validation::Invalid(message) = form_validation
                        .read()
                        .get_validation(&Fields::Name)
                    {
                        p { class: "mb-2 text-xs text-red-500", "{message}" }
                    }
                }

                if config.fields.contains(&Fields::Email) {
                    legend { class: "label", "Email" }
                    input {
                        class: "mt-1 mb-2 input {input_class(&form_validation.read().get_validation(&Fields::Email))}",
                        r#type: "text",
                        id: "email",
                        name: "email",
                        required: config.login_form,
                        placeholder: "exemple@exemple.com",
                        oninput: move |event| {
                            if !config.login_form {
                                form_validation.write().validate(Fields::Email, &event.data.value(), None);
                            }
                        },
                    }
                    if let Validation::Invalid(message) = form_validation
                        .read()
                        .get_validation(&Fields::Email)
                    {
                        p { class: "mb-2 text-xs text-red-500", "{message}" }
                    }
                }
                if config.fields.contains(&Fields::CurrentPassword) {
                    label { class: "label mt-1", "Mot de passe actuel" }
                    input {
                        class: "mt-1 mb-2 input {input_class(&form_validation.read().get_validation(&Fields::CurrentPassword))}",
                        r#type: "password",
                        id: "current_password",
                        name: "current_password",
                        oninput: move |event| {
                            form_validation
                                .write()
                                .validate(Fields::CurrentPassword, &event.data.value(), None);
                        },
                    }
                    if let Validation::Invalid(message) = form_validation
                        .read()
                        .get_validation(&Fields::CurrentPassword)
                    {
                        p { class: "mb-2 text-xs text-red-500", "{message}" }
                    }
                }

                if config.fields.contains(&Fields::Password) {
                    label { class: "label mt-1", "{password_label(config.login_form)}" }
                    input {
                        class: "mt-1 mb-2 input {input_class(&form_validation.read().get_validation(&Fields::Password))}",
                        r#type: "password",
                        id: "password",
                        name: "password",
                        required: config.login_form,
                        oninput: move |event| {
                            if !config.login_form {
                                password.set(event.data.value());
                                form_validation
                                    .write()
                                    .validate(Fields::Password, &event.data.value(), None);
                            }
                        },
                    }
                    if let Validation::Invalid(message) = form_validation
                        .read()
                        .get_validation(&Fields::Password)
                    {
                        p { class: "mb-2 text-xs text-red-500", "{message}" }
                    }
                }

                if config.fields.contains(&Fields::PasswordConfirmation) {
                    label { class: "label mt-1", "Confirmation du mot de passe" }
                    input {
                        class: "mt-1 mb-2 input {input_class(&form_validation.read().get_validation(&Fields::PasswordConfirmation))}",
                        r#type: "password",
                        id: "password_confirmation",
                        name: "password_confirmation",
                        oninput: move |event| {
                            form_validation
                                .write()
                                .validate(
                                    Fields::PasswordConfirmation,
                                    &event.data.value(),
                                    Some(&password.read()),
                                );
                            info!("{:?}", event);
                        },
                    }
                    if let Validation::Invalid(message) = form_validation
                        .read()
                        .get_validation(&Fields::PasswordConfirmation)
                    {
                        p { class: "mb-2 text-xs text-red-500", "{message}" }
                    }
                }

                button { class: " mx-4 mt-4 btn btn-primary", r#type: "submit", "{button_text}" }
            }
        }
    }
}

fn validate_name_input(name: &str) -> Result<(), String> {
    let error_message =
        "Doit contenir entre 3 et 30 caractères, uniquement des lettres, nombres et tirets."
            .to_string();

    if name.is_empty() || name.len() < 3 || name.len() > 30 {
        return Err(error_message);
    }

    let name_regex = regex::Regex::new(r"^[A-Za-z][A-Za-z0-9\-]*").unwrap();

    if !name_regex.is_match(name) {
        return Err(error_message);
    }

    Ok(())
}

fn validate_email_input(email: &str) -> Result<(), String> {
    let error_message = "L’email doit être au format email.".to_string();

    if email.is_empty() {
        return Err(error_message);
    }

    let email_regex =
        regex::Regex::new(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").unwrap();

    if !email_regex.is_match(email) {
        return Err(error_message);
    }

    Ok(())
}

fn validate_current_password_input(current_password: &str) -> Result<(), String> {
    let error_message = "Ne peut pas être vide.".to_string();

    if current_password.is_empty() {
        return Err(error_message);
    }

    Ok(())
}

fn validate_password_input(password: &str) -> Result<(), String> {
    let error_message = "Doit contenir entre 8 et 80 caractères.".to_string();

    if password.is_empty() || password.len() < 8 || password.len() > 80 {
        return Err(error_message);
    }

    Ok(())
}

fn validate_password_confirmation_input(
    password: &str,
    password_confirmation: &str,
) -> Result<(), String> {
    let error_message = "Doit être identique au mot de passe.".to_string();

    info!(password);
    if password != password_confirmation {
        return Err(error_message);
    }

    Ok(())
}
