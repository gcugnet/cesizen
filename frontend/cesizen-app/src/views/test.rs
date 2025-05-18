use dioxus::prelude::*;

#[component]
pub fn Test() -> Element {
    rsx! {
        button { class: "mx-4 mt-4 btn btn-primary", "DaisyUI Button" }
        div { class: "mx-4 mt-4 alert alert-success", "DaisyUI Alert" }
    }
}
