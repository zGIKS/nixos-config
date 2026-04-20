{ }:

{
  mkConfigLinks = entries:
    builtins.listToAttrs (map (entry: {
      name = entry.target;
      value = builtins.removeAttrs entry [ "target" ];
    }) entries);
}
