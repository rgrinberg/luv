(* This file is part of Luv, released under the MIT license. See LICENSE.md for
   details, or visit https://github.com/aantron/luv/blob/master/LICENSE.md. *)



module Os_fd :
sig
  module Fd :
  sig
    type t = C.Types.Os_fd.t
    (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_fd_t}}. *)

    val from_unix : Unix.file_descr -> (t, Error.t) result
    (** Attempts to convert from a
        {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
        [Unix.file_descr]} to a libuv [uv_os_fd_t].

        Fails on Windows if the descriptor is a [SOCKET] rather than a
        [HANDLE]. *)

    val to_unix : t -> Unix.file_descr
    (** Converts a [uv_os_fd_t] to a
        {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
        [Unix.file_descr]}. *)
  end

  module Socket :
  sig
    type t = C.Types.Os_socket.t
    (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_sock_t}}. *)

    val from_unix : Unix.file_descr -> (t, Error.t) result
    (** Attempts to convert from a
        {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
        [Unix.file_descr]} to a libuv [uv_os_sock_t].

        Fails on Windows if the descriptor is a [HANDLE] rather than a
        [SOCKET]. *)

    val to_unix : t -> Unix.file_descr
    (** Converts a [uv_os_sock_t] to a
        {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Unix.html#TYPEfile_descr}
        [Unix.file_descr]}. *)
  end
end

module Sockaddr :
sig
  (** Network address families. See
      {{:http://man7.org/linux/man-pages/man2/socket.2.html#DESCRIPTION}
      [socket(2)]}. *)
  module Address_family :
  sig
    type t = [
      | `UNSPEC
      | `INET
      | `INET6
      | `OTHER of int
    ]

    (**/**)

    (* Internal functions; do not use. *)

    val to_c : t -> int
    val from_c : int -> t
  end

  (** Socket types. See
      {{:http://man7.org/linux/man-pages/man2/socket.2.html#DESCRIPTION}
      [socket(2)]}. *)
  module Socket_type :
  sig
    type t = [
      | `STREAM
      | `DGRAM
      | `RAW
    ]

    (**/**)

    (* Internal functions; do not use. *)

    val to_c : t -> int
    val from_c : int -> t
  end

  type t
  (** Binds {{:http://man7.org/linux/man-pages/man7/ip.7.html#DESCRIPTION}
      [struct sockaddr]}.

      The functions in this module automatically take care of converting between
      network and host byte order. *)

  val ipv4 : string -> int -> (t, Error.t) result
  (** Converts a string and port number to an IPv4 [struct sockaddr].

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip4_addr}
      [uv_ip4_addr]}. *)

  val ipv6 : string -> int -> (t, Error.t) result
  (** Converts a string and port number to an IPv6 [struct sockaddr].

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip6_addr}
      [uv_ip4_addr]}. *)

  val to_string : t -> string option
  (** Converts a network address to a string.

      Binds either {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip4_name}
      [uv_ip4_name]} and
      {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_ip6_name}
      [uv_ip6_name]}. *)

  val port : t -> int option
  (** Extracts the port in a network address. *)

  (**/**)

  (* Internal functions; do not use. *)

  val copy_storage : C.Types.Sockaddr.storage Ctypes.ptr -> t
  val copy_sockaddr : C.Types.Sockaddr.t Ctypes.ptr -> int -> t

  val as_sockaddr : t -> C.Types.Sockaddr.t Ctypes.ptr
  val null : C.Types.Sockaddr.t Ctypes.ptr

  val wrap_c_getter :
    ('handle -> C.Types.Sockaddr.t Ctypes.ptr -> int Ctypes.ptr -> int) ->
    ('handle -> (t, Error.t) result)
end

module Resource :
sig
  val uptime : unit -> (float, Error.t) result
  (** Evaluates to the current uptime.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_uptime}
      [uv_uptime]}. *)

  val loadavg : unit -> float * float * float
  (** Evaluates to the load average.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_loadavg}
      [uv_loadavg]}. *)

  val free_memory : unit -> Unsigned.uint64
  (** Evaluates to the amount of free memory, in bytes.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_free_memory}
      [uv_get_free_memory]}. *)

  val total_memory : unit -> Unsigned.uint64
  (** Evaluates to the total amount of memory, in bytes.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_total_memory}
      [uv_get_total_memory]}. *)

  val constrained_memory : unit -> Unsigned.uint64 option
  (** Binds
      {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_get_constrained_memory}}. *)

  val getpriority : int -> (int, Error.t) result
  (** Evaluates to the priority of the process with the given pid.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getpriority}
      [uv_os_getpriority]}. *)

  val setpriority : int -> int -> (unit, Error.t) result
  (** Sets the priority of the process with the given pid.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_setpriority}
      [uv_os_setpriority]}. *)

  val resident_set_memory : unit -> (Unsigned.size_t, Error.t) result
  (** Evaluates to the resident set size for the current process.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_resident_set_memory}
      [uv_resident_set_memory]}. *)

  type timeval = {
    sec : Signed.Long.t;
    usec : Signed.Long.t;
  }
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_timeval_t}
      [uv_timeval_t]}. *)

  type rusage = {
    utime : timeval;
    stime : timeval;
    maxrss : Unsigned.uint64;
    ixrss : Unsigned.uint64;
    idrss : Unsigned.uint64;
    isrss : Unsigned.uint64;
    minflt : Unsigned.uint64;
    majflt : Unsigned.uint64;
    nswap : Unsigned.uint64;
    inblock : Unsigned.uint64;
    oublock : Unsigned.uint64;
    msgsnd : Unsigned.uint64;
    msgrcv : Unsigned.uint64;
    nsignals : Unsigned.uint64;
    nvcsw : Unsigned.uint64;
    nivcsw : Unsigned.uint64;
  }
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_rusage_t}
      [uv_rusage_t]}.

      See {{:http://man7.org/linux/man-pages/man2/getrusage.2.html#DESCRIPTION}
      [getrusage(2)]}. *)

  val getrusage : unit -> (rusage, Error.t) result
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_getrusage}
      [uv_getrusage]}.

      See {{:http://man7.org/linux/man-pages/man2/getrusage.2.html}
      [getrusage(2)]}. *)
end

module Pid :
sig
  val getpid : unit -> int
  (** Evaluates to the pid of the current process.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getpid}
      [uv_os_getpid]}. *)

  val getppid : unit -> int
  (** Evaluates to the pid of the parent process.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getppid}
      [uv_os_getppid]}. *)
end

module System_info :
sig
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_cpu_info_t}
      [uv_cpu_info_t]}. *)
  module CPU_info :
  sig
    type times = {
      user : Unsigned.uint64;
      nice : Unsigned.uint64;
      sys : Unsigned.uint64;
      idle : Unsigned.uint64;
      irq : Unsigned.uint64;
    }

    type t = {
      model : string;
      speed : int;
      times : times;
    }
  end

  val cpu_info : unit -> (CPU_info.t list, Error.t) result
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_cpu_info}
      [uv_cpu_info]}. *)

  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_utsname_t}
      [uv_utsname_t]}. *)
  module Uname :
  sig
    type t = {
      sysname : string;
      release : string;
      version : string;
      machine : string;
    }
  end

  val uname : unit -> (Uname.t, Error.t) result
  (** Retrieves operating system name and version information.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_uname}
      [uv_os_uname]}. *)
end

module Network :
sig
  val if_indextoname : int -> (string, Error.t) result
  (** Retrieves a network interface name.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_if_indextoname}
      [uv_if_indextoname]}. See
      {{:http://man7.org/linux/man-pages/man3/if_indextoname.3p.html}
      [if_indextoname(3p)]}. *)

  val if_indextoiid : int -> (string, Error.t) result
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_if_indextoiid}
      [uv_if_indextoiid]}. *)

  val gethostname : unit -> (string, Error.t) result
  (** Evaluates to the system's hostname.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_gethostname}
      [uv_os_gethostname]}. See
      {{:http://man7.org/linux/man-pages/man3/gethostname.3p.html}
      [gethostname(3p)]}. *)
end

module Path :
sig
  val exepath : unit -> (string, Error.t) result
  (** Evaluates to the executable's path.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_exepath}
      [uv_exepath]}. *)

  val cwd : unit -> (string, Error.t) result
  (** Evaluates to the current working directory.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_cwd} [uv_cwd]}. *)

  val chdir : string -> (unit, Error.t) result
  (** Changes the current working directory.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_chdir}
      [uv_chdir]}. *)

  val homedir : unit -> (string, Error.t) result
  (** Evaluates to the path of the home directory.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_homedir}
      [uv_os_homedir]}. *)

  val tmpdir : unit -> (string, Error.t) result
  (** Evaluates to the path of the temporary directory.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_tmpdir}
      [uv_os_tmpdir]}. *)
end

module Passwd :
sig
  type t = {
    username : string;
    uid : int;
    gid : int;
    shell : string option;
    homedir : string;
  }
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_passwd_t}
      [uv_passwd_t]}. *)

  val get_passwd : unit -> (t, Error.t) result
  (** Gets passwd entry for the current user.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_get_passwd}
      [uv_os_get_passwd]}. See
      {{:http://man7.org/linux/man-pages/man3/getpwuid_r.3p.html}
      [getpwuid_r(3p)]}. *)
end

module Env :
sig
  val getenv : string -> (string, Error.t) result
  (** Retrieves the value of an environment variable.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_getenv}
      [uv_os_getenv]}. *)

  val setenv : string -> value:string -> (unit, Error.t) result
  (** Sets an environment variable.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_setenv}
      [uv_os_setenv]}. *)

  val unsetenv : string -> (unit, Error.t) result
  (** Unsets an environment variable.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_unsetenv}
      [uv_os_unsetenv]}. *)

  val environ : unit -> ((string * string) list, Error.t) result
  (** Retrieves all environment variables.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_os_environ}
      [uv_os_environ]}. *)
end

module Time :
sig
  type t = {
    tv_sec : int64;
    tv_usec : int32;
  }
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_timeval64_t}
      [uv_timeval64_t]}. *)

  val gettimeofday : unit -> (t, Error.t) result
  (** Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_gettimeofday}
      [uv_gettimeofday]}. See
      {{:http://man7.org/linux/man-pages/man3/gettimeofday.3p.html}
      [gettimeofday(3p)]}. *)

  val hrtime : unit -> Unsigned.uint64
  (** Samples the high-resolution timer.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_hrtime}
      [uv_hrtime]}. *)

  val sleep : int -> unit
  (** Suspends the calling thread for at least the given number of milliseconds.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_sleep}
      [uv_sleep]}. *)
end

module Random :
sig
  val random :
    ?loop:Loop.t -> Buffer.t -> ((unit, Error.t) result -> unit) -> unit
  (** Fills the given buffer with bits from the system entropy source.

      Binds {{:http://docs.libuv.org/en/v1.x/misc.html#c.uv_random}
      [uv_random]}. *)

  module Sync :
  sig
    val random : Buffer.t -> (unit, Error.t) result
    (** Synchronous version of {!Luv.Random.random}. *)
  end
end
