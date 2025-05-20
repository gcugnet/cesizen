defmodule Cesizen.Information.Content do
  use Ash.Resource,
    otp_app: :cesizen,
    domain: Cesizen.Information,
    extensions: [AshJsonApi.Resource],
    data_layer: AshPostgres.DataLayer

  require Ash.Query

  json_api do
    type "content"
  end

  postgres do
    table "contents"
    repo Cesizen.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:text, :image]
      default :text
      public? true
    end

    attribute :body, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :category, Cesizen.Information.Category do
      public? true
    end
  end

  actions do
    defaults [
      :read,
      :destroy,
      update: :*
    ]

    create :create do
      primary? true
      description "Creates a new Information.Content."

      argument :category, :uuid do
        allow_nil? false
      end

      argument :title, :string do
        allow_nil? false
      end

      argument :body, :string do
        allow_nil? false
      end

      argument :type, :atom do
        allow_nil? true
      end

      change manage_relationship(:category, type: :append)
      change set_attribute(:title, arg(:title))
      change set_attribute(:body, arg(:body))

      change fn changeset, _context ->
        case Ash.Changeset.fetch_argument(changeset, :type) do
          {:ok, type} ->
            changeset
            |> Ash.Changeset.change_attribute(:type, type)

          _ ->
            changeset
        end
      end
    end

    read :list do
      argument :category, :uuid do
      end

      prepare fn query, _context ->
        case Ash.Query.fetch_argument(query, :category) do
          {:ok, category} ->
            query
            |> Ash.Query.filter(category_id == ^category)

          _ ->
            query
        end
      end
    end
  end
end
