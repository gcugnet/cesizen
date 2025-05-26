defmodule CesizenWeb.ContentLive.FormComponent do
  use CesizenWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>
          Use this form to manage content records in your database.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="content-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @form.source.type == :create do %>
          <.input field={@form[:category]} type="text" label="Category" /><.input
            field={@form[:title]}
            type="text"
            label="Title"
          /><.input field={@form[:body]} type="text" label="Body" /><.input
            field={@form[:type]}
            type="text"
            label="Type"
          />
        <% end %>
        <%= if @form.source.type == :update do %>
          <.input field={@form[:title]} type="text" label="Title" /><.input
            field={@form[:type]}
            type="select"
            label="Type"
            options={
              Ash.Resource.Info.attribute(Cesizen.Information.Content, :type).constraints[
                :one_of
              ]
            }
          />
          <.input field={@form[:body]} type="text" label="Body" /><.input
            field={@form[:category_id]}
            type="text"
            label="Category"
          />
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Content</.button>
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
  def handle_event("validate", %{"content" => content_params}, socket) do
    {:noreply,
     assign(socket,
       form: AshPhoenix.Form.validate(socket.assigns.form, content_params)
     )}
  end

  def handle_event("save", %{"content" => content_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: content_params) do
      {:ok, content} ->
        notify_parent({:saved, content})

        socket =
          socket
          |> put_flash(
            :info,
            "Content #{socket.assigns.form.source.type}d successfully"
          )
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{content: content}} = socket) do
    form =
      if content do
        AshPhoenix.Form.for_update(content, :update,
          as: "content",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Cesizen.Information.Content, :create,
          as: "content",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
