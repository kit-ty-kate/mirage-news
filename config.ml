open Mirage

let main = foreign "Unikernel.Make" (pclock @-> resolver @-> conduit @-> job)

let stack = generic_stackv4 default_network

let () =
  let packages = [
    package "ptime";
    package "irmin-mirage";
    package ~sublibs:["mirage"] "tls";
    package "syndic";
  ] in
  register "repo" ~packages [
    main $ default_posix_clock $ resolver_dns stack $ conduit_direct ~tls:true stack
  ]
