open Lwt.Infix

let remote_uri () = "git://127.0.0.1/"

module Make
    (Pclock : Mirage_types_lwt.PCLOCK)
    (Res : Resolver_lwt.S)
    (Con : Conduit_mirage.S) =
struct
  let start _clock resolver conduit =
    let module G = Git.Mem.Make (Git_mirage.SHA1) (Git.Inflate) (Git.Deflate) in
    let module FS = Irmin.Contents.String in
    let module Store = Irmin_mirage.Git.KV (G) (FS) in
    let module Sync = Irmin.Sync (Store) in
    let store_config = Irmin_mem.config () in
    let repo () = Store.Repo.v store_config in
    let upstream = Irmin.remote_uri (remote_uri ()) in
    repo () >>= Store.master >>= fun t ->
    Logs.info (fun f -> f "pulling repo");
    Sync.pull_exn t upstream `Set >>= fun () ->
    Logs.info (fun f -> f "repo pulled");
    Store.Head.get t >>= fun head ->
    let info = Store.Commit.info head in
    let msg = Irmin.Info.message info in
    Logs.info (fun f -> f "%s" msg);
    Lwt.return ()
end
