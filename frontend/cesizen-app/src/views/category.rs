use cesizen_api::api::uuid::Uuid;
use dioxus::prelude::*;

use crate::components::information::category::show::Show;

/// The Blog page component that will be rendered when the current route is `[Route::Blog]`
///
/// The component takes a `id` prop of type `i32` from the route enum. Whenever the id changes, the component function will be
/// re-run and the rendered HTML will be updated.
#[component]
pub fn Category(id: Uuid) -> Element {
    rsx! {

        Show { id }
    }
}
