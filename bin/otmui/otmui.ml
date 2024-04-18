open Ppx_yojson_conv_lib.Yojson_conv.Primitives

type message_object = { message : string } [@@deriving yojson]

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

(*NOTE: static*)

let () =
  Dream.run @@ Dream.logger
  @@ Dream.router
       [
         Dream.get "/static/**" (Dream.static ".");
         Dream.get "hello" (fun _ -> Dream.html "Hello, world!");
         Dream.get "hello/:num" (fun request ->
             let num = Dream.param request "num" |> int_of_string in
             Dream.html
               (Printf.sprintf "<html><p>you sent the number %i </p></html>" num));
       ]

(*NOTE: json*)

(*let () =*)
(*Dream.run @@ Dream.logger @@ Dream.origin_referrer_check*)
(*@@ Dream.router*)
(*[*)
(*Dream.post "/" (fun request ->*)
(*let%lwt body = Dream.body request in*)
(*let message_object =*)
(*body |> Yojson.Safe.from_string |> message_object_of_yojson*)
(*in*)
(*`String message_object.message |> Yojson.Safe.to_string*)
(*|> Dream.json);*)
(*]*)

(*NOTE: forms*)
(*let () =*)
(*Dream.run @@ Dream.logger @@ Dream.memory_sessions*)
(*@@ Dream.router*)
(*[*)
(*Dream.get "/" (fun request -> Dream.html (Form.show_form request));*)
(*Dream.post "/" (fun request ->*)
(*match%lwt Dream.form request with*)
(*| `Ok [ ("message", message) ] ->*)
(*Dream.html (Form.show_form ~message request)*)
(*| _ -> Dream.empty `Bad_Request);*)
(*]*)

(*NOTE: cookies*)
(*let () =*)
(*Dream.run @@ Dream.set_secret "foo" @@ Dream.logger*)
(*@@ fun request ->*)
(*match Dream.cookie request "ui.language" with*)
(*| Some value ->*)
(*Printf.ksprintf Dream.html "Your preferred language is %s!"*)
(*(Dream.html_escape value)*)
(*| None ->*)
(*let response = Dream.response "Set language preference; come again!" in*)
(*Dream.add_header response "Content-Type" Dream.text_html;*)
(*Dream.set_cookie response request "ui.language" "ut-OP";*)
(*Lwt.return response*)

(*NOTE: Sessions*)
(*let () =*)
(*Dream.run @@ Dream.logger @@ Dream.memory_sessions*)
(*@@ fun request ->*)
(*match Dream.session_field request "user" with*)
(*| None ->*)
(*let%lwt () = Dream.invalidate_session request in*)
(*let%lwt () = Dream.set_session_field request "user" "alice" in*)
(*Dream.html "You weren't logged in; but now you are!"*)
(*| Some username ->*)
(*Printf.kprintf Dream.html "Welcome back %s" (Dream.html_escape username)*)

(*let () =*)
(*Dream.run*)
(*~error_handler:(Dream.error_template Error_template.my_error_template)*)
(*@@ Dream.logger @@ Dream.not_found*)

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
