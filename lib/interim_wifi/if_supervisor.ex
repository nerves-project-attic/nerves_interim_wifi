defmodule Nerves.InterimWiFi.IFSupervisor do
  use Supervisor

  def start_link(options \\ []) do
    Supervisor.start_link(__MODULE__, [], options)
  end

  def init([]) do
      {:ok, {{:one_for_one, 10, 3600}, []}}
  end

  def setup(ifname, settings) do
    pidname = pname(ifname)
    if !Process.whereis(pidname) do
      child = worker(manager(ifname, settings),
                    [ifname, settings, [name: pidname]],
                    id: pidname)
      Supervisor.start_child(__MODULE__, child)
    else
      {:error, :already_added}
    end
  end

  def teardown(ifname) do
    pidname = pname(ifname)
    if Process.whereis(pidname) do
      Supervisor.terminate_child(__MODULE__, pidname)
      Supervisor.delete_child(__MODULE__, pidname)
    else
      {:error, :not_started}
    end
  end

  defp pname(ifname) do
    String.to_atom("Nerves.InterimWifi.Interface." <> ifname)
  end

  # Return the appropriate interface manager based on the interface's name
  # and settings
  defp manager(_name, _settings) do
    # Route everything through the wifi manager for now...
    Nerves.InterimWiFi.WiFiManager
  end
end
