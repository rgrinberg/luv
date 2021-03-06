(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



(** Pipes.

    See {{:http://docs.libuv.org/en/v1.x/pipe.html} [uv_pipe_t] {i - Pipe
    handle}}. *)

type t = [ `Pipe ] Stream.t
(** Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_t} [uv_pipe_t]}.

    Note that values of this type can also be used with functions in:

    - {!Luv.Stream}
    - {!Luv.Handle}

    In particular, see {!Luv.Handle.close}, {!Luv.Stream.accept},
    {!Luv.Stream.read_start}, {!Luv.Stream.write}. *)

val init :
  ?loop:Loop.t -> ?for_handle_passing:bool -> unit -> (t, Error.t) result
(** Allocates and initializes a pipe.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_init}
    [uv_pipe_init]}.

    The pipe is not yet connected to anything at this point. See
    {!Luv.Pipe.bind}, {!Luv.Stream.listen}, and {!Luv.Pipe.connect}. *)

val open_ : t -> File.t -> (unit, Error.t) result
(** Wraps an existing file descriptor in a libuv pipe.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_open}
    [uv_pipe_open]}. *)

val bind : t -> string -> (unit, Error.t) result
(** Assigns a pipe a name or an address.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_bind}
    [uv_pipe_bind]}. *)

val connect : t -> string -> ((unit, Error.t) result -> unit) -> unit
(** Connects to the pipe at the given name or address.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_connect}
    [uv_pipe_connect]}. *)

val getsockname : t -> (string, Error.t) result
(** Retrieves the name or address assigned to the given pipe.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_getsockname}
    [uv_pipe_getsockname]}. *)

val getpeername : t -> (string, Error.t) result
(** Retrieves the name or address of the given pipe's peer.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_getpeername}
    [uv_pipe_getpeername]}. *)

val pending_instances : t -> int -> unit
(** Binds
    {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_pending_instances}
    [uv_pipe_pending_instances]}. *)

val receive_handle :
  t -> [
    | `TCP of (TCP.t -> (unit, Error.t) result)
    | `Pipe of (t -> (unit, Error.t) result)
    | `None
  ]
(** Receives a file descriptor over the given pipe.

    File descriptors are sent using the [?send_handle] argument of
    {!Luv.Stream.write}.

    On the receiving end, call {!Luv.Stream.read_start}. When that function
    calls its callback, there may be file descriptors in the pipe, in addition
    to the ordinary data provided to the callback.

    To check, call this function {!Luv.Pipe.recieve_handle} in a loop until it
    returns [`None]. If it returns [`TCP f] or [`Pipe f], create an appropriate
    handle [handle] using either {!Luv.TCP.init} or {!Luv.Pipe.init}, and call
    [f handle] to receive the fd and associate it with the handle. *)

(** Constants for {!Luv.Pipe.chmod}. *)
module Mode :
sig
  type t = [
    | `READABLE
    | `WRITABLE
  ]
end

val chmod : t -> Mode.t list -> (unit, Error.t) result
(** Sets pipe permissions.

    Binds {{:http://docs.libuv.org/en/v1.x/pipe.html#c.uv_pipe_chmod}
    [uv_pipe_chmod]}. *)
