//! The views module contains the components for all Layouts and Routes for our app. Each layout and route in our [`Route`]
//! enum will render one of these components.
//!
//!
//! The [`Home`] and [`Blog`] components will be rendered when the current route is [`Route::Home`] or [`Route::Blog`] respectively.
//!
//!
//! The [`Navbar`] component will be rendered on all pages of our app since every page is under the layout. The layout defines
//! a common wrapper around all child routes.

mod home;
pub use home::Home;

mod navbar;
pub use navbar::Navbar;

mod login;
pub use login::Login;

mod register;
pub use register::Register;

mod my_account;
pub use my_account::MyAccount;

pub mod category;
pub use category::Category;

pub mod content;
pub use content::Content;

pub mod emotions;
pub use emotions::Emotions;

pub mod support;
pub use support::Support;
