//! The components module contains all shared components for our app. Components are the building blocks of dioxus apps.
//! They can be used to defined common UI elements like buttons, forms, and modals. In this template, we define a Hero
//! component  to be used in our app.

mod hero;
pub use hero::Hero;

pub mod user_form;
pub use user_form::UserForm;

pub mod not_found;
pub use not_found::NotFound;
