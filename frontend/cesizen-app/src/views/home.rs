use crate::components::information::category::list::List as InformationCategoriesList;
use crate::{Route, CURRENT_USER};
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

        InformationCategoriesList {}
        {}

        div { class: "m-4 flex flex-col text-xs font-medium items-center",
            "Besoin d’aide ?"
            Link {
                class: "mx-4 mt-2 btn btn-sm btn-secondary",
                to: Route::Support {},
                "Contacter le support"
            }
        }
    }
}
