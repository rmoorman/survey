defmodule Survey.User do
  use Survey.Web, :model
  import Ecto.Query
  require Ecto.Query
  alias Survey.Repo
  alias Survey.User

  schema "users" do
    field :hash, :string
    field :nick, :string
    field :edx_email, :string
    field :edx_userid, :string
    field :tags, {:array, :string}
    field :grade, {:array, :string}
    field :role, {:array, :string}
    field :steam, {:array, :string}
    field :survey, Survey.JSON
    field :yearsteaching, :integer
    field :surveystate, :integer
    field :allow_email, :boolean
    field :admin, :boolean
    field :resources_seen, {:array, :integer}
    field :unsubscribe, {:array, :string}
    has_many :user_grades, Survey.UserGrade
    belongs_to :sig, Survey.SIG
    belongs_to :design_group, Survey.DesignGroup
    timestamps
  end

  def cohorts_csv do
    csv = (from t in User, 
    where: fragment("? is not null", t.sig_id),
    select: [t.edx_userid, t.edx_email, t.sig_id])
    |> Repo.all
    |> CSV.Encoder.encode
    |> Enum.to_list
    |> Enum.join("")
    
    "username,email,cohort\r\n" <> csv
  end

  def get_by_edxid(edx) do
    (from f in User,
    where: f.edx_userid == ^edx)
    |> Repo.one
  end

  def get(id) do
    Repo.get(User, id)
  end

  def get_email(id) do
    (from f in Survey.User, 
    where: f.id == ^id,
    select: [f.edx_email])
    |> Repo.one
  end

  def unsubscribe(user, component) do
    unsub = if !user.unsubscribe do
      [component]
    else
      [ component | user.unsubscribe ]
    end
    %{ user | unsubscribe: unsub } |> Repo.update!
  end

  def is_unsubscribed?(id, component) do
    user = get(id)
    user.unsubscribe && (Enum.member?(user.unsubscribe, "all") ||
      Enum.member?(user.unsubscribe, component))
  end
end
