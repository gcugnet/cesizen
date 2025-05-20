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

alias Cesizen.Users
alias Cesizen.Emotions
alias Cesizen.Information

# ---------------------------------------------------------------------------- #
#                                    USERS                                     #
# ---------------------------------------------------------------------------- #

admin =
  Users.create!(
    %{
      name: "Guillaume",
      email: "guillaume@cugnet.eu",
      password: "AdminAdmin",
      role: :admin
    },
    actor: %{seeder: true}
  )

user =
  Users.create!(
    %{
      name: "Hervé",
      email: "herve@proton.me",
      password: "UserUser",
      role: :user
    },
    actor: %{seeder: true}
  )

# ---------------------------------------------------------------------------- #
#                                  EMOTIONS                                    #
# ---------------------------------------------------------------------------- #

joy = Emotions.create_basic!(%{name: "Joie"}, actor: admin)
anger = Emotions.create_basic!(%{name: "Colère"}, actor: admin)
fear = Emotions.create_basic!(%{name: "Peur"}, actor: admin)
sadness = Emotions.create_basic!(%{name: "Tristesse"}, actor: admin)
surprise = Emotions.create_basic!(%{name: "Surprise"}, actor: admin)
disgust = Emotions.create_basic!(%{name: "Dégoût"}, actor: admin)
pride = Emotions.create!(%{basic_emotion: joy.id, name: "Fierté"}, actor: admin)

contentment =
  Emotions.create!(%{basic_emotion: joy.id, name: "Contentement"}, actor: admin)

Emotions.create!(%{basic_emotion: joy.id, name: "Enchantement"}, actor: admin)
Emotions.create!(%{basic_emotion: joy.id, name: "Excitation"}, actor: admin)
Emotions.create!(%{basic_emotion: joy.id, name: "Émerveillement"}, actor: admin)
Emotions.create!(%{basic_emotion: joy.id, name: "Gratitude"}, actor: admin)

frustration =
  Emotions.create!(%{basic_emotion: anger.id, name: "Frustration"},
    actor: admin
  )

Emotions.create!(%{basic_emotion: anger.id, name: "Irritation"}, actor: admin)
Emotions.create!(%{basic_emotion: anger.id, name: "Rage"}, actor: admin)
Emotions.create!(%{basic_emotion: anger.id, name: "Ressentiment"}, actor: admin)
Emotions.create!(%{basic_emotion: anger.id, name: "Agacement"}, actor: admin)
Emotions.create!(%{basic_emotion: anger.id, name: "Hostilité"}, actor: admin)

Emotions.create!(%{basic_emotion: fear.id, name: "Inquiétude"}, actor: admin)
Emotions.create!(%{basic_emotion: fear.id, name: "Anxiété"}, actor: admin)
Emotions.create!(%{basic_emotion: fear.id, name: "Terreur"}, actor: admin)
Emotions.create!(%{basic_emotion: fear.id, name: "Appréhension"}, actor: admin)
Emotions.create!(%{basic_emotion: fear.id, name: "Panique"}, actor: admin)
Emotions.create!(%{basic_emotion: fear.id, name: "Crainte"}, actor: admin)

Emotions.create!(%{basic_emotion: sadness.id, name: "Chagrin"}, actor: admin)
Emotions.create!(%{basic_emotion: sadness.id, name: "Mélancolie"}, actor: admin)
Emotions.create!(%{basic_emotion: sadness.id, name: "Abattement"}, actor: admin)
Emotions.create!(%{basic_emotion: sadness.id, name: "Désespoir"}, actor: admin)
Emotions.create!(%{basic_emotion: sadness.id, name: "Solitude"}, actor: admin)
Emotions.create!(%{basic_emotion: sadness.id, name: "Dépression"}, actor: admin)

Emotions.create!(%{basic_emotion: surprise.id, name: "Étonnement"},
  actor: admin
)

Emotions.create!(%{basic_emotion: surprise.id, name: "Stupéfaction"},
  actor: admin
)

Emotions.create!(%{basic_emotion: surprise.id, name: "Sidération"},
  actor: admin
)

Emotions.create!(%{basic_emotion: surprise.id, name: "Incrédule"}, actor: admin)
Emotions.create!(%{basic_emotion: surprise.id, name: "Confusion"}, actor: admin)

Emotions.create!(%{basic_emotion: disgust.id, name: "Répulsion"}, actor: admin)
Emotions.create!(%{basic_emotion: disgust.id, name: "Déplaisir"}, actor: admin)
Emotions.create!(%{basic_emotion: disgust.id, name: "Nausée"}, actor: admin)
Emotions.create!(%{basic_emotion: disgust.id, name: "Dédain"}, actor: admin)
Emotions.create!(%{basic_emotion: disgust.id, name: "Horreur"}, actor: admin)

Emotions.create!(%{basic_emotion: disgust.id, name: "Dégoût profond"},
  actor: admin
)

Users.add_emotion!(%{emotion: pride.id}, actor: user)
Users.add_emotion!(%{emotion: contentment.id}, actor: user)
Users.add_emotion!(%{emotion: frustration.id}, actor: user)

# ---------------------------------------------------------------------------- #
#                                INFORMATION                                   #
# ---------------------------------------------------------------------------- #

help =
  Information.create_category!(%{name: "Aide"},
    actor: admin
  )

article =
  Information.create_category!(%{name: "Articles sur la santé mentale"},
    actor: admin
  )

Information.create!(
  %{
    category: help.id,
    title: "Fonctionnement de l’application",
    body: """
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    Long texte qui explique comment l’application fonctionne. \
    """
  },
  actor: admin
)

Information.create!(
  %{
    category: article.id,
    title: "Articles sur la santé mentale",
    body: """
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    Long texte sur la santé mentale. Long texte sur la santé mentale. \
    """
  },
  actor: admin
)
