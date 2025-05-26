defmodule CesizenWeb.UserLive.FormComponent do
  use CesizenWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          Use this form to manage user records in your database.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @form.source.type == :create do %>
          <.input field={@form[:name]} type="text" label="Name" /><.input
            field={@form[:email]}
            type="text"
            label="Email"
          /><.input field={@form[:password]} type="text" label="Password" /><.input
            field={@form[:role]}
            type="text"
            label="Role"
          />
        <% end %>
        <%= if @form.source.type == :update do %>
          <.input field={@form[:email]} type="text" label="Email" /><.input
            field={@form[:name]}
            type="text"
            label="Name"
          /><.input
            field={@form[:role]}
            type="select"
            label="Role"
            options={
              Ash.Resource.Info.attribute(Cesizen.Users.User, :role).constraints[
                :one_of
              ]
            }
          />
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save User</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    {:noreply,
     assign(socket,
       form: AshPhoenix.Form.validate(socket.assigns.form, user_params)
     )}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        socket =
          socket
          |> put_flash(
            :info,
            "User #{socket.assigns.form.source.type}d successfully"
          )
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{user: user}} = socket) do
    form =
      if user do
        AshPhoenix.Form.for_update(user, :update,
          as: "user",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Cesizen.Users.User, :create,
          as: "user",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
