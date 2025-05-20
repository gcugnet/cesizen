use dioxus::prelude::*;

use crate::{Route, CURRENT_USER};

#[component]
pub fn MyAccount() -> Element {
    let nav = navigator();

    rsx! {
        if let Some(user) = &*CURRENT_USER.read() {
            div { class: "h-[60vh] grow flex items-center justify-center",
                div { class: "card w-96 bg-base-100 card-xl shadow-sm",

                    div { class: "card-body items-center text-center",
                        div { class: "card-title", "Bonjour {user.name()} !!" }
                        p { "Page à implémenter." }
                    }
                }
            }
        } else {
            {
                nav.push(Route::Login {});
            }
        }
    }
}
