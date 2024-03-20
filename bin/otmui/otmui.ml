let successful = ref 0
let failed = ref 0

let count_requests inner_handler request =
  try%lwt
    let%lwt response = inner_handler request in
    successful := !successful + 1;
    Lwt.return response
  with exn ->
    failed := !failed + 1;
    raise exn

let () =
  Dream.run ~error_handler:Dream.debug_error_handler
  @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/:word" (fun req ->
             Dream.param req "word" |> Template.render |> Dream.html);
         (*Dream.get "/bad" (fun _ -> Dream.empty `Bad_Request);*)
         (*Dream.get "/fail" (fun _ -> raise (Failure "the web app failed!"));*)
       ]

(*let () =*)
(*Dream.run @@ Dream.logger @@ count_requests*)
(*@@ Dream.router*)
(*[*)
(*Dream.get "/fail" (fun _ -> raise (Failure "the web app failed!"));*)
(*Dream.get "/" (fun _ ->*)
(*Dream.html*)
(*(Printf.sprintf "%3i requests successful<br>%3i requests failed"*)
(*!successful !failed));*)
(*Dream.post "/echo" (fun request ->*)
(*let%lwt body = Dream.body request in*)
(*Dream.respond*)
(*~headers:[ ("Content type", "application/octet-stream") ]*)
(*body);*)
(*]*)

(*let my_log = Dream.sub_log "my_log"*)

(*let () =*)
(*Dream.initialize_log ~level:`Error ();*)
(*Dream.run @@ Dream.logger*)
(*@@ Dream.router*)
(*[*)
(*Dream.get "/" (fun request ->*)
(*Dream.log "Sending greeting to %s" (Dream.client request);*)
(*Dream.html "Good morning, world!");*)
(*Dream.get "/fail" (fun _ ->*)
(*my_log.warning (fun log -> log "raising exception");*)
(*raise (Failure "The web app failed!"));*)
(*]*)
