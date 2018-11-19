let () = {
  print_endline("(0) Started.");


  /* A delay with Repromise. */

  Luv.Repromise.Timer.delay(1000)
  |> Repromise.wait((_) => print_endline("(1) Repromise delay elapsed!"));


  /* A delay with Lwt (concurrent with previous). */

  Luv.Lwt.Timer.delay(2000)
  |> Lwt.map((_) => print_endline("(2) Lwt delay elapsed!"))
  |> ignore;


  /* For good measure, a delay using the vanilla Luv callback API. */

  let timer =
    switch (Luv.Timer.init()) {
    | Result.Ok(timer) => timer
    | Result.Error(_) => exit(1)
    };
  Luv.Timer.start(timer, 3000, () => {
    Luv.Handle.close(timer);
    print_endline("(3) Luv delay elapsed!");
  })
  |> ignore;


  /* Wait for all the delays to complete.

     It doesn't matter whether Luv.Repromise.run or Luv.Lwt.run is called,
     because they are both aliases for the same underlying Luv I/O loop. Both
     Repromise and Lwt are integrated into that common Luv I/O loop as
     plugins. */

  Luv.Repromise.run();
};
