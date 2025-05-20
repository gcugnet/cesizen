use dioxus::prelude::*;

#[component]
pub fn NotFound(route: Vec<String>) -> Element {
    rsx! {
        div { class: "h-[60vh] grow flex items-center justify-center",
            div { class: "card w-96 bg-base-100 card-xl shadow-sm",

                div { class: "card-body items-center text-center",
                    div { class: "card-title", "404" }
                    p { "Page non trouvée." }
                }
            }
        }
    }
}
