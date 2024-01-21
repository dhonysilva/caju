defmodule Caju.OpenTelemetry do
  @moduledoc false

  require OpenTelemetry.Tracer, as: Tracer

  def add_site_attributes(site) do
    case site do
      %Caju.Membership.Site{} = site ->
        Tracer.set_attributes([
          {"caju.site.id", site.id},
          {"caju.site.domain", site.name}
        ])

      id when is_integer(id) ->
        Tracer.set_attributes([{"caju.site.id", id}])

      _any ->
        :ignore
    end
  end

  def add_user_attributes(user) do
    case user do
      %Caju.Accounts.User{} = user ->
        Tracer.set_attributes([
          {"caju.user.id", user.id},
          {"caju.user.email", user.email}
        ])

      id when is_integer(id) ->
        Tracer.set_attributes([{"caju.user.id", id}])

      _any ->
        :ignore
    end
  end

  # https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/semantic_conventions/README.md#service
  def resource_attributes(runtime_metadata) do
    [
      {"service.name", "analytics"},
      {"service.namespace", "plausible"},
      {"service.instance.id", runtime_metadata[:host]},
      {"service.version", runtime_metadata[:version]}
    ]
  end
end
