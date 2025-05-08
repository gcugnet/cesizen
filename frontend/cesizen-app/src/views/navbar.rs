use crate::Route;
use dioxus::prelude::*;

/// The Navbar component that will be rendered on all pages of our app since every page is under the layout.
///
///
/// This layout component wraps the UI of [Route::Home] and [Route::Blog] in a common navbar. The contents of the Home and Blog
/// routes will be rendered under the outlet inside this component
#[component]
pub fn Navbar() -> Element {
    rsx! {
        div { id: "navbar", class: "navbar bg-base-100 shadow-sm",
            Link { class: "btn btn-ghost text-xl", to: Route::Home {}, "Home" }
            Link { class: "btn btn-ghost text-xl", to: Route::Blog { id: 1 }, "Blog" }
        }

        // The `Outlet` component is used to render the next component inside the layout. In this case, it will render either
        // the [`Home`] or [`Blog`] component depending on the current route.
        Outlet::<Route> {}
    }
}
