# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Cesizen.Repo.insert!(%Cesizen.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Cesizen.Accounts

Accounts.create_user!(%{
  name: "Guillaume",
  email: "guillaume@cugnet.eu",
  password: "AdminAdmin",
  role: :admin
})

Accounts.create_user!(%{
  name: "Hervé",
  email: "herve@proton.me",
  password: "UserUser",
  role: :user
})
