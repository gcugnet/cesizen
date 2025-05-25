use crate::{Route, API};
use cesizen_api::api::{
    information_category::InformationCategory, information_content::InformationContent, uuid::Uuid,
};
use dioxus::prelude::*;

/// The Blog page component that will be rendered when the current route is `[Route::Blog]`
///
/// The component takes a `id` prop of type `i32` from the route enum. Whenever the id changes, the component function will be
/// re-run and the rendered HTML will be updated.
#[component]
pub fn Category(id: Uuid) -> Element {
    let nav = navigator();

    let get_category =
        use_resource(move || async move { InformationCategory::get(&API.read(), &id).await });

    let list_contents =
        use_resource(move || async move { InformationContent::list(&API.read(), Some(&id)).await });

    rsx! {
        div {

            // Content
            h1 { "This is blog #{id}!" }
            p {
                "In blog #{id}, we show how the Dioxus router works and how URL parameters can be passed as props to our route components."
            }

            // Navigation links
            // The `Link` component lets us link to other routes inside our app. It takes a `to` prop of type `Route` and
            // any number of child nodes.
            span { " <---> " }
        }
    }
}
