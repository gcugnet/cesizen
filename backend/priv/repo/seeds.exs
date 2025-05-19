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

_admin =
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

joy = Emotions.create_basic!(%{name: "Joie"})
anger = Emotions.create_basic!(%{name: "Colère"})
fear = Emotions.create_basic!(%{name: "Peur"})
sadness = Emotions.create_basic!(%{name: "Tristesse"})
surprise = Emotions.create_basic!(%{name: "Surprise"})
disgust = Emotions.create_basic!(%{name: "Dégoût"})

pride = Emotions.create!(%{basic_emotion: joy.id, name: "Fierté"})
contentment = Emotions.create!(%{basic_emotion: joy.id, name: "Contentement"})
Emotions.create!(%{basic_emotion: joy.id, name: "Enchantement"})
Emotions.create!(%{basic_emotion: joy.id, name: "Excitation"})
Emotions.create!(%{basic_emotion: joy.id, name: "Émerveillement"})
Emotions.create!(%{basic_emotion: joy.id, name: "Gratitude"})

frustration = Emotions.create!(%{basic_emotion: anger.id, name: "Frustration"})
Emotions.create!(%{basic_emotion: anger.id, name: "Irritation"})
Emotions.create!(%{basic_emotion: anger.id, name: "Rage"})
Emotions.create!(%{basic_emotion: anger.id, name: "Ressentiment"})
Emotions.create!(%{basic_emotion: anger.id, name: "Agacement"})
Emotions.create!(%{basic_emotion: anger.id, name: "Hostilité"})

Emotions.create!(%{basic_emotion: fear.id, name: "Inquiétude"})
Emotions.create!(%{basic_emotion: fear.id, name: "Anxiété"})
Emotions.create!(%{basic_emotion: fear.id, name: "Terreur"})
Emotions.create!(%{basic_emotion: fear.id, name: "Appréhension"})
Emotions.create!(%{basic_emotion: fear.id, name: "Panique"})
Emotions.create!(%{basic_emotion: fear.id, name: "Crainte"})

Emotions.create!(%{basic_emotion: sadness.id, name: "Chagrin"})
Emotions.create!(%{basic_emotion: sadness.id, name: "Mélancolie"})
Emotions.create!(%{basic_emotion: sadness.id, name: "Abattement"})
Emotions.create!(%{basic_emotion: sadness.id, name: "Désespoir"})
Emotions.create!(%{basic_emotion: sadness.id, name: "Solitude"})
Emotions.create!(%{basic_emotion: sadness.id, name: "Dépression"})

Emotions.create!(%{basic_emotion: surprise.id, name: "Étonnement"})
Emotions.create!(%{basic_emotion: surprise.id, name: "Stupéfaction"})
Emotions.create!(%{basic_emotion: surprise.id, name: "Sidération"})
Emotions.create!(%{basic_emotion: surprise.id, name: "Incrédule"})
Emotions.create!(%{basic_emotion: surprise.id, name: "Émerveillement"})
Emotions.create!(%{basic_emotion: surprise.id, name: "Confusion"})

Emotions.create!(%{basic_emotion: disgust.id, name: "Répulsion"})
Emotions.create!(%{basic_emotion: disgust.id, name: "Déplaisir"})
Emotions.create!(%{basic_emotion: disgust.id, name: "Nausée"})
Emotions.create!(%{basic_emotion: disgust.id, name: "Dédain"})
Emotions.create!(%{basic_emotion: disgust.id, name: "Horreur"})
Emotions.create!(%{basic_emotion: disgust.id, name: "Dégoût profond"})

Users.add_emotion!(%{emotion: pride.id}, actor: user)
Users.add_emotion!(%{emotion: contentment.id}, actor: user)
Users.add_emotion!(%{emotion: frustration.id}, actor: user)
