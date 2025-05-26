defmodule CesizenWeb.UserLive.Index do
  use CesizenWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Users
      <:actions>
        <.link patch={~p"/users/new"}>
          <.button>New User</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="users"
      rows={@streams.users}
      row_click={fn {_id, user} -> JS.navigate(~p"/users/#{user}") end}
    >
      <:col :let={{_id, user}} label="Id">{user.id}</:col>

      <:col :let={{_id, user}} label="Email">{user.email}</:col>

      <:col :let={{_id, user}} label="Name">{user.name}</:col>

      <:col :let={{_id, user}} label="Role">{user.role}</:col>

      <:action :let={{_id, user}}>
        <div class="sr-only">
          <.link navigate={~p"/users/#{user}"}>Show</.link>
        </div>

        <.link patch={~p"/users/#{user}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, user}}>
        <.link
          phx-click={JS.push("delete", value: %{id: user.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="user-modal"
      show
      on_cancel={JS.patch(~p"/users")}
    >
      <.live_component
        module={CesizenWeb.UserLive.FormComponent}
        id={(@user && @user.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        user={@user}
        patch={~p"/users"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :users,
       Ash.read!(Cesizen.Users.User, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(
      :user,
      Ash.get!(Cesizen.Users.User, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({CesizenWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Ash.get!(Cesizen.Users.User, id, actor: socket.assigns.current_user)
    Ash.destroy!(user, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :users, user)}
  end
end
