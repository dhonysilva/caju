defmodule CajuWeb.Router do
  use CajuWeb, :router

  import CajuWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CajuWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :fetch_current_user_uuid
    plug :fetch_current_cart
  end

  defp fetch_current_user_uuid(conn, _) do
    if user_uuid = get_session(conn, :current_uuid) do
      assign(conn, :current_uuid, user_uuid)
    else
      new_uuid = Ecto.UUID.generate()

      conn
      |> assign(:current_uuid, new_uuid)
      |> put_session(:current_uuid, new_uuid)
    end
  end

  alias Caju.ShoppingCart

  defp fetch_current_cart(conn, _opts) do
    if cart = ShoppingCart.get_cart_by_user_uuid(conn.assigns.current_uuid) do
      assign(conn, :cart, cart)
    else
      {:ok, new_cart} = ShoppingCart.create_cart(conn.assigns.current_uuid)
      assign(conn, :cart, new_cart)
    end
  end

  pipeline :app_layout do
    # plug :put_root_layout, html: {CajuWeb.LayoutView, :app}
    # plug :put_root_layout, html: {CajuWeb.Layouts, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CajuWeb do
    pipe_through :browser

    get "/", PageController, :home

    get "/hello", HelloController, :index
    get "/hello/:messenger", HelloController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", CajuWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:caju, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CajuWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", CajuWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{CajuWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", CajuWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{CajuWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      # Survey Live
      live "/survey", SurveyLive, :index

      live "/sites", SiteLive, :index, as: :site
    end

    # Site
    resources "/sites", SiteController

    # Resourses of Site and settings
    get "/sites/:website/memberships/invite", Site.MembershipController, :invite_member_form
    post "/sites/:website/memberships/invite", Site.MembershipController, :invite_member

    post "/sites/invitations/:invitation_id/accept", InvitationController, :accept_invitation

    post "/sites/invitations/:invitation_id/reject", InvitationController, :reject_invitation

    delete "/sites/:website/invitations/:invitation_id", InvitationController, :remove_invitation

    get "/:website/settings", SiteController, :settings
    get "/:website/settings/general", SiteController, :settings_general
    get "/:website/settings/people", SiteController, :settings_people

    live "/organizations", OrganizationLive.Index, :index
    live "/organizations/new", OrganizationLive.Index, :new
    live "/organizations/:id/edit", OrganizationLive.Index, :edit

    live "/organizations/:id", OrganizationLive.Show, :show
    live "/organizations/:id/show/edit", OrganizationLive.Show, :edit

    resources "/products", ProductController
    resources "/categories", CategoryController

    resources "/cart_items", CartItemController, only: [:create, :delete]

    get "/cart", CartController, :show
    put "/cart", CartController, :update

    resources "/orders", OrderController, only: [:create, :show]
  end

  scope "/", CajuWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{CajuWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
