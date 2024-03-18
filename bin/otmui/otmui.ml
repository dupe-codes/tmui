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
  Dream.run @@ Dream.logger @@ count_requests
  @@ Dream.router
       [
         Dream.get "/fail" (fun _ -> raise (Failure "the web app failed!"));
         Dream.get "/" (fun _ ->
             Dream.html
               (Printf.sprintf "%3i requests successful<br>%3i requests failed"
                  !successful !failed));
         Dream.post "/echo" (fun request ->
             let%lwt body = Dream.body request in
             Dream.respond
               ~headers:[ ("Content type", "application/octet-stream") ]
               body);
       ]
