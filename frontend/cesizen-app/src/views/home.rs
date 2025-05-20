use crate::{components::Hero, CURRENT_USER};
use dioxus::logger::tracing::info;
use dioxus::prelude::*;

/// The Home page component that will be rendered when the current route is `[Route::Home]`
#[component]
pub fn Home(greetings: bool) -> Element {
    rsx! {
        if greetings {
            {
                info!("Greetings is {:?}.", greetings);
            }
            if let Some(user) = &*CURRENT_USER.read() {
                div { class: "mx-4 alert alert-success", "Bienvenue {user.name()} !" }
            }
        }
        Hero {}
    }
}
