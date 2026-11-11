{ ... }:

{
  services.openssh = {
    enable = true;
    # No abrir el puerto 22 en interfaces de red públicas o no confiables por defecto.
    # El acceso remoto sigue permitido de forma segura a través de interfaces confiables (ej. Tailscale).
    openFirewall = false;
    settings = {
      PermitRootLogin = "no";
    };
  };
}
