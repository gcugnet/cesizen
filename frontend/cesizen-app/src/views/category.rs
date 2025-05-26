use cesizen_api::api::uuid::Uuid;
use dioxus::prelude::*;

use crate::components::information::category::show::Show as ShowCategory;
use crate::components::information::content::list::List as ListContents;
use crate::Route;

#[component]
pub fn Category(id: Uuid) -> Element {
    rsx! {
        div { class: "breadcrumbs text-sm",
            ul {
                li {
                    Link { to: Route::Home { greetings: false }, "Accueil" }
                }
                li {
                    Link { to: Route::Category { id }, "Catégorie" }
                }
            }
        }

        ShowCategory { id }
        ListContents { id }
    }
}
