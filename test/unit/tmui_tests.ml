let ( -: ) name f = Alcotest.test_case name `Quick f

let tests =
  ( "a simple test suite",
    [
      ( "simple yes" -: fun () ->
        let input = "no" in
        Alcotest.(check string) "the input is no" "no" input );
      ( "simple add" -: fun () ->
        let result = Tmui.example_fn 1 in
        Alcotest.(check int) "the result is 2" 2 result );
    ] )
