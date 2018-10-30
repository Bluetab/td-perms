defmodule TdPerms.MixProject do
  use Mix.Project

  def project do
    [
      app: :td_perms,
      version: "0.3.11",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :redix],
      mod: {TdPerms.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redix, ">= 0.0.0"},
      {:credo, "~> 0.9.3", only: [:dev, :test], runtime: false},
      {:poison, "~> 2.2.0"}
    ]
  end
end
